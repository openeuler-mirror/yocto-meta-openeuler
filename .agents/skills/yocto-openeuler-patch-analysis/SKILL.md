---
name: yocto-openeuler-patch-analysis
description: '分析并融合 openEuler Embedded recipe 的多来源补丁时使用，与 yocto-openeuler-recipe 配合（后者管 recipe 新增/升级，本 skill 专管补丁）。覆盖 src-openeuler spec 补丁、yocto 基础 recipe 补丁、Embedded 层 files/ 适配补丁三来源的枚举与分类、冲突/重复/漏打/死补丁检测、CVE 与功能正确性补丁的取舍规则、SRC_URI 运算符与补丁应用顺序（=+ prepend / += append / :remove）、FILESEXTRAPATHS 解析优先级（层 files/ 覆盖 src-openeuler 同名补丁）、spec↔SRC_URI 交叉比对查漏打/多余（xcheck）、用 SRC_URI:remove 剔除与 openEuler 冲突的 yocto 基础补丁、大规模 :remove 的四类根因归因（已上游合入/发行版策略/陈旧空操作/配置片段）与陈旧空操作检测（stale）、版本错配（基础 recipe 版本 vs PV）与 Revert→重打补丁对的顺序敏感性、用 devtool 刷新消除 patch-fuzz、按 openEuler spec 做架构对齐（%ifnarch sw_64、%patchNNNN -R）、qemu-aarch64 验证 do_patch 无告警、无 do_patch 日志时的免构建 dry-run 验证（纯净源码 + 存活补丁集干跑）、offset（良性）与 fuzz（风险）严重度区分。触发关键词：补丁分析、patch analysis、补丁融合、patch fusion、src-openeuler 补丁、yocto 补丁、patch-fuzz、fuzz 告警、死补丁、dead patch、补丁分类、patch classification、do_patch、SRC_URI 顺序、FILESEXTRAPATHS、devtool 刷新补丁、CVE 补丁、架构对齐、disable-initialize_clock、交叉比对、xcheck、漏打、多余补丁、SRC_URI:remove、剔除基础补丁、版本错配、Revert 重打、计数对账、class-native 条件补丁、python3 补丁、stale remove、陈旧空操作、免构建 dry-run、offset vs fuzz、PATCHTOOL、版本升级过时补丁、busybox 补丁、四类根因。'
argument-hint: "要分析/整改补丁的包名或 recipe 目录，例如 'python3'、'systemd' 或 'meta-openeuler/recipes-core/systemd'"
---

# Skill: yocto-openeuler-patch-analysis — 多来源补丁分析与融合

## 定位与配合关系

- **`yocto-openeuler-recipe`**：负责 recipe/bbappend 的**新增与版本升级**（定位源码、设 `PV`、`SRC_URI` 适配 `file://`、校验和）。
- **本 skill**：负责其中的**补丁子系统**——把三个来源的补丁**枚举、分类、去重、取舍、排序、消歧、验证**，并把每个"打/不打"的决策写进注释。

需要新增/升级整个包时先走 `yocto-openeuler-recipe`；进入"这个包到底该打哪些补丁、顺序对不对、有没有 fuzz/死补丁"时切到本 skill。

> 路径约定：`<ws-root>` = oebuild 工作区根（含 `src/`、`build/`）；`<layer>` = `src/yocto-meta-openeuler/meta-openeuler`；容器内 `src/` 挂载为 `/usr1/openeuler/src`，`build/<machine>` 挂载为 `/home/openeuler/build/<machine>`。

---

## 两种用法：分析 vs 整改

先判断任务属于哪类，**避免在纯分析任务里误改 recipe**：

- **分析（只读）**：回答"这个包打了哪些补丁、顺序对不对、有没有 fuzz/死补丁/漏打"，产出报告，
  **不改任何 recipe**，可直接复用 build 目录里既有的 `log.do_patch`，无需重建。触发如
  `分析一下 python3 配方的补丁`。
- **整改（读+改+验证）**：在分析基础上实际增删补丁、刷新消 fuzz、加分类注释，再
  `bitbake -c patch -f` 重建验证。触发如 `整改/完善 systemd 补丁`。

两类共用下面的流程与脚本，区别只在"是否落盘修改 + 是否重建验证"。

---

## 三来源补丁模型

openEuler Embedded 的一个包，补丁最多来自三处，**必须全部枚举后再决策**，避免"只改一处导致漏打/重复/冲突"：

| 组 | 来源 | 位置 | 典型内容 |
|---|---|---|---|
| **A** | src-openeuler `.spec` 的 backport 段 | `src/openeuler/<pkg>/`（spec 里 `Patch6xxx`） | openEuler 回合的上游修复 |
| **B** | src-openeuler `.spec` 的定制段 | `src/openeuler/<pkg>/`（spec 里 `Patch9xxx`） | openEuler 发行版定制（含 CVE、cgroup、日志等） |
| **C** | 本层适配补丁 | `<layer>/recipes-*/<pkg>/files/` | Embedded 专属适配（如 base_dir、depmod service） |
| （基础） | yocto 上游 recipe 自带补丁 | `systemd.inc` / `<pkg>_<ver>.bb` 的 `SRC_URI` | 上游 OE 构建适配（`0002/0008/27254…`） |

A/B 通常由 `openeuler.bbclass` + `OPENEULER_DL_DIR` 自动从 src-openeuler 目录解析，无需拷进本层；C 与"需覆盖 A/B 同名补丁"的刷新版才放进本层 `files/`。

---

## 分步流程

复制此清单跟踪进度：

```
补丁分析进度：
- [ ] 1. 枚举三来源 + 基础 recipe 全部补丁，交叉比对（xcheck 查漏打/多余；stale 查陈旧 :remove）
- [ ] 2. 读 spec 分类（Patch6xxx/Patch9xxx/其他 Patch*；%ifnarch 反向撤销；惰性架构补丁）
- [ ] 3. 逐条取舍（CVE/功能正确性必打；:remove 冲突基础补丁；跳过必须写原因）
- [ ] 4. 定顺序（运算符语义 + Revert→重打对）并写分类注释          ← 整改才落盘
- [ ] 5. 消 patch-fuzz（devtool 刷新）+ 删死补丁                    ← 整改才落盘
- [ ] 6. qemu-aarch64 验证 do_patch 无告警（分析可复用既有日志）
```

### 第 1 步 — 枚举全部补丁 + 交叉比对

```bash
PKG=systemd
R=<layer>/recipes-core/$PKG          # 本层 recipe 目录（或单个 .bbappend 文件）
SPEC=<ws-root>/src/openeuler/$PKG/$PKG.spec

# 本层 recipe 引用的补丁 + 基础 recipe 的 SRC_URI
grep -rnE 'file://[^ ;"]+\.patch' "$R"

# spec 声明的补丁（other/6xxx/9xxx 分组）与架构条件
scripts/patch-audit.sh spec "$SPEC"

# spec 声明 vs SRC_URI 引用交叉比对：漏打 / 多余 / 已 :remove
scripts/patch-audit.sh xcheck "$SPEC" "$R"
```

`spec` 模式输出四段：`other Patch*`（如 `Patch1`/`Patch251`，多是 openEuler 的构建/路径适配
补丁，别漏）、`Patch6xxx`（backport）、`Patch9xxx`（定制），以及 `%prep` 里的
`%ifnarch/%ifarch/%patchNNNN -R` 架构条件——这是"架构对齐"的权威依据。

`xcheck` 先汇总一行 `spec=N referenced=M removed=K applied=J`，再列 MISSING / EXTRA / REMOVED
三组。**解读陷阱（务必记住，否则误判）：**

- **MISSING ≠ 漏打 bug**：可能是**有意跳过**（如 systemd `disable-initialize_clock` 在非 sw_64
  被 openEuler 反向撤销）。每条 MISSING 都要回第 3 步给"打/不打 + 原因"，不要无脑补上。
- **EXTRA 常是 yocto 侧补丁**：基础 recipe（poky/OE）的 `0002/0008/27254…`、本层 C 组适配补丁
  都不在 openEuler spec 里，落进 EXTRA 属**正常**。
- **扫描范围影响结果**：第二参数传**单个 `.bbappend`** 只比对该文件；传**整个 recipe 目录**会把
  目录内基础 recipe 副本（若有）的补丁一并计入 EXTRA。python3 传 `.bbappend` 得
  `referenced=22 removed=1 applied=21`（干净）；systemd 传整目录则 EXTRA 变多。**据此解读 EXTRA。**

**计数对账陷阱**（手工核对补丁数极易错）：

- `SRC_URI:remove` 剔除的补丁仍会被朴素 `grep file://.*\.patch` 计为"已引用"，使 applied 虚高。
  `xcheck` 已用 `applied = referenced − removed` 修正；手工核对也要减去。
- 基础 recipe 里 `class-native`（`SRC_URI:append:class-native`）或 `PACKAGECONFIG`/`OVERRIDES`
  条件下的补丁**不进 target 的 `do_patch`**，故"声明总数"通常 **>** target `log.do_patch` 里
  `Applying patch` 条数。对账以 **target do_patch 实际条数**为准，别拿声明总数硬凑。

### 第 2 步 — 分类与架构对齐

openEuler spec 用编号段区分补丁性质，直接映射到本 skill 的 A/B 组。

**关键：架构条件反向撤销。** 若 spec 里出现

```spec
%ifnarch sw_64
%patch9029 -R -p1        # 在非 sw_64 架构上"反向撤销"该补丁
%endif
```

表示该补丁**只在 sw_64 生效**，在 aarch64/arm/riscv64 上净效果是"不打"。
openEuler Embedded **不支持 sw_64**，因此这类补丁应**从 SRC_URI 移除**以与 openEuler 实际行为对齐，并注释说明。反之，若补丁对所有架构无条件应用（哪怕内部由 `__sw_64__` 守卫、在 aarch64 上惰性无害），则**保留**以对齐。

> **若 spec 完全没有 `%ifnarch`**（如 python3 的 21 个补丁全部无条件应用），说明 openEuler 对
> 所有架构一视同仁，Embedded **全部保留**即对齐。其中只改特定架构代码的补丁（如 loongarch64
> 专属 hunk）在 aarch64 上由架构宏隔离、**惰性无害**，同样保留——判据是"与 openEuler 在目标
> 架构上的净效果一致"，而非"当前架构是否用得到"。

### 第 3 步 — 取舍决策规则

对每条补丁给出"打 / 不打"，依据（源自社区打补丁经验）：

**必须打：**
- CVE / 信息安全修复
- 功能正确性修复（含"适配 yocto 构建"的补丁，如 base_dir、sysv-install、binfmt 依赖）

**可跳过（但必须写原因）：**
- 与目标架构无关且 openEuler 本身在该架构上反向撤销（见第 2 步）
- 已被上游新版本合入 / 被其他补丁取代
- 无法干净应用且不修复真实缺陷

**每一个"不打"都要在 bbappend/inc 注释里写明原因**（见"分类注释模板"）。

**`:remove` 剔除冲突的 yocto 基础补丁（一等融合操作）：** 当 openEuler 补丁与 poky/OE 基础
recipe 自带补丁**冲突或语义重复**时，用 `SRC_URI:remove = " file://<base>.patch "` 剔除基础补丁，
让 openEuler 版本生效——这是补丁融合的核心手段，不是边角料。例：python3 基础 recipe 带
`0001-Skip-failing-tests...`（poky 为跑通自身 ptest 跳过部分测试），与 openEuler 测试策略冲突，
bbappend 用 `:remove` 剔除；实测 `do_patch` 中该补丁不再出现。被 `:remove` 的补丁在 `xcheck` 里进
REMOVED 组、不计入 applied，注释要写明"为何剔除"。

**`:remove` 的四类根因（逐条归因，别笼统说"冲突"）：** busybox 实测发现，被 `:remove` 的基础补丁
分四类，根因不同、处置不同：

| 类 | 根因 | 判据 | 处置 |
|---|---|---|---|
| ① 已上游合入 | 版本错配：基础 recipe 为旧版打的补丁，新版 `PV` 已含 | 新版 spec 不再带该补丁 | 移除正确（保留会失败/重复） |
| ② 发行版策略 | poky 专属行为，Embedded 不想要（connmand、fail_on_no_media…） | 改的是 poky 约定而非真实缺陷 | 移除正确（有意分化） |
| ③ 陈旧空操作 | `:remove` 了基础 recipe 里**根本不存在**的补丁（照搬更新版 poky 残留） | 基础 recipe SRC_URI 里搜不到 | **cruft，应清理**（无害但误导） |
| ④ 配置片段 | 被移除的是 `.cfg`/defconfig 片段而非 `.patch`，已被本层 defconfig 取代 | 后缀非 `.patch` | 移除正确 |

> **③ 陈旧空操作可脚本检出**：`scripts/patch-audit.sh stale <bbappend> <base-recipe>` 逐条比对
> `:remove` 项是否存在于基础 recipe SRC_URI，列出 STALE。busybox 实测 `removed=13 effective=10
> stale_noop=3`（`0001-awk-fix-CVEs`、`0002-man-fix-segfault`、`0001-gen_build_files-…` 均不在
> poky 1.35.0）。**`xcheck` 的盲区**：它只统计 `.patch`，`.cfg` 类 `:remove`（如 busybox
> `longopts.cfg`）不计入 removed；要完整 `:remove` 清单（含 `.cfg`）用 `stale` 模式。

**版本错配风险：** 基础 recipe 版本与 bbappend 改写的 `PV` 可能不同（python3：poky 是
`python3_3.11.5.bb`，bbappend 设 `PV=3.11.6` 并用 openEuler 的 `Python-3.11.6.tar.xz`）。为 3.11.5
写的基础补丁被应用到 3.11.6 源码上，可能 fuzz 甚至语义漂移。分析时要**核对基础补丁是否仍适配当前
PV**；出现 fuzz 按第 6 步刷新，或评估是否已被 openEuler 补丁覆盖。

**Revert→重打的顺序敏感对：** openEuler 有时先 `Revert "<上游提交>"` 再重打自己的版本（如 python3
的 CVE-2023-27043 相关补丁对）。这类补丁**必须保持 Revert 在前、重打在后**的相对顺序，否则重打会被
随后的 Revert 抵消。枚举时识别成对项，定序时锁定先后。

### 第 4 步 — 顺序与运算符语义

BitBake 中 `SRC_URI` 的补丁**按最终字符串从左到右依次应用**。运算符语义（易错）：

| 写法 | 语义 | 效果 |
|---|---|---|
| `SRC_URI =+ "..."` | **prepend**（前置） | 放在已有值**最前**，最先应用 |
| `SRC_URI += "..."` | append（后置） | 放在已有值**最后**，最后应用 |
| `SRC_URI:prepend = "..."` | override 前置 | 解析末尾前置（含 override 场景） |
| `SRC_URI:append = "..."` | override 后置 | 解析末尾后置 |
| `SRC_URI:remove = "..."` | 删除 | 从结果中移除指定条目 |

`.bbappend` 在基础 `.bb` 之后解析，故：基础 recipe 的 `SRC_URI =`（如 git 源 + `0026`）先成形，本层 `.bbappend` 里的 `=+` 把 A/B 组**前置**、`+=` 把 C 组**后置**。最终典型顺序：

```
[A/B 组：src-openeuler 补丁]  →  [基础 recipe：git/0026/0002/0008/27254…]  →  [C 组：本层 files/ 适配]
```

**保序技巧（需要分组插注释时）：** BitBake 字符串内不能写 `#` 注释。用中间变量按序 `+=` 累积、组间插注释，末尾一次性 `SRC_URI =+`：

```bitbake
OE_PATCHES = " file://<pkg>-${PV}.tar.gz "
# --- Group A: backported upstream fixes (spec Patch6xxx) ---
OE_PATCHES += " file://backport-xxx.patch ... "
# --- Group B: openEuler specific (spec Patch9xxx) ---
OE_PATCHES += " file://fix-yyy.patch ... "
SRC_URI =+ "${OE_PATCHES}"        # 一次性前置，保持整段在基础补丁之前
# --- Group C: Embedded adaptation (this layer) ---
SRC_URI += " file://update-rtc-...patch "
```

### 第 5 步 — FILESEXTRAPATHS 优先级与"覆盖/消歧"

`file://x.patch` 的解析顺序（`do_patch` 日志可实证）：

```
本层 files/  →  本层 <pkg>/  →  src/openeuler/  →  src/openeuler/<pkg>/
```

因此**把刷新版补丁放进本层 `files/`，即可 shadow（覆盖）src-openeuler 的同名补丁**——这是消除 fuzz、或替换 openEuler 版本以适配 Embedded 的标准手法（C 组同理）。用 `order` 模式（见"验证"节）可确认每条补丁**实际**从哪个路径解析。

### 第 6 步 — 消除 patch-fuzz（devtool 刷新）

`do_patch` 出现 `Hunk #N succeeded at X with fuzz F (offset Y lines)` 即 patch-fuzz 告警，应尽量消除。用 devtool 拿到"干净上下文"重新生成补丁：

> **offset ≠ fuzz，严重度不同（busybox 实测）：**
> - `... succeeded at X (offset Y lines)` = 上下文**精确匹配**、仅行号平移 → **良性**，补丁正确
>   应用；多由版本错配（补丁写在旧版、应用到新版）或补丁交错引起。
> - `... succeeded at X with fuzz F` = patch **丢弃了 F 行上下文**强行匹配 → **有风险**，可能误改，
>   应刷新消除。
>
> 是否显式告警取决于 `PATCHTOOL`：`quilt`（GNU patch，如本仓库 busybox）打印 offset/fuzz；`git`
> 静默处理 offset。bitbake 本身**不解析** patch 输出、不升级为 bb WARNING，这些只是 `log.do_patch`
> 里的 NOTE；但本 skill 的 `fuzz` 审计模式保守地把 offset 也标出，据此人工复核严重度。

```bash
# 容器内；-O/--no-overrides 规避 devtool 在容器中的 rebase 报错
devtool modify -O <pkg>
cd <ws-root>/build/<machine>/workspace/sources/<pkg>
# 找到目标补丁对应的 commit，用其父提交生成规范 diff
git --no-pager diff --no-color <commit>^ <commit> > /tmp/refreshed.patch
```

把 `git diff` 产物套回原补丁头部（保留 `From/Subject/Resolves` 与 `-- \n<git-ver>` 尾部），写入**本层 `files/`** 覆盖 src-openeuler 版。校验零 fuzz：

```bash
git checkout -q <commit>^
patch -p1 -F0 --dry-run < /tmp/refreshed.patch ; echo "F0=$?"   # 期望 0
git apply --check /tmp/refreshed.patch          ; echo "GIT=$?" # 期望 0
git checkout -q <commit>
```

> 手写补丁必须用 `git diff` 生成规范 hunk（含 `a/` `b/` 前缀与精确行号），不要手改行号。

### 第 7 步 — 死补丁检测与删除

本层 `files/` 下未被任何 `.bb/.bbappend/.inc` 引用的 `.patch` 即死补丁：

```bash
scripts/patch-audit.sh dead <layer>/recipes-*/<pkg>
```

确认无引用（全仓库 grep 补丁名）后用删除工具移除，避免误导后续维护者。

---

## 验证（qemu-aarch64，默认平台）

**分析任务可直接复用既有日志**（无需重建）：若 build 目录里已有目标包的 `log.do_patch`
（`find <ws-root>/build -path '*/<pkg>/*-r*/temp/log.do_patch'`），直接对它跑 `fuzz`/`order` 即可，
跳过下面的重建步骤。**整改任务**改了 recipe 后才必须清理 workspace 并强制重跑。

**没有 `log.do_patch` 时——免构建 dry-run（busybox 实测有效）：** 包若走 sstate 或未构建，可能没有
do_patch 日志。此时无需重建即可验证：`do_unpack` 后的 workdir 里已含**存活补丁集**（被 `:remove`
的不会被 fetch，可反证移除生效），源码目录 `S`（如 `busybox-1.36.1/`）是**纯净未打补丁**状态。用它
做一次等价干跑：

```bash
W=$(echo <ws-root>/build/<machine>/tmp/work/*/<pkg>/<pv>-r*)
ls "$W"/*.patch                    # 存活补丁集：被 :remove 的不在这里 → 实证移除生效
rm -rf /tmp/verify && cp -r "$W/<pkg>-<pv>" /tmp/verify && cd /tmp/verify
# 按真实 SRC_URI 顺序干跑（基础补丁去掉 :remove 项，再接 bbappend :append/=+ 的补丁）
for p in <surviving-patches-in-order>; do
  patch -p1 --no-backup-if-mismatch < "$W/$p" 2>&1 | grep -iE 'fuzz|offset|FAILED|rejected' \
    && echo "  ^^ $p" || echo "clean: $p"
done
```

> 容器内 `/tmp` 若受沙盒限制（`bwrap: ... uid map: Permission denied`），改用 workspace 内临时目录
> 或以提升权限运行。干跑顺序须与真实 SRC_URI 一致，否则会误报 offset。

**验证前务必清理 devtool workspace**：`devtool modify` 生成的 `workspace/appends/<pkg>_*.bbappend` 会 `inherit externalsrc` 接管配方、令 `do_patch` 变空操作；且该 externalsrc 与带 `SRCREV` 的配方同时存在时，`bitbake -p` 可能报
`SRCREV was used yet no valid SCM was found in SRC_URI`（属 workspace 副作用，非配方问题）。

```bash
# 容器内
devtool reset <pkg>            # 失败时用 -n 跳过 clean，或手动移除 workspace/appends、workspace/sources
bitbake -p                     # 确认 0 errors
bitbake <pkg> -c patch -f      # 强制重跑 do_patch

LOG=<ws-root>/build/<machine>/tmp/work/*/<pkg>/*-r*/temp/log.do_patch
scripts/patch-audit.sh fuzz  "$LOG"    # 期望 OK / exit 0
scripts/patch-audit.sh order "$LOG"    # 核对顺序 + 每条补丁的实际解析路径
```

**成功标准：**
- `do_patch: Succeeded`，`0 errors`（`-f` 的 `tainted` WARNING 属预期，可忽略）
- `fuzz` 模式 `exit 0`（无 `with fuzz` / `FAILED`）；仅 `offset N lines`（上下文精确匹配、行号平移）属良性，见第 6 步 offset/fuzz 之分，可保留或刷新
- `order` 输出：被移除的补丁不再出现；刷新/适配补丁解析自**本层 `files/`**；分组顺序与预期一致

---

## 分类注释模板

写进 `<pkg>-openeuler.inc` 或 `<pkg>_%.bbappend`（BitBake 注释只能在字符串外）：

```bitbake
# Patches come from three places:
#   A. upstream fixes backported by openEuler (spec Patch6xxx)
#   B. openEuler specific patches (spec Patch9xxx)
#   C. openEuler Embedded adaptation patches shipped by this layer
# Applied top to bottom; keep the listing order. A patch is dropped only when it
# neither fixes a real defect nor is required by the build; reason noted below.

# --- Group A / B ... ---

# PatchNNNN (<name>.patch) intentionally NOT applied: openEuler keeps it only for
# <arch> and reverts it elsewhere ("%ifnarch <arch> %patchNNNN -R -p1"); Embedded
# does not support <arch>, so dropping it matches openEuler behaviour.

# Refreshed locally against <pkg> <ver> to remove a patch-fuzz warning; the copy in
# files/ shadows the src-openeuler one (FILESEXTRAPATHS).

# --- Group C: Embedded adaptation ---
# openEuler ships <name>.patch but it assumes base_dir=/usr/bin; Embedded uses /bin,
# so the local copy in files/ shadows it and is the version that gets applied.
```

---

## 工具脚本

`scripts/patch-audit.sh`（执行，非阅读）：

```bash
scripts/patch-audit.sh dead   <recipe-dir>           # 死补丁（未被引用的本地 .patch）
scripts/patch-audit.sh fuzz   <do_patch-log>         # fuzz/offset/failed hunk 告警
scripts/patch-audit.sh order  <do_patch-log>         # 应用顺序 + 每条补丁实际解析路径
scripts/patch-audit.sh spec   <spec-file>            # other/6xxx/9xxx 分组 + %ifnarch 撤销
scripts/patch-audit.sh xcheck <spec> <dir|bbappend>  # spec↔SRC_URI 交叉比对（漏打/多余/:remove）
scripts/patch-audit.sh stale  <bbappend> <base-recipe>  # :remove 了基础 recipe 不存在的补丁（陈旧空操作）
```

退出码：`0` 干净、`1` 有发现（死补丁 / fuzz / 漏打 / 陈旧 remove）、`2` 用法错误。

---

## 提交前检查清单

- [ ] 三来源 + 基础 recipe 补丁已全部枚举，无漏打/重复
- [ ] `xcheck` 已跑；每条 MISSING 有"打/不打 + 原因"结论，EXTRA 已辨明来源（yocto 基础/C 组属正常）
- [ ] 每条补丁有明确"打/不打"结论；所有"不打"均在注释中写明原因
- [ ] CVE / 信息安全 / 功能正确性（yocto 构建适配）补丁均已打
- [ ] 与 openEuler 冲突/过时的基础补丁已用 `:remove` 剔除并注释；被剔除项未被误计入 applied
- [ ] `:remove` 项已用 `stale` 核对：无陈旧空操作（移除的补丁确实存在于基础 recipe），`.cfg` 片段一并检查
- [ ] 无 do_patch 日志时已用"免构建 dry-run"（纯净 `S` + 存活补丁集）验证补丁全部干净应用
- [ ] offset 与 fuzz 已区分：fuzz 必消除；offset 属版本错配残留，酌情刷新
- [ ] 基础 recipe 版本与 `PV` 错配时，已核对基础补丁仍适配当前版本（无 fuzz/语义漂移）
- [ ] Revert→重打补丁对的相对顺序已锁定（Revert 在前）
- [ ] 架构条件已对齐 openEuler spec（`%ifnarch` 反向撤销的补丁已按需移除；无 `%ifnarch` 则全保留）
- [ ] `SRC_URI` 运算符与顺序正确（`=+` 前置 / `+=` 后置），分组顺序符合预期
- [ ] 需覆盖 src-openeuler 同名补丁者已放入本层 `files/`（FILESEXTRAPATHS shadow）
- [ ] `do_patch` 无 `with fuzz` / `offset` 告警（`patch-audit.sh fuzz` exit 0）
- [ ] 本层无死补丁（`patch-audit.sh dead` exit 0）
- [ ] 验证前已清理 devtool workspace，`bitbake -p` 0 errors
- [ ] `bitbake <pkg> -c patch -f` 在 qemu-aarch64 通过，`order` 输出符合预期

---

## 附：systemd 案例（ worked example ）

`meta-openeuler/recipes-core/systemd/` 的一次完整整改：

1. **枚举/分类**：`patch-audit.sh spec systemd.spec` → Patch6001–6007（A 组 backport）、Patch9008–9057（B 组定制）；基础 recipe（`systemd.inc` + `systemd_253.7.bb`）带 `0026/0002/0008/0004/27254/27253`；C 组为本层 `update-rtc-...patch`。
2. **架构对齐**：spec `%prep` 有 `%ifnarch sw_64 / %patch9029 -R -p1`，即 `disable-initialize_clock.patch` 仅 sw_64 生效。Embedded 不支持 sw_64 → **移除**并注释；`Systemd-Add-sw64-architecture.patch`（Patch9036）对所有架构无条件应用、内部 `__sw_64__` 守卫在 aarch64 惰性无害 → **保留**。
3. **消 fuzz**：`logind-set-RemoveIPC-to-false-by-default.patch` 原报 `Hunk #1 ... with fuzz 1 (offset 10 lines)`。用 `devtool modify -O systemd` 取源码树，`git diff <c>^ <c>` 重生成，`patch -p1 -F0 --dry-run` 与 `git apply --check` 均 0，写入本层 `files/` 覆盖 src-openeuler 版。
4. **删死补丁**：`patch-audit.sh dead` 之外，全仓库 grep 确认 `fix-glibc-2.36-redefinition-error.patch` 无引用 → 删除。
5. **保序 + 注释**：`systemd-openeuler.inc` 用 `SYSTEMD_OE_PATCHES` 中间变量分组累积、末尾 `SRC_URI =+ "${SYSTEMD_OE_PATCHES}"`，C 组用 `SRC_URI +=`；每组及每个决策点加注释。
6. **验证**：清理 devtool workspace → `bitbake -p`（0 errors）→ `bitbake systemd -c patch -f`。结果 62 条补丁全应用、`fuzz` exit 0；`order` 显示 `disable-initialize_clock` 不再出现、`logind` 解析自本层 `files/`、顺序为 A(1–7)→B(8–55)→基础(56–61)→C(62)。

---

## 附：python3 案例（纯分析，未改文件）

`meta-openeuler/recipes-devtools/python/python3_%.bbappend` 的一次**只读分析**（示范"分析"用法，
与 systemd 的"整改"用法互补）：

1. **三来源定位**：本层 `python3_%.bbappend`（`PV=3.11.6`，**无 `files/` 子目录**）；基础
   `poky python3_3.11.5.bb`（声明 22 个 `.patch`）；src-openeuler `python3.spec`（21 个补丁）。
2. **枚举/分类**：`patch-audit.sh spec` → `Patch1`/`Patch251`（other，构建适配）+ `Patch6000–6015`
   （16 个 backport，多为 CVE）+ `Patch9000–9002`（3 个定制）；`%prep` **全部无条件应用、无
   `%ifnarch`** → 按第 2 步"无 %ifnarch"情形，**全部保留即对齐**（含 loongarch64 专属补丁，
   aarch64 惰性无害）。
3. **交叉比对**：`xcheck python3.spec python3_%.bbappend` → `spec=21 referenced=22 removed=1
   applied=21`，MISSING/EXTRA 均空 → 干净。`removed=1` 是 bbappend 用 `:remove` 剔除的 poky
   `0001-Skip-failing-tests...`（与 openEuler 测试策略冲突，见第 3 步）。
4. **无 Group C**：本层无 `files/`，21 个 openEuler 补丁全部经 `OPENEULER_DL_DIR` 从 src-openeuler
   解析；`openeuler.bbclass` 删除基础 recipe 的 `http://...Python-${PV}.tar.xz`，由 bbappend 前置的
   `file://Python-${PV}.tar.xz` 取代（**无重复 tarball**）。
5. **验证（复用既有日志）**：直接读 build 目录 aarch64 `3.11.6-r0` 的 `log.do_patch`，`fuzz` exit 0；
   `order` 显示 1–21 为 openEuler spec 补丁（严格按 spec 顺序）、22–39 为 poky 基础补丁，被 `:remove`
   的 `0001-Skip-failing-tests` 确实未出现。**纯分析无需重建。**
6. **附带发现**：`dead` 审计在同目录报 `python3-pytest` 的一个死补丁——属**另一配方**，不在 python3
   解释器范围内。说明 `dead`/`xcheck` 传目录时要留意目录内**混放的多个配方**，按需缩小到具体
   recipe 文件或子目录。

---

## 附：busybox 案例（版本错配主导 + 免构建验证）

`meta-openeuler/recipes-core/busybox/busybox_%.bbappend` 的**只读分析**，示范"版本升级导致大规模
`:remove`"这一最常见场景（与 systemd 整改、python3 分析互补）：

1. **三来源**：本层 bbappend（`PV=1.36.1`，`files/` 只有 defconfig/inittab/devmem.cfg，**无本地
   `.patch`**）；基础 `poky busybox_1.35.0.bb`（14 个补丁）；src-openeuler `busybox.spec`（**仅 3 个
   CVE backport** `Patch6000–6002`，无 `%ifnarch`）。`xcheck` → `spec=3 referenced=15 removed=12
   applied=3`，MISSING/EXTRA 均空 → 干净。
2. **版本错配是主因**：基础 1.35.0 → `PV` 抬到 1.36.1，大批 poky 补丁过时。`:remove` 13 项按四类
   根因归因：① 已上游合入（`CVE-2022-30065` + 两个 printable-sanitize + testsuite-uudecode，1.36.1
   已含）② poky 策略（`fail_on_no_media`/`recognize_connmand`/`depmod-debug`/`udhcpc-no_deconfig`/
   `devmem-128bit`）③ **陈旧空操作 3 个**（`awk-fix-CVEs`/`man-fix-segfault`/`gen_build_files`，不在
   poky 1.35.0）④ 配置片段（`longopts.cfg`）。
3. **纠正"冲突"误解**：openEuler 只带 3 个 CVE 补丁，与被移除的 12 个 poky 补丁**无文本重叠**——不是
   补丁互相冲突，而是版本升级 + 发行版策略分化。
4. **`stale` 检出陈旧 remove**：`patch-audit.sh stale busybox_%.bbappend busybox_1.35.0.bb` →
   `removed=13 effective=10 stale_noop=3`（即 ③ 类，建议清理）。
5. **免构建 dry-run 验证**（无 do_patch 日志）：`do_unpack` 后 workdir 只含 8 个存活补丁（5 poky +
   3 openEuler CVE；12 个被移除的确实不在）；对纯净 `busybox-1.36.1/` 按序干跑，**8 个全应用、零
   FAILED、零真 fuzz**，仅 3 个良性 offset（`makefile-libbb-race` +2、`sysctl-EIO` +2、openEuler
   `CVE-2023-42363` +14，上下文精确匹配）。`PATCHTOOL=quilt` → offset 进日志但非 bb WARNING。
6. **CVE 差集对齐**：poky 1.35.0 有 `CVE-2022-30065` 但无 28391/48174/42363；openEuler 1.36.1
   baseline 已含前者、backport 后三者。bbappend 精确追加这 3 个 → **无安全回退**。
7. **结论**：大量 `:remove` 是版本升级的**正确副产物**，非功能损失。唯二可动手项：清理 3 个陈旧
   空操作 remove（③）、可选刷新 3 个 offset（追求日志零告警时）。

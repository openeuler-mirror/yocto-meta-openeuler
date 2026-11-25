# yocto-openeuler-patch-analysis 案例

本文件收录完整案例（systemd 整改、python3 只读分析、busybox 版本错配），
按需阅读。案例中的补丁计数与结论记录于当时版本，仅作方法示范，数值需以
当前仓库为准。流程与检查清单见 [SKILL.md](SKILL.md)。

---

## systemd 案例（整改）

`meta-openeuler/recipes-core/systemd/` 的一次完整整改：

1. **枚举/分类**：`patch-audit.sh spec systemd.spec` → Patch6001–6007（A 组 backport）、Patch9008–9057（B 组定制）；基础 recipe（`systemd.inc` + `systemd_253.7.bb`）带 `0026/0002/0008/0004/27254/27253`；C 组为本层 `update-rtc-...patch`。
2. **架构对齐**：spec `%prep` 有 `%ifnarch sw_64 / %patch9029 -R -p1`，即 `disable-initialize_clock.patch` 仅 sw_64 生效。Embedded 不支持 sw_64 → **移除**并注释；`Systemd-Add-sw64-architecture.patch`（Patch9036）对所有架构无条件应用、内部 `__sw_64__` 守卫在 aarch64 惰性无害 → **保留**。
3. **消 fuzz**：`logind-set-RemoveIPC-to-false-by-default.patch` 原报 `Hunk #1 ... with fuzz 1 (offset 10 lines)`。用 `devtool modify -O systemd` 取源码树，`git diff <c>^ <c>` 重生成，`patch -p1 -F0 --dry-run` 与 `git apply --check` 均 0，写入本层 `files/` 覆盖 src-openeuler 版。
4. **删死补丁**：`patch-audit.sh dead` 之外，全仓库 grep 确认 `fix-glibc-2.36-redefinition-error.patch` 无引用 → 删除。
5. **保序 + 注释**：`systemd-openeuler.inc` 用 `SYSTEMD_OE_PATCHES` 中间变量分组累积、末尾 `SRC_URI =+ "${SYSTEMD_OE_PATCHES}"`，C 组用 `SRC_URI +=`；每组及每个决策点加注释。
6. **验证**：清理 devtool workspace → `bitbake -p`（0 errors）→ `bitbake systemd -c patch -f`。结果 62 条补丁全应用、`fuzz` exit 0；`order` 显示 `disable-initialize_clock` 不再出现、`logind` 解析自本层 `files/`、顺序为 A(1–7)→B(8–55)→基础(56–61)→C(62)。

---

## python3 案例（纯分析，未改文件）

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

## busybox 案例（版本错配主导 + 免构建验证）

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

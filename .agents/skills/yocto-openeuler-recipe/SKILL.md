---
name: yocto-openeuler-recipe
description: '为 OpenEuler Embedded 新增、更新或分析 BitBake recipe 文件（*.bb、*.bbappend）时使用。覆盖从 src-openeuler/openeuler atomgit 仓库定位正确源码、在 meta-openeuler 中创建/更新 .bbappend、将 SRC_URI 适配为 file:// 路径（openeuler.bbclass 要求）、合并 openEuler 与上游 Yocto 补丁、通过 oebuild bitbake 在 qemu-aarch64 上验证构建。触发关键词：recipe、bbappend、bbfile、SRC_URI、patch、包适配、openeuler 源码、atomgit、PV 版本升级、FILESEXTRAPATHS。'
argument-hint: "要新增或更新的包名，例如 libfoo 或 libfoo_1.2.3"
---

# Skill: OpenEuler Embedded — Recipe 新增与更新

## 工作区布局（相关路径）

> 下文命令中 `<workspace-root>` 表示 oebuild 工作区根目录（含 `src/`、`build/`、`.venv/`），路径因开发者环境而异。

```
yocto-meta-openeuler/
└── meta-openeuler/
    ├── classes/
    │   └── openeuler.bbclass       ← 从 SRC_URI 中去除 http/https/git
    ├── conf/distro/openeuler.conf  ← OPENEULER_SP_DIR、OPENEULER_LOCAL_NAME、FILESEXTRAPATHS
    └── recipes-<category>/
        └── <package>/
            ├── <package>_%.bbappend   ← 我们的适配文件
            └── files/                 ← 可选：不在 openeuler 仓库中的补丁

yocto-poky/meta/                    ← 上游 recipe 参考
yocto-meta-openembedded/meta-oe/    ← 上游 recipe 参考（社区）
```

**关键变量（来自 `openeuler.conf`）：**

| 变量 | 默认值 | 含义 |
|---|---|---|
| `OPENEULER_SP_DIR` | 由 `compile.yaml` 设置 | 所有按包划分的源码目录根 |
| `OPENEULER_LOCAL_NAME` | `${BPN}` | `OPENEULER_SP_DIR` 下的仓库/子目录名 |
| `OPENEULER_DL_DIR` | `${OPENEULER_SP_DIR}/${OPENEULER_LOCAL_NAME}` | 源码压缩包和补丁的获取位置 |
| `OPENEULER_SRC_URI_REMOVE` | `"https git http"` | 被 `openeuler.bbclass` 去除的 URI 协议 |

由于 `FILESEXTRAPATHS:prepend = "${OPENEULER_DL_DIR}:"`，`SRC_URI` 中所有
`file://` 条目优先从 OpenEuler 下载目录解析，其次从 recipe 的 `files/`
子目录解析。

---

## 源码优先级决策树

```
1. https://atomgit.com/src-openeuler/<package>   ← 首选：openEuler 发行版包
2. https://atomgit.com/openeuler/<package>        ← openEuler 项目（库类较少见）
3. Yocto 上游（yocto-poky、yocto-meta-openembedded、meta-ros、…）
```

**如何确认：**

- 在浏览器访问 `https://atomgit.com/src-openeuler/<package-name>`，或在 atomgit 中搜索
- 查看该仓库中的 `.spec` 文件——它列出了版本、源码包名和所有补丁

---

## 分步流程

### 第 1 步 — 查找上游 Yocto Recipe

定位 `.bbappend` 要覆盖的基础 `.bb` 文件：

```bash
# 在 yocto-poky 和 meta-openembedded 中搜索
find <workspace-root>/src/yocto-poky \
     <workspace-root>/src/yocto-meta-openembedded \
     -name "<package>*.bb" 2>/dev/null

# 或使用 bitbake 查找并检查 recipe
source <workspace-root>/.venv/bin/activate
cd <workspace-root>/build/qemu_arm64
oebuild bitbake -e <package> 2>/dev/null | grep -E "^(PV|FILE|SRC_URI|FILESEXTRAPATHS) "
```

记录上游信息：

- `PV`（版本）
- `SRC_URI` 条目及已应用的补丁
- Recipe 分类（`recipes-core`、`recipes-support` 等）

### 第 2 步 — 检查 OpenEuler 源码仓库

```
https://atomgit.com/src-openeuler/<package>
```

从 `.spec` 文件中提取：

- `Version:` → 成为新的 `PV`
- `Source0:` → 压缩包名模式（通常为 `%{name}-%{version}.tar.gz` 或 `.tar.xz`）
- `Patch*:` 条目 → 需要移植到 recipe 的补丁

**压缩包必须存在于** `${OPENEULER_DL_DIR}`（由 `do_openeuler_fetch` 自动获取）。
记录确切的文件名——它将用于 `SRC_URI:prepend`。

### 第 3 步 — 确定目标 bbappend 位置

与上游 recipe 的分类保持一致：

```
上游：yocto-poky/meta/recipes-support/libfoo/libfoo_1.0.bb
目标：meta-openeuler/recipes-support/libfoo/libfoo_%.bbappend
```

文件名中使用 `%`（通配符）以匹配任意上游版本。

如果目录不存在，创建它：

```bash
mkdir -p <workspace-root>/src/yocto-meta-openeuler/meta-openeuler/recipes-<category>/<package>/
```

### 第 4 步 — 编写 .bbappend

**最小骨架——作为起点：**

```bitbake
# 上游参考：<上游-bb-路径>

PV = "<openeuler-version>"

# 使用 OpenEuler 源码压缩包；openeuler.bbclass 会从 SRC_URI 中去除 http/https/git
SRC_URI:prepend = " \
    file://${BP}.tar.gz \
    "
```

**带补丁（最常见情况）：**

```bitbake
# 上游参考：yocto-poky/meta/recipes-support/libfoo/libfoo_1.2.bb

PV = "1.5.0"

SRC_URI:prepend = " \
    file://${BP}.tar.gz \
    file://fix-CVE-2024-12345.patch \
    file://backport-feature-xyz.patch \
    "

# 移除与新版本冲突/被替代的上游补丁
SRC_URI:remove = " \
    file://0001-upstream-patch-no-longer-needed.patch \
    "
```

**当 OpenEuler 仓库名与 `${BPN}` 不同时：**

```bitbake
# 例如：上游 BPN=glib-2.0，openEuler 仓库名=glib2
OPENEULER_LOCAL_NAME = "glib2"
```

**当源码压缩包使用非标准名称时：**

```bitbake
# 若解压后目录名不同，覆盖 S
S = "${WORKDIR}/${BPN}-${PV}"

SRC_URI:prepend = " \
    file://${BPN}-${PV}.tar.bz2 \
    "
```

**校验和** — 如上游 `.bb` 要求则添加：

```bitbake
SRC_URI[sha256sum] = "<openeuler 压缩包的 sha256>"
```

### 第 5 步 — 补丁策略

从**两个**来源收集补丁并合并：

#### 5a. 上游 Yocto recipe 的补丁

检查上游 `.bb` 中的 `SRC_URI`：

- 对新版本**仍然有效**的补丁 → 保留在 `SRC_URI:append`
- 新版本**已合入上游**的补丁 → 用 `SRC_URI:remove` 移除
- **无法干净应用**的补丁 → 丢弃或手动移植

#### 5b. OpenEuler .spec 文件中的补丁

读取 `Patch*:` 并应用规则：

- 如果补丁不在 OpenEuler 下载目录中，将其移植到 recipe 的 `files/` 子目录
- `src-openeuler` 的补丁通过 `FILESEXTRAPATHS` 和 `OPENEULER_DL_DIR` 自动可用
- 始终验证补丁在新 `PV` 下能否干净应用

#### 5c. 补丁应用顺序

`SRC_URI:prepend` 中的补丁先应用（在上游补丁之前）。
需要在上游补丁之后应用的补丁使用 `SRC_URI:append`。

如果补丁需要非默认的 `patchdir`：

```bitbake
file://some.patch;patchdir=subdir
```

### 第 6 步 — 在 qemu-aarch64 上构建验证

```bash
source <workspace-root>/.venv/bin/activate
cd <workspace-root>/build/qemu_arm64

# 完整构建（有 sstate 时复用）
oebuild bitbake <package>

# 强制干净重建
oebuild bitbake -c cleansstate <package>
oebuild bitbake <package>

# 快速仅编译检查
oebuild bitbake -c compile <package>

# 查看展开后的变量
oebuild bitbake -e <package> 2>/dev/null | grep -E "^(PV|SRC_URI|S|OPENEULER)"
```

**成功标准：**

- 输出中无 `ERROR:` 行
- `WARNING:` 行为零或极少（出现需调查）
- `Tasks Summary: ... all succeeded`

**常见错误及修复：**

| 错误 | 可能原因 | 修复方法 |
|---|---|---|
| 压缩包 `file not found in path` | `PV` 不匹配或压缩包未获取 | 检查 `OPENEULER_DL_DIR`，核对 `PV` |
| `Patch does not apply` | 补丁与新版本不兼容 | 移植或丢弃该补丁 |
| `do_fetch` ENOSPC | inotify 限制 | `sudo sysctl -w fs.inotify.max_user_watches=524288` |
| `OPENEULER_LOCAL_NAME` 错误 | 仓库名不匹配 | 设置 `OPENEULER_LOCAL_NAME = "correct-name"` |
| `LIC_FILES_CHKSUM` 不匹配 | 新版本中许可文件变更 | 从构建错误输出更新校验和 |

---

## 参考：按场景的 bbappend 模式

### 新包（无已有上游 bbappend，从零添加）

```bitbake
# 源码：atomgit.com 上的 src-openeuler/<package>
# 上游基础：<上游-bb-路径>

PV = "<openeuler-version>"
LICENSE = "<license>"
LIC_FILES_CHKSUM = "file://COPYING;md5=<md5>"

SRC_URI = " \
    file://${BP}.tar.gz \
    file://fix-something.patch \
    "
SRC_URI[sha256sum] = "<sha256>"

DEPENDS += "libdep"
```

> 对于完全没有上游基础的全新 recipe，创建 `<package>_<version>.bb` 而不是 `.bbappend`。

### 已有 bbappend 的版本升级

```bitbake
# 从上游 1.0 升级到 openEuler 1.5.0

PV = "1.5.0"

SRC_URI:prepend = "file://${BP}.tar.gz "

# 1.5.0 不再需要的补丁
SRC_URI:remove = "file://0001-old-fix.patch "

# 来自 openEuler 1.5.0 .spec 的新补丁
SRC_URI:append = " \
    file://fix-CVE-2024-99999.patch \
    "

SRC_URI[sha256sum] = "<new-sha256>"
LIC_FILES_CHKSUM = "file://COPYING;md5=<new-md5>"
```

### 非标准压缩包名的包（oee-archive）

部分包使用 `oee-archive` 机制将同一仓库的多个内容打包：

```bitbake
inherit oee-archive

OPENEULER_LOCAL_NAME = "bigpackage-repo"
# oee-archive 自动处理 SRC_URI；不要与 pypi-src-openeuler.inc 一起使用
```

### Python 包（继承 pypi.bbclass）

当以下三个条件都满足时使用 `pypi-src-openeuler.inc`：

1. 上游 `.bb` 有 `inherit pypi`
2. OpenEuler 仓库名为 `python-<PYPI_PACKAGE>`
3. 压缩包名为 `<PYPI_PACKAGE>-<PV>.tar.gz`

```bitbake
PV = "x.y.z"
require pypi-src-openeuler.inc
SRC_URI[sha256sum] = "<sha256>"
```

---

## 提交前检查清单

- [ ] `.bbappend` 文件名为 `<package>_%.bbappend`（版本通配符）
- [ ] `PV` 与 OpenEuler `.spec` 或压缩包中的版本一致
- [ ] `SRC_URI:prepend` 以源码压缩包开头，格式为 `file://${BP}.tar.{gz,xz,bz2}`
- [ ] atomgit 仓库名与 `${BPN}` 不同时已设置 `OPENEULER_LOCAL_NAME`
- [ ] 所有上游补丁已保留、移除或干净移植
- [ ] 所有 OpenEuler `.spec` 补丁已应用或明确记录为跳过（附原因）
- [ ] 版本变更时已更新 `LIC_FILES_CHKSUM` 和 `SRC_URI[sha256sum]`
- [ ] `oebuild bitbake <package>` 在 qemu-aarch64 上无错误通过
- [ ] 构建输出没有此前不存在的 `WARNING:` 行

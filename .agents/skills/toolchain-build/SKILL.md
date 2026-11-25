---
name: toolchain-build
description: '通过 menu.sh 构建 openEuler Embedded 交叉编译链。当用户需要 build toolchain、构建编译链、编译交叉链、compile gcc、编译 gcc、build llvm、构建 llvm、clang musl、menu.sh、ct-ng build、cross compile、交叉编译、prepare、docker container build、容器构建，或需要启动/进入/验证构建容器（aarch64、arm32、riscv64、x86_64、llvm、clang-musl）时使用。不适用于 oebuild Python 包操作。'
---

# toolchain-build Skill

通过 `menu.sh` 构建 openEuler Embedded 的三类交叉编译链。`menu.sh` 默认
自动启动 Docker 容器（`openeuler-sdk:latest`）执行构建，无需手动管理容器。

## 支持的编译链

| choice | 类型 | 架构 | libc | 编译器 |
| --- | --- | --- | --- | --- |
| `gcc-aarch64` | GCC | arm64 | glibc 2.38 | gcc 12.3.0 |
| `gcc-aarch64-musl` | GCC | arm64 | musl 1.2.3 | gcc 10.3.0 (LEGACY) |
| `gcc-arm32` | GCC | arm32 | glibc 2.38 | gcc 12.3.0 |
| `gcc-arm32-musl` | GCC | arm32 | musl 1.2.4 | gcc 12.3.0 |
| `gcc-x86_64` | GCC | x86_64 | glibc 2.38 | gcc 12.3.0 |
| `gcc-riscv64` | GCC | riscv64 | glibc 2.38 | gcc 12.3.0 |
| `gcc-riscv64-musl` | GCC | riscv64 | musl 1.2.4 | gcc 12.3.0 |
| `llvm` | LLVM | 多架构 | — | LLVM 17.0.6 |
| `clang-musl-arm32` | Clang+musl | arm32 | musl 1.2.4 | Clang 19.1.7 |

短别名：`aarch64`、`aarch64-musl`、`arm32`、`arm32-musl`、`x86_64`、`riscv64`、`riscv64-musl`。

## 前置条件

1. Docker CLI 已安装且当前用户有权限运行容器。
2. 镜像 `openeuler-sdk:latest` 存在；不存在时 `menu.sh` 自动从
   `.oebuild/dockerfile/openeuler-sdk/Dockerfile` 构建。
3. 仓库已克隆，`.oebuild/toolchains/menu.sh` 可执行。

## 关键路径

| 路径 | 说明 |
| --- | --- |
| `.oebuild/toolchains/menu.sh` | 统一构建入口 |
| `.oebuild/toolchains/work/<choice>/` | 工作目录（源码 + 中间产物，已 gitignore） |
| `.oebuild/toolchains/output/` | 产物目录（已 gitignore） |
| `.oebuild/toolchains/output/<target-triple>/` | GCC 产物 |
| `.oebuild/toolchains/output/clang-llvm-17.0.6/` | LLVM 产物 |
| `.oebuild/toolchains/output/llvm-musl-arm/` | Clang+musl 产物 |

## 构建模式

| 模式 | 说明 |
| --- | --- |
| `auto`（默认） | 自动启动容器，prepare + build 一步到位 |
| `interactive` | 容器内准备源码后进入交互 shell |
| `raw` | 只打印 docker 命令与构建步骤，不执行 |

## 执行步骤

### Step 0: 切换到仓库根目录

```bash
cd "$(git rev-parse --show-toplevel)"
```

### Step 1: 交互式菜单（推荐首次使用）

```bash
cd .oebuild/toolchains && ./menu.sh
```

弹出 9 项扁平列表，选择编译链后选择构建模式。菜单会显示容器镜像名、
挂载根（MOUNT_ROOT）、产物目录等信息。

### Step 2: 命令行直接构建

```bash
# auto 模式（默认）：启动容器，prepare + build 一步到位
cd .oebuild/toolchains
./menu.sh gcc-aarch64
./menu.sh llvm
./menu.sh clang-musl-arm32

# 交互模式
./menu.sh gcc-aarch64 interactive

# 原始模式（只打印命令）
./menu.sh gcc-aarch64 raw

# 指定工作目录
./menu.sh gcc-aarch64 auto /tmp/my-workdir
```

### Step 3: 验证产物

构建完成后检查产物目录：

```bash
# GCC 系列
ls .oebuild/toolchains/output/<target-triple>/bin/
# 例如 aarch64:
ls .oebuild/toolchains/output/aarch64-openeuler-linux-gnu/bin/

# LLVM
ls .oebuild/toolchains/output/clang-llvm-17.0.6/bin/

# Clang+musl
ls .oebuild/toolchains/output/llvm-musl-arm/bin/
```

验证交叉编译器可执行：

```bash
.oebuild/toolchains/output/aarch64-openeuler-linux-gnu/bin/aarch64-openeuler-linux-gnu-gcc --version
```

## 容器化机制

镜像检查、挂载、UID 匹配与 CT_PREFIX 注入的实现，见
[toolchain-architecture 技能](../toolchain-architecture/SKILL.md) 的
"容器化构建机制"一节。

## 环境变量

| 变量 | 默认值 | 说明 |
| --- | --- | --- |
| `DOCKER_IMAGE` | `openeuler-sdk:latest` | 容器镜像名 |
| `MOUNT_ROOT` | 自动检测（`yocto-meta-openeuler/../..`） | 挂载根目录 |
| `OUTPUT_DIR` | `toolchains/output` | 产物输出目录 |
| `WORK_BASE` | `toolchains/work` | 工作目录基址 |
| `CT_PREFIX` | 等于 `OUTPUT_DIR` | ct-ng 安装前缀（由 menu.sh 传入容器） |

覆盖示例：

```bash
OUTPUT_DIR=/tmp/my-output ./menu.sh gcc-aarch64
WORK_BASE=/tmp/my-work ./menu.sh llvm
```

## 容器内环境

镜像组件版本（gcc 7.3.0、gcc-12、ct-ng 1.26.0、cmake、ninja）见
[toolchain-architecture 技能](../toolchain-architecture/SKILL.md) 的镜像表。

## 常见问题排查

| 问题 | 原因 | 解决方案 |
| --- | --- | --- |
| `docker: command not found` | Docker 未安装 | 安装 Docker CLI |
| `Docker image not found` 后自动构建失败 | Dockerfile 路径问题 | 手动构建：`cd .oebuild/dockerfile/openeuler-sdk && docker build -t openeuler-sdk:latest .` |
| `Permission denied` on work/output 目录 | 容器 UID 与主机不匹配 | menu.sh 自动 usermod；若仍失败检查 `id -u`/`id -g` |
| ct-ng 输出目录只读 | ct-ng 默认 0555 安装 | menu.sh 已在构建后自动 `chmod -R u+w` |
| LLVM build.sh `C_COMPILER_PATH` 错误 | llvm-project 脚本硬编码 gcc | build.sh wrapper 已自动 sed 补丁 |
| Clang+musl 输出复制失败 | GCC tarball 解包 0555 | menu.sh 已自动 `chmod -R u+w` 后复制 |
| 重复下载源码 | `open_source/` 目录已存在 | menu.sh 自动跳过已准备的源码 |

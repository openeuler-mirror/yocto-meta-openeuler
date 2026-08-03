# toolchains — openEuler Embedded 编译链统一入口

## 介绍

本目录集中管理 openEuler Embedded 的三类交叉编译链，用户可通过统一入口
`menu.sh` 一次性选择要构建的编译链，无需记三套分散的目录与命令。

## 目录结构

```
toolchains/
├── menu.sh                  # 统一构建入口（交互式菜单 / 命令行调用）
├── README.md                 # 本文件
├── gcc/                      # GCC 交叉编译链（crosstool-NG 驱动）
│   ├── configs/              #   7 个架构 + libc 组合的 config_*
│   ├── patches/             #   OE 专有补丁
│   ├── prepare.sh           #   下载源码 + 解包 + 应用补丁
│   ├── update.sh            #   GCC 头文件特性 + config 路径刷新
│   ├── release.yaml         #   gitee release 元数据
│   └── README.md            #   GCC 编译链详细文档
├── llvm/                    # LLVM 主机工具链
│   ├── configs/             #   LLVM 仓库名与分支
│   ├── prepare.sh           #   下载 LLVM 源码
│   ├── build.sh             #   构建 + GCC 集成 + 打包（包装脚本）
│   ├── release.yaml         #   gitee release 元数据
│   └── README.md            #   LLVM 工具链详细文档
└── clang-musl-arm32/        # Clang+musl ARM32 专用编译链
    ├── configs/             #   依赖仓和版本配置
    ├── prepare.sh           #   下载 gcc-musl + llvm-project + musl
    ├── build-llvm-musl-arm32.sh  #  7 步构建脚本
    ├── release.yaml         #   gitee release 元数据
    └── README.md            #   Clang+musl ARM32 详细文档
```

## 编译链一览

| 编译链 | 目录 | 架构 | libc | 编译器 | 目标三元组 |
| --- | --- | --- | --- | --- | --- |
| gcc-aarch64 | gcc/ | arm64 | glibc 2.38 | gcc 12.3.0 | aarch64-openeuler-linux-gnu |
| gcc-aarch64-musl | gcc/ | arm64 | musl 1.2.3 | gcc 10.3.0 | aarch64-openeuler-linux-musl |
| gcc-arm32 | gcc/ | arm32 | glibc 2.38 | gcc 12.3.0 | arm-openeuler-linux-gnueabi |
| gcc-arm32-musl | gcc/ | arm32 | musl 1.2.4 | gcc 12.3.0 | arm-openeuler-linux-musleabi |
| gcc-x86_64 | gcc/ | x86_64 | glibc 2.38 | gcc 12.3.0 | x86_64-openeuler-linux-gnu |
| gcc-riscv64 | gcc/ | riscv64 | glibc 2.38 | gcc 12.3.0 | riscv64-openeuler-linux-gnu |
| gcc-riscv64-musl | gcc/ | riscv64 | musl 1.2.4 | gcc 12.3.0 | riscv64-openeuler-linux-musl |
| llvm | llvm/ | 多架构 | — | LLVM 17.0.6 | native + aarch64 交叉 |
| clang-musl-arm32 | clang-musl-arm32/ | arm32 | musl 1.2.4 | Clang 19.1.7 | arm-openeuler-linux-musleabi |

> `gcc-aarch64-musl` 标记为 LEGACY（停留在 gcc 10.3.0 / ct-ng 1.25.0 旧栈，未上 CI）。

## 统一入口 menu.sh

`menu.sh` 默认自动启动 Docker 容器进行构建，无需手动管理容器。启动时
自动完成以下操作：

1. 检查 Docker 镜像 `openeuler-sdk:latest` 是否存在，不存在则自动构建；
2. 将仓库上级目录挂载到容器内同路径（确保容器内外路径一致）；
3. 将容器内 `openeuler` 用户的 UID/GID 调整为与主机一致，避免挂载目录
   权限问题；
4. 以 `openeuler` 用户身份在容器内执行构建脚本。

### 环境变量

| 变量 | 默认值 | 说明 |
| --- | --- | --- |
| `DOCKER_IMAGE` | `openeuler-sdk:latest` | 容器镜像名 |
| `OUTPUT_DIR` | `<MOUNT_ROOT>/build/toolchains` | 统一产物输出目录 |
| `WORK_BASE` | `toolchains/work` | 工作目录基址 |

> `MOUNT_ROOT` 自动检测为仓库上级目录（`yocto-meta-openeuler/../..`），
> 覆盖仓库本身和 `build/` 目录。

### 交互式菜单

```bash
cd .oebuild/toolchains
./menu.sh
```

弹出 9 项扁平列表，选择编译链后选择构建模式（auto / interactive / raw）。
菜单会显示容器镜像名、挂载根、产物目录等信息。

### 命令行调用

```bash
# 自动模式（默认）：启动容器，prepare + build 一步到位
./menu.sh gcc-aarch64
./menu.sh llvm
./menu.sh clang-musl-arm32

# 交互模式：容器内准备源码后进入交互 shell
./menu.sh gcc-aarch64 interactive

# 原始模式：只打印 docker 命令与构建步骤，不执行
./menu.sh gcc-aarch64 raw

# 指定工作目录
./menu.sh gcc-aarch64 auto /tmp/my-workdir
```

### 构建模式

| 模式 | 说明 |
| --- | --- |
| `auto`（默认） | 自动启动容器，跑完 prepare + build，产物安装到 `OUTPUT_DIR` |
| `interactive` | 容器内准备源码后进入交互 shell，由用户手动跑剩余命令 |
| `raw` | 只打印 docker 命令与构建步骤序列，不执行 |

### 产物与工作目录

- **工作目录**：默认 `toolchains/work/<choice>`（如 `work/gcc-aarch64`），
  包含 `open_source/` 源码和中间构建产物。已准备过的源码会跳过重复下载。
  可通过 `WORK_BASE` 环境变量或命令行参数覆盖。
- **产物目录**：统一存放在 `OUTPUT_DIR`（默认 `build/toolchains/`）：
  - GCC 系列：通过 `CT_PREFIX` 环境变量直接安装到 `OUTPUT_DIR/<target-triple>/`
  - LLVM：构建后复制到 `OUTPUT_DIR/clang-llvm-17.0.6/`
  - Clang+musl：构建后复制到 `OUTPUT_DIR/llvm-musl-arm/`

### 短别名

| 别名 | 等价于 |
| --- | --- |
| `aarch64` | `gcc-aarch64` |
| `aarch64-musl` | `gcc-aarch64-musl` |
| `arm32` | `gcc-arm32` |
| `arm32-musl` | `gcc-arm32-musl` |
| `x86_64` | `gcc-x86_64` |
| `riscv64` | `gcc-riscv64` |
| `riscv64-musl` | `gcc-riscv64-musl` |

## 向后兼容

为保持 `oebuild` Python 包和 CI 流水线无需修改即可继续工作，以下符号链接
指向新目录：

```
.oebuild/cross-tools              → toolchains/gcc
.oebuild/llvm-toolchain           → toolchains/llvm
.oebuild/arm32-clang-musl-toolchain → toolchains/clang-musl-arm32
```

oebuild（`toolchain.py`、`generate.py`）和 CI jenkinsfile 通过这些旧路径
访问脚本，符号链接保证路径解析透明。

## 与 oebuild 的关系

`oebuild` 是独立的 Python 包，其 `generate` 子命令可弹出配置菜单并
自动调用 `cross-tools/prepare.sh` + `update.sh` + `ct-ng build`。
`menu.sh` 是轻量级 bash 替代入口，不依赖 Python，覆盖全部三类编译链。
两者可并存使用：

- **GCC 系列**：`oebuild generate` 或 `menu.sh gcc-*` 均可
- **LLVM**：`menu.sh llvm`（oebuild 暂未集成 LLVM 构建）
- **Clang+musl ARM32**：`menu.sh clang-musl-arm32`（oebuild 暂未集成）

## 构建容器

### 统一容器（menu.sh 自动管理）

`menu.sh` 默认使用 `openeuler-sdk:latest` 容器镜像，自动完成容器启动、
UID 匹配、目录挂载等操作，用户无需手动管理容器。

容器启动流程：
1. 检查镜像是否存在，不存在则从 `.oebuild/dockerfile/openeuler-sdk/Dockerfile`
   自动构建；
2. 以 root 启动容器，将 `openeuler` 用户的 UID/GID 调整为与主机一致；
3. 切换到 `openeuler` 用户执行构建脚本；
4. 通过 `CT_PREFIX` 环境变量将 GCC 交叉链直接安装到产物目录。

容器内环境：

| 组件 | 版本 | 用途 |
| --- | --- | --- |
| gcc (默认) | 7.3.0 | GCC 交叉链（ct-ng） |
| gcc-12 | 12.4.0 | LLVM / Clang 构建 |
| ct-ng | 1.26.0 | GCC 交叉链构建引擎 |
| cmake | 3.27.9 | LLVM / Clang 构建 |
| ninja | 1.11.1 | LLVM / Clang 构建 |

> 构建脚本自动检测 `gcc-12` 是否可用：LLVM/Clang 构建优先使用 gcc-12，
> GCC 交叉链使用默认 gcc 7.3.0。

Dockerfile 位于 `.oebuild/dockerfile/openeuler-sdk/Dockerfile`，可手动构建：

```bash
cd .oebuild/dockerfile/openeuler-sdk
docker build -t openeuler-sdk:latest .
```

如需手动启动容器（用于调试），可使用 `interactive` 模式：

```bash
./menu.sh gcc-aarch64 interactive
```

或直接启动：

```bash
docker run -it --rm \
  -v /path/to/demo:/path/to/demo \
  -e CT_PREFIX=/path/to/demo/build/toolchains \
  --user 0:0 \
  openeuler-sdk:latest bash
# 容器内执行 usermod 调整 UID 后切换到 openeuler 用户
```

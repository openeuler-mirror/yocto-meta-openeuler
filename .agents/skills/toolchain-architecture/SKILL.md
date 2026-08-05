---
name: toolchain-architecture
description: "Understand the unified toolchain directory structure, oebuild integration, and backward compatibility. Use when user asks about '目录结构', '架构', 'oebuild', 'menu.sh 和 oebuild 的关系', 'backward compat', '向后兼容', 'symlink', '符号链接', 'cross-tools', 'llvm-toolchain', 'arm32-clang-musl', 'container image', 'Dockerfile', 'openeuler-sdk', 'ct-ng', 'crosstool-NG', 'how does it work', '工作原理', 'design rationale', or needs architectural guidance."
---

# toolchain-architecture Skill

理解 yocto-meta-openeuler 编译链的统一目录结构、oebuild Python 包集成、
向后兼容符号链接与容器镜像设计。

## 统一目录结构

三类交叉编译链统一收拢在 `.oebuild/toolchains/` 下：

```
.oebuild/toolchains/
├── menu.sh                  # 统一构建入口（Bash，Docker 容器化）
├── README.md                # 顶层文档
├── gcc/                      # GCC 交叉编译链（crosstool-NG 驱动）
│   ├── configs/              #   7 个架构 + libc 组合的 config_*
│   ├── patches/             #   OE 专有补丁
│   ├── prepare.sh           #   下载源码 + 解包 + 应用补丁
│   ├── update.sh            #   GCC 头文件特性 + config 路径刷新
│   ├── release.yaml         #   gitee release 元数据
│   └── README.md            #   GCC 详细文档
├── llvm/                    # LLVM 主机工具链
│   ├── configs/              #   LLVM 仓库名与分支
│   ├── prepare.sh           #   下载 LLVM 源码
│   ├── build.sh              #   构建 + GCC 集成 + 打包（包装脚本）
│   ├── release.yaml          #   gitee release 元数据
│   └── README.md            #   LLVM 详细文档
├── clang-musl-arm32/        # Clang+musl ARM32 专用编译链
│   ├── configs/              #   依赖仓和版本配置
│   ├── prepare.sh            #   下载 gcc-musl + llvm-project + musl
│   ├── build-llvm-musl-arm32.sh  #  7 步构建脚本
│   ├── release.yaml          #   gitee release 元数据
│   └── README.md            #   Clang+musl 详细文档
├── work/                    # 工作目录（运行时生成，已 gitignore）
│   └── <choice>/            #   如 gcc-aarch64/
└── output/                  # 产物目录（运行时生成，已 gitignore）
    ├── <target-triple>/     #   GCC 系列
    ├── clang-llvm-17.0.6/   #   LLVM
    └── llvm-musl-arm/       #   Clang+musl ARM32
```

## 三类编译链详解

### GCC 系列（crosstool-NG 驱动）

- **构建引擎**：crosstool-NG (ct-ng) 1.26.0
- **构建流程**：`prepare.sh`（下载源码 + 补丁）→ `update.sh`（刷新 GCC
  头文件特性 + config 路径）→ `ct-ng build`（编译交叉链）
- **配置文件**：`gcc/configs/config_<arch>` — ct-ng 配置片段
- **安装控制**：`CT_PREFIX` 环境变量覆盖 ct-ng 默认安装目录
  （`~/x-tools/`），由 menu.sh 设置为 `OUTPUT_DIR`
- **7 个架构 + libc 组合**：aarch64/glibc、aarch64/musl(LEGACY)、
  arm32/glibc、arm32/musl、x86_64/glibc、riscv64/glibc、riscv64/musl
- **输出**：`output/<target-triple>/`（如 `aarch64-openeuler-linux-gnu/`）

### LLVM 主机工具链

- **版本**：LLVM 17.0.6
- **构建方式**：调用 llvm-project 自带的 `build.sh`，经我们的 wrapper
  脚本（`llvm/build.sh`）添加 gcc-12 检测、CC/CXX 透传、C_COMPILER_PATH
  补丁、strripped 拼写修复
- **构建流程**：`prepare.sh`（克隆 llvm-project）→ `build.sh`（cmake +
  ninja + GCC 库集成 + 打包）
- **输出**：`output/clang-llvm-17.0.6/`

### Clang+musl ARM32

- **版本**：Clang 19.1.7 + musl 1.2.4
- **构建方式**：自定义 7 步 cmake + ninja 脚本
  （`build-llvm-musl-arm32.sh`）
- **构建流程**：`prepare.sh`（下载 gcc-musl + llvm-project + musl）→
  `build-llvm-musl-arm32.sh all --gcc-dir ... --llvm-src ... --musl-src ...
  --output-dir ...`
- **输出**：`output/llvm-musl-arm/`

## oebuild 集成

`oebuild` 是独立的 Python 包（安装在
`~/.local/lib/python3.10/site-packages/oebuild/`），**不属于本仓库**，
无法在本仓库中修改。其 `generate` 子命令可弹出配置菜单并自动调用
`cross-tools/prepare.sh` + `update.sh` + `ct-ng build`。

### oebuild 硬编码路径

oebuild 在 `toolchain.py` 和 `generate.py` 中硬编码了以下路径：
- `.oebuild/cross-tools` — GCC 编译链目录
- `.oebuild/llvm-toolchain` — LLVM 编译链目录

这些路径**不可修改**（因为 oebuild 是外部包），因此本仓库通过符号链接
保持兼容。

## 向后兼容符号链接

为保持 oebuild 和 CI 流水线无需修改即可继续工作，以下符号链接指向新目录：

```
.oebuild/cross-tools              → toolchains/gcc
.oebuild/llvm-toolchain           → toolchains/llvm
.oebuild/arm32-clang-musl-toolchain → toolchains/clang-musl-arm32
```

- **oebuild**（`toolchain.py`、`generate.py`）通过旧路径访问 GCC 脚本。
- **CI jenkinsfile**（`.oebuild/workflows/` 下 3 个 jenkinsfile）通过旧路径
  触发构建。
- 符号链接保证路径解析透明，oebuild 和 CI 无感知。

## menu.sh 与 oebuild 的关系

| 维度 | oebuild | menu.sh |
| --- | --- | --- |
| 语言 | Python | Bash |
| 依赖 | 安装 oebuild 包 | 仅需 Docker |
| 覆盖范围 | 仅 GCC 系列 | 全部三类（GCC + LLVM + Clang+musl） |
| 容器管理 | 无 | 自动（镜像检测 + UID 匹配 + 挂载） |
| 产物管理 | 用户手动 | 统一 `output/` 目录 |

两者可并存使用：
- **GCC 系列**：`oebuild generate` 或 `menu.sh gcc-*` 均可
- **LLVM**：仅 `menu.sh llvm`（oebuild 暂未集成）
- **Clang+musl ARM32**：仅 `menu.sh clang-musl-arm32`（oebuild 暂未集成）

## 容器镜像

### 统一镜像 openeuler-sdk:latest

合并自原有两套 Dockerfile（GCC 专用 + LLVM/Clang 专用），提供：

| 组件 | 版本 | 用途 |
| --- | --- | --- |
| gcc（默认） | 7.3.0 | GCC 交叉链（ct-ng） |
| gcc-12 | 12.4.0 | LLVM / Clang 构建（/opt/gcc-12，/usr/local/bin/gcc-12 wrapper） |
| ct-ng | 1.26.0 | GCC 交叉链构建引擎 |
| cmake | 3.27.9 | LLVM / Clang 构建 |
| ninja | 1.11.1 | LLVM / Clang 构建 |
| glibc | 2.28 | 容器基础系统 |

- **基础镜像**：openEuler 22.03 LTS
- **容器用户**：`openeuler`（UID 1000, GID 1000），HOME=/home/openeuler
- **Dockerfile 位置**：`.oebuild/dockerfile/openeuler-sdk/Dockerfile`

### 手动构建镜像

```bash
cd .oebuild/dockerfile/openeuler-sdk
docker build -t openeuler-sdk:latest .
```

## 容器化构建机制（menu.sh 自动管理）

1. **镜像检查**：`docker image inspect openeuler-sdk:latest`，不存在则自动构建。
2. **MOUNT_ROOT 检测**：`MOUNT_ROOT="$(cd "${YOCTO_DIR}/../.." && pwd)"`
   — 仓库上两级目录，覆盖仓库本身及其上级目录。
3. **容器启动**：
   ```bash
   docker run --rm \
     -v "${MOUNT_ROOT}:${MOUNT_ROOT}" \
     -e CT_PREFIX="${OUTPUT_DIR}" \
     -e HOME=/home/openeuler \
     --user 0:0 \
     "${DOCKER_IMAGE}" bash "${entry_script}"
   ```
4. **UID 匹配**：入口脚本执行
   `usermod -u ${HOST_UID} -g ${HOST_GID} openeuler`，
   然后 `chown -R openeuler:openeuler /home/openeuler`。
5. **执行**：`su -s /bin/bash openeuler -c "cd '${work_dir}' && ${exec_cmd}"`。

## 关键设计决策

### 为什么 work/ 和 output/ 在 toolchains/ 下？

- **work/**：源码和中间产物，与编译链脚本同属一级，便于管理。
- **output/**：产物统一存放，不散落在 `demo/build/` 或其他位置。
- 两者均 gitignore，不提交仓库。

### 为什么 MOUNT_ROOT 是仓库上两级？

- 仓库路径：`/home/ubuntu/demo/src/yocto-meta-openeuler`
- MOUNT_ROOT：`/home/ubuntu/demo`
- 覆盖范围：仓库本身（`src/yocto-meta-openeuler`）+ 兄弟目录
- 确保 `work/` 和 `output/` 在容器内外路径一致。

### 为什么用 --user 0:0 启动？

- 需要以 root 执行 `usermod` 和 `chown`。
- UID 匹配后切换到 `openeuler` 用户执行构建，避免权限问题。

## 何时使用

- 用户询问目录结构
- 用户询问 oebuild 与 menu.sh 的关系
- 用户询问向后兼容机制
- 用户询问容器镜像设计
- 用户需要架构设计指导
- 修改目录结构前的参考

## 何时不使用

- 构建编译链（使用 toolchain-build skill）
- 提交代码（使用 toolchain-git-flow skill）
- 修改具体脚本文件（直接编辑）

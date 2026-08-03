# clang-musl-arm32 — openEuler Embedded ARM32 Clang+Musl 交叉编译链

## 介绍

该模块用于制作 openEuler Embedded 的 ARM32 Clang+Musl 交叉编译链，目标三元组为 `arm-openeuler-linux-musleabi`。该编译链使用 Clang 作为编译器、LLD 作为链接器、musl 作为 C 标准库、compiler-rt 作为运行时库，专为 ARM32 小型化场景设计。

## 目录结构

```
clang-musl-arm32/
├── configs/
│   └── config.xml                # 依赖仓和版本配置
├── prepare.sh                    # 下载前置依赖（gcc-musl、llvm-project、musl）
├── build-llvm-musl-arm32.sh      # 构建 clang+musl ARM32 交叉编译链（7 步）
├── release.yaml                  # 版本发布配置
└── README.md                     # 本文件
```

## 构建容器

```
swr.cn-north-4.myhuaweicloud.com/openeuler-embedded/openeuler-container:latest
```

> 注意：自行构建时，在进入容器时使用 `-u` 参数指定用户为 `openeuler`。

## 使用说明

Clang+musl ARM32 编译链的构建可通过统一入口 `../menu.sh clang-musl-arm32` 或直接使用本目录脚本完成。

### 方式一：使用统一入口（推荐）

```bash
# 自动模式：prepare + build 一步到位
./menu.sh clang-musl-arm32

# 交互模式：只准备源码，手动执行剩余步骤
./menu.sh clang-musl-arm32 interactive

# 原始模式：只打印命令，不执行
./menu.sh clang-musl-arm32 raw
```

### 方式二：直接使用本目录脚本

#### 1. 下载构建所需的前置依赖

前置依赖包括：32 位 gcc+musl 交叉编译链、llvm-project 源码、musl 源码。运行 prepare.sh 可自动下载：

```bash
./prepare.sh <work_dir>
```

其中 `<work_dir>` 为工作目录，所有依赖将下载到该目录下的 `open_source/` 子目录中。若不指定，默认使用脚本所在目录。

32 位 gcc+musl 编译链因文件存储平台限制被分为 3 个分块（`1_openeuler_gcc_arm32le-musl.tar.gz`、`2_openeuler_gcc_arm32le-musl.tar.gz`、`3_openeuler_gcc_arm32le-musl.tar.gz`），prepare.sh 会自动下载所有分块并合并解压。

#### 2. 构建 clang+musl ARM32 交叉编译链

前置依赖下载完成后，运行 build-llvm-musl-arm32.sh 构建编译链：

```bash
cd <work_dir>
./build-llvm-musl-arm32.sh all \
    --gcc-dir ./open_source/openeuler_gcc_arm32le-musl \
    --llvm-src ./open_source/llvm-project \
    --musl-src ./open_source/openeuler-musl/ \
    --output-dir ./toolchain
```

参数说明：

| 参数 | 说明 |
| --- | --- |
| `--gcc-dir` | 32 位 gcc+musl 交叉编译链目录路径 |
| `--llvm-src` | llvm-project 源码目录路径 |
| `--musl-src` | musl 源码目录路径（包含 musl tar 包的目录） |
| `--output-dir` | 编译链输出安装目录 |

脚本会自动完成以下 7 个步骤：

1. 检查前置条件（cmake、ninja 等）
2. 拷贝源码到输出目录并应用 compiler-rt 和 libunwind 补丁
3. 构建 LLVM/Clang/LLD
4. 构建 compiler-rt（ARM 运行时库）
5. 构建 libunwind（ARM 异常处理库）
6. 构建 musl C 库
7. 设置 sysroot、创建符号链接、验证编译链

构建完成后，编译链安装在 `<output-dir>/llvm-musl-arm/` 目录下。

### 3. 使用编译链验证镜像构建

编译链构建完成后，可配合 oebuild 进行镜像构建验证。在 compile.yaml 中配置：

```yaml
EXTERNAL_TOOLCHAIN_LLVM = "/usr1/openeuler/llvm-musl-arm"
DISTRO_FEATURES:append = " clang ld-is-lld"
EXTERNAL_TOOLCHAIN_CLANG_BIN = "${EXTERNAL_TOOLCHAIN_LLVM}/bin"
EXTERNAL_TOOLCHAIN_GCC:arm = "/usr1/openeuler/gcc/openeuler_gcc_arm32le-musl"
EXTERNAL_TARGET_SYS:arm = "arm-openeuler-linux-musleabi"
TCLIBC = "musl"
```

并在 docker_param 的 volumes 中挂载编译链目录：

```yaml
- <path-to-gcc-musl>/openeuler_gcc_arm32le-musl:/usr1/openeuler/gcc/openeuler_gcc_arm32le-musl
- <path-to-llvm-musl>/llvm-musl-arm:/usr1/openeuler/llvm-musl-arm
```

然后执行：

```bash
oebuild bitbake openeuler-image-minimal
```

## release.yaml

此文件用于记录编译链版本发布信息，具体参数如下。

| 参数 | 说明 |
| --- | --- |
| `tag_name` | 发行版标签 |
| `name` | 发行版名称 |
| `body` | 发行版描述 |
| `target_commitish` | 标签关联的对应仓库分支 |
| `owner` | 所属工作组 |
| `repo` | 仓库名称 |

# llvm — openEuler Embedded LLVM 主机工具链

## 介绍

该模块用于制作 openEuler Embedded 的 LLVM 工具链。一条 LLVM 工具链既能支持 x86_64 下的 native 构建，也能支持 aarch64 下的交叉构建。支持 openEuler Embedded 其他架构的交叉构建待后续完善。

## 目录结构

```
llvm/
├── configs/
│   └── config.xml          # LLVM 仓库名与分支配置
├── prepare.sh              # 源码准备：git clone llvm-project
├── build.sh                # 构建包装：llvm-project/build.sh + GCC 集成 + 打包
├── release.yaml            # 版本发布配置
└── README.md               # 本文件
```

## 构建容器

```
swr.cn-north-4.myhuaweicloud.com/openeuler-embedded/openeuler-sdk:latest
```

> 注意：自行构建时，在进入容器时使用 `-u` 参数指定用户为 `openeuler`。

## 使用说明

LLVM 工具链的构建可通过统一入口 `../menu.sh llvm` 或直接使用本目录脚本完成。

### 方式一：使用统一入口（推荐）

```bash
# 自动模式：prepare + build 一步到位
./menu.sh llvm

# 交互模式：只准备源码，手动执行剩余步骤
./menu.sh llvm interactive

# 指定 GCC 交叉链目录用于集成
./menu.sh llvm auto /tmp/llvm-work
# 然后手动运行：
#   build.sh /tmp/llvm-work --gcc-dir /path/to/openeuler_gcc_arm64le
```

### 方式二：直接使用本目录脚本

#### 1. 下载 LLVM 源码

```bash
./prepare.sh ./
```

源码将下载到 `./open_source/llvm-project/`。

#### 2. 构建 LLVM 工具链

```bash
# 仅构建
./build.sh ./

# 构建 + 集成 aarch64 GCC 交叉链
./build.sh ./ --gcc-dir /path/to/openeuler_gcc_arm64le

# 构建 + 集成 + 打包
./build.sh ./ --gcc-dir /path/to/openeuler_gcc_arm64le --package
```

`build.sh` 是 llvm-project 自带 `build.sh` 的包装脚本，它自动执行：

1. 调用 llvm-project 的 `build.sh -e -o -s -i -b release -I clang-llvm-17.0.6`
2. 若提供 `--gcc-dir`，将 aarch64 GCC 的头文件、库文件、sysroot 集成到 LLVM 工具链，并创建 `aarch64-openeuler-linux-gnu-ld` 软链接
3. 若提供 `--package`，将产物打包为 `clang-llvm-17.0.6.tar.gz`

#### llvm-project build.sh 参数参考

```
$ ./build.sh -h
Usage: ./build.sh [options]

Options:
  -b type  Specify CMake build type (default: RelWithDebInfo).
  -c       Use ccache (default: 0).
  -e       Build for embedded cross tool chain.
  -E       Build for openEuler.
  -h       Display this help message.
  -i       Install the build (default: 0).
  -I name  Specify install directory name (default: "install").
  -j N     Allow N jobs at once (default: 8).
  -o       Enable LLVM_INSTALL_TOOLCHAIN_ONLY=ON.
  -r       Delete install dir and perform a clean build.
  -s       Strip binaries and minimize file permissions when installing.
  -t       Enable unit tests (make check-all).
  -v       Enable verbose build output (default: quiet).
  -f       Enable classic flang.
  -X archs Build only specified backends (default: "ARM;AArch64;X86").
```

构建完成的 LLVM 工具链安装在 `clang-llvm-17.0.6` 目录下。

### 3. GCC 交叉链集成说明

使用 LLVM 工具链进行交叉构建时，需要使用 `--gcc-toolchain=` 和 `--sysroot=` 选项指定目标架构的头文件和库文件路径，或者将相关文件集成到 LLVM 工具链中。openEuler LLVM 已使能特性能够搜索默认集成的路径。

集成所需的头文件和库文件来自 GCC 交叉工具链，可从 [openEuler Embedded Toolchains](https://gitee.com/openeuler/yocto-meta-openeuler/releases) 下载最新的 `aarch64` 版本。

集成步骤（`build.sh --gcc-dir` 自动完成）：

```bash
# llvm toolchain 目录:
#     /path/to/llvm-project/clang-llvm-17.0.6
# gcc toolchain 目录:
#     /path/to/gcc/openeuler_gcc_arm64le
cd /path/to/llvm-project/clang-llvm-17.0.6
mkdir -p lib64 aarch64-openeuler-linux-gnu
cp -rf /path/to/gcc/openeuler_gcc_arm64le/lib64/gcc lib64/
cp -rf /path/to/gcc/openeuler_gcc_arm64le/aarch64-openeuler-linux-gnu/include aarch64-openeuler-linux-gnu/
cp -rf /path/to/gcc/openeuler_gcc_arm64le/aarch64-openeuler-linux-gnu/sysroot aarch64-openeuler-linux-gnu/

# 创建 ld 软链接
cd bin
ln -sf ld.lld aarch64-openeuler-linux-gnu-ld
```

## release.yaml

此文件用于升级 toolchain 工具版本，具体参数如下。

| 参数 | 说明 |
| --- | --- |
| `tag_name` | 发行版标签 |
| `name` | 发行版名称 |
| `body` | 发行版描述 |
| `target_commitish` | 标签关联的对应仓库分支 |
| `owner` | 所属工作组 |
| `repo` | gitee 仓库名称 |

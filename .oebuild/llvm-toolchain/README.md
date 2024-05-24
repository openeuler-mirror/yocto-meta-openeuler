# llvm-toolchain

#### 介绍

该模块用于制作openEuler嵌入式的LLVM工具链，一条LLVM工具链既能支持x86_64下的native构建，也能支持aarch64下的交叉构建。支持openEuler嵌入式其他架构的交叉构建待后续完善。

#### 软件架构和配置说明

configs: 相关依赖仓的配置

prepare.sh: 用于下载构建所需的依赖仓库

编译链构建容器：swr.cn-north-4.myhuaweicloud.com/openeuler-embedded/openeuler-sdk:latest

> 注意：
>
> 自行构建时，在进入容器时使用`-u`参数指定用户为`openeuler`

#### 使用说明

LLVM工具链的构建目前只支持自行构建，暂未集成到`oebuild`，待后续完善。通过该模块下的脚本和LLVM源码仓的脚本可以较为方便的构建LLVM工具链。

1，下载构建LLVM工具链需要的源码

```
./llvm-toolchain/prepare.sh ./
```

2，进入LLVM源码目录构建LLVM工具链

```
cd ./open_source/llvm-project
./build.sh -e -o -s -i -b release -I clang-llvm-17.0.6
```

使用`./build.sh -h`命令能够查看各个参数的作用，参考如下，

```
$ ./build.sh -h
Usage: ./build.sh [options]

Build the compiler under /home/llvm-project/build, then install under /home/llvm-project/install.

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
  -r       Delete /home/llvm-project/install and perform a clean build (default: incremental).
  -s       Strip binaries and minimize file permissions when (re-)installing.
  -t       Enable unit tests for components that support them (make check-all).
  -v       Enable verbose build output (default: quiet).
  -f       Enable classic flang.
  -X archs Build only the specified semi-colon-delimited list of backends (default: "ARM;AArch64;X86").
```

构建完成的LLVM工具链安装在`-I`指定的目录下，默认为`install`目录。

3，LLVM工具链集成交叉构建时目标架构的头文件和库文件

使用LLVM工具链进行交叉构建时，需要使用`--gcc-toolchain=`和`--sysroot=`选项指定目标架构的头文件和库文件所在的路径，或者将相关的文件集成到LLVM工具链当中，openEuler LLVM已经使能特性能够搜索默认集成的路径。

集成所需的头文件和库文件来自于GCC交叉工具链，可以从该[下载链接](https://gitee.com/openeuler/yocto-meta-openeuler/releases)中下载最新`openEuler Embedded Toolchains`版本的GCC交叉工具链，选择其中的`aarch64`版本。集成方式如下，

```
# llvm toolchain 目录:
#     /path/to/llvm-project/clang-llvm-17.0.6
# gcc toolchain 目录:
#     /path/to/gcc/openeuler_gcc_arm64le
cd /path/to/llvm-project/clang-llvm-17.0.6
mkdir lib64 aarch64-openeuler-linux-gnu
cp -rf /path/to/gcc/openeuler_gcc_arm64le/lib64/gcc lib64/
cp -rf /path/to/gcc/openeuler_gcc_arm64le/aarch64-openeuler-linux-gnu/include aarch64-openeuler-linux-gnu/
cp -rf /path/to/gcc/openeuler_gcc_arm64le/aarch64-openeuler-linux-gnu/sysroot aarch64-openeuler-linux-gnu/

# 交叉构建工程中，由于部分软件包无法接收到LDFLAGS中的-fuse-ld=lld选项，导致需要去寻找ld链接器，目前以建立软链接进行处理
cd /path/to/llvm-project/clang-llvm-17.0.6/bin
ln -sf ld.lld aarch64-openeuler-linux-gnu-ld
```

# release.yaml

#### 介绍

此文件主要用于升级toolchain工具版本，具体参数如下。

tag_name: 发行版标签

name: 发行版名称

body: 发行版描述

target_commitish: 标签关联的对应仓库分支

owner: 所属工作组

repo: gitee仓库名称


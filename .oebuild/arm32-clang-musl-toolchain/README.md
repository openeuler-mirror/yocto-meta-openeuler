# arm32-clang-musl-toolchain

#### 介绍

该模块用于制作openEuler Embedded的ARM32 Clang+Musl交叉编译链，目标三元组为`arm-openeuler-linux-musleabi`。该编译链使用Clang作为编译器、LLD作为链接器、musl作为C标准库、compiler-rt作为运行时库，专为ARM32小型化场景设计。

#### 软件架构和配置说明

configs/config.xml: 相关依赖仓和版本的配置

prepare.sh: 用于下载构建所需的前置依赖（32位gcc+musl编译链、llvm-project源码、musl源码）

build-llvm-musl-arm32.sh: 用于构建clang+musl ARM32交叉编译链

编译链构建容器：swr.cn-north-4.myhuaweicloud.com/openeuler-embedded/openeuler-container:latest

> 注意：
>
> 自行构建时，在进入容器时使用`-u`参数指定用户为`openeuler`

#### 使用说明

1. 下载构建所需的前置依赖

前置依赖包括：32位gcc+musl交叉编译链、llvm-project源码、musl源码。运行prepare.sh可自动下载：

```
sh arm32-clang-musl-toolchain/prepare.sh <work_dir>
```

其中`<work_dir>`为工作目录，所有依赖将下载到该目录下的`open_source/`子目录中。若不指定，默认使用脚本所在目录。

32位gcc+musl编译链因文件存储平台限制被分为3个分块（1_openeuler_gcc_arm32le-musl.tar.gz、2_openeuler_gcc_arm32le-musl.tar.gz、3_openeuler_gcc_arm32le-musl.tar.gz），prepare.sh会自动下载所有分块并合并解压。

2. 构建clang+musl ARM32交叉编译链

前置依赖下载完成后，运行build-llvm-musl-arm32.sh构建编译链：

```
cd <work_dir>
./arm32-clang-musl-toolchain/build-llvm-musl-arm32.sh all \
    --gcc-dir ./open_source/openeuler_gcc_arm32le-musl \
    --llvm-src ./open_source/llvm-project \
    --musl-src ./open_source/openeuler-musl/ \
    --output-dir ./toolchain
```

参数说明：

- `--gcc-dir`: 32位gcc+musl交叉编译链目录路径
- `--llvm-src`: llvm-project源码目录路径
- `--musl-src`: musl源码目录路径（包含musl tar包的目录）
- `--output-dir`: 编译链输出安装目录

脚本会自动完成以下7个步骤：

1. 检查前置条件（cmake、ninja等）
2. 拷贝源码到输出目录并应用compiler-rt和libunwind补丁
3. 构建LLVM/Clang/LLD
4. 构建compiler-rt（ARM运行时库）
5. 构建libunwind（ARM异常处理库）
6. 构建musl C库
7. 设置sysroot、创建符号链接、验证编译链

构建完成后，编译链安装在`<output-dir>/llvm-musl-arm/`目录下。

3. 使用编译链验证镜像构建

编译链构建完成后，可配合oebuild进行镜像构建验证。在compile.yaml中配置：

```yaml
EXTERNAL_TOOLCHAIN_LLVM = "/usr1/openeuler/llvm-musl-arm"
DISTRO_FEATURES:append = " clang ld-is-lld"
EXTERNAL_TOOLCHAIN_CLANG_BIN = "${EXTERNAL_TOOLCHAIN_LLVM}/bin"
EXTERNAL_TOOLCHAIN_GCC:arm = "/usr1/openeuler/gcc/openeuler_gcc_arm32le-musl"
EXTERNAL_TARGET_SYS:arm = "arm-openeuler-linux-musleabi"
TCLIBC = "musl"
```

并在docker_param的volumns中挂载编译链目录：

```yaml
- <path-to-gcc-musl>/openeuler_gcc_arm32le-musl:/usr1/openeuler/gcc/openeuler_gcc_arm32le-musl
- <path-to-llvm-musl>/llvm-musl-arm:/usr1/openeuler/llvm-musl-arm
```

然后执行：

```
oebuild bitbake openeuler-image-minimal
```

# release.yaml

#### 介绍

此文件主要用于记录编译链版本发布信息，具体参数如下。

tag_name: 发行版标签

name: 发行版名称

body: 发行版描述

target_commitish: 标签关联的对应仓库分支

owner: 所属工作组

repo: 仓库名称
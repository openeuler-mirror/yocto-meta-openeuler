# cross_tools

#### 介绍

该模块用于制作openEuler嵌入式的交叉编译器

#### 软件架构和配置说明

configs:  依赖工具及其crosstool-ng的各架构构建配置

prepare.sh: 用于下载构建所需的依赖仓库，并按照下载的路径，刷新config

对于64位编译器，脚本中(update_feature)通过修改GCC源码，默认从lib64目录下寻找链接器，并在libstdc++.so中添加默认安全选项（relro、now、noexecstack）

可通过ct-ng show-config查看配置基础情况（例如cp config_aarch64 .config && ct-ng show-config）

编译链构建容器：swr.cn-north-4.myhuaweicloud.com/openeuler-embedded/openeuler-sdk:latest

> 注意：
>
> 如果是自行构建，则在进入容器时使用-u 参数指定用户为openeuler

最终配置可参见输出件*gcc -v

例（arm64）：

````
COLLECT_GCC=/home/openeuler/x-tools/aarch64-openeuler-linux-gnu/bin/aarch64-openeuler-linux-gnu-gcc
COLLECT_LTO_WRAPPER=/home/openeuler/x-tools/aarch64-openeuler-linux-gnu/libexec/gcc/aarch64-openeuler-linux-gnu/10.3.1/lto-wrapper
Target: aarch64-openeuler-linux-gnu
Configured with: /usr1/cross-ng_openeuler/.build/aarch64-openeuler-linux-gnu/src/gcc/configure --build=x86_64-build_pc-linux-gnu --host=x86_64-build_pc-linux-gnu --target=aarch64-openeuler-linux-gnu --prefix=/home/openeuler/x-tools/aarch64-openeuler-linux-gnu --exec_prefix=/home/openeuler/x-tools/aarch64-openeuler-linux-gnu --with-sysroot=/home/openeuler/x-tools/aarch64-openeuler-linux-gnu/aarch64-openeuler-linux-gnu/sysroot --enable-languages=c,c++,fortran --with-pkgversion='crosstool-NG 1.25.0' --enable-__cxa_atexit --disable-libmudflap --enable-libgomp --disable-libssp --disable-libquadmath --disable-libquadmath-support --disable-libsanitizer --disable-libmpx --disable-libstdcxx-verbose --with-gmp=/usr1/cross-ng_openeuler/.build/aarch64-openeuler-linux-gnu/buildtools --with-mpfr=/usr1/cross-ng_openeuler/.build/aarch64-openeuler-linux-gnu/buildtools --with-mpc=/usr1/cross-ng_openeuler/.build/aarch64-openeuler-linux-gnu/buildtools --with-isl=/usr1/cross-ng_openeuler/.build/aarch64-openeuler-linux-gnu/buildtools --enable-lto --enable-threads=posix --enable-target-optspace --enable-plugin --enable-gold --disable-nls --enable-multiarch --with-multilib-list=lp64 --with-local-prefix=/home/openeuler/x-tools/aarch64-openeuler-linux-gnu/aarch64-openeuler-linux-gnu/sysroot --enable-long-long --with-arch=armv8-a --with-gnu-as --with-gnu-ld --enable-c99 --enable-shared --enable-poison-system-directories --enable-symvers=gnu --disable-bootstrap --disable-libstdcxx-dual-abi --enable-default-pie --libdir=/home/openeuler/x-tools/aarch64-openeuler-linux-gnu/lib64 --with-build-time-tools=/home/openeuler/x-tools/aarch64-openeuler-linux-gnu/aarch64-openeuler-linux-gnu/bin
Thread model: posix
Supported LTO compression algorithms: zlib
gcc version 10.3.1 (crosstool-NG 1.25.0)
````

#### 使用说明

编译链的构建有三种方式，一种是自动构建模式，第二种是交互构建模式，第三种是原始构建模式，所谓自动构建模式就是用户确定好构建内容后oebuild自动执行构建行为，交互构建模式即为生成交叉编译链构建的基础配置文件后通过执行oebuild toolchain后根据给出的提示进行构建，原始构建模式是最能反映交叉编译链的构建流程的，前两种方式都是通过oebuild做了封装，是为了更方便开发者使用，而原始构建模式则是一步步按流程全部执行一遍，因此对于初学者，推荐原始构建模式。

自动构建模式：

1，执行`oebuild generate`会弹出命令行菜单，选择`Build Toolchain`，然后选定`Auto Build`，此时会列出目前支持的交叉编译链类型，选定需要编译的交叉编译链即可，可以多选

2，按esc后按y保存配置文件退出，此时就开始自动进行交叉编译链的编译

交互构建模式：

1，执行`oebuild generate`会弹出命令行菜单，选择`Build Toolchain`，然后按ESC后按y保存退出，此时终端窗口会有一些提示，表达的意思是进入toolchain的编译目录，然后执行`oebuild toolchain`开始构建

2，进入编译目录会有toolchain.yaml构建配置文件，然后执行`oebuild toolchain`

````
oebuild toolchain

Welcome to the openEuler Embedded build environment, where you
can create openEuler Embedded cross-chains tools by follows:
./cross-tools/prepare.sh ./
cp config_aarch64 .config && ct-ng build
cp config_aarch64-musl .config && ct-ng build
cp config_arm32 .config && ct-ng build
cp config_x86_64 .config && ct-ng build
cp config_riscv64 .config && ct-ng build

[openeuler@huawei-thinkcentrem920t-n000 jjj]$
````
3，此时继续执行，这一步主要是下载交叉编译链需要的各种库

```
./cross-tools/prepare.sh ./
```

4，拷贝config配置文件，然后执行编译命令（这里以aarch64为例）

```
$: cp config_aarch64 .config
$: ct-ng build
```

原始构建模式：

1，创建一个sdk构建容器

```
docker run -it -u openeuler -v /dev/net/tun:/dev/net/tun swr.cn-north-4.myhuaweicloud.com/openeuler-embedded/openeuler-sdk bash
```

2，克隆yocto-meta-openeuler源码，为了提高效率，设置深度为1

```
$ docker clone https://gitee.com/openeuler/yocto-meta-openeuler.git --depth=1
```

3，进入.oebuild/cross-tools，执行prepare.sh下载依赖库，运行完成后会在当下目录出现open_source，这个目录存放构建交叉编译链依赖的库

```
$ cd yocto-meta-openeuler/.oebuild/cross-tools
$ ./prepare.sh
```

4，进入configs目录，选择需要构建的编译链类型，这里以aarch64为例，构建完成后会在cross-tools/x-tools下有发布件

```
$ cd configs
$ cp config_aarch64 .config
$ ct-ng build
```

不管是自动构建模式还是交互构建模式，在构建完后会在编译目录下生成二进制产物，编译链二进制产物在x-tools目录下，我们需要对编译链文件名做一些修改，参照如下命令：

````
$: cd x-tools
# 针对aarch64的处理
$: mv aarch64-openeuler-linux-gnu openeuler_gcc_arm64le
$: tar czf openeuler_gcc_arm64le.tar.gz openeuler_gcc_arm64le
# 针对arm32的处理
$: mv arm-openeuler-linux-gnueabi openeuler_gcc_arm32le
$: tar czf openeuler_gcc_arm32le.tar.gz openeuler_gcc_arm32le
# 针对x86-64的处理
$: mv x86_64-openeuler-linux-gnu openeuler_gcc_x86_64
$: tar czf openeuler_gcc_x86_64.tar.gz openeuler_gcc_x86_64
# 针对riscv64的处理
$: mv riscv64-openeuler-linux-gnu openeuler_gcc_riscv64
$: tar czf openeuler_gcc_riscv64.tar.gz openeuler_gcc_riscv64
# 针对aarch64-musl的处理
$: mv aarch64-openeuler-linux-musl openeuler_gcc_arm64le_musl
$: tar czf openeuler_gcc_arm64le_musl.tar.gz openeuler_gcc_arm64le_musl
````

# release.yaml

### 介绍

此文件主要用于升级toolchain工具版本，具体参数如下。

tag_name: 发行版标签

name: 发行版名称

body: 发行版描述

target_commitish: 标签关联的对应仓库分支

owner: 所属工作组

repo: gitee仓库名称




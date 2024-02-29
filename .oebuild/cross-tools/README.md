# cross_tools

#### 介绍

该模块用于制作openEuler嵌入式的交叉编译器

#### 软件架构和配置说明

configs:  依赖工具及其crosstool-ng的各架构构建配置

prepare.sh: 用于下载构建所需的依赖仓库，并按照下载的路径，刷新config

对于64位编译器，脚本中(update_feature)通过修改GCC源码，默认从lib64目录下寻找链接器，并在libstdc++.so中添加默认安全选项（relro、now、noexecstack）

可通过ct-ng show-config查看配置基础情况（例如cp config_aarch64 .config && ct-ng show-config）

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

在oebuild命令环境中，输入oebuild generate进入菜单配置界面，选择toolchain进行构建后，
oebuild会自动下载本代码进行对应的toolchain构建。

或者直接输入 oebuild generate -toolchain -tn config_aarch64 即可跳过界面选择直接进行toolchain构建,如不指定tn参数则构建全部工具链，oebuild已经将对应的ct-ng操作进行集成，以全量构建为例，具体操作如下。
````
    cd /usr1 && git clone -b master https://gitee.com/openeuler/yocto-embedded-tools.git
    cd yocto-embedded-tools/cross_tools
    ./prepare.sh
    chown -R openeuler:users /usr1
    su openeuler
    #aarch64:
    cp config_aarch64 .config && ct-ng build
    #arm32
    cp config_arm32 .config && ct-ng build
    #x86_64
	cp config_x86_64 .config && ct-ng build
    #riscv64
	cp config_riscv64 .config && ct-ng build
````
上述操作oebuild均是在已经准备好ct-ng的镜像容器中进行，待执行完成之后进入到指定容器中进行如下操作即可获取对应编译工具链。
````
    cd /home/openeuler/x-tools/
    mv aarch64-openeuler-linux-gnu openeuler_gcc_arm64le
    tar czf openeuler_gcc_arm64le.tar.gz openeuler_gcc_arm64le
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





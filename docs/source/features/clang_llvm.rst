.. _clang_llvm:

clang/llvm 编译工具链支持
#########################

本章介绍如何使用 clang/llvm 编译工具链构建 openEuler Embedded。

clang/llvm 介绍
******************

LLVM 项目是模块化和可重用编译器以及工具链的集合，clang 是其编译器前端。相比较于 GNU 编译工具链，其优势在于编译速度更快，静态检查工具更加完善，可拓展性更强等等。

GNU 工具链与 LLVM 工具链主要区别如下表：

========= ============== ==================
项目      GNU工具链      LLVM工具链
========= ============== ==================
C编译器   gcc            clang
C++编译器 g++            clang++
binutils  GNU binutils   LLVM binutils
汇编器    GNU as         集成汇编器
链接器    ld.bfd,ld.gold LLVM linker ld.lld
运行时    libgcc         compiler-rt
原子操作  libatomic      compiler-rt
C语言库   GNU libc glibc LLVM libc
C++标准库 libstdc++      libc++
C++ABI    libsupcxx      libc++abi
栈展开    libgcc_s       LLVM libunwind
========= ============== ==================

meta-clang 层介绍
********************

``meta-clang`` 层包含使用 clang/llvm 编译工具链所需要的 recipes 和 bbclass 文件，由于 openEuler 使用 external-toolchain 机制，无需在 yocto 工程中编译 clang/llvm 工具链。

meta-clang 层中主要起作用的是 clang.bbclass 文件，该文件用来控制编译时传入 clang/llvm 编译工具链的变量和依赖，除此之外，目前还有一小部分软件包并不完美支持使用 clang/llvm 来编译，nonclangable.conf 文件记录了这些软件包的情况。

构建指导
***********

1. 使用 oebuild 和标准容器进行构建
===================================

   参考 :ref:`oebuild_install` 初始化容器环境，并熟悉使用 oebuild 构建 openEuler Embedded。使能 clang/llvm 编译工具链需要在生成配置文件时增加 ``-f clang``

   .. code-block:: console

      oebuild generate -p ${platform} -d ${build_directory} -f clang

   键入 ``oebuild bitbake`` 进入容器环境进行镜像构建，构建命令如下

   .. code-block:: console

      bitbake openeuler-image-llvm

   .. attention::

      当前仅验证了 qemu-aarch64 和树莓派平台的标准镜像，包括 5.10 版本和 6.6 版本的内核。

2. 使用自定义 clang/llvm 编译工具链进行构建
============================================

   用户也可以自定义定制 clang/llvm 编译工具链来进行 openEuler Embedded 的构建。

2.1 LLVM 工具链构建方式
------------------------

     1. 获取编译容器

     .. code-block:: console

       docker pull swr.cn-north-4.myhuaweicloud.com/openeuler-embedded/openeuler-sdk:latest

     2. 进入容器

     .. code-block:: console

       docker run -idt --network host --name clang_compile -u openeuler swr.cn-north-4.myhuaweicloud.com/openeuler-embedded/openeuler-sdk:latest bash
       docker exec -it clang_compile bash

     3. 下载 openEuler LLVM 源码，用户可基于 openEuler llvm-project 仓进行特性的开发

     .. code-block:: console

       cd ~
       git clone -b dev_17.0.6 https://gitee.com/openeuler/llvm-project.git --depth=1

     .. attention::

       请基于 dev_17.0.6 分支进行开发，其他版本 LLVM 未进行过验证，开源版本 LLVM 缺少 openEuler Embedded 构建工程的相关适配，如需使用，需要自行适配。

     4. 构建 LLVM 工具链

     .. code-block:: console

       cd ~/llvm-project
       ./build.sh -e -o -s -i -b release -I clang-llvm-17.0.6

     5. LLVM 工具链集成交叉构建时目标架构的头文件和库文件

     正常交叉构建时，需要使用目标架构的头文件、运行时库（如crtbegin.o）、标准C库（如libc.so）等，LLVM工具链默认使用GCC的运行时库，可以通过 ``--gcc-toolchain=`` 选项指定对应GCC的路径，而标准C库、依赖库等可以通过 ``--sysroot=`` 选项指定对应的路径。

     因此，使用LLVM工具链进行交叉构建时，需要使用 ``--gcc-toolchain=`` 和 ``--sysroot=`` 选项指定目标架构的头文件和库文件所在的路径，或者将相关的文件集成到LLVM工具链当中，openEuler LLVM已经使能特性能够搜索默认集成的路径。

     集成所需的头文件和库文件来自于GCC交叉工具链，可以从该 `下载链接 <https://gitee.com/openeuler/yocto-meta-openeuler/releases>`_ 中下载最新 ``openEuler Embedded Toolchains`` 版本的GCC交叉工具链，选择其中的 ``aarch64`` 版本。集成方式如下，

     .. code-block:: console

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

     6. LLVM 工具链预发布版本获取

     预发布的 LLVM 工具链版本可以从如下地址获取 `openEuler Embedded LLVM Toolchains <https://gitee.com/openeuler/yocto-meta-openeuler/releases>`_ ，预发布版本支持 x86_64 的 native 构建和 aarch64 的交叉构建，并且已经集成了交叉构建所需的目标架构的头文件和库文件。

2.2 openEuler Embedded 构建方式
---------------------------------

     1. 生成配置文件时使用如下命令

     .. code-block:: console

       oebuild generate -p ${platform} -d ${build_directory} -t /path/to/clang-llvm-17.0.6 -f clang

     键入 ``oebuild bitbake`` 进入容器环境进行镜像构建，当前 ``/usr1/openeuler/native_gcc/`` 目录为 oebuild 默认挂载的编译器目录。

     2. 目前需要调整 ``conf/local.conf`` 配置文件

     .. code-block:: console

       # 在 == the content is user added == 以下部分
       # 注释掉：EXTERNAL_TOOLCHAIN_GCC:aarch64 = "/usr1/openeuler/native_gcc"
       # 并增加一行：EXTERNAL_TOOLCHAIN_LLVM = "/usr1/openeuler/native_gcc"
       vim conf/local.conf

     3. 构建命令

     .. code-block:: console

       bitbake openeuler-image-llvm

3. SDK 生成
==============

   .. code-block:: console

      bitbake openeuler-image-llvm -c populate_sdk

   .. attention::

      安装完成 LLVM 版本 SDK 后，在首次初始化 SDK 时会存在若干处交互配置项，目前需要全部手动输入 N

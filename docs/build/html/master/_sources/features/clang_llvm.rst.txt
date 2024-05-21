.. _clang_llvm:

clang/llvm 编译工具链支持
#########################

本章介绍如何使用 clang/llvm 编译工具链构建 openEuler Embedded。

clang/llvm 介绍
---------------

LLVM 项目是模块化和可重用编译器以及工具链的集合，clang 是其编译器前端。相比较于GNU编译工具链，其优势在于编译速度更快，静态检查工具更加完善，可拓展性更强等等。

GNU工具链与LLVM工具链主要区别如下表：

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
-----------------

``meta-clang`` 层包含使用 clang/llvm 编译器工具链所需要的recipes和bbclass文件，由于 openeuler 使用 external-toolchain 机制，无需在 yocto 工程中编译 clang/llvm 工具链。

meta-clang层中主要起作用的是clang.bbclass文件，该文件用来控制编译时传入clang/llvm编译器工具链变量和依赖，除此之外，目前还有一小部分软件包并不完美支持使用clang/llvm来编译，nonclangable.conf文件记录了这些软件包的情况。

构建指导
--------

1. clang/llvm 编译工具链获取：

   - 源码构建

     1. 获取编译容器

     .. code-block:: console

       docker pull swr.cn-north-4.myhuaweicloud.com/openeuler-embedded/openeuler-sdk:latest

     2. 进入容器

     .. code-block:: console

       docker run -idt --network host --name clang_compile -u openeuler swr.cn-north-4.myhuaweicloud.com/openeuler-embedded/openeuler-sdk:latest bash
       docker exec -it clang_compile bash

     3. 下载openEuler LLVM源码

     .. code-block:: console

       cd ~
       git clone -b dev_17.0.6 https://gitee.com/openeuler/llvm-project.git --depth=1

     4. 构建LLVM工具链

     .. code-block:: console

       cd ~/llvm-project
       ./build.sh -e -o -s -i -b release -I clang-llvm-17.0.6

     5. LLVM工具链集成交叉构建时目标架构的头文件和库文件

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

   - LLVM工具链发布版本

     直接从LLVM工具链版本发布地址下载获取 `openEuler Embedded LLVM Toolchains <https://gitee.com/openeuler/yocto-meta-openeuler/releases>`_ ，发布版本支持X86_64的native构建和aarch64的交叉构建，并且已经集成了交叉构建所需的目标架构的头文件和库文件。

2. 构建环境

   参考 :ref:`oebuild_install` 初始化容器环境，生成配置文件时使用如下命令。
   
   .. code-block:: console

      oebuild generate -p ${platform} -d ${build_directory} -t /path/to/clang-llvm-17.0.6 -f clang

   除了使用上述命令进行配置文件生成，还可以使用如下命令进入到菜单选择界面进行对应数据填写和选择，效果跟上述命令相同。

   .. code-block:: console

       oebuild generate

   具体界面如下图所示:

   .. image:: ../_static/images/generate/oebuild-generate-select.png

   键入 ``oebuild bitbake`` 进入容器环境后， ``/usr1/openeuler/native_gcc/`` 目录为oebuild默认挂载的编译器目录。
   此外，需要调整 ``conf/local.conf`` 文件，

   .. code-block:: console

      # 删除文件内的一行: EXTERNAL_TOOLCHAIN:aarch64 = "/usr1/openeuler/native_gcc"
      vim conf/local.conf

   .. attention::
      
      当前仅验证支持了qemu-aarch64和树莓派平台的标准镜像。

3. 构建命令

   .. code-block:: console

      bitbake openeuler-image-llvm

4. SDK生成

   .. code-block:: console

      bitbake openeuler-image-llvm -c populate_sdk

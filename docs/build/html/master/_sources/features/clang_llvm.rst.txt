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

     获取编译容器

     .. code-block:: console

       docker pull swr.cn-north-4.myhuaweicloud.com/openeuler-embedded/cross-compile-bisheng:v0.1

     进入容器

     .. code-block:: console

       docker run -idt --network host --name clang_compile swr.cn-north-4.myhuaweicloud.com/openeuler-embedded/cross-compile-bisheng:v0.1 bash
       docker exec -it clang_compile bash

     下载llvm-project

     .. code-block:: console

       cd ~
       git clone https://gitee.com/openeuler/llvm-project.git -b dev_15x

     初始化环境并编译

     .. code-block:: console

       source /etc/profile
       cd llvm-project
       ./build.sh -e -o -s -i -b release

   - 预编译发布

     直接从预编译发布网站获取 `LLVM <http://43.136.114.130/llvm/>`_

2. 构建环境

   参考 :ref:`openeuler_embedded_oebuild` 初始化容器环境，生成配置文件时使用如下命令
   
   .. code-block:: console

      oebuild generate -p platform -d build_direction -t /path/to/clang-llvm-15.0.3 -f clang

   键入 ``oebuild bitbake`` 进入容器环境后，拷贝arm64架构GCC库至编译器目录

   ``/usr1/openeuler/native_gcc/`` 为oebuild默认挂载的编译器目录

   .. code-block:: console

      sudo cp /usr1/openeuler/gcc/openeuler_gcc_arm64le/* /usr1/openeuler/native_gcc/

   .. attention::
      
      当前只支持arm64架构

3. 构建命令

   .. code-block:: console

      bitbake openeuler-image-llvm

4. SDK生成

   .. code-block:: console

      bitbake openeuler-image-llvm -c populate_sdk

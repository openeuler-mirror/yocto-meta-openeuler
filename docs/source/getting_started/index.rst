.. _getting_started:

快速上手
********

简介
====

openEuler Embedded是基于openEuler社区面向嵌入式场景的Linux版本。由于嵌入式系统应用受到多个因素的约束，如资源、功耗、多样性等，
使得面向服务器领域的Linux及相应的构建系统很难满足嵌入式场景的要求，因此业界广泛采用 `Yocto <https://www.yoctoproject.org/>`_
来定制化构建嵌入式Linux。

openEuler Embedded当前也采用的Yocto构建，但实现了与openEuler其他版本代码同源，本章节将介绍如何使用 `yocto-meta-openeuler <https://gitee.com/openeuler/yocto-meta-openeuler>`_
项目构建 ARM64 QEMU 镜像，以及如何基于镜像完成基本的嵌入式Linux应用开发。建议按照指导步骤完成镜像构建和运行，以熟悉 `yocto-meta-openeuler` 的开发流程，树莓派等其它镜像的构建开发流程类似，具体可参阅 :ref:`南向支持 <bsp>` 章节。

____

构建 ARM64 QEMU 镜像
====================

openEuler Embedded采用yocto构建，但通过 `oebuild <https://gitee.com/openeuler/oebuild>`_ 简化了构建流程。按照以下步骤可以快速构建出一个openEuler Embedded镜像，包括工具链。

.. note::

   - | 当前 **仅支持在x86_64位的Linux环境** 下使用 oebuild 进行构建，并且要在 **普通用户** 下进行 oebuild 的安装运行。更多关于 oebuild 的介绍请参阅 :ref:`oebuild 介绍 <openeuler_embedded_oebuild>` 章节。

   - openEuler Embedded 的 CI 会归档最新的构建镜像，若希望快速获取可用的镜像，请访问 `dailybuild <http://121.36.84.172/dailybuild/openEuler-Mainline/>`_ ，在 ``dailybuild/openEuler-Mainline/openeuler-xxxx-xx-xx/embedded_img`` 中可以下载镜像。

1. 安装必要的主机包
-------------------

   需要在构建主机上安装必要的主机包，包括oebuild及其运行依赖：

   .. tabs::

      .. code-tab:: shell openEuler

         # 安装必要的软件包
         $ sudo yum install python3 python3-pip docker
         $ pip install oebuild

         # 配置docker环境
         $ sudo usermod -a -G docker $(whoami)
         $ sudo systemctl daemon-reload && sudo systemctl restart docker
         $ sudo chmod o+rw /var/run/docker.sock

      .. code-tab:: shell Ubuntu

         # 安装必要的软件包
         $ sudo apt-get install python3 python3-pip docker docker.io
         $ pip install oebuild

         # 配置docker环境
         $ sudo usermod -a -G docker $(whoami)
         $ sudo systemctl daemon-reload && sudo systemctl restart docker
         $ sudo chmod o+rw /var/run/docker.sock

2. 初始化oebuild构建环境
------------------------

   运行 oebuild 完成初始化工作，包括创建工作目录、拉取构建容器等，之后的构建都需要在 ``<work_dir>`` 下进行：

   .. code-block:: shell

      # <work_dir> 为要创建的工作目录
      $ oebuild init <work_dir>

      # 切换到工作目录
      $ cd <work_dir>

      # 拉取构建容器、yocto-meta-openeuler 项目代码
      $ oebuild update

3. 开始构建
-----------

   继续执行以下命令进行 ``ARM64 QEMU`` 镜像的构建，``build_arm64`` 为该镜像的构建目录：

   .. code-block:: shell

      # 所有的构建工作都需要在 oebuild 工作目录下进行
      $ cd <work_dir>

      # 为 openeuler-image-qemu-arm64 镜像创建配置文件 compile.yaml
      $ oebuild generate -p aarch64-std -d build_arm64

      # 切换到包含 compile.yaml 的编译空间目录，如 build/build_arm64/
      $ cd build/build_arm64/

      # 根据提示进入 build_arm64 构建目录，并开始构建
      $ oebuild bitbake openeuler-image

4. 运行镜像
-----------

   完成构建后，在构建目录下的 ``output`` 目录下可以看到如下文件：

   - ``zImage``: 内核镜像，基于openEuler社区Linux 5.10代码构建；
   - ``openeuler-image-qemu-xxx.cpio.gz``: 标准根文件系统镜像， 进行了必要安全加固，增加了audit、cracklib、OpenSSH、Linux PAM、shadow、iSula容器等所支持的软件包；
   - ``openeuler-image-qemu-aarch64-xxx.iso``: iso格式的镜像，可用于制作U盘启动盘；
   - ``vmlinux``: 对应的vmlinux，可用于内核调试。

   在主机上通过以下命令安装QEMU:

   .. tabs::

      .. tab:: openEuler

         $ sudo yum install qemu-system-aarch64

      .. tab:: Ubuntu

         $ sudo apt-get install qemu-system-arm

   之后，通过以下命令启动镜像：

   .. code-block:: console

      $ qemu-system-aarch64 -M virt-4.0 -m 1G -cpu cortex-a57 -nographic \
          -kernel zImage \
          -initrd openeuler-image-qemu-aarch64-*.rootfs.cpio.gz

   QEMU运行成功并登录后，将会呈现openEuler Embedded的Shell。

   .. note::

      - 由于标准根文件系统镜像进行了安全加固，因此第一次启动时，需要为登录用户名root设置密码，且密码强度有相应要求，需要 **数字、字母、特殊字符组合最少8位**，例如openEuler@2023

      - 如果想了解有关运行 QEMU 的更多帮助信息，包括如何使能网络、如何共享主机文件等，请参阅开发手册中的 :ref:`QEMU使用 <qemu_start>` 章节。

____

基于SDK的应用开发
=================

嵌入式往往面临资源受限的问题，包括处理器性能、内存容量、存储空间等。因此，需要使用交叉编译器在构建主机上编译目标代码，以在嵌入式系统上运行。

openEuler Embedded提供了SDK自解压安装包，包含了应用程序开发所依赖的交叉编译器、库、头文件，下面将介绍如何构建ARM64的SDK，以及如何使用SDK进行用户态程序、内核模块的开发。

1. 构建SDK
----------

   进入到镜像构建目录 ``build_arm64``，执行以下命令：

   .. code-block:: shell

      oebuild bitbake openeuler-image -c do_populate_sdk

   构建完成后，在 ``output`` 目录下可以看到SDK安装包：

   - ``openeuler-glibc-x86_64-xxxxx-toolchain-xxxx.sh``: openEuler Embedded SDK自解压安装包，SDK包含了进行开发（用户态程序、内核模块等)所必需的工具、库和头文件等。

.. _install-openeuler-embedded-sdk:

2. 安装SDK
----------

  - **安装依赖软件包**

    使用SDK开发内核模块需要安装一些必要的软件包，运行如下命令：

    .. tabs::

       .. tab:: openEuler

          $ sudo yum install make gcc g++ flex bison gmp-devel libmpc-devel openssl-devel

       .. tab:: Ubuntu

          $ sudo apt-get install make gcc g++ flex bison libgmp3-dev libmpc-dev libssl-dev

  - **执行SDK自解压安装脚本**

    运行如下命令：

    .. code-block:: console

       $ sh openeuler-glibc-x86_64-openeuler-image-aarch64-qemu-aarch64-toolchain-*.sh

    根据提示输入工具链的安装路径，默认路径是 :file:`/opt/openeuler/<openeuler version>`，若不设置，则按默认路径安装；也可以配置相对路径或绝对路径。
    其中 "*" 代表不同的版本。

    一个例子如下：

    .. code-block:: console

       $ sh openeuler-glibc-x86_64-openeuler-image-aarch64-qemu-aarch64-toolchain-*.sh
       openEuler embedded(openEuler Embedded Reference Distro) SDK installer version *
       ================================================================
       Enter target directory for SDK (default: /opt/openeuler/<openeuler version>): sdk
       You are about to install the SDK to "/usr1/openeuler/sdk". Proceed [Y/n]? y
       Extracting SDK...............................................done
       Setting it up...SDK has been successfully set up and is ready to be used.
       Each time you wish to use the SDK in a new shell session, you need to source the environment setup script e.g.
       $ . /usr1/openeuler/sdk/environment-setup-aarch64-openeuler-linux

  - **设置SDK环境变量**

    前一步执行结束最后已打印source命令，运行即可。

    .. code-block:: console

       $ . /usr1/openeuler/sdk/environment-setup-aarch64-openeuler-linux

  - **查看是否安装成功**

    运行如下命令，查看是否安装成功、环境设置成功。

    .. code-block:: console

       $ aarch64-openeuler-linux-gcc -v

3. 使用SDK编译hello world样例
-----------------------------

  1. **准备代码**

     以构建一个hello world程序为例，运行在openEuler Embedded根文件系统镜像中。

     创建一个 :file:`hello.c` 文件，源码如下：

     .. code-block:: c

        #include <stdio.h>

        int main(void)
        {
            printf("hello world\n");
        }

     编写CMakeLists.txt，和hello.c文件放在同一个目录。

     .. code-block:: CMake

        project(hello C)

        add_executable(hello hello.c)

  2. **编译生成二进制**

     进入 :file:`hello.c` 文件所在目录，使用工具链编译, 命令如下：

     .. code-block:: console

        $ cmake ..
        $ make

     把编译好的hello程序拷贝到openEuler Embedded系统中。

  3. **运行用户态程序**

     在openEuler Embedded系统中运行hello程序。

     .. code-block:: console

        $ ./hello

     如运行成功，则会输出 ``hello world``。

4. 使用SDK编译内核模块样例
--------------------------

  1. **准备代码**

     以编译一个最简单的内核模块为例，运行在openEuler Embedded内核中。

     创建一个 :file:`hello.c` 文件，源码如下：

     .. code-block:: c

        #include <linux/init.h>
        #include <linux/module.h>

        static int hello_init(void)
        {
            printk("Hello, openEuler Embedded!\r\n");
            return 0;
        }

        static void hello_exit(void)
        {
            printk("Byebye!");
        }

        module_init(hello_init);
        module_exit(hello_exit);

        MODULE_LICENSE("GPL");

     编写Makefile，和hello.c文件放在同一个目录：

     .. code-block:: Makefile

        KERNELDIR := ${KERNEL_SRC}
        CURRENT_PATH := $(shell pwd)

        target := hello
        obj-m := $(target).o

        build := kernel_modules

        kernel_modules:
   	        $(MAKE) -C $(KERNELDIR) M=$(CURRENT_PATH) modules
        clean:
   	        $(MAKE) -C $(KERNELDIR) M=$(CURRENT_PATH) clean

     :file:`KERNEL_SRC` 为SDK中内核源码树的目录，该变量在安装SDK后会被自动设置。

  2. **编译生成内核模块**

     进入hello.c文件所在目录，使用工具链编译，命令如下：

     .. code-block:: console

        $ make

     将编译好的hello.ko拷贝到openEuler Embedded系统中。

  3. **插入内核模块**

     在openEuler Embedded系统中插入内核模块:

     .. code-block:: console

        $ insmod hello.ko

     如运行成功，则会在内核日志中出现 ``Hello, openEuler Embedded!``。

____

了解更多
========

   相信根据上述指导完成了QEMU镜像的构建、运行后，您对 openEuler Embedded 的开发构建流程已经有所熟悉，但也许您也会有一些疑惑：
   openEuler Embedded还能用来做些什么？如何理解学习yocto？如何更深入地参与项目的讨论建设？

   您可以阅读文档相关的介绍，或参与SIG组例会，更深入地了解openEuler Embedded：

   - | :ref:`openEuler Embedded 关键特性 <openeuler_embedded_features>`：
     | 可以了解openEuler Embedded 正在进行的一些技术探索，包括ROS的支持，如何使用openEuler Embedded控制originbot小车；包括混合关键性系统的支持，如何在一颗SoC上同时部署Linux和RTOS；也包括嵌入式容器iSulad的支持等。

   - | :ref:`openEuler Embedded 南向支持 <bsp>`：
     | 可以将openEuler Embedded部署在不同架构的板子上，包括树莓派4B、海思的Hi3093、瑞芯微的RK3568，以及x86_64架构的工控机，RISC-V的visionfive2等。

   - | :ref:`openEuler Embedded 构建系统 <yocto>`：
     | 可以了解yocto的一些基础知识，学习如何新增一个软件包，如何增加新的南向BSP支持等。

   - | `openEuler mailweb <https://mailweb.openeuler.org/hyperkitty/list/dev@openeuler.org/>`_ ：
     | 可以订阅openEuler邮件列表，收取 Yocto & Embedded SIG联合例会的通知，SIG例会双周举行一次，会议时间固定为北京时间的周四下午两点半。

   - | `SIG组例会视频 <https://space.bilibili.com/527064077/channel/collectiondetail?sid=230709>`_ ：
     | 可以观看往期的SIG组例会回放，了解openEuler Embedded的发展以及一些有趣的知识分享。

   非常希望您在深入了解openEuler Embedded之后，能有一个良好的体验。对于遇到的问题，欢迎到SIG组例会上交流，或者在 `Issues <https://gitee.com/openeuler/yocto-meta-openeuler/issues>`_ 中反馈，同时也十分欢迎您的提交。

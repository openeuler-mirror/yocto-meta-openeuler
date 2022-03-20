.. _getting_started:

快速上手
##########

openEuler Embedded是基于openEuler社区面向嵌入式场景的Linux版本。由于嵌入式系统应用受到多个因素的约束，如资源、功耗、多样性等，
使得面向服务器领域的Linux及相应的构建系统很难满足嵌入式场景的要求，因此业界广泛采用 `Yocto <https://www.yoctoproject.org/>`_
来定制化构建嵌入式Linux。openEuler Embedded当前也采用的Yocto构建，但实现了与openEuler其他版本代码同源，具体的构建方法请参考
`SIG-Yocto <https://gitee.com/openeuler/community/tree/master/sig/sig-Yocto>`_
下相关代码仓中的内容。

本文档主要用于介绍如何获取预先构建好的镜像，如何运行镜像，以及如何基于镜像完成基本的嵌入式Linux应用开发。

获取镜像
***********

当前发布的已构建好的镜像，只支持arm和aarch64两种架构，且只支持qemu中ARM virt-4.0平台，您可以通过如下链接获得相应的镜像：

- `qemu_arm <https://repo.openeuler.org/openEuler-21.09/embedded_img/qemu-arm>`_： 32位arm架构, ARM Cortex A15处理器
- `qemu_aarch64 <https://repo.openeuler.org/openEuler-21.09/embedded_img/qemu-aarch64>`_: 64位aarch64架构 ARM Cortex A57处理器

只要相应环境支持qemu仿真器（版本5.0以上），您可以将提供的openEuler Embedded镜像部署在物理裸机、云环境、容器或虚拟机上。

镜像内容
***********

所下载的镜像，由以下几部分组成：

- 内核镜像 **zImage**: 基于openEuler社区Linux 5.10代码构建得到。相应的内核配置可通过如下链接获取：

  - `arm(cortex a15) <https://gitee.com/openeuler/yocto-embedded-tools/blob/openEuler-21.09/config/arm/defconfig-kernel>`_
  - `arm(cortex a57) <https://gitee.com/openeuler/yocto-embedded-tools/blob/openEuler-21.09/config/arm64/defconfig-kernel>`_, 
    针对aarch64架构，额外增加了镜像自解压功能，可以参见相应的 `patch <https://gitee.com/openeuler/yocto-embedded-tools/blob/openEuler-21.09/patches/arm64/0001-arm64-add-zImage-support-for-arm64.patch>`_

- 根文件系统镜像（依据具体需求，以下二选一）

  - **initrd_tiny**：极简根文件系统镜像，只包含基本功能。包含 busybox 和基本的 glibc 库。该镜像功能简单，但内存消耗很小，适合探索 Linux内核相关功能。
  - **initrd**：标准根文件系统镜像，在极简根文件系统镜像的基础上，进行了必要安全加固，增加了audit、cracklib、OpenSSH、Linux PAM、shadow、iSula容器等软件包。该镜像适合进行更加丰富的功能探索。

运行镜像
***********

通过运行镜像，一方面您可以体验openEuler Embedded的功能，一方面也可以完成基本的嵌入式Linux开发。

.. note::

   - 建议使用QEMU5.0以上版本运行镜像，由于一些额外功能（网络、共享文件系统)需要依赖QEMU的virtio-net, virtio-fs等特性，如未在QEMU中使能，则运行时可能会产生错误，此时可能需要从源码重新编译QEMU。

   - 运行镜像时，建议把内核镜像和根文件系统镜像放在同一目录下，后续说明以标准根文件系统为例(initrd)。


极简运行场景
==============

该场景下，qemu未使能网络和共享文件系统，适合快速的功能体验。

针对arm(ARM Cortex A15)，运行如下命令：

.. code-block:: console

    qemu-system-arm -M virt-4.0 -cpu cortex-a15 -nographic -kernel zImage -initrd initrd

针对aarch64(ARM Cortex A57)，运行如下命令：

.. code-block:: console

    qemu-system-aarch64 -M virt-4.0 -cpu cortex-a57 -nographic -kernel zImage -initrd initrd


由于标准根文件系统镜像进行了安全加固，因此第一次启动时，需要为登录用户名root设置密码，且密码强度有相应要求， 需要数字、字母、特殊字符组合最少8位，例如openEuler@2021。当使用极简根文件系统镜像时，系统会自动登录, 无需输入用户名和密码。

qemu运行成功并登录后，将会呈现openEuler Embedded的Shell。

使能共享文件系统场景
==========================

通过共享文件系统，可以使得运行qemu仿真器的宿主机和openEuler Embedded共享文件，这样在宿主机上交叉编译的程序，拷贝到共享目录中，即可在openEuler Embedded上运行。

假设将宿主机的/tmp目录作为共享目录，并事先在其中创建了名为hello_openeuler.txt的文件，使能共享文件系统功能的操作指导如下：

1. **启动qemu**

针对arm(ARM Cortex A15)，运行如下命令：

.. code-block:: console

    qemu-system-arm -M virt-4.0 -cpu cortex-a15 -nographic -kernel zImage -initrd initrd -device virtio-9p-device,fsdev=fs1,mount_tag=host -fsdev local,security_model=passthrough,id=fs1,path=/tmp

针对aarch64(ARM Cortex A57)，运行如下命令：

.. code-block:: console

    qemu-system-aarch64 -M virt-4.0 -cpu cortex-a57 -nographic -kernel zImage -initrd initrd -device virtio-9p-device,fsdev=fs1,mount_tag=host -fsdev local,security_model=passthrough,id=fs1,path=/tmp


2. **映射文件系统**

在openEuler Embedded启动并登录之后，需要运行如下命令，映射(mount)共享文件系统

.. code-block:: console

    cd /tmp
    mkdir host
    mount -t 9p -o trans=virtio,version=9p2000.L host /tmp/host

即把共享文件系统映射到openEuler Embedded的/tmp/host目录下。

3. **检查共享是否成功**

在openEuler Embedded中，运行如下命令:

.. code-block:: console

    cd /tmp/host
    ls

如能发现hello_openeuler.txt，则共享成功。

使能网络场景
===============

通过qemu的virtio-net和宿主机上的虚拟网卡，可以实现宿主机和openEuler embedded之间的网络通信。

1. **启动qemu**

针对arm(ARM Cortex A15)，运行如下命令：

.. code-block:: console

    qemu-system-arm -M virt-4.0 -cpu cortex-a15 -nographic -kernel zImage -initrd initrd -device virtio-net-device,netdev=tap0 -netdev tap,id=tap0,script=/etc/qemu-ifup

针对aarch64(ARM Cortex A57)，运行如下命令：

.. code-block:: console

    qemu-system-aarch64 -M virt-4.0 -cpu cortex-a57 -nographic -kernel zImage -initrd initrd -device virtio-net-device,netdev=tap0 -netdev tap,id=tap0,script=/etc/qemu-ifup

2. **宿主上建立虚拟网卡**

在宿主机上需要建立名为tap0的虚拟网卡，可以借助/etc/qemu-ifup脚本实现，其执行需要root权限，具体内容如下：

.. code-block:: console

    #!/bin/bash
    ifconfig $1 192.168.10.1 up

通过qemu-ifup脚本，宿主机上将创建名为tap0的虚拟网卡，地址为192.168.10.1。

3. **配置openEuler embedded网卡**

openEuler Embedded登陆后，执行如下命令：

.. code-block:: console

    ifconfig eth0 192.168.10.2


4. **确认网络连通**

在openEuler Embedded中，执行如下命令：

.. code-block:: console

    ping 192.168.10.1

如能ping通，则宿主机和openEuler Embedded之间的网络是连通的。

.. note::

    如需openEuler embedded借助宿主机访问互联网，则需要在宿主机上建立网桥，此处不详述，如有需要，请自行查阅相关资料。



基于openEuler embedded的用户态应用开发
********************************************

当前发布的镜像除了体验openEuler Embedded的基本功能外，还可以进行基本的用户态应用开发，也即在openEuler embedded上运行用户自己的程序。


1. **环境准备**

由于当前镜像采用了linaro arm/aarch64 gcc 7.3.1工具链构建，因此建议应用开发也使用相同的工具链接进行，可以从如下链接中获取相应工具链：

- `linaro arm <https://releases.linaro.org/components/toolchain/binaries/7.3-2018.05/arm-linux-gnueabi/gcc-linaro-7.3.1-2018.05-x86_64_arm-linux-gnueabi.tar.xz>`_
- `linrao arm sysroot <https://releases.linaro.org/components/toolchain/binaries/7.3-2018.05/arm-linux-gnueabi/sysroot-glibc-linaro-2.25-2018.05-arm-linux-gnueabi.tar.xz>`_
- `linaro aarch64 <https://releases.linaro.org/components/toolchain/binaries/7.3-2018.05/aarch64-linux-gnu/gcc-linaro-7.3.1-2018.05-x86_64_aarch64-linux-gnu.tar.xz>`_
- `linrao aarch64 sysroot <https://releases.linaro.org/components/toolchain/binaries/7.3-2018.05/aarch64-linux-gnu/sysroot-glibc-linaro-2.25-2018.05-aarch64-linux-gnu.tar.xz>`_

下载并解压到指定的目录中，例如/opt/openEuler_toolchain。

2. **创建并编译用户态程序**

以构建一个hello openEuler程序为例，运行在aarch64的标准根文件系统镜像中。

在宿主机中，创建一个hello.c文件，源码如下：

.. code-block:: c

    #include <stdio.h>

    int main(void)
    {
        printf("hello openEuler\r\n");
    }

然后在宿主机上使用对应的工具链编译, 相应命令如下：

.. code-block:: console

    export PATH=$PATH:/opt/openEuler_toolchain/gcc-linaro-7.3.1-2018.05-x86_64_aarch64-linux-gnu/bin
    aarch64-linux-gnu-gcc --sysroot=<path-to-sysroot-glibc-linaro-2.25-2018.05-aarch64-linux-gnu> hello.c -o hello
    mv hello /temp

把交叉编译好的hello程序拷贝到/tmp目录下，然后参照使能共享文件系统中的描述，使得openEuler embedded可以访问宿主机的目录。

3. **运行用户态程序**

在openEuler embedded中运行hello程序。

.. code-block:: console

    cd /tmp/host
    ./hello

如运行成功，openEuler Embedded的shell中就会输出hello openEuler。

.. _qemu_start:

QEMU使用
########

本文档主要介绍如何通过qemu运行openEuler Embedded，以及如何使能网络，如何共享宿主机的文件。下面以arm64为例，其它架构与之类似。

1. 安装QEMU
===========

   方法一：通过以下命令安装QEMU

     .. tabs::

        .. tab:: openEuler

           $ sudo yum install qemu-system-aarch64

        .. tab:: Ubuntu

           $ sudo apt-get install qemu-system-arm

   方法二：基于openEuler社区 `QEMU <https://gitee.com/openeuler/qemu/tree/stable-5.0/>`_ 代码自行编译

     1. 首先下载对应的代码并切换到stable-5.0分支：

     .. code-block:: console

        $ git clone https://gitee.com/openeuler/qemu.git qemu
        $ cd qemu
        $ git checkout -b stable-5.0 remotes/origin/stable-5.0

     2. 编译生成对应的二进制：

     .. code-block:: console

        $ ./configure --target-list=arm-softmmu,aarch64-softmmu --disable-werror
        $ make -j 8
        $ make install #调试不需要

     编译完成后会生成 ``arm-softmmu/qemu-system-arm``、``aarch64-softmmu/qemu-system-aarch64`` 两个文件。

     .. note::

        - | configure 执行过程中，可能会有诸如 ``glib-2.48 gthread-2.0 is required to compile QEMU`` 的失败打印，请按照提示自行安装升级对应的软件包。

        - | configure 时可以通过不同的参数来 ``enable/disable`` 一些 QEMU 的特性或编译选项，如示例中增加的 ``--disable-werror`` 可以允许编译 warning；
          | 如想要体验 openEuler Embedded 共享文件系统场景，需要在 configure 时增加 ``--enable-virtfs`` 来使能对应功能。

2. 获取openEuler Embedded镜像
=============================

   参照 :ref:`快速上手<getting_started>` 部分，使用 `yocto-meta-openeuler <https://gitee.com/openeuler/yocto-meta-openeuler>`_ 项目构建 ARM64 QEMU 镜像，或者在 `dailybuild <http://121.36.84.172/dailybuild/openEuler-Mainline/>`_ 下载镜像。

3. 使用QEMU运行镜像
===================

   一个简单的qemu执行命令如下：

   .. code-block:: console

      $ qemu-system-aarch64 -M virt-4.0 -m 1G -cpu cortex-a57 -nographic \
          -kernel zImage \
          -initrd openeuler-image-qemu-aarch64-*.rootfs.cpio.gz

   执行之后等待OS加载完成，很快就能看到登陆提示：

   .. code-block:: console

      Authorized uses only. All activity may be monitored and reported.
      qemu-aarch64 login:

   这意味您已经成功在机器上启动了openEuler Embedded的系统，但此时无法配置网络，也无法通过共享文件系统的方式访问宿主机的文件，接下来会分别介绍如何使能网络和共享文件系统。

4. 使能网络场景
===============

   通过 QEMU 的 ``virtio-net`` 和宿主机上的虚拟网卡，可以实现宿主机和 openEuler Embedded 之间的网络通信，之后可以通过 ``scp`` 实现宿主机和 openEuler Embedded 传输文件。

   .. note::

      如需openEuler Embedded借助宿主机访问互联网，则需要在宿主机上建立网桥，此处不详述，如有需要，请自行查阅相关资料。

   **Step1：宿主上建立虚拟网卡**

     在宿主机上需要建立名为tap0的虚拟网卡，可以借助脚本实现，创建 :file:`/etc/qemu-ifup` 脚本，具体内容如下：

     .. code-block:: console

        #!/bin/bash
        ifconfig $1 192.168.10.1 up

     其执行需要root权限：

     .. code-block:: console

        $ chmod a+x /etc/qemu-ifup

     通过 :file:`qemu-ifup` 脚本，宿主机上将创建名为tap0的虚拟网卡，地址为 ``192.168.10.1``。

   **Step2：启动QEMU时添加netdev**

     针对aarch64(ARM Cortex A57)，运行如下命令：

     .. code-block:: console

        $ qemu-system-aarch64 -M virt-4.0 -m 1G -cpu cortex-a57 -nographic \
           -kernel zImage \
           -initrd openeuler-image-qemu-aarch64-*.rootfs.cpio.gz \
           -device virtio-net-device,netdev=tap0 \
           -netdev tap,id=tap0,script=/etc/qemu-ifup
      
     .. note::
        如果宿主机是Ubuntu，则运行上述命令可能会出现could not configure /dev/net/tun: Operation not permitted\
        的错误。此时，用户需要sudo权限执行上述命令，才能正常运行。

   **Step3：配置openEuler Embedded网卡**

     openEuler Embedded登陆后，默认会为 eth0 配置地址 ``192.168.10.8``：

     .. code-block:: console

        qemu-aarch64 ~ # ifconfig
        eth0      ... ...
                  inet addr:192.168.10.8  Bcast:0.0.0.0  Mask:255.255.255.0

     也可以通过 ``ifconfig`` 手动配置新的地址，如：

     .. code-block:: console

        $ ifconfig eth0 192.168.10.2

   **Step4：确认网络连通**

     在openEuler Embedded中，执行如下命令：

     .. code-block:: console

        $ ping 192.168.10.1

     如能ping通，则宿主机和openEuler Embedded之间的网络是连通的。

5. 使能共享文件系统场景
=======================

   通过共享文件系统，可以使得运行 QEMU 仿真器的宿主机和 openEuler Embedded 共享文件，这样在宿主机上交叉编译的程序，拷贝到共享目录中，即可在 openEuler Embedded 上运行。注意 QEMU 必须支持 virtfs，即配置了 ``--enable-virtfs``。

   假设将宿主机的 ``/tmp`` 目录作为共享目录，并事先在其中创建了名为 :file:`hello_openeuler.txt` 的文件，使能共享文件系统功能的操作指导如下：

   **Step1：启动QEMU时添加fsdev**

     针对aarch64(ARM Cortex A57)，运行如下命令：

     .. code-block:: console

        $ qemu-system-aarch64 -M virt-4.0 -m 1G -cpu cortex-a57 -nographic \
            -kernel zImage \
            -initrd openeuler-image-qemu-aarch64-*.rootfs.cpio.gz \
            -device virtio-9p-device,fsdev=fs1,mount_tag=host \
            -fsdev local,security_model=passthrough,id=fs1,path=/tmp

   **Step2：映射文件系统**

     在 openEuler Embedded 启动并登录之后，需要运行如下命令，映射(mount)共享文件系统：

     .. code-block:: console

        $ cd /tmp
        $ mkdir host
        $ mount -t 9p -o trans=virtio,version=9p2000.L host /tmp/host

     即把共享文件系统映射到 openEuler Embedded 的 ``/tmp/host`` 目录下。

   **Step3：检查共享是否成功**

     在openEuler Embedded中，执行如下命令：

     .. code-block:: console

        $ ls /tmp/host

     如能发现hello_openeuler.txt，则共享成功。

附录：QEMU常用的启动参数
========================

   以下是一些常用的QEMU启动参数：

   - **-M virt**: 指定需要使用的machine类型，virt是qemu提供的一个通用machine，可以同时支持arm32和arm64（部分cortex不支持）， ``-M help`` 可以列出所有支持的machine列表
   - **-m 1G**: 可选，可以通过修改此参数来增大OS的可用内存
   - **-cpu cortex-a57**: 指定模拟的cpu类型，指定 ``-M`` 的情况下可以使用 ``-cpu help`` 查看当前machine支持的cpu类型
   - **-smp 2**: 可选，可以修改OS的cpu数量，默认为1
   - **-append**: 可选，指定内核的启动参数(cmdline)
   - **-kernel**、**-initrd**: 分别用于指定OS的内核和文件系统
   - **-dtb**: 可选，用于指定dtb(device tree)文件
   - **-d in_asm -D qemu.log**: 可选，输出qemu在tcg模式下的"指令流"。 ``-d`` 选择指令流类型，可以用 ``-d help`` 查看支持的选项列表； ``-D`` 指定输出的文件名
   - **-s -S**: 可选，调试参数。 ``-S`` 可以让qemu加载OS的zImage、initrd到指定位置后停止运行，等待gdb连接； ``-s`` 等价于 ``--gdb tcp::1234`` ，启动gdb server并默认监听1234端口
   - **-serial**: 可选，用于串口重定向。不指定时默认为 ``-serial stdio`` ，即打印到标准输入输出。也可以重定向到tcp: ``-serial tcp::1111,server,nowait`` ，通过 ``telnet localhost 1111`` 连接

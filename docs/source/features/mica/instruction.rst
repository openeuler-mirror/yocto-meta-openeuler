使用指导
########

MICA 主要包含三部分组件：

1. ``内核模块`` ：提供RTOS启动、专用中断收发、保留内存管理等功能。不同的部署模式会有对应的内核态实现，例如 bare-metal 部署模式，对应的内核模块是 mcs_km.ko。

2. ``micad`` ：MICA 的守护进程。负责管理和控制RTOS实例的创建、运行及销毁。micad 监听来自于 mica 命令行工具的调用，并根据这些调用执行相应的操作。此外，micad 还负责不同实例上的服务注册等功能。

3. ``mica`` ：MICA 的命令行工具。可以使用 mica 命令根据配置文件来创建、启动、停止RTOS实例，并且能够查看实例的状态和关联的服务信息。

下面，会基于 openEuler Embedded mcs 镜像介绍 MICA 的使用流程。

____

在ARM64 QEMU上运行
******************

1. 制作 dtb

  部署 Client OS 需要在 Linux 的设备树中添加 ``mcs-remoteproc`` 设备节点，为 Client OS 预留出必要的保留内存。
  当前，可以通过 mcs 仓库提供的 `create_dtb.sh <https://gitee.com/openeuler/mcs/blob/master/tools/create_dtb.sh>`_ 脚本生成对应的 dtb：

  .. tabs::

     .. code-tab:: console bare-metal部署

        # create a dtb for qemu_cortex_a53
        $ ./create_dtb.sh qemu-a53


     .. code-tab:: console jailhouse部署

        # create a dtb for qemu_cortex_a53 to support jailhouse
        $ ./create_dtb.sh qemu-a53 -f jailhouse

  成功执行后，会在当前目录下生成 ``qemu.dtb`` 或 ``qemu-jailhouse.dtb`` 文件，对应 QEMU 配置为：`2G RAM, 4 cores`。

2. 启动 QEMU

  .. note::

     下文的QEMU启动命令默认使能 ``virtio-net``，请先阅读 :ref:`QEMU 使用指导 <qemu_enable_net>` 了解如何开启网络。

  使用生成出来的 dtb，按照以下命令启动 QEMU，注意，bare-metal 部署和 jailhouse 部署所依赖的 QEMU 命令略有不同：

  .. tabs::

     .. tab:: bare-metal部署

        | 使用生成出来的 ``qemu.dtb``，按照以下命令启动 QEMU，注意：
        | 1. `-m` 和 `-smp` 要与 dtb 的配置(2G RAM, 4 cores)保持一致，否则会启动失败。
        | 2. 需要指定 `maxcpus=3` 为 Client OS 预留出 core 3。

        .. code-block:: console

           $ sudo qemu-system-aarch64 -M virt,gic-version=3 -cpu cortex-a53 -nographic \
               -device virtio-net-device,netdev=tap0 \
               -netdev tap,id=tap0,script=/etc/qemu-ifup \
               -m 2G -smp 4 \
               -append 'maxcpus=3' \
               -kernel zImage \
               -initrd openeuler-image-*.cpio.gz \
               -dtb qemu.dtb

     .. tab:: jailhouse部署

        | 使用生成出来的 ``qemu-jailhouse.dtb``，按照以下命令启动 QEMU，注意：
        | 1. `-m` 和 `-smp` 要与 dtb 的配置(2G RAM, 4 cores)保持一致，否则会启动失败。
        | 2. 启动 Jailhouse 需要指定 psci method 为 smc，因此，`-M` 需要配置为 ``virt,gic-version=3,virtualization=on,its=off``。
        | 3. 需要通过添加启动参数 ``mem=780M`` 来预留出 Jailhouse 和 Non-root-cell 的内存。

        .. code-block:: console

          $ sudo qemu-system-aarch64 -M virt,gic-version=3,virtualization=on,its=off \
              -cpu cortex-a53 -nographic \
              -device virtio-net-device,netdev=tap0 \
              -netdev tap,id=tap0,script=/etc/qemu-ifup \
              -m 2G -smp 4 \
              -append 'mem=780M' \
              -kernel zImage \
              -initrd openeuler-image-*.cpio.gz \
              -dtb qemu-jailhouse.dtb

3. 部署 Client OS

  用户首先需要创建配置文件来关联实时OS以及指定部署方式，之后可以通过 ``mica`` 命令基于配置文件部署 client OS。
  关于配置文件和 mica 命令的详细介绍请参考 :ref:`mica命令与配置文件介绍 <mica_ctl>`。

  当前 openEuler Embedded mcs 镜像默认安装了一些配置文件样例：`/etc/mica/*.conf`，因此可以通过以下步骤启动：

  .. tabs::

     .. tab:: bare-metal部署

        (1) 调整内核打印等级：

        .. code-block:: console

           # 为了不影响shell的使用，先屏蔽内核打印：
           qemu-aarch64:~$ echo "1 4 1 7" > /proc/sys/kernel/printk

        (2) 启动 client OS：

        | 镜像启动时默认会根据 `/etc/mica/qemu-zephyr-rproc.conf` 创建 client OS 实例。
        | 通过 ``mica status`` 查看该实例状态：

        .. code-block:: console

          qemu-aarch64:~$ mica status
          Name                          Assigned CPU        State               Service
          qemu-zephyr                   3                   Offline

        | 可以看到实例的名称为 qemu-zephyr，关联的 CPU ID 为3，状态为 Offline。
        | 通过 ``mica start <Name>`` 启动实例：

        .. code-block:: console

          qemu-aarch64:~$ mica start qemu-zephyr
          starting qemu-zephyr...
          start qemu-zephyr successfully!

        启动成功后，执行 ``mica status`` 查询状态：

        .. code-block:: console

          qemu-aarch64:~$ mica status
          Name                          Assigned CPU        State               Service
          qemu-zephyr                   3                   Running             rpmsg-tty1(/dev/ttyRPMSG0) rpmsg-tty(/dev/ttyRPMSG1)

        状态更新为 Running，并且能观察到该实例提供了两个服务：rpmsg-tty 以及 rpmsg-tty1。
        rpmsg-tty 绑定了 zephyr 的 shell，因此可以通过 screen 打开 tty 设备 ``/dev/ttyRPMSG1`` 来访问 zephyr 的 shell：

        .. code-block:: console

          # 打开 Client OS 的 shell
          qemu-aarch64:~$ screen /dev/ttyRPMSG1

          ... ...
          # 回车后可以连上 shell，并执行 zephyr 的 shell 命令

          uart:~$ kernel version
          Zephyr version 3.2.0

        之后，可以通过 ``Ctrl-a k`` 或 ``Ctrl-a Ctrl-k`` 组合键退出shell，参考 `screen(1) — Linux manual page <https://man7.org/linux/man-pages/man1/screen.1.html#DEFAULT_KEY_BINDINGS>`_ 。

        (3) 停止 client OS：

        通过 ``mica stop <Name>`` 停止实例：

        .. code-block:: console

          qemu-aarch64:~$ mica stop qemu-zephyr
          stopping qemu-zephyr...
          stop qemu-zephyr successfully!
          qemu-aarch64:~$ mica status
          Name                          Assigned CPU        State               Service
          qemu-zephyr                   3                   Offline

        (4) 销毁 client OS：

        通过 ``mica rm <Name>`` 销毁实例：

        .. code-block:: console

          qemu-aarch64:~$ mica rm qemu-zephyr
          removing qemu-zephyr...
          rm qemu-zephyr successfully!
          qemu-aarch64:~$ mica status
          Name                          Assigned CPU        State               Service

        销毁实例后，可以执行 ``mica create qemu-zephyr-rproc.conf`` 重新创建实例。

     .. tab:: jailhouse 部署

        (1) 使用 SSH 登录 QEMU：

        由于 jailhouse 启动 RTOS VM 后，会占用 QEMU 串口，因此需要先通过 SSH 登录到 QEMU：

        .. code-block:: console

           # 通过 SSH 登录 QEMU：
           $ ssh root@192.168.10.8

        (2) 初始化 Root Cell：

        .. code-block:: console

          qemu-aarch64:~$ jailhouse enable /usr/share/jailhouse/cells/qemu-arm64-mcs.cell

        (3) 启动 client OS：

        通过 ``mica create <Conf>`` 创建实例：

        .. code-block:: console

          qemu-aarch64:~$ mica create qemu-zephyr-ivshmem.conf
          Creating qemu-zephyr-ivshmem...
          Successfully created qemu-zephyr-ivshmem!

        通过 ``mica start <Name>`` 启动实例：

        .. code-block:: console

          qemu-aarch64:~$ mica start qemu-zephyr-ivshmem
          starting qemu-zephyr-ivshmem...
          start qemu-zephyr-ivshmem successfully!

        启动成功后，执行 ``mica status`` 查询状态：

        .. code-block:: console

          qemu-aarch64:~$ mica status
          Name                          Assigned CPU        State               Service
          qemu-zephyr-ivshmem           3                   Running             rpmsg-tty1(/dev/ttyRPMSG0) rpmsg-tty(/dev/ttyRPMSG1)

        可以观察到，状态为 Running，并且该实例提供了两个服务：rpmsg-tty 以及 rpmsg-tty1。
        rpmsg-tty 绑定了 zephyr 的 shell，因此可以通过 screen 打开 tty 设备 ``/dev/ttyRPMSG1`` 来访问 zephyr 的 shell：

        .. code-block:: console

          # 打开 Client OS 的 shell
          qemu-aarch64:~$ screen /dev/ttyRPMSG1

          ... ...
          # 回车后可以连上 shell，并执行 zephyr 的 shell 命令

          uart:~$ kernel version
          Zephyr version 3.2.0

        之后，可以通过 ``Ctrl-a k`` 或 ``Ctrl-a Ctrl-k`` 组合键退出shell，参考 `screen(1) — Linux manual page <https://man7.org/linux/man-pages/man1/screen.1.html#DEFAULT_KEY_BINDINGS>`_ 。

        (3) 停止 client OS：

        通过 ``mica stop <Name>`` 停止实例：

        .. code-block:: console

          qemu-aarch64:~$ mica stop qemu-zephyr-ivshmem
          stopping qemu-zephyr-ivshmem...
          stop qemu-zephyr-ivshmem successfully!
          qemu-aarch64:~$ mica status
          Name                          Assigned CPU        State               Service
          qemu-zephyr-ivshmem           3                   Offline

        (4) 销毁 client OS：

        通过 ``mica rm <Name>`` 销毁实例：

        .. code-block:: console

          qemu-aarch64:~$ mica rm qemu-zephyr-ivshmem
          removing qemu-zephyr-ivshmem...
          rm qemu-zephyr-ivshmem successfully!
          qemu-aarch64:~$ mica status
          Name                          Assigned CPU        State               Service

        销毁实例后，可以执行 ``mica create qemu-zephyr-ivshmem.conf`` 重新创建实例。

____

在树莓派4B上运行
****************

oebuild 构建出来的 MCS 镜像已经通过 dt-overlay 等方式预留了相关资源，并且默认使用了支持 psci 的 uefi 引导固件。
因此只需要根据 :ref:`openeuler-image-uefi启动使用指导 <raspberrypi4-uefi-guide>` 进行镜像启动，再部署 MICA 即可，步骤跟QEMU类似，但树莓派当前仅支持 bare-metal 部署。

____

在x86工控机上运行
*****************

.. note::

   当前 x86 工控机只支持运行 UniProton，并且 x86 的部署方法与 arm64 有所不同，整合工作还在进行中。

首先，需要先根据 :ref:`工控机HVAEIPC-M10 镜像构建安装指导 <hvaepic-m10>` 在工控机上安装 openEuler Embedded 镜像。

之后，我们还需要编译 UniProton 以及 x86环境下需要的额外启动程序 ap_boot，
请参考 `openEuler Embedded & Uniproton x86 MICA环境安装指导 <https://gitee.com/openeuler/UniProton/blob/master/doc/demoUsageGuide/x86_64_demo_usage_guide.md>`_ 。

启动 openEuler Embedded 后，需要为 UniProton 预留出必要的内存、CPU资源。如四核CPU建议预留一个核，内存建议预留512M。
可通过修改 boot 分区的 grub.cfg 配置内核启动参数，新增 ``maxcpus=3 memmap=512M\$0x110000000`` 参数，参考如下：

.. code-block:: console

   openEuler-Embedded:~$ mount /dev/sda1 /boot
   openEuler-Embedded:~$ cat /boot/efi/boot/grub.cfg
   # Automatically created by OE
   serial --unit=0 --speed=115200 --word=8 --parity=no --stop=1
   default=boot
   timeout=10

   menuentry 'boot'{
   linux /bzImage  root=*** rw rootwait quiet maxcpus=3 memmap=512M\$0x110000000 console=ttyS0,115200 console=tty0
   }

修改完成后，请重启工控机，并通过以下命令查看当前CPU和内存的使用情况：

.. code-block:: console

   # 查看CPU核心数
   $ nproc
   3
   # 查看内存使用情况
   $ cat /proc/iomem
   ...
   110000000-12fffffff : Reserved
   ...

这说明当前系统正在使用3个CPU，已经预留出了一个CPU。
内存方面，系统已经预留出了从0x110000000到0x12fffffff的内存资源。

接下来，我们通过在openEuler Embedded上运行如下命令启动MICA：

.. code-block:: console

   # 调整内核打印等级(可选择不执行)
   $ echo "1 4 1 7" > /proc/sys/kernel/printk

   $ mica start /path/to/executable

   # 若成功运行，会有如下打印：
   ...
   start client os
   ...
   pls open /dev/pts/1 to talk with client OS
   pty_thread for console is runnning
   ...
   found matched endpoint, creating console with id:2 in host os

   # 根据打印提示（found matched endpoint, creating console with id:2 in host os），
   # 说明成功创建了console，可以通过 /dev/pts/1 查看 UniProton 的串口输出，例如：
   $ screen /dev/pts/1

   # 敲回车后，可以查看uniproton输出信息
   # 可以通过 <Ctrl-a k> 或 <Ctrl-a Ctrl-k> 组合键退出console，具体请参考 screen 的 manual page

如果想停止当前的Client OS，可以通过以下命令：

.. code-block:: console

   $ mica stop

----------------

.. _mica_debug:

调试支持 GDB stub 的 Client OS
============================================

当前仅支持调试运行在树莓派4B（aarch64）和x86工控机（x86_64）的Uniproton。

相关接口定义
-------------

首先，对于Client OS而言，需要支持GDB stub。
当前MICA框架仅支持基于简单ring buffer通信的方式进行GDB stub信息的交互，
ring buffer的地址和大小在MCS仓库中 ``library/include/mcs/mica_debug_ring_buffer.h`` 中定义：

.. code-block:: c

   // x86 ring buffer base address offset and size
   #define RING_BUFFER_SHIFT 0x4000
   #define RING_BUFFER_SIZE 0x1000

   // aarch64 ring buffer address and size
   #define RING_BUFFER_ADDR 0x70040000
   #define RING_BUFFER_SIZE 0x1000

x86架构下由于ring buffer存在的物理空间的首地址始终相对于Uniproton的入口地址是固定的，
在做内存映射的时候我们ring buffer的首地址可以通过Uniproton的入口地址减去 ``RING_BUFFER_SHIFT`` 得到。

ring buffer 的定义在 ``library/include/mcs/ring_buffer.h`` 文件中。

使用方法
----------

首先，需要构建含有MICA的openEuler Embedded镜像，请参考 :ref:`MICA镜像构建指南 <mcs_build>` 。

然后，需要生成适配了GDB stub 的 Uniproton，参考 `UniProton GDB stub 构建指南 <https://gitee.com/zuyiwen/UniProton/blob/stub_dev/src/component/gdbstub/readme.txt>`_ 。

在运行命令时，需要在启动MICA时加上 ``-d`` 参数。
并且，由于需要对可执行文件进行调试， ``-t`` 参数需要指定包含符号表的可执行文件的路径。
一般来说，plain binary format的可执行文件并没有相关调试信息，
所以我们只能使用elf格式的可执行文件进行调试。
当然，如果 ``-t`` 参数指定的是格式为plain binary format的可执行文件的路径，
调试模式仍然可以正常启动，但是在启动GDB client的时候无法正确读取符号表，
需要用 ``file`` 命令额外指定包含符号表的可执行文件的路径。

以下是启动MICA调试模式的命令：

.. code-block:: console

   # 若使用的是标准镜像，则使用mica脚本启动MICA：
   $ mica start /path/to/executable -d
   # 若没有mica脚本，则使用如下命令启动MICA：
   $ insmod /path/to/mcs_km.ko rmem_base=0x118000000 rmem_size=0x10000000
   # 启动MICA调试模式：
   $ /path/to/mica_main -c 3 -t /path/to/executable -a 0x118000000 -b /path/to/ap_boot -d
   ...
   MICA gdb proxy server: starting...
   GNU gdb (GDB) 12.1
   Copyright (C) 2022 Free Software Foundation, Inc.
   License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
   This is free software: you are free to change and redistribute it.
   There is NO WARRANTY, to the extent permitted by law.
   Type "show copying" and "show warranty" for details.
   This GDB was configured as "x86_64-openeuler-linux".
   ...
   MICA gdb proxy server: read for messages forwarding ...
   (gdb) 

此时，用户可以直接通过GDB命令行输入命令与Client OS进行交互。
如果用户想要通过GDB命令行像正常情况一样运行client OS，可以直接不设置断点，输入命令 ``continue`` 。

按下 ``ctrl-c`` 之后会返回GDB命令行，此时用户可以输入GDB命令与Client OS进行交互。
如果用户想要退出调试模式，必须在GDB命令行输入 ``quit`` 命令。之后，
MICA会退出与调试相关的模块，并保留pty application模块，以保持和Client OS通过pty交互的能力。
Uniproton会清除所有断点，并进入正常的运行状态。

.. note::

   当前Uniproton的GDB stub仅支持 ``break``， ``continue``， ``print`` 和 ``quit`` 四个命令。
   并不支持 ``ctrl-c``，所以按下后虽然会返回GDB命令行，但是Uniproton仍然在运行。


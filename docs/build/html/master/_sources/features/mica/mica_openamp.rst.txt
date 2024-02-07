.. _build_openamp_mica:

使用指导
########

在ARM64 QEMU上运行
******************

1. 制作 dtb

  部署 Client OS 需要在 Linux 的设备树中添加 ``mcs-remoteproc`` 设备节点，为 Client OS 预留出必要的保留内存。
  当前，可以通过 mcs 仓库提供的 `create_dtb.sh <https://gitee.com/openeuler/mcs/blob/master/tools/create_dtb.sh>`_ 脚本生成对应的 dtb：

  .. code-block:: console

     # create a dtb for qemu_cortex_a53
     $ ./create_dtb.sh qemu-a53

  成功执行后，会在当前目录下生成 ``qemu.dtb`` 文件，对应 QEMU 配置为：`2G RAM, 4 cores`。

2. 启动 QEMU

  .. note::

     下文的QEMU启动命令默认使能 ``virtio-net``，请先阅读 :ref:`QEMU 使用指导 <qemu_enable_net>` 了解如何开启网络。

  使用生成出来的 ``qemu.dtb``，按照以下命令启动 QEMU，注意，需要指定 `maxcpus=3` 为 Client OS 预留出 core 3，
  并且 `-m` 和 `-smp` 要与 dtb 的配置(2G RAM, 4 cores)保持一致，否则会启动失败：

  .. code-block:: console

     $ sudo qemu-system-aarch64 -M virt,gic-version=3 -cpu cortex-a53 -nographic \
         -device virtio-net-device,netdev=tap0 \
         -netdev tap,id=tap0,script=/etc/qemu-ifup \
         -m 2G -smp 4 \
         -append 'maxcpus=3' \
         -kernel zImage \
         -initrd openeuler-image-*.cpio.gz \
         -dtb qemu.dtb

3. 部署 Client OS

  调整内核打印等级：

  .. code-block:: console

     # 为了不影响shell的使用，先屏蔽内核打印：
     qemu-aarch64:~$ echo "1 4 1 7" > /proc/sys/kernel/printk

  运行 ``mica`` 程序，根据配置文件创建 client os：

  .. code-block:: console

     qemu-aarch64:~$ mica --help
     usage: mica [-h] {create,start,stop,status} ...

     Query or send control commands to the micad.

     positional arguments:
       {create,start,stop,status...}
                             the command to execute
         create              Create a new mica client
         start               Start a client
         stop                Stop a client
         status              query the mica client status
         ...

     options:
       -h, --help            show this help message and exit

  qemu 镜像中默认安装了一个配置文件样例：`/etc/mica/qemu-zephyr-rproc.conf` ，
  因此可以通过以下命令启动：``mica create /etc/mica/qemu-zephyr-rproc.conf``

  .. code-block:: console

     qemu-aarch64:~$ mica create /etc/mica/qemu-zephyr-rproc.conf
     Creating qemu-zephyr...
     Successfully created qemu-zephyr!
     starting qemu-zephyr...
     start qemu-zephyr successfully!

  由于在配置文件中指定了 AutoBoot，因此在创建时会自动拉起 qemu-zephyr 实例，拉起成功后，
  可以通过以下命令查看实例状态：``mica status``

  .. code-block:: console

     qemu-aarch64:~$ mica status
     Name                          Assigned CPU        State               Service
     qemu-zephyr                   3                   Running             rpmsg-tty1(/dev/ttyRPMSG0) rpmsg-tty(/dev/ttyRPMSG1)

  可以看到该实例关联的 CPU ID 为3，状态为 Running，并且为 Linux 提供了两个服务：rpmsg-tty 以及 rpmsg-tty1。
  rpmsg-tty 绑定了 zephyr 的 shell，因此我们可以通过打开对应的设备 ``/dev/ttyRPMSG1`` 来访问 zephyr 的 shell：

  .. code-block:: console

     # 打开 Client OS 的 shell
     qemu-aarch64:~$ screen /dev/ttyRPMSG1

     ... ...
     # 回车后可以连上 shell，并执行 zephyr 的 shell 命令

     uart:~$ kernel version
     Zephyr version 3.2.0

  之后，可以通过 ``Ctrl-a k`` 或 ``Ctrl-a Ctrl-k`` 组合键退出shell，参考 `screen(1) — Linux manual page <https://man7.org/linux/man-pages/man1/screen.1.html#DEFAULT_KEY_BINDINGS>`_ 。

____

在树莓派4B上运行
****************

oebuild 构建出来的 MCS 镜像已经通过 dt-overlay 等方式预留了相关资源，并且默认使用了支持 psci 的 uefi 引导固件。
因此只需要根据 :ref:`openeuler-image-uefi启动使用指导 <raspberrypi4-uefi-guide>` 进行镜像启动，再部署 MICA 即可，步骤跟QEMU类似。

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

首先，需要构建含有MICA的openEuler Embedded镜像，请参考 :ref:`基于OpenAMP的MICA镜像构建指南 <build_openamp_mica>` 。

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


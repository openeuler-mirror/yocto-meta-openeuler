基于 OpenAMP 的混合部署框架
###########################

构建指南
========

   .. seealso::

      目前支持 qemu-arm64, 树莓派4B, Hi3093, ok3568, x86工控机。推荐使用 oebuild 快速构建包含混合部署功能的 MCS 镜像，参考 :ref:`openEuler Embedded MCS镜像构建指导 <mcs_build>`。

      若需要单独构建混合部署的组件，请参考 `mcs 构建安装指导 <https://gitee.com/openeuler/mcs#%E6%9E%84%E5%BB%BA%E5%AE%89%E8%A3%85%E6%8C%87%E5%AF%BC>`_ 。
      注意，x86仅支持 UniProton，需要切换到 `uniproton_dev 分支 <https://gitee.com/openeuler/mcs/tree/uniproton_dev/>`_ 。

____

在ARM64 QEMU上运行
==================

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

  调整内核打印等级并插入内核模块：

  .. code-block:: console

     # 为了不影响shell的使用，先屏蔽内核打印：
     $ echo "1 4 1 7" > /proc/sys/kernel/printk

     # 插入内核模块
     $ modprobe mcs_km

  插入内核模块后，可以通过 `cat /proc/iomem` 查看预留出来的 mcs_mem。
  若 mcs_km.ko 插入失败，可以通过 dmesg 看到对应的失败日志，可能的原因有：1.使用的交叉工具链与内核版本不匹配；2.未预留内存资源

  运行mica_main程序，启动 client os：

  .. code-block:: console

     $ mica_main -c [cpu_id] -t [target_binfile] -a [target_binaddress]
     eg:
     $ mica_main -c 3 -t /lib/firmware/qemu-zephyr-image.bin -a 0x7a000000

  若mica_main成功运行，会有如下打印：

  .. code-block:: console

     $ mica_main -c 3 -t /lib/firmware/qemu-zephyr-image.bin -a 0x7a000000
     ...
     start client os
     ...
     pls open /dev/pts/0 to talk with client OS
     pty_thread for uart is runnning
     ...

  此时， **按ctrl-c可以通知client os下线并退出mica_main** ，下线后支持重复拉起。
  也可以根据打印提示（ ``pls open /dev/pts/0 to talk with client OS`` ），
  通过 /dev/pts/0 与 client os 进行 shell 交互，例如：

  .. code-block:: console

     # 通过 SSH 登录 QEMU
     $ ssh root@192.168.10.8

     ... ...

     # 打开 Client OS 的 shell
     qemu-aarch64:~$ screen /dev/pts/0

     ... ...

     uart:~$ kernel version
     Zephyr version 3.2.0

  可以通过 ``Ctrl-a k`` 或 ``Ctrl-a Ctrl-k`` 组合键退出shell，参考 `screen(1) — Linux manual page <https://man7.org/linux/man-pages/man1/screen.1.html#DEFAULT_KEY_BINDINGS>`_ 。

____

在树莓派4B上运行
================

  oebuild 构建出来的 MCS 镜像已经通过 dt-overlay 等方式预留了相关资源，并且默认使用了支持 psci 的 uefi 引导固件。
  因此只需要根据 :ref:`openeuler-image-uefi启动使用指导 <raspberrypi4-uefi-guide>` 进行镜像启动，再部署mcs即可，步骤跟QEMU类似：

  .. code-block:: console

     # 调整内核打印等级
     $ echo "1 4 1 7" > /proc/sys/kernel/printk

     # 插入内核模块
     $ modprobe mcs_km

     # 运行mica_main程序，启动 client os：
     $ mica_main -c 3 -t /lib/firmware/rpi4-zephyr-image.bin -a 0x7a000000

     # 若mica_main成功运行，会有如下打印：
     ...
     start client os
     ...
     pls open /dev/pts/0 to talk with client OS
     pty_thread for uart is runnning
     ...

     # 此时， **按ctrl-c可以通知client os下线并退出mica_main** ，下线后支持重复拉起。
     # 也可以根据打印提示（ ``pls open /dev/pts/0 to talk with client OS`` ），
     # 通过 /dev/pts/0 与 client os 进行 shell 交互，例如：

     # 通过 SSH 登录树莓派
     $ ssh root@192.168.10.8

     ... ...

     # 打开 Client OS 的 shell
     qemu-aarch64:~$ screen /dev/pts/0

     ... ...

     uart:~$ kernel version
     Zephyr version 3.2.0

     # 可以通过 <Ctrl-a k> 或 <Ctrl-a Ctrl-k> 组合键退出shell，具体请参考 screen 的 manual page

____

在Hi3093上运行
==============

  Hi3093 需要在 uboot 中添加启动参数 ``maxcpus=3`` 预留出一个 cpu 跑 UniProton：

  .. code-block:: console

     # 使用在ctrl+b进入uboot，限制启动的cpu数量
     setenv bootargs "${bootargs} maxcpus=3"

  部署mcs的步骤跟QEMU类似，UniProton作为Client OS：

  .. code-block:: console

     # 调整内核打印等级
     $ echo "1 4 1 7" > /proc/sys/kernel/printk

     # 插入内核模块
     $ modprobe mcs_km

     # 运行mica_main程序，启动 client os：
     $ mica_main -c 3 -t /firmware/hi3093_ut.bin -a 0x93000000 &

     # 若mica_main成功运行，会有如下打印：
     ...
     start client os
     ...
     pls open /dev/pts/1 to talk with client OS
     pty_thread for console is runnning
     ...

     # 根据打印提示（ ``pls open /dev/pts/0 to talk with client OS`` ），
     # 通过 /dev/pts/1 查看 UniProton 的串口输出，例如：
     qemu-aarch64:~$ screen /dev/pts/1

     # 敲回车后，可以查看uniproton输出信息
     # 可以通过 <Ctrl-a k> 或 <Ctrl-a Ctrl-k> 组合键退出console，具体请参考 screen 的 manual page

____

在ok3568上运行
==============

  ok3568支持通过mcs拉起 RT-Thread，步骤如下：

  .. code-block:: console

     # 调整内核打印等级
     $ echo "1 4 1 7" > /proc/sys/kernel/printk

     # 插入内核模块
     $ modprobe mcs_km

     # 运行mica_main程序，启动 client os：
     $ mica_main -c 3 -t /firmware/rtthread-ok3568.bin -a 0x7a000000

     # 若mica_main成功运行，会有如下打印：
     ...
     start client os
     ...

     # ok3568支持通过输入功能编号进行交互、下线、重新拉起:
     # 输入h查看用法
       h
       please input number:<1-8>
       1. test echo
       2. send matrix
       3. start pty
       4. close pty
       5. shutdown clientOS
       6. start clientOS
       7. test ping
       8. test flood-ping
       9. exit

----------

在HVAEIPC-M10 (x86工控机) 上运行
=================================

  当前x86工控机只支持运行UniProton。
  首先，我们需要先构建运行在x86工控机上的openEuler Embedded，参考 :ref:`openEuler Embedded x86工控机镜像构建和安装指导 <hvaepic-m10>`。
  
  之后，我们还需要编译Uniproton以及x86环境下需要的额外启动程序ap_boot，
  参考 `openEuler Embedded & Uniproton x86 MICA环境安装指导 <https://gitee.com/openeuler/UniProton/blob/master/doc/demoUsageGuide/x86_64_demo_usage_guide.md>`_ 。
  
  我们需要单独构建mica_main以及mcs_km.ko，
  参考 `mcs 构建安装指导 <https://gitee.com/openeuler/mcs#%E6%9E%84%E5%BB%BA%E5%AE%89%E8%A3%85%E6%8C%87%E5%AF%BC>`_ 。
  或者，也可以使用oebuild，参考 :ref:`openEuler Embedded MCS镜像构建指导 <mcs_build>` ，
  只是在构建的时候只单独构建mica_main以及mcs_km.ko，而非包含这两者的openEuler Embedded镜像：

  .. code-block:: console
   
    # 启动构建容器
    $ oebuild bitbake
    # 构建mica_main
    $ bitbake mcs-linux
    # 构建mcs_km.ko
    $ bitbake mcs-km

  这种方式构建出来的二进制文件在当前构建目录的 ``tmp/work`` 目录下。
  mica_main的路径在 ``tmp/work/x86_64-openeuler-linux/mcs-linux/1.0-r0/image/usr/bin/mica_main`` 。
  mcs_km.ko的路径在 ``tmp/work/generic_x86_64-openeuler-linux/mcs-km/0.0.1-r0/image/lib/modules/5.10.0-openeuler/extra/mcs_km.ko`` 。

  在启动openEuler Embedded前，通过修改启动盘的启动分区的grub.cfg文件，
  为Client OS预留出一个CPU以及内存资源。
  将镜像启动分区挂载到 /mnt 目录下，然后修改 /mnt/efi/boot/grub.cfg 文件，
  在 ``menuentry 'boot'`` 中添加 ``maxcpus=3`` 和 ``mem=12G`` 参数。

  .. code-block:: console

    $ sudo mount /dev/sda1 /mnt
    $ sudo vim /mnt/efi/boot/grub.cfg
    $ sudo umount /mnt
  
  x86工控机是4核心CPU，我们希望预留1个CPU用来运行Uniproton。
  当我们成功在x86工控机上启动openEuler Embedded以后，
  可以通过以下命令查看当前CPU和内存的使用情况：

  .. code-block:: console

    # 查看CPU核心数
    $ nproc
    3
    # 查看内存使用情况
    $ free -h
                  total        used        free      shared  buff/cache   available
      Mem:        9.9Gi       158Mi        9.8Gi       728Ki       45Mi        9.7Gi

  这说明当前系统正在使用3个CPU，已经预留出了一个CPU。系统总共可用的内存容量为9.9Gi，可以说明我们已经限制了Linux使用的内存容量。
  这里之所以不是12Gi是因为其他的一些内存使用比如内核预留的一些空间并不会展示在这里。

  接下来，我们通过在openEuler Embedded上运行如下命令启动MICA：

  .. code-block:: console

     # 调整内核打印等级
     $ echo "1 4 1 7" > /proc/sys/kernel/printk

     # 此demo使用标准openEuler Embedded镜像，所以我们单独编译了一个mcs_km.ko
     # 使用insmod而非modprobe命令插入
     # 8GB内存环境：
     $ insmod /path/to/mcs_km.ko load_addr=0x1c0000000
     # 16GB内存环境：
     $ insmod /path/to/mcs_km.ko load_addr=0x400000000

     # 运行mica_main程序，启动 client os (8GB内存环境)：
     $ mica_main -c 3 -t /path/to/uniproton-x86.bin -a 0x1c0000000 -b /path/to/ap_boot
     # 16GB内存环境：
     $ mica_main -c 3 -t /path/to/uniproton-x86.bin -a 0x400000000

     ...
     start client os
     ...
     pls open /dev/pts/1 to talk with client OS
     pty_thread for console is runnning
     ...
     found matched endpoint, creating console with id:2 in host os

     # 根据打印提示（ ``found matched endpoint, creating console with id:2 in host os`` ），
     # 说明成功创建了console，可以通过 /dev/pts/1 查看 UniProton 的串口输出，例如：
     $ screen /dev/pts/1

     # 敲回车后，可以查看uniproton输出信息
     # 可以通过 <Ctrl-a k> 或 <Ctrl-a Ctrl-k> 组合键退出console，具体请参考 screen 的 manual page

     
基于 Jailhouse 的混合部署框架
*****************************

当前 openEuler Embedded 支持 Jailhouse 上的混合部署，可以通过 Root-cell (Linux) 拉起 Non-root-cell (RTOS)，并允许两端通过 RPMSG 相互通信。

引入 Jailhouse 虚拟化层，能够实现多个OS之间的强隔离与保护，并且能够将 MICA（混合关键性系统）和具体的架构独立开，MICA 关注上层的消息服务，
包括生命周期管理、tty服务等，而架构相关的适配，交由虚拟化层实现，解决不同架构的适配问题。

____

构建说明
========

   .. seealso::

      目前仅支持 ``arm64(aarch64) qemu``，参考 :ref:`openEuler Embedded MCS镜像构建指导 <mcs_build>`。

      对于 `Jailhouse`，请注意修改 oebuild 的编译配置文件 ``compile.yaml``，把 MCS_FEATURES 中的 openamp 改成 jailhouse。

____

如何在ARM64 QEMU上运行
======================

1. 制作 dtb

  部署 Client OS 需要在 Linux 的设备树中添加 ``mcs-remoteproc`` 设备节点，为 Client OS 预留出必要的保留内存。
  当前，可以通过 mcs 仓库提供的 `create_dtb.sh <https://gitee.com/openeuler/mcs/blob/master/tools/create_dtb.sh>`_ 脚本生成对应的 dtb：

  .. code-block:: console

     # create a dtb for qemu_cortex_a53 to support jailhouse
     $ ./create_dtb.sh qemu-a53 -f jailhouse

  成功执行后，会在当前目录下生成 ``qemu-jailhouse.dtb`` 文件，对应 QEMU 配置为：`2G RAM, 4 cores`。

2. 启动 QEMU

  .. note::

     下文的QEMU启动命令默认使能 ``virtio-net``，请先阅读 :ref:`QEMU 使用指导 <qemu_enable_net>` 了解如何开启网络。

  | 使用生成出来的 ``qemu-jailhouse.dtb``，按照以下命令启动 QEMU，注意：
  |  1. `-m` 和 `-smp` 要与 dtb 的配置(2G RAM, 4 cores)保持一致，否则会启动失败。
  |  2. 启动 Jailhouse 需要指定 psci method 为 smc，因此，`-M` 需要配置为 ``virt,gic-version=3,virtualization=on,its=off``。
  |  3. 需要通过添加启动参数 ``mem=780M`` 来预留出 Jailhouse 和 Non-root-cell 的内存。

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

  使用 ``mica start { CLIENT }`` 启动 Client OS，目前在 MCS 镜像中安装了可用的 ``qemu-zephyr-ivshmem.elf``：

  .. code-block:: console

     qemu-aarch64:~$ mica start qemu-zephyr-ivshmem.elf --mode virt
     Starting qemu-zephyr-ivshmem.elf on CPU3
     Please open /dev/ttyRPMSG0 to talk with client OS

4. 打开 Client OS 的 shell

  启动后，Linux 的串口停止接收输入，使用 SSH 打开第二个shell，并通过 screen 接入 Client OS 的 shell：

  .. code-block:: console

     # 通过 SSH 登录 QEMU
     $ ssh root@192.168.10.8

     ... ...

     # 打开 Client OS 的 shell
     qemu-aarch64:~$ screen /dev/ttyRPMSG0

     ... ...

     uart:~$ kernel uptime
     Uptime: 8963940 ms
     uart:~$ kernel version
     Zephyr version 3.2.0

  可以通过 ``Ctrl-a k`` 或 ``Ctrl-a Ctrl-k`` 组合键退出shell，参考 `screen(1) — Linux manual page <https://man7.org/linux/man-pages/man1/screen.1.html#DEFAULT_KEY_BINDINGS>`_ 。


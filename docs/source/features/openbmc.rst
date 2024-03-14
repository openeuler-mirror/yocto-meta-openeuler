.. _obmc_image_intro:

OpenBMC 镜像构建和使用
####################################

构建OpenBMC镜像
====================================

首先，在生成构建目录的时候，需要指定 `-f openeuler-obmc` 选项，这样才能在local.conf中包含构建OpenBMC镜像所需的配置。

当前仅支持QEMU平台，因此可以不需要指定 `-p` 参数。生成构建目录时，会自动选择 `qemu-aarch64` 作为构建目标。

进入构建目录后，执行 `oebuild bitbake` 命令，进入构建容器，然后执行 `bitbake openeuler-image-obmc` 命令，开始构建OpenBMC镜像。

构建成功后，产物里会有 `zImage` 和 `rootfs.cpio.gz`，分别是内核压缩镜像和临时根文件系统。

在QEMU中启动OpenBMC镜像
=====================================

可以使用以下命令：

.. code-block:: console

    $ sudo qemu-system-aarch64 -M virt,gic-version=3 -m 1G -cpu cortex-a53 \
    -nographic -smp 4 -kernel zImage -dtb qemu_mcs.dtb \
    -netdev bridge,br=br_qemu,id=net0 -device virtio-net-pci,netdev=net0 \
    -initrd openeuler-image-obmc-qemu-aarch64-20240304073931.rootfs.cpio.gz

其中，`zImage` 和 `rootfs.cpio.gz` 分别是构建OpenBMC镜像产物中的内核压缩镜像和临时根文件系统。
`-M` 是指定QEMU使用的模拟硬件环境，比如GIC版本等。
`-m` 是指定虚拟机内存大小，
`-cpu` 是指定虚拟机CPU型号，
`-nographic` 是指定不使用图形界面，
`-smp` 是指定虚拟机CPU核数，
`-kernel` 是指定内核压缩镜像，
`-dtb` 是指定设备树文件，
`-netdev` 是指定网络设备，
`-device` 是指定网络设备类型，
`-initrd` 是指定临时根文件系统。

启动后，以root用户身份登录，并执行如下命令，查看bmcweb服务的情况：

.. code-block:: console

    $ systemctl status bmcweb

如果状态显示running，说明服务正常启动。

如果希望访问该服务，可以访问此虚拟机的443端口，比如：

.. code-block:: console

    $ wget https://192.168.122.11 --no-check-certificate

测试启动时长
=====================================

本镜像内置 `systemd-analyze`，可以用于详细分析系统的启动时间长度。

.. code-block:: console

    $ systemd-analyze time

会详细的打印出内核和用户空间启动分别对应的时间长度，以及总的启动时间长度。

.. code-block:: console

    $ systemd-analyze blame

会详细的打印出各个服务的启动时间长度，因此查看是哪个服务影响了系统的启动时间长度。
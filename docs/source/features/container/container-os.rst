.. _container_os:

Container OS镜像
########################################

openeuler-container-os镜像简介
=============================================

当前openEuler Embedded提供了一个专门的Container OS镜像，该镜像专为运行容器而制作，
因此系统底噪较小。生成的zImage的大小约2.9M，rootfs.cpio.gz的大小约为27M（无systemd），
或者36M（有systemd）。
此镜像会集成iSula容器引擎，以及openEuler服务器版本的容器镜像。
用户在启动此镜像并登录进入root用户以后，系统会自动启动openEuler服务器版本的容器，
并进入交互界面。

构建和运行openeuler-container-os镜像 
`参考视频 <https://www.bilibili.com/video/BV1D6421375S/?spm_id_from=333.999.0.0&vd_source=27f310e89750ee568b19dbff5d1406f1>`_ 。

运行openeuler-container-os镜像
===============================================

由于openeuler-container-os镜像中含有容器镜像，因此rootfs解压后的体积约300M，超过了init ramfs的最大限制，
因此，构建生成了一个wic.bz2文件，用户解压后，可以得到一个只有ext4格式文件系统的磁盘镜像文件。
所以，运行的命令会稍有不同：

.. code-block:: console

    $ sudo qemu-system-aarch64 -M virt,gic-version=3 -m 1G -cpu cortex-a53 \
      -nographic -smp 4 -kernel zImage -dtb qemu_mcs.dtb -netdev bridge,br=br_qemu,id=net0 \
      -device virtio-net-pci,netdev=net0 \
      -drive file=openeuler-container-os-qemu-aarch64-20240207150042.rootfs.wic,format=raw \
      -append 'root=/dev/vda1 rootfstype=ext4 rw rootwait'

上述命令中，使用了 ``-netdev`` 和 ``-device`` 参数，
将openEuler Embedded镜像中的网卡设备连接到了宿主机的网桥上。
这样，openEuler Embedded镜像就可以通过宿主机的网桥访问外网了。
``-dtb`` 参数指定了openEuler Embedded镜像中的设备树文件，具体dtb可以通过 ``-machine dumpdtb=qemu.dtb`` 命令获取。
如果用户有其他额外的硬件需求，可以使用如下命令将dtb文件转换为可编辑的dts文件：

.. code-block:: console

    $ dtc -I dtb -O dts qemu.dtb -o qemu.dts

之后，可以根据自己的需求修改qemu.dts文件，最后再通过如下命令将其转换为dtb文件后使用：

.. code-block:: console

    $ dtc -I dts -O dtb qemu.dts -o qemu.dtb

``-nographic`` 参数表示不使用图形界面，而是使用串口终端。
``-smp`` 参数指定了openEuler Embedded镜像中的CPU个数。
``-m`` 参数指定了openEuler Embedded镜像中的内存大小
``-drive`` 参数指定了openEuler Embedded镜像的磁盘文件。
``-append`` 参数指定了openEuler Embedded镜像的内核启动参数。由于此磁盘镜像文件
是一个只有ext4格式文件系统的磁盘镜像文件，因此 ``root`` 参数指定了 ``/dev/vda1``，
表示根文件系统在第一个分区，
``rootfstype`` 参数指定了 ``ext4``， ``rw`` 表示读写权限， ``rootwait`` 表示等待根文件系统准备好。
``-kernel`` 参数指定了openEuler Embedded镜像中的内核文件。

如果用户希望可以访问互联网，除了使用 ``-netdev`` 和 ``-device`` 参数将openEuler Embedded镜像中的网卡设备连接到宿主机的网桥上，
还需要在宿主机中配置网桥以及iptables转发规则，并且需要在openEuler Embedded镜像中配置网卡的IP地址和默认网关。
具体的QEMU NAT模式配置，参见 :ref:`qemu_internet_nat`。

openeuler-container-os镜像启动后，会以root身份自动启动iSula daemon服务端.
在用户以root身份登录进入系统后，如果是第一次启动系统，会加载openEuler服务器版本的容器镜像，
并创建对应版本的容器。之后每次启动系统，都会自动启动并进入已经创建好的容器。

使用openEuler服务器版本镜像
======================================

执行如下命令，拉取openEuler服务器版本镜像：

.. code-block:: console

    # 拉取openEuler 23.09版本镜像
    $ isula pull openeuler/openeuler:23.09
    # -net=host 表示使用宿主机的网络
    $ isula run -it -net=host openeuler/openeuler:23.09 sh

此时，我们已经运行一个容器镜像，并能通过命令行与之交互。
服务器版本镜像默认含有dnf包管理工具，我们可以通过dnf安装一些软件包。
比如，我们可以通过如下命令安装ping命令：

.. code-block:: console

    sh-5.2# dnf install iputils

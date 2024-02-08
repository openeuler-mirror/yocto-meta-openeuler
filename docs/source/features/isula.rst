.. _isula_intro:

iSula容器引擎与container os镜像
########################################

iSula简介
==========

iSula是openEuler社区开发的容器引擎，它是一个轻量级的容器引擎，支持容器的创建、启动、停止、删除、暂停、恢复、查看、导入、导出、镜像管理等功能。

openEuler Embedded在构建时集成了iSula容器引擎，用户可以通过iSula容器引擎来管理容器。
当前iSula容器引擎的默认容器运行时为lcr，也支持runc和kata-runtime。
支持的容器镜像格式为OCI和external rootfs。

iSula有两种容器管理操作接口：CLI和CRI。
CLI采用命令行方式，是标准的C/S架构模式，将iSulad作为daemon服务端，iSula作为独立的客户端命令，供用户使用。
CRI是由K8S对外提供的容器和镜像服务接口，供容器引擎接入K8S使用。

当前，openEuler Embedded支持iSula容器引擎的CLI接口。之后会支持CRI接口，并与KubeEdge等容器管理工具进行集成。

openeuler-container-os镜像简介
=============================================

当前openEuler Embedded提供了一个专门的container OS镜像，该镜像专为运行容器而制作，
因此系统底噪较小。生成的zImage的大小约2.9M，rootfs.cpio.gz的大小约为27M（无systemd），
或者36M（有systemd）。
此镜像会集成iSula容器引擎，以及openEuler服务器版本的容器镜像。
用户在启动此镜像并登录进入root用户以后，系统会自动启动openEuler服务器版本的容器，
并进入交互界面。

构建和运行openeuler-container-os镜像 `参考视频 <https://www.bilibili.com/video/BV1D6421375S/?spm_id_from=333.999.0.0&vd_source=27f310e89750ee568b19dbff5d1406f1>`_ 。

构建带有iSula的openEuler Embedded镜像
=========================================

当前openEuler Embedded标准镜像中已经集成了iSula容器引擎。
只需要构建一个标准的openEuler Embedded镜像即可。
具体的构建过程，参见 :ref:`oebuild_usage`。

构建openeuler-container-os的过程和标准的openEuler Embedded镜像类似，
不同之处仅仅在于，在构建镜像中需要输入如下命令而非 ``bitbake openeuler-image`` ：

.. code-block:: console

    $ bitbake openeuler-container-os

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

手动启动iSula daemon服务端
======================================

如果是标准的openEuler Embedded镜像，默认不会自动启动iSulad。用户可以手动启动iSula daemon服务端。

首先，进入openEuler Embedded镜像后，我们需要为iSula daemon服务端配置镜像源。
打开 ``/etc/isulad/daemon.json`` 文件，并在 ``registry-mirrors`` 字段中添加镜像源地址。
我们可以添加 ``"docker.io"``。

之后，运行如下命令启动iSula daemon服务端：

.. code-block:: console

    # 将isula daemon服务端作为后台进程启动
    $ isulad &
    ...
    ...
    isulad 20240131074734.534 - iSulad successfully booted in 0.120 s

如果启动成功，会有相应的日志信息输出到串口终端上。

如果用户在生成构建目录的时候，特性里选择了 ``systemd`` ，那么在启动openEuler Embedded镜像后，
可以使用如下命令启动iSula daemon服务端：

.. code-block:: console

    # 启动iSula daemon服务端
    $ systemctl start isulad

iSula容器引擎使用简介
======================================

本文档仅记载一些简单的操作，更具体的参数命令和操作，
请参见iSula容器引擎的 `官方文档 <https://docs.openeuler.org/zh/docs/23.09/docs/Container/iSula容器引擎.html>`_ 。

**拉取一个镜像**

.. code-block:: console

    # 拉取一个镜像
    $ isula pull busybox

此命令从daemon.json中配置的镜像源地址拉取busybox镜像。

**查看本地镜像列表**

.. code-block:: console

    # 查看镜像列表
    $ isula images
    REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
    busybox             latest              59788edf1f3e        2 weeks ago         1.22MB

**运行容器**

.. code-block:: console

    # 运行一个容器
    $ isula run -it busybox sh
    / #

成功运行后，我们可以通过命令行与容器进行交互。

如果想要退出容器，可以在命令行输入 ``exit`` 命令。

**创建一个容器**

.. code-block:: console

    # 创建一个容器
    $ isula create -it busybox sh

上述命令以交互模式创建了一个容器，并且分配了伪终端，但是没有运行。

如果用户希望启动并接入已有的容器，可以使用如下的两条命令：

**启动一个容器**

.. code-block:: console

    # 启动一个容器
    $ isula start <container_id>

**进入容器交互界面（接入容器）**

.. code-block:: console

    # 进入容器交互界面
    $ isula attach <container_id>

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

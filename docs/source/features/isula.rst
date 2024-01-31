.. _isula_intro:

iSula容器引擎使用方法
############################

iSula是openEuler社区开发的容器引擎，它是一个轻量级的容器引擎，支持容器的创建、启动、停止、删除、暂停、恢复、查看、导入、导出、镜像管理等功能。

openEuler Embedded在构建时集成了iSula容器引擎，用户可以通过iSula容器引擎来管理容器。
当前iSula容器引擎的默认容器运行时为lcr，也支持runc和kata-runtime。
支持的容器镜像格式为OCI和external rootfs。

iSula有两种容器管理操作接口：CLI和CRI。
CLI采用命令行方式，是标准的C/S架构模式，将iSulad作为daemon服务端，iSula作为独立的客户端命令，供用户使用。
CRI是由K8S对外提供的容器和镜像服务接口，供容器引擎接入K8S使用。

当前，openEuler Embedded支持iSula容器引擎的CLI接口。接下来会讲解具体的构建流程，以及如何使用iSula容器引擎。

构建带有iSula的openEuler Embedded镜像
=========================================

当前openEuler Embedded标准镜像中已经集成了iSula容器引擎。
但是，如果在使用oebuild生成构建目录的时候没有加上 ``-f systemd``，则无法正常运行容器，
因为iSula需要依赖cgroup的配置信息。
解决方法是，用户需要在启动的时候，手动挂载cgroup的配置信息。
具体的命令如下：

.. code-block:: console

    $ mount -t tmpfs tmpfs /sys/fs/cgroup/
    $ mkdir -p /sys/fs/cgroup/cpu
    $ mount -t cgroup -o cpu cpu /sys/fs/cgroup/cpu
    $ mkdir -p /sys/fs/cgroup/devices
    $ mount -t cgroup -o devices devices /sys/fs/cgroup/devices
    $ mkdir -p /sys/fs/cgroup/freezer
    $ mount -t cgroup -o freezer freezer /sys/fs/cgroup/freezer
    $ mkdir -p /sys/fs/cgroup/cpuset
    $ mount -t cgroup -o cpuset cpuset /sys/fs/cgroup/cpuset
    $ mkdir -p /sys/fs/cgroup/memory
    $ mount -t cgroup -o memory memory /sys/fs/cgroup/memory
    $ echo 1 > /sys/fs/cgroup/memory/memory.use_hierarchy
    $ mkdir -p /sys/fs/cgroup/hugetlb
    $ mount -t cgroup -o hugetlb hugetlb /sys/fs/cgroup/hugetlb
    $ mkdir -p /sys/fs/cgroup/blkio
    $ mount -t cgroup -o blkio blkio /sys/fs/cgroup/blkio

其他的构建过程，参见 :ref:`openeuler_embedded_oebuild`。

当我们已经有了一个openEuler Embedded镜像后，就可以使用iSula容器引擎了。
以qemu-aarch64为例，我们可以使用如下命令启动openEuler Embedded镜像：

.. code-block:: console

    $ sudo qemu-system-aarch64 -M virt,gic-version=3 -m 1G -cpu cortex-a53 \
    -nographic -smp 4 -kernel zImage -dtb qemu.dtb \
    -netdev bridge,br=br_qemu,id=net0 -device virtio-net-pci,netdev=net0 \
    -initrd rootfs.cpio.gz

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
``-initrd`` 参数指定了openEuler Embedded镜像中的根文件系统。
``-kernel`` 参数指定了openEuler Embedded镜像中的内核文件。
具体的QEMU NAT模式配置，参见 :ref:`qemu_internet_nat`。

进入openEuler Embedded镜像后，首先我们需要为iSula daemon服务端配置镜像源。
打开 ``/etc/isulad/daemon.json`` 文件，并在 ``registry-mirrors`` 字段中添加镜像源地址。
我们可以添加 ``"docker.io"``。

之后，运行如下命令启动iSula daemon服务端：

.. code-block:: console

    # 将isula daemon服务端作为后台进程启动
    $ isulad &
    isulad 20240131074734.534 - iSulad successfully booted in 0.120 s

如果启动成功，会有相应的日志信息输出到串口终端上。

接下来，我们就可以使用iSula容器引擎了。首先，我们需要拉取一个镜像。

.. code-block:: console

    # 拉取一个镜像
    $ isula pull busybox

拉取成功后，我们可以查看镜像列表。

.. code-block:: console

    # 查看镜像列表
    $ isula images
    REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
    busybox             latest              59788edf1f3e        2 weeks ago         1.22MB

接下来，我们可以运行一个容器。

.. code-block:: console

    # 运行一个容器
    $ isula run -it busybox sh
    / #

成功运行后，我们可以通过命令行与容器进行交互。

如果想要退出容器，可以在命令行输入 ``exit`` 命令。

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
    sh-5.2# ping www.baidu.com

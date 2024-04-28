iSula容器引擎及使用方法
###############################################

iSula简介
==========

iSula是openEuler社区开发的容器引擎，它是一个轻量级的容器引擎，支持容器的创建、启动、停止、删除、暂停、恢复、查看、导入、导出、镜像管理等功能。

openEuler Embedded在构建时集成了iSula容器引擎，用户可以通过iSula容器引擎来管理容器。
当前iSula容器引擎的默认容器运行时为lcr，也支持runc和kata-runtime。
支持的容器镜像格式为OCI镜像，Docker镜像和external rootfs。

iSula有两种容器管理操作接口：CLI和CRI。
CLI采用命令行方式，是标准的C/S架构模式，将iSulad作为daemon服务端，iSula作为独立的客户端命令，供用户使用。
CRI是由K8S对外提供的容器和镜像服务接口，供容器引擎接入K8S使用。

当前，openEuler Embedded支持iSula容器引擎的CLI接口。之后会支持CRI接口，并与KubeEdge等容器管理工具进行集成。

构建带有iSula的openEuler Embedded镜像
=========================================

当前openEuler Embedded标准镜像中已经集成了iSula容器引擎。
只需要构建一个标准的openEuler Embedded镜像即可。
具体的构建过程，参见 :ref:`oebuild_usage`。

构建openeuler-container-os的过程和标准的openEuler Embedded镜像类似，
不同之处仅仅在于，在构建镜像中需要输入如下命令而非 ``bitbake openeuler-image`` ：

.. code-block:: console

    $ bitbake openeuler-container-os

手动启动iSula daemon
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



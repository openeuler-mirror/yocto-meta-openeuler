openEuler Embedded OCI 镜像构建和使用
################################################################################

简介
=================

随着容器技术的不断发展和普及，越来越多的场景下会使用容器技术运行相关的操作系统。
openEuler Embedded作为一个开源的操作系统，也需要提供相应的容器镜像，
以便用户能够方便地使用和体验。
考虑到用户体验的方便性，当前提供的OCI镜像是最小镜像，体积仅为8M。
如果用户有自定义的需要，可以基于此镜像做进一步的修改。

构建OCI镜像
===========================

构建目录不需要有任何特殊的feature，只需要创建对应架构的构建目录即可。
具体的构建过程，参见 :ref:`oebuild_usage`。

进入构建目录并输入 `oebuild bitbake` 进入容器后，执行如下命令构建OCI镜像：

.. code-block:: shell

    $ bitbake openeuler-oci-image

构建完成后，在 `output/<timestamp>` 目录下会有 `tar.bz2` 结尾的文件，
这个文件是openEuler Embedded的文件系统，
用于接下来构建OCI镜像使用。同时，目录下还有一个 `Dockerfile` 文件，
用于通过 `docker build` 构建OCI镜像。 

在容器中运行容器需要原本的容器有特权权限，但是这是一件比较危险的事情。同时，
容器内运行容器需要额外将容器运行的资源挂载到容器内，这样会增加很多的复杂性。
因此，当前的构建镜像不提供容器内直接通过docker生成容器镜像的功能，
而是提供了一个 `Dockerfile` ，用户可以在构建容器之外的环境构建镜像。
我们假设用户用来构建的机器上已经安装了docker并且docker服务已经启动。
接下来，用户可以在 `output/<timestamp>` 目录下输入如下命令构建OCI镜像：

.. code-block:: shell

    $ docker build -t openeuler-oci-image:latest -f Dockerfile .
    $ docker save -o openeuler-oci-image.tar openeuler-oci-image:latest

构建完成后，用户可以将导出的镜像文件 `openeuler-oci-image.tar` 分发给其他用户。

使用OCI镜像
===========================

用户可以输入如下命令加载镜像：

.. code-block:: shell

    $ docker load -i openeuler-oci-image.tar

加载完成后，用户可以通过如下命令进入容器：

.. code-block:: shell

    $ docker run -it openeuler-oci-image:latest /bin/bash

进入镜像后，用户还可以通过如下命令查看镜像的详细信息：

.. code-block:: shell

    $ cat /etc/os-release
    ID=openeuler
    NAME="openEuler Embedded(openEuler Embedded Reference Distro)"
    VERSION="24.03-LTS (openEuler24_03-LTS)"
    VERSION_ID=24.03-lts
    PRETTY_NAME="openEuler Embedded(openEuler Embedded Reference Distro) 24.03-LTS (openEuler24_03-LTS)"
    DISTRO_CODENAME="openEuler24_03-LTS"


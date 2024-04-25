openEuler Embedded Docker镜像构建和使用
################################################################################

简介
=================

随着容器技术的不断发展和普及，越来越多的场景下会使用容器技术运行操作系统。
openEuler Embedded作为一个开源的操作系统，也需要提供相应的容器镜像，
以便用户能够方便地使用和体验。当前最普及的容器引擎是Docker，
openEuler社区的容器引擎iSula在使用“load”命令加载镜像的时候也仅支持Docker镜像，
因此，考虑到用户体验的方便性，当前提供的容器镜像格式为Docker镜像。
同时，考虑到用户机器的资源限制，我们构建的容器镜像是openEuler Embedded最小镜像，
体积仅为8.2M。如果用户有自定义的需要，可以基于此镜像做进一步的修改。

构建Docker镜像
===========================

构建目录不需要有任何特殊的feature，只需要创建对应架构的构建目录即可。
具体的构建过程，参见 :ref:`oebuild_usage`。

进入构建目录并输入 `oebuild bitbake` 进入容器后，执行如下命令构建Docker镜像：

.. code-block:: shell

    $ bitbake openeuler-docker-image

构建完成后，在 `output/<timestamp>` 
目录下会有 `openeuler-docker-image.tar` 结尾的文件，
这个文件就是openEuler Embedded的Docker镜像，只是以tar格式存档。
用户可以将此文件分发给其他用户使用。

使用openEuler Embedded Docker镜像
==============================================================

openEuler Embedded Docker镜像可以被docker和isula加载并使用。
下面以isula为例讲解使用方法。

首先，用户先讲openeuler-docker-image.tar文件拷贝到目标机器上，
接着用户可以输入如下命令加载镜像：

.. code-block:: shell

    $ isula load -i openeuler-docker-image.tar

加载完成后，用户可以通过如下命令创建一个新容器并进入容器命令行进行交互：

.. code-block:: shell

    $ isula run -it openeuler-docker-image:latest /bin/bash

进入镜像后，用户可以通过如下命令查看镜像的详细信息：

.. code-block:: shell

    $ cat /etc/os-release
    ID=openeuler
    NAME="openEuler Embedded(openEuler Embedded Reference Distro)"
    VERSION="24.03-LTS (openEuler24_03-LTS)"
    VERSION_ID=24.03-lts
    PRETTY_NAME="openEuler Embedded(openEuler Embedded Reference Distro) 24.03-LTS (openEuler24_03-LTS)"
    DISTRO_CODENAME="openEuler24_03-LTS"


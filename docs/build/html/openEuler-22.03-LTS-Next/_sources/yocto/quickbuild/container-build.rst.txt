.. _container_build:

容器环境下的快速构建指导
=================================

由于openEuler Embedded构建过程需要基于openEuler操作系统，且需要安装较多系统工具和构建工具。为方便开发人员快速搭建构建环境，我们将构建过程所依赖的操作系统和工具封装到一个容器中，
这就使得开发人员可以快速搭建一个构建环境，进而投入到代码开发中去，避免在准备环境阶段消耗大量时间。

1. 环境准备
**************

需要使用docker创建容器环境，为了确保docker成功安装，需满足以下软件硬件要求

- 操作系统: 推荐使用Ubuntu、Debian和RHEL（Centos、Fedora等）

- 内核: 推荐3.8及以上的内核

- 驱动: 内核必须支持一种合适的存储驱动，例如: Device Mapper、AUFS、vfs、btrfs、ZFS

- 架构: 运行64位架构的计算机（x86_64和amd64）

2. 安装docker
************************

1) 检查当前环境是否已安装docker工具
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

运行如下命令，可以看到当前docker版本信息，则说明当前环境已安装docker，无需再次安装。

.. code-block:: console

    docker version

2) 如果没有安装，可参考官方链接安装
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

官网地址: http://www.dockerinfo.net/document

openEuler环境可参考Centos安装Docker。

例: openEuler环境docker安装命令如下：

.. code-block:: console

    sudo yum install docker

3. 获取容器镜像
****************

通过 ``docker pull`` 命令拉取华为云中构建openEuler-Embedded-22.03-LTS-SP1的镜像到宿主机。命令如下:

.. code-block:: console

    docker pull swr.cn-north-4.myhuaweicloud.com/openeuler-embedded/openeuler-container:22.03-lts-sp1

4. 准备容器构建环境
*********************

1) 启动容器
^^^^^^^^^^^^^

可通过 ``docker run`` 命令启动容器，为了保证容器启动后可以在后台运行，且可以正常访问网络，建议使用如下命令启动：

.. code-block:: console

    docker run -idt --network host swr.cn-north-4.myhuaweicloud.com/openeuler-embedded/openeuler-container:22.03-lts-sp1 bash

参数说明:

- -i 让容器的标准输入保持打开

- -d 让 Docker 容器在后台以守护态（Daemonized）形式运行

- -t 选项让Docker分配一个伪终端（pseudo-tty）并绑定到容器的标准输入上

- --network 将容器连接到（host）网络

- swr.cn-north-4.myhuaweicloud.com/openeuler-embedded/openeuler-container 指定镜像名称

- bash 进入容器的方式

2) 查看已启动的容器id
^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: console

    docker ps

3) 进入容器
^^^^^^^^^^^^

.. code-block:: console

    docker exec -it 容器id bash

构建环境已准备完成，下面就可以在容器中进行构建了。

5. 开始构建
************

1) 切换openeuler用户

.. code-block:: console
    
    su openeuler

2) 下载源码
^^^^^^^^^^^^

- 获取源码下载脚本

.. code-block:: console

    git clone https://gitee.com/openeuler/yocto-meta-openeuler.git -b openEuler-22.03-LTS-SP1 -v /usr1/openeuler/src/yocto-meta-openeuler

- 通过脚本下载源码

.. code-block:: console

    cd /usr1/openeuler/src/yocto-meta-openeuler/scripts
    sh download_code.sh /usr1/openeuler/src

c) 进入构建脚本所在路径，初始化容器构建依赖工具，运行编译脚本

.. code-block:: console

    # 初始化容器构建依赖工具
    . /opt/buildtools/nativesdk/environment-setup-x86_64-pokysdk-linux
    # 进入编译初始化脚本目录
    cd /usr1/openeuler/src/yocto-meta-openeuler/scripts
    # 通过编译初始化脚本初始化编译环境
    source compile.sh aarch64-std /usr1/build
    bitbake openeuler-image

3) 构建结果说明
^^^^^^^^^^^^^^^^^

结果件默认生成在构建目录下的output目录下，例如上面aarch64-std的构建结果件生成在 :file:`/usr1/build/output` 目录下，如下表：

+---------------------------------------------+-------------------------------------------------------------+
|      filename                               |             description                                     |
+=============================================+=============================================================+
| Image-5.10.0                                | openEuler Embedded image                                    |
+---------------------------------------------+-------------------------------------------------------------+
| openeuler-glibc-x86_64-openeuler-image      | openEuler Embedded sdk toolchain                            |
| -\*-toolchain-\*.sh                         |                                                             |
+---------------------------------------------+-------------------------------------------------------------+
| openeuler-image-qemu-aarch64-               | openEuler Embedded file system                              |
| \*.rootfs.cpio.gz                           |                                                             |
+---------------------------------------------+-------------------------------------------------------------+
| zImage                                      | openEuler Embedded compressed image                         |
+---------------------------------------------+-------------------------------------------------------------+
| openeuler-image-qemu-aarch64-               | openeuler iso image                                         |
| \*.iso                                      |                                                             |
+---------------------------------------------+-------------------------------------------------------------+
| openeuler-image-live-qemu-aarch64-          | openEuler Embedded live file system                         |
| \*.rootfs.cpio.gz                           |                                                             |
+---------------------------------------------+-------------------------------------------------------------+
| vmlinux-5.10.0                              | openEuler Embedded vmlinux                                  |
+---------------------------------------------+-------------------------------------------------------------+


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

通过 ``docker pull`` 命令拉取华为云中的镜像到宿主机。命令如下:

.. code-block:: console

    docker pull swr.cn-north-4.myhuaweicloud.com/openeuler-embedded/openeuler-container

默认下载最新镜像，也可以根据需要编译的版本指定下载镜像版本，命令如下:

.. code-block:: console

   docker pull [Container Image Name]:[Tag]
   # example: docker pull swr.cn-north-4.myhuaweicloud.com/openeuler-embedded/openeuler-container:latest

容器镜像信息列表：

+---------------------------------------------+----------------+-----------------------------------+----------------+--------------+
|   Container Image Name                      | Tag            | For Image Branch                  | Kernel Version | Libc Version |
+=============================================+================+===================================+================+==============+
| swr.cn-north-4.myhuaweicloud.com/openeuler  | latest         | master                            | 21.03          | 2.31         |
| -embedded/openeuler-container               |                |                                   |                |              |
+---------------------------------------------+----------------+-----------------------------------+----------------+--------------+
| swr.cn-north-4.myhuaweicloud.com/openeuler  | 22.09          | openEuler-22.09                   | 21.03          | 2.31         |
| -embedded/openeuler-container               |                |                                   |                |              |
+---------------------------------------------+----------------+-----------------------------------+----------------+--------------+
| swr.cn-north-4.myhuaweicloud.com/openeuler  | 22.03-lts      | openEuler-22.03-LTS               | 22.03 LTS      | 2.34         |
| -embedded/openeuler-container               |                |                                   |                |              |
+---------------------------------------------+----------------+-----------------------------------+----------------+--------------+
| swr.cn-north-4.myhuaweicloud.com/openeuler  | 21.09          | openEuler-21.09                   | 21.03          | 2.31         |
| -embedded/openeuler-container               |                |                                   |                |              |
+---------------------------------------------+----------------+-----------------------------------+----------------+--------------+

  .. note::

    构建不同分支/版本的openEuler镜像，需使用不同的容器，如“For Image Branch”一列即为对应关系
    另外，新的容器镜像，为了兼容主机端工具以及yocto poky的nativesdk,我们使用了内置libc 2.31版本的容器，所以C库版本会比22.03时要更早

4. 准备容器构建环境
*********************

1) 启动容器
^^^^^^^^^^^^^

可通过 ``docker run`` 命令启动容器，为了保证容器启动后可以在后台运行，且可以正常访问网络，建议使用如下命令启动：

.. code-block:: console

    docker run -idt --network host swr.cn-north-4.myhuaweicloud.com/openeuler-embedded/openeuler-container bash

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

1) 下载源码
^^^^^^^^^^^^

- 获取源码下载脚本

.. code-block:: console

    git clone https://gitee.com/openeuler/yocto-meta-openeuler.git -b <For Image Branch> -v /usr1/openeuler/src/yocto-meta-openeuler
    #example: git clone https://gitee.com/openeuler/yocto-meta-openeuler.git -b master -v /usr1/openeuler/src/yocto-meta-openeuler

.. note::

    <For Image Branch> 参见容器镜像列表一列内容
    因构建所需全量代码的获取来源由yocto-meta-openeuler仓库承载，所以如要构建对应版本的代码（如openEuler-22.09或openEuler-22.03-LTS等），需下载对应分支的yocto-meta-openeuler
    另外请注意，构建不同分支/版本的openEuler镜像，需使用不同的容器

- 通过脚本下载源码

.. code-block:: console

    cd /usr1/openeuler/src/yocto-meta-openeuler/scripts
    sh download_code.sh /usr1/openeuler/src

.. note::

    22.09及master之后的版本支持/usr1/openeuler/src/yocto-meta-openeuler/script/oe_helper.sh
    可通过source oe_helper.sh参见usage说明来下载代码

2) 编译构建
^^^^^^^^^^^^^

- 编译架构: aarch64-std、aarch64-pro、arm-std、raspberrypi4-64

- 构建目录: /usr1/build

- 源码目录: /usr1/openeuler/src

- 编译器所在路径: /usr1/openeuler/gcc/openeuler_gcc_arm64le

 .. note::

   - 不同的编译架构使用不同的编译器，aarch64-std、aarch64-pro、raspberrypi4-64使用openeuler_gcc_arm64le编译器，arm-std使用openeuler_gcc_arm32le编译器。

- 下面以以aarch64-std目标架构编译为例。

a) 将/usr1目录所属群组改为openeuler，否则切换至openeuler用户构建会存在权限问题

.. code-block:: console

    chown -R openeuler:users /usr1

b) 切换至openeuler用户

.. code-block:: console

    su openeuler

c) 进入构建脚本所在路径，运行编译脚本

.. code-block:: console

    # 进入编译初始化脚本目录
    cd /usr1/openeuler/src/yocto-meta-openeuler/scripts

.. code-block:: console

    # 22.03及其之前版本请跳过此命令（22.09及其之后版本请务必执行此命令）：
    # 初始化容器构建依赖工具（poky nativesdk）
    . /opt/buildtools/nativesdk/environment-setup-x86_64-pokysdk-linux

.. code-block:: console

    # 通过编译初始化脚本初始化编译环境
    source compile.sh aarch64-std /usr1/build /usr1/openeuler/gcc/openeuler_gcc_arm64le
    bitbake openeuler-image

.. note::

    22.09及master之后的版本支持/usr1/openeuler/src/yocto-meta-openeuler/script/oe_helper.sh
    可通过source oe_helper.sh参见usage说明来初始化编译环境

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


.. _yocto_quick_build:

原生环境下的快速构建指导
===========================================

原生环境构建配置过于复杂，约束较多，当前 **不建议** 用户使用此方法进行构建。

构建环境的准备
*********************************************

yocto中主机端命令使用
^^^^^^^^^^^^^^^^^^^^^^^^^^^

Yocto或者说Bitbake本质上是一组python程序，其最小运行环境要求如下：
 | - Python3 > 3.6.0
 | - Git > 1.8.3.1
 | - Tar > 1.28

在构建过程中所需要的其他工具，Yocto都可以根据相应的软件包配方自行构建出来，从而达到自包含的效果。在这个过程中，Yocto还会依据自身需要，对相应的工具打上yocto专属补丁（如dnf, rpm等）。这些主机工具会在第一次的构建中从源码开始构建，因此Yocto第一次构建比较费时。

为了加速构建特别是第一次构建，openEuler Embedded采取了“能用原生工具就用原生工具，能不构建就不构建”的策略，尽可能使用主机上预编译的原生的工具。
这就需要依赖主机上软件包管理工具（apt, dnf, yum, zypper等)实现安装好。

Yocto是通过HOSTTOOLS变量来实现主机工具的引入，为会每个在HOSTTOOLS中列出的工具建立相应的软链接。为了避免来自主机对构建环境的污染，Yocto会重新准备不同于主机的环境，例如PATH变量等，因此如果新增依赖主机上的某个命令，需显示在Yocto的HOSTTOOLS变量中增加，否则即使主机上存在，Yocto构建时也会报错找不到相应的工具。相应流程如下图所示：

.. image:: ../../../image/yocto/hosttools.png

当前openEuler Embedded所需要主机工具已经默认在local.conf.sample中的HOSTTOOLS定义，主要工具描述如下：

=========     =============
工具名         用途
=========     =============
cmake         cmake构建工具
ninjia        ninja构建系统
=========     =============


openEuler Embedded所需构建工具
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

1）构建os
 - `操作系统:openEuler-20.03-LTS-SP2 <https://repo.openeuler.org/openEuler-20.03-LTS-SP2/docker_img/x86_64/openEuler-docker.x86_64.tar.xz>`_

2）安装系统额外工具
 ::
 
       yum -y install tar cmake gperf sqlite-devel chrpath gcc-c++ patch rpm-build flex autoconf automake m4 bison bc libtool gettext-devel createrepo_c rpcgen texinfo hostname python meson dosfstools mtools parted ninja-build autoconf-archive libmpc-devel gmp-devel

3）预编译的交叉工具链和库
 | Yocto可以构建出交叉编译所需的交叉工具链和C库，但整个流程复杂且耗时，不亚于内核乃至镜像的构建，而且除了第一次构建，后面很少会再涉及。同时，绝大部分开发者都不会直接与工具链和C库构建打交道。所以为了简化该流程，openEuler Embedded采取的策略是采用预编译的交叉工具链和库，会专门维护和发布相应的带有C库的工具链。
 | 目前在22.03我们提供了对arm32位和aarch64位两种架构的工具链支持，通过如下方式可以获得：

 - 下载rpm包: ``wget https://repo.openeuler.org/openEuler-22.03-LTS/EPOL/main/x86_64/Packages/gcc-cross-1.0-0.oe2203.x86_64.rpm``
 - 解压rpm包: ``rpm2cpio gcc-cross-1.0-0.oe2203.x86_64.rpm | cpio -id``

 - 解压后可以看到当前路径下会有tmp目录，编译链存放于该目录下
 
   - ARM 32位工具链: openeuler_gcc_arm32le.tar.xz
   - ARM 64位工具链: openeuler_gcc_arm64le.tar.xz

 | 在22.09我们提供了ct-ng作为工具生成的工具链，已集成于22.09分支的镜像构建容器中，用户也可自行构建，构建方法见：
 
 - `22.09及master支持基于ct-ng构建编译器的使用方法 <https://gitee.com/openeuler/yocto-embedded-tools/blob/master/cross_tools/README.md>`_

已安装好工具的构建容器
^^^^^^^^^^^^^^^^^^^^^^^^^^^

openEuler Embedded的构建过程中会使用到大量的各式各样的主机工具。如前文所述，为了加速构建，openEuler Embedded依赖主机事先安装好相应的工具，但这也会带来一不同主机环境会有不同的工具版本的问题，例如构建需要cmake高于1.9版本，但主机上最高只有cmake 1.8。为了解决这一问题，openEuler Embedded提供了专门的构建容器，提供统一的构建环境。

使用者可以通过如下链接获得容器镜像直接用于编译：

 - `openEuler Embedded构建容器的基础镜像 <https://repo.openeuler.org/openEuler-21.03/docker_img/x86_64/openEuler-docker.x86_64.tar.xz>`_


构建代码下载与准备
*********************************************

openEuler Embedded整个构建工程的文件布局如下，假设openeuler_embedded为顶层目录：

::

    <顶层目录openeuler_embedded>
    ├── src  源代码目录，包含所有软件包代码、内核代码和Yocto构建代码
    ├── build  openEuler Embedded的构建目录，生成的各种镜像放在此目录下

1）下载脚本所在仓库(例如下载到src/yocto-meta-openeuler目录下),以openEuler-22.03-LTS分支为例，其他分支请修改：
 | ``git clone https://gitee.com/openeuler/yocto-meta-openeuler.git -b openEuler-22.03-LTS -v src/yocto-meta-openeuler``
 | 脚本为src/yocto-meta-openeuler/scripts/download_code.sh
 |      此脚本有3个参数：
 |                         参数1：下载的源码路径，默认相对脚本位置下载，例如前面样例，代码仓会下到src/下
 |                         参数2：下载的分支，默认值见脚本，不同分支按版本确定
 |                         参数3：下代码的xml文件，标准manifest格式，按xml配置下代码

2）执行下载脚本
 | 下载最新代码: ``sh src/yocto-meta-openeuler/scripts/download_code.sh``
 | 下载指定版本代码: ``sh src/yocto-meta-openeuler/scripts/download_code.sh "" "" "manifest.xml"``

 - 指定openEuler Embedded版本的代码的manifest.xml文件从openEuler Embedded发布件目录embedded_img/source-list/下获取


openEuler Embedded版本构建
*****************************

一键式构建脚本：:file:`src/yocto-meta-openeuler/scripts/compile.sh` , 具体细节可以参考该脚本。

编译脚本的主要流程：

1. 设置PATH增加额外工具路径
#. TEMPLATECONF指定local.conf.sample等配置文件路径
#. 调用poky仓的oe-init-build-env进行初始化配置
#. 在编译目录的conf/local.conf中配置MACHINE，按需增加额外新增的层
#. 在编译目录执行bitbake openeuler-image编译openEuler Embedded的image和sdk
#. 执行完发布件在编译目录的output目录下

以编译标准arm架构为例，编译方法如下:

::

    source src/yocto-meta-openeuler/scripts/compile.sh arm-std
    bitbake openeuler-image  #执行第一条source后，会提示出bitbake命令

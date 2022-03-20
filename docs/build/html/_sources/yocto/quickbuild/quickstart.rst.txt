openEuler快速构建指导
=================

构建环境的准备
*********************************************

* 主机工具

Yocto或者说Bitbake本质上一组python程序，其最小运行环境要求如下：
- Python3 > 3.6.0
- Git > 1.8.3.1
- Tar 1.28
在构建过程中所需要的其他工具，Yocto都可以根据相应的软件包配方自行构建出来，从而达到自包含的效果。
在这个过程中，Yocto还会依据自身需要，对相应的工具打上yocto专属补丁（如dnf, rpm）等。这些主机工具
会在第一次的构建中从源码开始构建，因此Yocto第一次构建比较费时。

为了加速构建特别是第一次构建，openEuler Embedded采取了“能用原生工具就用原生工具，能不构建就不构建”的策略，尽可能使用主机上预编译的原生的工具。
这就需要依赖主机上软件包管理工具（apt, dnf, yum, zypper等)实现安装好。

Yocto是通过HOSTTOOLS变量来实现主机工具的引入，为会每个在HOSTTOOLS中列出的工具建立相应的软链接。为了避免来自主机对构建环境的污染，Yocto会重新
准备不同于主机的环境，例如PATH变量等，因此如果新增依赖主机上的某个命令，需显示在Yocto的HOSTTOOLS变量中增加，否则即使主机上存在，Yocto构建时也会
报错找不到相应的工具。相应流程如下图所示：

.. image:: ../../image/yocto/hosttools.png

当前openEuler Embedded所需要主机工具已经默认在local.conf.sample中的HOSTTOOLS定义，各个工具描述如下：

=========     =============
工具名         用途
=========     =============
cmake         cmake构建工具
ninjia        cmake构建后端
=========     =============

* 预编译的交叉工具链和库

Yocto可以构建出交叉编译所需的交叉工具链和C库，但整个流程复杂且耗时，不亚于内核乃至镜像的构建，而且除了第一次构建，后面很少会再涉及。同时，绝大部分开发者
都不会直接与工具链和C库构建打交道。所以为了简化该流程，openEuler Embedded采取的策略是采用预编译的交叉工具链和库，会专门维护和发布相应的带有C库的工具链。
目前我们提供了对arm32位和aarch64位两种架构的工具链支持， 通过下方链接可以获得：

 - `ARM 32位工具链 <https://gitee.com/openeuler/yocto-embedded-tools/attach_files/911963/download/openeuler_gcc_arm32le.tar.xz>`_
 - `ARM 64位工具链 <https://gitee.com/openeuler/yocto-embedded-tools/attach_files/911964/download/openeuler_gcc_arm64le.tar.xz>`_

* 构建容器

openEuler Embedded的构建过程中会使用到大量的各式各样的主机工具。如前文所述，为了加速构建，openEuler Embedded依赖主机事先安装好相应的工具，但这也会带
来一不同主机环境会有不同的工具版本的问题，例如构建需要cmake高于1.9版本，但主机上最高只有cmake 1.8。为了解决这一问题，openEuler Embedded提供了专门的构
建容器，提供统一的构建环境。

使用者可以通过如下链接获得容器构建文件和基础镜像，构建出相应的容器：

 - `openEuler Embedded构建容器的构建文件 <https://gitee.com/openeuler/yocto-embedded-tools/blob/openEuler-21.09/dockerfile/Dockerfile>`_
 - `openEuler Embedded构建容器的基础镜像 <https://repo.openeuler.org/openEuler-21.03/docker_img/x86_64/openEuler-docker.x86_64.tar.xz>`_

完整的预编译好的容器镜像稍后会提供

构建代码与软件包代码的下载与准备
*********************************************

openEuler Embedded整个构建工程的文件布局如下，假设openeuler_embedded为顶层目录：

::

    <顶层目录openeuler_embedded>
    ├── src  源代码目录，包含所有软件包代码、内核代码和Yocto构建代码
    ├── build  openEuler Embedded的构建目录，生成的各种镜像放在此目录下


* 准备Yocto构建代码相关仓库，请在src目录下克隆如下仓库， 并切换到相应分支：

  - Yocto核心组件：
     + poky: https://gitee.com/openeuler/yocto-poky
     + pseudo: https://gitee.com/src-openeuler/yocto-pseudo
     + opkg-utils: https://gitee.com/src-openeuler/yocto-opkg-utils

  - 核心开发工具：
     + yocto-embedded-tools: https://gitee.com/openeuler/yocto-embedded-tools
  - openEuler Embedded构建模板和方法:
     + yocto-meta-openeuler: https://gitee.com/openeuler/yocto-meta-openeuler

* 软件包源代码的准备，请在src目录根据需要下载或克隆内核和软件包仓库

稍后会提供工具，帮助使用者快速构建好相应的环境。

版本构建及qemu部署
***********************

一键式构建脚本：:file:`scr/yocto-meta-openeuler/scripts/build.sh` , 具体细节可以参考该脚本

主要构建流程：

1. 设置PATH增加额外工具路径
#. TEMPLATECONF指定配置文件路径
#. 调用poky仓的oe-init-build-env进行初始化配置
#. 在conf/local.conf中配置MACHINE，按需增加额外新增的层
#. 执行bitbake openeuler-image编译openeuler的image和sdk

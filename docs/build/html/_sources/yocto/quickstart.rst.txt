.. _yocto_quickstart:

快速构建
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
都不会直接与工具链和C库构建打交道。所以为了简化该流程，openEuler Embedded采取的策略是采用预编译的交叉工具链和库，会专门维护和发布相应的带有C库的工具链，
目前提供了对arm32位和aarch64位的支持。

 - `ARM 32位工具链 <https://gitee.com/openeuler/yocto-embedded-tools/attach_files/911963/download/openeuler_gcc_arm32le.tar.xz>`_
 - `ARM 64位工具链 <https://gitee.com/openeuler/yocto-embedded-tools/attach_files/911964/download/openeuler_gcc_arm64le.tar.xz>`_

* 构建容器

openEuler Embedded的构建过程中会使用到大量的各式各样的主机工具。如前文所述，为了加速构建，openEuler Embedded依赖主机事先安装好相应的工具，但这也会带
来一不同主机环境会有不同的工具版本的问题，例如构建需要cmake高于1.9版本，但主机上最高只有cmake 1.8。为了解决这一问题，openEuler Embedded提供了专门的构
建容器，提供统一的构建环境。

 - `openEuler Embedded构建容器 <https://repo.openeuler.org/openEuler-20.03-LTS-SP2/docker_img/x86_64/openEuler-docker.x86_64.tar.xz>`_


poky及openEuler代码下载
***************************

假设openeuler_embedded为顶层目录，则所有代码包位于src子目录下：

* git clone Yocto相关仓库

  - Yocto核心组件：
     + poky: https://gitee.com/openeuler/yocto-poky
     + pseudo: https://gitee.com/src-openeuler/yocto-pseudo
     + opkg-utils: https://gitee.com/src-openeuler/yocto-opkg-utils

  - 核心开发工具：
     + yocto-embedded-tools: https://gitee.com/openeuler/yocto-embedded-tools
  - openEuler Embedded构建模板和方法:
     + yocto-meta-openeuler: https://gitee.com/openeuler/yocto-meta-openeuler

* 软件包源代码的准备


版本构建及qemu部署
***********************

一键式构建脚本：https://gitee.com/ilisimin/yocto-pseudo/blob/openEuler-21.09/scripts/build.sh
qemu部署：https://gitee.com/openeuler/docs/blob/master/docs/zh/docs/Embedded/embedded.md

主要构建流程：

1. 设置PATH增加额外工具路径
#. TEMPLATECONF指定配置文件路径
#. 调用poky仓的oe-init-build-env进行初始化配置
#. 在conf/local.conf中配置MACHINE，按需增加额外新增的层
#. 执行bitbake openeuler-image编译openeuler的image和sdk

::

 export PATH="/opt/buildtools/ninja-1.10.1/bin/:$PATH"
 TEMPLATECONF="${SRC_DIR}/yocto-meta-openeuler/meta-openeuler/conf"
 rm -rf "${BUILD_DIR}"
 mkdir -p "${BUILD_DIR}"
 source "${SRC_DIR}"/yocto-poky/oe-init-build-env ${BUILD_DIR}

 sed -i "s|^MACHINE.*|MACHINE = \"${MACHINE}\"|g" conf/local.conf
 echo "$MACHINE" | grep "^raspberrypi"
 if [ $? -eq 0 ];then
 \    grep "meta-raspberrypi" conf/bblayers.conf |grep -v "^[[:space:]]*#" || sed -i "/\/meta-openeuler /a \  ${SRC_DIR}/yocto-meta-openeuler/bsp/meta-raspberrypi \\\\" conf/bblayers.conf
 fi

 AUTOMAKE_V=$(ls /usr/bin/automake-1.* |awk -F "/" '{print $4}')
 grep "HOSTTOOLS .*$AUTOMAKE_V" conf/local.conf || echo "HOSTTOOLS += \"$AUTOMAKE_V\"" >> conf/local.conf
 bitbake openeuler-image

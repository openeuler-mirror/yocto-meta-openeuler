.. _add_new_bsp_layer:

yocto-meta-openeuler 新增 bsp 层
################################

本文档介绍如何在 ``yocto-meta-openeuler`` 仓库中新增 bsp 适配层

yocto-meta-openeuler 仓 bsp 目录层次说明
****************************************

bsp 目录下当前共有两个目录: ``meta-openeuler-bsp`` ``meta-raspberrypi``

-  ``meta-raspberrypi``

  该层提供树莓派开发板在硬件上的 recipes 和 conf 文件，例如一些基本固件，只要是跟开发板硬件强相关的 recipes 都可以放在该层中。一般该层由上游社区提供，例如 ``meta-raspberrypi`` 层在 openeuler 中仅仅只是引入，未对其中的 recipes 和 conf 文件作侵入式的修改，这便于后续升级和维护。

-  ``meta-openeuler-bsp``

  单独的 bsp 层无法独立在 openeuler 层中很好的工作，作为 bsp 层与 openeuler 层之间的桥梁， ``meta-openeuler-bsp`` 层提供统一的对bsp层的修改，层中对 recipes 的修改基于yocto工程中 ``bbappend`` 形式来实现。


新增 bsp 层举例说明
*******************

-  新增 ``meta-template`` 层

  上一节提到过，该层主要是提供与硬件强相关的 recipes 和 conf 文件，如果有上游社区提供完整的层，可以像引入 ``meta-raspberrypi`` 层一样直接引入。但是如果没有上游社区提供完整的层，就需要从零开始新建该层了，这里提供一种仅仅适配 ``openeuler`` 层的新建方式，而不是标准 ``yocto`` 形式的完整的层。

  1.缩减 ``meta-raspberrypi`` 层

  .. code-block:: console

    tree -L 2 -d .
    .
    ├── classes
    ├── conf
    │   └── machine
    ├── files
    │   └── custom-licenses
    ├── recipes-bsp
    │   ├── bootfiles
    │   └── common
    ├── recipes-kernel
    │   ├── bluez-firmware-rpidistro
    │   └── linux-firmware-rpidistro
    └── wic


  ``classes``: 存放类文件目录

  ``conf``: 存放配置文件目录

  ``recipes-bsp``: 存放启动相关固件的recipes目录

  ``recipes-kernel``: 存放与内核相关固件recipes目录

  ``wic``: 暂时不考虑

  缩减完的 ``meta-raspberrypi`` 层同样可以支撑编译生成树莓派sd卡镜像，这就说明这是 ``meta-raspberrypi`` 层的最小集合，因此可以仿照这个最小集合来新增 bsp 层。

  2.最小集合分析

  ``classes`` 和 ``recipes-bsp`` 目录

  首先，树莓派主要启动方式是通过把镜像烧录到sd卡中来启动，这就需要在 yocto 工程中生成可供烧录至sd卡的镜像， ``meta-raspberrypi`` 层中提供了 ``classes/sdcard_image-rpi.bbclass`` 这样一个类文件来实现(也可以看作是一个制作脚本)。脚本中的实现也不复杂，主要是构建 boot.img 文件并写入/boot分区，把 rootfs 文件写入/root分区，其中 boot.img 中会包含dtb，cmdline，config，kernel，启动固件等内容，这些内容怎么获取，最终是什么样的形式，是由 ``recipes-bsp/bootfiles/`` 目录中对应的 recipes 来决定的， ``sdcard_image-rpi.bbclass`` 只负责将最终产物搬移至 boot.img 中。这也就是 ``classes`` 和 ``recipes-bsp`` 中主要组成部分，逻辑是 ``classes/sdcard_image-rpi.bbclass`` 镜像生成脚本依赖 ``recipes-bsp/bootfiles/`` 中启动相关recipes的产物。

  .. attention::
    具体怎么组织文件内容，以及最终镜像的产物由开发板对应的启动方式来确定，这里只以树莓派为例。

  ``conf`` 目录

  关于层的一些配置 ``layer.conf`` 是必须的，里面定义了层配置。 ``machine/xxxxx.conf`` 也是必须的，可以参考章节 :ref:`构建系统/yocto开发/如何定制添加layer<yocto_development>`

  ``recipes-kernel`` 目录

  与 kernel 相关的固件 recipes，以树莓派的WI-FI驱动加载为例，内核驱动 brcmfmac.ko 在加载时需要先加载对应的固件，这些固件怎么编译/获取需要在该目录下的 recipes 中定义。


  3.最终极简情况下的 ``meta-template`` 层结构如下

  .. code-block:: console

    .
    └── conf
        ├── layer.conf
        └── machine
            └── template.conf

  ** layer.conf 文件内容示例 **

  .. code-block:: console

   # We have a conf and classes directory, append to BBPATH
   BBPATH .= ":${LAYERDIR}"

   # We have a recipes directory containing .bb and .bbappend files, add to BBFILES
   BBFILES += "${LAYERDIR}/recipes*/*/*.bb \
               ${LAYERDIR}/recipes*/*/*.bbappend"

   BBFILE_COLLECTIONS += "template"
   BBFILE_PATTERN_template := "^${LAYERDIR}/"
   BBFILE_PRIORITY_template = "10"

   LAYERSERIES_COMPAT_template = "hardknott honister"

  ** template.conf 文件内容示例 **

  .. code-block:: console

   # must needed, using which file depends on which arch
   # poky privides some predefined files on different archs
   # you can look through these files in yocto-poky/meta/conf/machine
   # or using files privided by meta-openeuler like:
   # require conf/machine/xxxx.inc
   require conf/machine/include/tune-cortexa72.inc

  ``recipes-*`` 的内容是可选的，如果涉及到二次打包镜像，建议像树莓派那样，提供定制化脚本，放在classes目录中，在 ``conf/machine/template.conf`` 中增加 ``IMAGE_CLASSES += "xxxxx"`` 使其生效，并增加相应依赖的启动固件的 recipes；如果涉及到其他固件，也可以添加相应的 recipes。

-  修改 ``meta-openeuler-bsp`` 层

  1. 新增了 ``meta-template`` 层后，需要在 ``meta-openeuler-bsp`` 层中使其生效。修改 ``meta-openeuler-bsp/conf/layer.conf`` 文件即可：

  .. code-block:: console

   template:${LAYERDIR}/template/*/*/*.bb \
   template:${LAYERDIR}/template/*/*/*.bbappend \

   BBPATH_append =. ":${LAYERDIR}/template"

  2. 新增 ``template`` 目录

  目录的最小结构如下：

  .. code-block:: console

   .
   ├── recipes-core
   │   └── images
   │       └── template.inc
   └── recipes-kernel
       └── linux
           └── linux-openeuler.bbappend

  该目录主要是提供针对 openeuler 层的适配操作，比如新增 bsp 所开启/关闭的内核选项与默认的不一样，就可以通过 ``linux-openeuler.bbappend`` 来修改。 ``template.inc``  文件是必须存在的，可以为空，也可以做一些与 images 相关的适配操作。其他对 yocto 工程中任何 recipes 和 task 的修改，都可以通过该目录下来实现。

  .. attention::

    新增其他 recipes 可以在 ``packagegroup-*.bbappend`` 添加使其生效


-  修改 ``compile.sh`` 脚本

  在 ``get_build_info`` 函数中使能新增bsp的machine支持

  .. code-block::

       "template")
           MACHINE="template"
           ;;

  并设置toolchain的路径(这里以arrch64为例，也可以在compile.sh的参数解析中新增)

  .. code-block::

       "qemu-aarch64" | "raspberrypi4-64" | "template")
       EXTERNAL_TOOLCHAIN_DIR="EXTERNAL_TOOLCHAIN_aarch64";;

  在 ``set_env`` 函数中新增 ``meta-template`` 层

  .. code-block::

       if echo "$MACHINE" | grep -q "template";then
           grep "meta-bsp-template" conf/bblayers.conf |grep -qv "^[[:space:]]*#" || sed -i "/\/meta-openeuler /a \  "${SRC_DIR}"/yocto-meta-openeuler/bsp/meta-bsp-template \\\\" conf/bblayers.conf
       fi

  至此，可以通过 ``source compile.sh template /path/to/build/dir`` 初始化 yocto 工程，使用 ``bitbake openeuler-image`` 生成镜像了。

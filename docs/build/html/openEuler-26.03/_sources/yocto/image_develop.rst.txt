.. _yocto_image_develop:

镜像定制
############

镜像配方
=============

镜像的最终生成是通过一个特殊的配方文件来控制的，这个配方通常会继承自 ``core-image`` 类。在镜像配置中，有几个关键的变量需要关注：

- IMAGE_FSTYPES：指定镜像的生成类型，如 cpio.gz、iso、wic（分区镜像）等；
- IMAGE_ROOTFS_SIZE：定义镜像的大小，以 kb 为单位；
- INITRAMFS_MAXSIZE：限制镜像的最大大小；
- IMAGE_INSTALL：指定要在镜像中安装的软件包；
- TOOLCHAIN_HOST_TASK：指定生成的 SDK 工具中应包含的主机工具和库等；
- TOOLCHAIN_TARGET_TASK：指定生成的 SDK 工具中应包含的目标端工具和库；


如何往镜像中添加包
========================

从 :ref:`yocto_recipe` 章节我们了解到，软件包构建后会生成多个子包，并分布在每个配方 :file:`${WORKDIR}/packages-split` 目录下，这些子包的目录名可以看作是 **IMAGE_INSTALL** 的参数，实际上也可以通过 ``bitbake-getvar`` 命令获取每个配方的 **PACKAGES** 变量值。

**示例一：** 基于 :ref:`yocto_recipe` 章节，添加 **hello** 子包到镜像中，需添加如下代码到镜像配方：

::

    IMAGE_INSTALL += "hello"

**示例二：** 添加部分内核模块包到镜像中，添加代码如下：

::

    IMAGE_INSTALL += "kernel-module-vc4 \
    kernel-module-v3d \
    kernel-module-drm"

然而，一个镜像通常会包含很多个软件包，如果每次都需要手动添加一系列软件包到镜像中，这将变得相当乏味。因此，Yocto 提供了一套 packagegroup 方案，用于将软件包进行分组，从而简化了软件包的安装和管理。我们将在下文中详细介绍 packagegroup 的使用方法和优势。


packagegroup 介绍
===================

packagegroup 为 Yocto 提供了一种方便的方式来定义和管理软件包集合，这使得用户能够轻松地一次性安装或卸载多个相关的软件包。通过使用 packagegroup，用户可以避免手动添加每个单独的软件包到构建过程中，从而简化了构建过程并提高了效率。这对于大型项目或具有特定需求的用户来说非常有用，因为它可以帮助他们更好地组织和管理软件包。

实际上，packagegroup 也是通过配方来实现功能的，这些配方专注于配置软件包依赖关系，而不会包含任何具体的文件。例如，:file:`packagegroup-core-boot.bb` 配置了一个系统启动所需的最小软件包集合，包含了内核、启动脚本、busybox/systemd等关键组件。而 :file:`packagegroup-isulad.bb` 则专注于配置 iSulad 运行时所需的一些必要软件包。这样的配置方式使得用户可以更方便地管理和维护软件包的依赖关系，从而简化了构建过程。

在使用时，开发者只需要将对应的 packagegroup 添加到镜像配方 **IMAGE_INSTALL** 变量。如下：

::

    IMAGE_INSTALL += "packagegroup-core-boot packagegroup-isulad"

综上所述，Yocto 需要 packagegroup 来提供一种方便、高效的方式来组织和控制软件包的安装，以及管理和维护复杂的软件包依赖关系。这有助于简化构建过程、提高效率，并满足不同项目和用户的特定需求。


运行时依赖（RDEPENDS）知识
==========================

**RDEPENDS** 变量通常用于指定运行时依赖关系，这意味着这些依赖项是在目标系统上部署软件包时需要的。此外，Yocto 会自动在包之间添加常见类型的运行时依赖项，这意味着用户不需要显式声明每个依赖项。然而，对于特定的需求或特殊的依赖关系，用户需要使用 **RDEPENDS** 变量进行自定义配置。

**RDEPENDS** 变量的语法如下：

::

    RDEPENDS:${PN} = "dependency1 dependency2 ..."

其中， ${PN} 是软件包名称，dependency1、dependency2 等是软件包的依赖项。例如，假设有一个名为 "myapp" 的软件包，它依赖于 "libxml2" 和 "libcurl" 软件包，可以在 "myapp" 的配方文件中使用以下代码来定义RDEPENDS变量：

::

    RDEPENDS:${PN} = "libxml2 libcurl"

这将确保在安装 "myapp" 软件包到镜像时，"libxml2" 和 "libcurl" 软件包也会被安装。

在默认情况下，:file:`bitbake.conf` 文件中配置了 ``RDEPENDS:${PN}-dev = "${PN}"``，这意味着在安装开发包（dev包）时，对应的主体包（主包）也会被同时安装。这种配置确保了开发包对主体包的依赖关系，从而在构建过程中能够正确地构建和安装相关软件包。

.. note::

    与 RDEPENDS 作用类似的还有 RRECOMMENDS 变量，这里不作详细说明。


镜像配方示例
===================

**示例一：** :file:`meta/recipes-core/images/core-image-minimal.bb` 。

来自 Poky 的极简 image 配方示例。

::

    SUMMARY = "A small image just capable of allowing a device to boot."

    IMAGE_INSTALL = "packagegroup-core-boot ${CORE_IMAGE_EXTRA_INSTALL}"

    ### 指定要安装的额外语言包
    IMAGE_LINGUAS = " "

    LICENSE = "MIT"

    inherit core-image

    IMAGE_ROOTFS_SIZE ?= "8192"
    IMAGE_ROOTFS_EXTRA_SPACE:append = "${@bb.utils.contains("DISTRO_FEATURES", "systemd", " + 4096", "", d)}"

目前 Poky 官方示例没有增加预构建工具兼容代码，因此只支持 native 构建模式，构建任务会多一些；此外如果使用了外部工具链构建方式，需要添加 ``TOOLCHAIN_HOST_TASK = ""`` 到镜像配方中。构建方式如下：

::

    ...
    $ oebuild bitbake
    $ vi conf/local.conf
    ### 使用 native 构架模式需修改 OPENEULER_PREBUILT_TOOLS_ENABLE = "no"
    $ bitbake core-image-minimal
    ### 镜像生成目录
    $ cd tmp/deploy/images/MACHINE


**示例二：** :file:`meta-openeuler/recipes-core/images/openeuler-image-tiny.bb`。

来自 openEuler 的极简 image 配方示例。镜像中只包含了 kernel、busybox 以及必须的启动脚本。

::

    # no host package for image-tiny
    TOOLCHAIN_HOST_TASK = ""

    SUMMARY = "A small image just capable of allowing a device to boot."

    # no any image features to get minimum rootfs
    IMAGE_FEATURES = "empty-root-password"

    require openeuler-image-common.inc

    # tiny image overwrite this variable, or IMAGE_INSTALL was standard packages in openeuler-image-common.inc file
    IMAGE_INSTALL = " \
    packagegroup-core-boot \
    packagegroup-qt \
    packagegroup-kernel-modules \
    "

    # make install or nologin when using busybox-inittab
    set_permissions_from_rootfs:append() {
        cd "${IMAGE_ROOTFS}"
        if [ -e ./etc/inittab ];then
            sed -i "s#respawn:/sbin/getty.*#respawn:-/bin/sh#g" ./etc/inittab
        fi
        cd -
    }

构建方式如下：

::

    ...
    $ oebuild bitbake
    $ vi conf/local.conf
    $ bitbake openeuler-image-tiny
    ### 镜像生成目录
    $ cd tmp/deploy/images/MACHINE


镜像定制方式
======================

- 参考官方示例新建镜像配方；
- 基于已存在的镜像配方文件，使用 bbappend 方式适配；
- 提前镜像公共配置到 inc 文件，通过 ``require`` 去调用。例如 :file:`meta-openeuler/recipes-core/images/openeuler-image-common.inc` 同时被 :file:`openeuler-image-tiny.bb`、 :file:`openeuler-image.bb` 调用。

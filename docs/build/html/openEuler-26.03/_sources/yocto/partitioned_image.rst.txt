.. _kickstart-wks-reference:

===========================
使用 yocto 创建分区镜像
===========================

如果您需要为设备创建SD卡、闪存或HDD上的多个分区，可以使用OpenEmbedded Image Creator Wic，它能为您生成具有正确分区的镜像。


如何生成分区镜像
=================

wic 命令用于从现有的 OpenEmbedded/Yocto 构建产物生成分区镜像，该命令位于 ``poky/scripts/`` 目录。镜像生成是由包含在 Openembedded Kickstart 文件（通常以 ``.wks`` 为扩展名） 中的分区命令驱动的。通过使用 wic 命令对特定的构建产物进行处理，可以生成可直接写入介质并在特定系统上使用的镜像或镜像集。

.. note:: 
    
    当前版本的 wic 仅支持基本的 kickstart 命令： partition（简称part）和 bootloader。未来可能会有更多功能的支持。


要生成Wic格式的镜像，您需要修改 :file:`machine.conf` 文件，通常可以按照以下步骤进行：

- IMAGE_FSTYPES变量需包含 wic，具体配置方式: ``IMAGES_FSTYPES += "wic"``
- WKS_FILE变量指定需使用的 wks 文件。wks 文件必须位于 ``wic`` 目录或 ``poky/scripts/lib/wic/canned-wks/`` 目录中，具体配置方式： ``WKS_FILE = "wks_file_name"``


openEuler 使用实例，创建sd卡启动的香橙派镜像，如下：

- bsp/meta-openeuler-bsp/conf/machine/orangepi4-lts.conf
- bsp/meta-openeuler-bsp/conf/machine/include/rockchip-wic.inc
- bsp/meta-openeuler-bsp/wic/sdimage-opi.wks


wic 命令使用
================

以下是常用的一些 wic 命令使用参数：

::

    ### 帮助命令
    $ wic --help
    $ wic help rm   ### rm可替换为其它需要查看的命令

    ### 列出已存在的的 wks 文件
    $ wic list images
    ### 查看 beaglebone-yocto.wks 的帮助信息
    $ wic list beaglebone-yocto help
    
    ### 列出 wic 镜像所有分区
    $ wic ls tmp/deploy/images/qemux86/core-image-minimal-qemux86.wic
    ### 列出分区1的内容
    $ wic ls tmp/deploy/images/qemux86/core-image-minimal-qemux86.wic:1


wic 创建镜像的两种模式
==========================

1、raw 模式
-------------

调用 wic 命令进行使用，需指定使用的 wks 文件、文件系统目录、bootimg 所在目录、内核所在目录等。以 orangepi4-lts 构建为例：

::

  $ wic create sdimage-opi -o wic-test \
  --rootfs-dir tmp/work/orangepi4_lts-openeuler-linux/openeuler-image-tiny/1.0-r0/rootfs \
  --bootimg-dir tmp/deploy/images/orangepi4-lts \
  --kernel-dir tmp/deploy/images/orangepi4-lts \
  --native-sysroot tmp/work/orangepi4_lts-openeuler-linux/openeuler-image-tiny/1.0-r0/recipe-sysroot-native
  INFO: Creating image(s)...

  INFO: The new image(s) can be found here:
    wic-test/sdimage-opi-202401040309-sda.direct

  The following build artifacts were used to create the image(s):
    ROOTFS_DIR:                   /home/openeuler/orange-ok3399-dir/tmp/work/orangepi4_lts-openeuler-linux/openeuler-image-tiny/1.0-r0/rootfs
    BOOTIMG_DIR:                  tmp/deploy/images/orangepi4-lts/
    KERNEL_DIR:                   tmp/deploy/images/orangepi4-lts/
    NATIVE_SYSROOT:               tmp/work/orangepi4_lts-openeuler-linux/openeuler-image-tiny/1.0-r0/recipe-sysroot-native/

  INFO: The image(s) were created using OE kickstart file:
    /usr1/openeuler/src/yocto-meta-openeuler/bsp/meta-openeuler-bsp/wic/sdimage-opi.wks


检查输出日志，确认在 ``wic-test/`` 目录中生成了新的分区镜像。

.. note:: 
    
    - --native-sysroot 参数指定使用 wic 所依赖的工具路径，如果主机环境已存在需要的工具，可任意指定一个 recipe-sysroot-native 目录路径，这里指定为 openeuler-image-tiny 的 recipe-sysroot-native 目录；如果主机不存在，则需要构建 wic-tools 配方，并指定 wic-tools 的 recipe-sysroot-native 目录路径为 --native-sysroot 路径；
    - wks 文件也可以使用绝对路径。

2、cooked 模式
----------------

此模式基于已使用Yocto构建的镜像，并需在Yocto的构建目录下执行相关命令。具体操作如下：

::

  $ bitbake wic-tools
  $ wic create wks_file -e IMAGE_NAME

.. note:: 
    
    如果使用IMAGE_FSTYPES已经包含了 wic，则会自动生成 wic 格式的镜像，不需要手动调用执行上述命令。


自动生成 extlinux.conf
=========================

要生成 :file:`extlinux.conf` 文件，您需要配置相关参数。您可以通过参考 :file:`uboot-extlinux-config.bbclass` 文件来获取详细的配置说明。此类允许您生成用于U-Boot引导的 :file:`extlinux.conf` 文件，并将其部署到DEPLOY_DIR_IMAGE目录中。


烧录方法
==============

生成的Wic格式镜像可以使用 dd 或 bmaptool 命令进行烧录。以下是一些示例命令：

::

  $ sudo dd if=mkefidisk-201804191017-sda.direct of=/dev/sdX
  $ sudo bmaptool --no-bmap copy mkefidisk-201804191017-sda.direct /dev/sdX


参考文献
===============

1、yocto 文档

| https://docs.yoctoproject.org/ref-manual/kickstart.html
| https://docs.yoctoproject.org/dev-manual/wic.html

2、kickstart官方文档：

| https://pykickstart.readthedocs.io/en/latest/kickstart-docs.html

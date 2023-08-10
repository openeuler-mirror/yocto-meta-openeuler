.. _add_new_bsp_layer:

======================================
新增 BSP 层指南
======================================

本篇章介绍如何新增BSP层。


BSP 层介绍
=================

板级支持包（BSP）是定义如何支持特定硬件设备、设备集或硬件平台的信息集合。BSP包括有关设备上存在的硬件功能的信息、内核配置信息以及所需的任何其他硬件驱动程序；BSP还列出了除了用于基本和可选平台功能的通用Linux软件堆栈之外所需的任何其他软件组件，例如"u-boot"和"grub"。

因此，BSP层也需要提供如上的功能。BSP层与其他yocto层定义在技术上并没有区别，BSP层也是一个yocto层，只是提供的功能与普通层会有稍许差异。BSP层的核心是 :file:`conf/machine/*.conf` 文件，其中定义了硬件依赖的信息。BSP层的目录层级一般分布如下： ::

    conf：存放一或多个bsp_root_name.conf文件；
    classes：存放硬件相关的类文件目录；
    recipes-bsp：存放启动相关固件的recipes目录；
    recipes-kernel：存放与内核相关固件recipes目录；
    recipes-*：其他的一些recipes目录，通常采用bbappend对源bb进行适配，实现适配硬件的功能；


编写 bsp_root_name.conf 常用的变量
=========================================

编写 :file:`conf/machine/bsp_root_name.conf` 需要了解一些yocto已支持的与硬件有关的变量。

- PREFERRED_PROVIDER_virtual/kernel：定义内核的源bb；openEuler已默认设置为linux-openeuler；
- PREFERRED_VERSION_linux-yocto：poky中有多个linux-yocto（内核，openEuler需改为linux-openeuler）的版本，此变量可决定需要的linux-yocto的版本；openEuler内核目前只有一个版本，可不设置；
- MACHINE_FEATURES：支持的硬件功能列表；
- MACHINE_EXTRA_RRECOMMENDS：与硬件相关的程序包列表，这些程序包对于启动映像不是必需的，常定义为内核模块、设备树等包；当前openEuler未使用，期待后续优化；
- EXTRA_IMAGEDEPENDS: 构建镜像依赖于配方（类似于DEPENDS），但不会安装到根文件系统；
- DEFAULTTUNE：优化硬件、CPU和应用程序性能，yocto当前已支持很多的处理器，见 ``meta/conf/machine/include`` 目录；
- TUNE_FEATURES：在给定特定处理器的情况下，用于调整编译器以获得最佳使用的功能；影响TUNE_CCARGS变量；
- TUNE_CCARGS：为目标系统指定架构特定的C编译器标志；影响CC、CXX等变量；
- IMAGE_FSTYPES：创建根文件系统的格式；
- EXTRA_IMAGECMD：指定镜像创建命令的其他选项，影响IMAGE_CMD变量；使用时需对应镜像类型关联的override；
- IMAGE_CMD：指定为特定镜像类型创建镜像文件的命令；使用时需对应镜像类型关联的override；
- SERIAL_CONSOLES：定义要使用getty启用的串行控制台（TTY）；
- SERIAL_CONSOLES_CHECK：指定TTY设备，以便在使用getty启用它们之前检查 ``/proc/consoles`` ；此变量目前仅支持SysVinit，不支持systemd；
- KERNEL_IMAGETYPE：要为设备构建的内核类型；
- KERNEL_DEVICETREE：生成的Linux内核设备树（即dtb文件的名称）；
- KERNEL_MODULE_AUTOLOAD：启动时自动加载的内核模块；
- KERNEL_EXTRA_ARGS：编译内核时传递的"make"命令行参数。
- UBOOT_SUFFIX：指向生成的U-Boot扩展名，默认为 ``bin``；
- UBOOT_MACHINE：指定生成U-Boot映像时在make命令行上传递的值；
- UBOOT_CONFIG：可同时配置UBOOT_MACHINE、IMAGE_FSTYPE、UBOOT_BINARIES，以','为分割符；类似于PACKAGECONFIG变量；
- UBOOT_ENTRYPOINT：指定U-Boot映像的入口点；
- UBOOT_LOADADDRESS：指定U-Boot映像的加载地址；
- IMAGE_BOOT_FILES：使用带有"bootimg partition"或"bootimg efi"源插件的Wic工具准备映像时，安装在设备引导分区中的文件；
- WKS_FILE: 用于创建分区映像文件的位置；
- EFI_PROVIDER：指定使用的EFI bootloader；
- XSERVER：指定应安装的程序包，以便为当前计算机提供X服务器和驱动程序；
- PACKAGE_EXTRA_ARCHS：指定与设备CPU兼容的架构列表。当您为使用不同处理器（如XScale和ARM926-EJS）的多个不同设备构建时，此变量非常有用。

.. note:: 
    
    - ENABLE_UART：树梅派层独有变量，为1则使能UART功能；
    - CMDLINE：树梅派层独有变量，用于生成cmdline.txt；
    - CMDLINE_SERIAL：树梅派层独有变量，用于生成CMDLINE。


bsp_root_name.conf 变量使用示例
===================================

=================================== ===============================================================
变量                                     使用示例
=================================== ===============================================================
DEFAULTTUNE                            DEFAULTTUNE ?= "riscv64"
TUNE_FEATURES                          TUNE_FEATURES ??= "${TUNE_FEATURES_tune-${DEFAULTTUNE}}"
PREFERRED_PROVIDER_virtual/kernel      PREFERRED_PROVIDER_virtual/kernel = "linux-openeuler"
KERNEL_IMAGETYPE                       KERNEL_IMAGETYPE = "zImage"
KERNEL_DEVICETREE                      KERNEL_DEVICETREE = "am335x-bone.dtb am335x-boneblack.dtb am335x-bonegreen.dtb"
KERNEL_MODULE_AUTOLOAD                 KERNEL_MODULE_AUTOLOAD += "mlan"
KERNEL_EXTRA_ARGS                      KERNEL_EXTRA_ARGS += "LOADADDR=${UBOOT_ENTRYPOINT}"
EXTRA_IMAGEDEPENDS                     EXTRA_IMAGEDEPENDS += "u-boot"
MACHINE_FEATURES                       MACHINE_FEATURES += "efi pci vc4graphics"
MACHINE_EXTRA_RRECOMMENDS              MACHINE_EXTRA_RRECOMMENDS += "kernel-modules"
IMAGE_FSTYPES                          IMAGE_FSTYPES += "cpio.gz"
EXTRA_IMAGECMD                         EXTRA_IMAGECMD_ext4 ?= "-i 4096"
IMAGE_CMD                              IMAGE_CMD_ext4 = "oe_mkext234fs ext4 ${EXTRA_IMAGECMD}"
SERIAL_CONSOLES                        SERIAL_CONSOLES ?= "115200;ttyS0 115200;ttyO0"
SERIAL_CONSOLES_CHECK                  SERIAL_CONSOLES_CHECK = "${SERIAL_CONSOLES}"
UBOOT_SUFFIX                           UBOOT_SUFFIX ?= "bin"
UBOOT_MACHINE                          UBOOT_MACHINE = "config"
UBOOT_ENTRYPOINT                       UBOOT_ENTRYPOINT = "0x80008000"
UBOOT_LOADADDRESS                      UBOOT_LOADADDRESS = "0x80008000"
IMAGE_BOOT_FILES                       IMAGE_BOOT_FILES ?= "u-boot.${UBOOT_SUFFIX} ${SPL_BINARY} ${KERNEL_IMAGETYPE} ${KERNEL_DEVICETREE}"
WKS_FILE                               WKS_FILE ??= "${IMAGE_BASENAME}.${MACHINE}.wks"
EFI_PROVIDER                           EFI_PROVIDER ??= "grub-efi"
XSERVER                                XSERVER ?= "xserver-xorg xf86-video-fbdev"
=================================== ===============================================================


bsp_root_name.conf 文件示例（from Poky）
===========================================

 :file:`meta-yocto-bsp/conf/machine/genericx86-64.conf`： ::
      
    #@TYPE: Machine
    #@NAME: Generic x86_64
    #@DESCRIPTION: Machine configuration for generic x86_64 (64-bit) PCs and servers. Supports a moderately wide range of drivers that should boot and be usable on "typical" hardware.

    DEFAULTTUNE ?= "core2-64"
    require conf/machine/include/tune-core2.inc
    require conf/machine/include/genericx86-common.inc

    SERIAL_CONSOLES_CHECK = "ttyS0"
    #For runqemu
    QB_SYSTEM_NAME = "qemu-system-x86_64"

 :file:`meta-yocto-bsp/conf/machine/include/genericx86-common.inc`： ::

    include conf/machine/include/x86-base.inc
    require conf/machine/include/qemuboot-x86.inc
    MACHINE_FEATURES += "wifi efi pcbios"

    PREFERRED_VERSION_linux-yocto ?= "5.10%"
    PREFERRED_PROVIDER_virtual/kernel ?= "linux-yocto"
    PREFERRED_PROVIDER_virtual/xserver ?= "xserver-xorg"
    XSERVER ?= "${XSERVER_X86_BASE} \
                ${XSERVER_X86_EXT} \
                ${XSERVER_X86_I915} \
                ${XSERVER_X86_I965} \
                ${XSERVER_X86_FBDEV} \
                ${XSERVER_X86_VESA} \
                ${XSERVER_X86_MODESETTING} \
            "

    MACHINE_EXTRA_RRECOMMENDS += "kernel-modules linux-firmware"

    GLIBC_ADDONS = "nptl"

    EXTRA_OECONF:append:pn-matchbox-panel-2 = " --with-battery=acpi"

    IMAGE_FSTYPES += "wic wic.bmap"
    WKS_FILE ?= "genericx86.wks.in"
    EFI_PROVIDER ??= "grub-efi"
    do_image_wic[depends] += "gptfdisk-native:do_populate_sysroot"
    do_image_wic[recrdeptask] += "do_bootimg"


yocto-meta-openeuler 仓 bsp 目录层次介绍
===========================================

bsp目录下存放openeuler当前支持的bsp层，开发者新增的bsp层放在此目录下；其中meta-openeuler-bsp层通常是对上游层的一些适配与自研，类似于meta-openeuler层与meta层的关系。以下对目录下各bsp层作简要介绍：

-  ``meta-openeuler-bsp``

  上游的bsp层无法独立在openeuler层中很好的工作，该层作为上游层与openeuler层之间的桥梁， ``meta-openeuler-bsp`` 层提供统一的对bsp层的修改，层中对recipes的修改基于yocto工程中 ``bbappend`` 形式来实现。

-  ``meta-raspberrypi``

  此层提供树莓派开发板在硬件上的元数据文件，例如一些基本固件，与开发板硬件强相关的recipes都放在该层中。该层由上游社区提供，在openeuler中仅仅只是引入，未对其中的元数据文件作侵入式的修改，这便于后续升级和维护。

-  ``meta-xxx``
  
  其它支持的bsp层，如meta-rockchip与meta-hisilicon。


meta-raspberrypi 分析
=============================

**meta-raspberrypi实现树梅派镜像构建的原理：** 

首先，树莓派主要启动方式是通过把镜像烧录到sd卡中来启动，这就需要在yocto工程中生成可供烧录至sd卡的镜像， ``meta-raspberrypi`` 层中提供了 ``classes/sdcard_image-rpi.bbclass`` 这样一个类文件来实现(也可以看作是一个制作脚本)。脚本中的实现也不复杂，主要是构建 boot.img 文件并写入/boot分区，把 rootfs 文件写入/root分区，其中 boot.img 中会包含dtb、cmdline、config、kernel、启动固件等内容，这些内容怎么获取，最终是什么样的形式，是由 ``recipes-bsp/bootfiles/`` 目录中对应的 recipes 来决定的， ``sdcard_image-rpi.bbclass`` 只负责将最终产物搬移至 boot.img 中。这也就是 ``classes`` 和 ``recipes-bsp`` 中主要组成部分，逻辑是 ``classes/sdcard_image-rpi.bbclass`` 镜像生成脚本依赖 ``recipes-bsp/bootfiles/`` 中启动相关recipes的产物。

.. note:: 

    具体怎么组织文件内容，以及最终镜像的产物由开发板对应的启动方式来确定。


添加自定义的BSP层
============================

1. 初始化yocto构建环境；

2. 增加一个普通的层；

  ::

      # 生成一个默认层，可以自定义层路径，默认在当前目录生成
      $ bitbake-layers create-layer /path/to/yocto-meta-openeuler/bsp/meta-bsp_name
      # 添加层到bblayers.conf
      $ bitbake-layers add-layer /path/to/yocto-meta-openeuler/bsp/meta-bsp_name

3. 根据需求编写 :file:`conf/machine/bsp_root_name.conf、bb、bbclass` （bb、bbclass文件是可选项）；通常需修改CPU、内核类型、根文件系统格式、设备树、内核模块等相关变量；

4. 修改构建目录中 :file:`conf/local.conf` 中MACHINE变量的值为 :file:`conf/machine/bsp_root_name.conf` 实际的值（不加.conf）；

5. 构建镜像。

.. note:: 

  如果涉及到二次打包镜像，建议像树莓派那样，提供定制化脚本，放在classes目录中，在 ``conf/machine/bsp_root_name.conf`` 中增加 ``IMAGE_CLASSES += "xxxxx"`` 使其生效，并增加相应依赖的启动固件的 recipes；如果涉及到其他固件，也可以添加相应的 recipes。

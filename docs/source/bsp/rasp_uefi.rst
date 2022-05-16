.. _rasp_uefi:

树莓派的UEFI支持和网络启动
##############################

本文档介绍如何让树莓派4B支持UEFI（UEFI第三方固件支持PSCI标准实现，混合部署的从核启停依赖此功能），并通过网络启动openEuler Embedded

刷新固件使树莓派4B支持UEFI引导（混合部署依赖此固件的PSCI支持）
************************************************************************************************

环境/工具准备
========================

编译工具链：可用openEuler Embedded的交叉编译工具链，参照 :ref:`快速上手/基于SDK的应用开发<getting_started>` 部分。

设备：建议树莓派4B的出厂配置，包括树莓派4B基础套件和SD卡

树莓派4B UEFI固件下载和刷新方法
================================================

**1 下载树莓派官方固件**

- `树莓派官方固件 <https://github.com/raspberrypi/firmware/archive/master.zip>`_

  - 下载上述固件后解压，将boot目录下的内容，拷贝到SD卡（boot盘）根目录,删除kernel*.img文件:

  .. code-block:: console

      rm /xxx/firmware-master/boot/kernel*.img
      cp -rf /xxx/firmware-master/boot/* SDbootVolumes/

**2 下载树莓派UEFI固件**

- `树莓派UEFI固件(v1.32版本为例) <https://github.com/pftf/RPi4/releases/download/v1.32/RPi4_UEFI_Firmware_v1.32.zip>`_

  - 下载上述固件后解压，将所有文件拷贝到SD卡（boot盘）根目录（覆盖之前的文件）:

  .. code-block:: console

      cp -rf /xxx/RPi4_UEFI_Firmware_v1.32/* SDbootVolumes/

 .. attention::

      * 此UEFI版本的固件默认使用3G内存limit，可以在UEFI菜单中关闭3G limit，否则系统启动后你看到的内存只有3G【参考 `官方配置说明 <https://github.com/pftf/RPi4/>`_ 】

      * UEFI+ACPI部署方法，树莓派使用的内核必须支持ACPI特性

树莓派网络启动openEuler Embedded
************************************************

1 准备PXE部署服务器
========================

以ubunutu 14.04为例，dhcp中指定的filename就是grup的efi引导文件名

假设服务器网段为192.168.10.x，服务器ip为192.168.10.1，网卡eth0用于dhcp服务，初始化服务器ip例：

  .. code-block:: console
    
    sudo ifconfig eth0 192.168.10.1 up

2 使能DHCP服务
========================

安装DHCP软件:

  .. code-block:: console

    sudo apt-get install isc-dhcp-server

编辑/etc/dhcp/dhcpd.conf文件，内容示例：

  .. code-block:: console

    allow booting;
    allow bootp;
    option domain-name "example.org";
    default-lease-time 600;
    max-lease-time 7200;
    ddns-update-style none;

    subnet 192.168.10.0 netmask 255.255.255.0 {
    range 192.168.10.100 192.168.10.200;
    filename "mygrub.efi"; #默认下载的grub文件名，和3中制作的efi引导程序名字需匹配
    option routers 192.168.10.1;
    next-server 192.168.10.1; #tftp服务器IP，PXE必须，HTTPBOOT可选
    option broadcast-address 192.168.10.255;
    }

配置DHCP服务网络接口,编辑文件/etc/default/isc-dhcp-server 增加/修改字段：

  .. code-block:: console

    INTERFACES=”eth0” #dhcp使用的网卡

启动DHCP服务:

  .. code-block:: console

    sudo /etc/init.d/isc-dhcp-server restart

3 使能TFTP服务
========================

安装TFTP服务器软件:

  .. code-block:: console

    sudo apt-get install tftpd-hpa

配置TFTP服务，编辑/etc/default/tftpd-hpa 文件，示例内容如下:

  .. code-block:: console

    TFTP_USERNAME="tftp"
    TFTP_ADDRESS=":69"
    TFTP_DIRECTORY="/var/lib/tftpboot/"
    TFTP_OPTIONS="--secure -l -c -s"

启动TFTP服务:

  .. code-block:: console

    sudo /etc/init.d/tftpd-hpa restart

4 grub准备（编译+制作grub启动组件）
================================================

**grub源码获取**

下载地址：https://github.com/coreos/grub/releases/tag/grub-2.02

**grub组件编译**

解压源码包并进入根目录，准备开始构建arm64-efi（交叉编译）的grub库，注意此时交叉编译工具已经配置完毕，按如下步骤执行:

  .. code-block:: console

    ./autogen.sh
    ./configure --prefix=/xxx/grub-2.02/build --with-platform=efi --disable-werror --target=aarch64-openeuler-linux-gnu
    make

构建成功后，在当前目录会生成对应的二进制和grub组件依赖库，其中，grub-core即制作grub-efi需要的工具库，grub-mkimage即制作板子grub.efi引导的host-tool。

**制作引导程序**

接下来制作板子引导grub程序，下例输出名为mygrub.efi：

  .. code-block:: console

    ./grub-mkimage -d ./grub-core -O arm64-efi -o mygrub.efi -p '' ls grub-core/*.mod | cut -d "." -f 1

  .. note::

        xxxxx目录中请不要带“.”，否则请适配上述语法。

**制作引导配置文件**

最后，编辑grub.cfg配置文件，grub.cfg配置文件放在tftp的根目录（/var/lib/tftpboot/grub.cfg），grub.cfg示例内容如下（--- 后面是cmdline内容，linux gz压缩的内核，initrd文件系统）：

  .. code-block:: console

    insmod gzio
    set timeout=0

    menuentry 'Start OpenEuler' {
    echo "openEuler test."
    linux /Image.gz console=ttyAMA0,115200
    initrd /initrd.cpio.gz
    }

  .. note::

    console=ttyAMA0,115200 这里ttyAMA0是树莓派硬件串口，使用引脚14TXD和15RXD作为控制台，若有HDMI驱动，可另外指定console，比如console=tty1

附：openEuler/Embedded内核Image.gz和文件系统initrd的获取
========================================================================

**文件系统例子**

可使用openEuler Embedded发布的qemu-aarch64参考 `文件系统 <https://repo.openeuler.org/openEuler-22.03-LTS/embedded_img/arm64/aarch64-std/openeuler-image-qemu-aarch64-20220331025547.rootfs.cpio.gz>`_ 

 .. note::

    文件系统/etc/inittab的配置注意getty登录时串口重定向要使用ttyAMA0.（树莓派4硬件串口PL011对应，引脚14TXD和15RXD）

**内核单独编译例子（openEuler）**

参考： `openEuler树莓派交叉编译内核 <https://gitee.com/openeuler/raspberrypi/blob/master/documents/%E4%BA%A4%E5%8F%89%E7%BC%96%E8%AF%91%E5%86%85%E6%A0%B8.md>`_ 

 .. attention::

   * 上述UEFI+ACPI部署方法，必须在config中开启ACPI系列功能支持。在make menuconfig ARCH=arm64菜单中，选中ACPI默认系列支持，经测试当前UEFI固件只能选ACPI启动，其他两项UEFI+DTB、DTB均未成功。

   * 编译生成的Image，在上述grub.cfg的引导示例中，需使用gz命令压缩成Image.gz

**操作说明**

将上述内核和文件系统，放在tftp服务目录下（/var/lib/tftpboot）即可进行网络启动。

网络启动基本流程如下：

a. DHCP服务器给单板分配IP

b. 单板启动UEFI选择PXE启动

c. PXE根据DHCP的filename和tftp服务器地址，从tftp服务器下载mygrub.efi

d. 进入grub引导程序，根据grub.cfg配置，从对应tftp目录下载文件系统和内核并加载启动

其中，使用的ACPI资源表/DTB是UEFI固件初始化好的（引导内核前已放在对应内存），不过cmdline/bootargs可通过grub.cfg进行配置，在加载内核时，grub会传递给UEFI并上报给系统。

    .. figure:: ../../image/bsp/rasp_uefi.png
        :align: center


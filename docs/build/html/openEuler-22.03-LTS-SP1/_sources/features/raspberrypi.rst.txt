.. _raspberrypi:

树莓派4B的支持
######################################

本章主要介绍openEuler Embedded中树莓派4B的构建，使用和特性介绍。

树莓派镜像构建指导
***********************************
**构建环境**

1.构建环境推荐：master, openEuler-22.03-LTS

2.构建指导: :ref:`参考容器环境下的快速构建指导 <container_build>`

- 构建命令示例：

.. code-block:: console

  su openeuler

  source /usr1/openeuler/src/yocto-meta-openeuler/scripts/compile.sh raspberrypi4-64 /usr1/openeuler/src/build/build-raspberrypi4-64/

  bitbake openeuler-image

- 构建镜像生成目录示例：

.. code-block:: console

  /usr1/openeuler/src/build/build-raspberrypi4-64/output


- 二进制介绍：

  1. Image: 树莓派内核镜像

  2. openeuler-glibc-x86-64-openeuler-image-cortexa72-raspberrypi4-64-toolchain-\*.sh: SDK工具链

  3. openeuler-image-raspberrypi4-64-\*.rootfs.rpi-sdimg: openEuler Embedded树莓派支持SD卡镜像

**镜像使用方法**

1.镜像烧录:

- linux

.. code-block:: console
    
  dd if=openeuler-image-raspberrypi4-64-*.rootfs.rpi-sdimg of=/dev/xxxx

**if** : 指定编译好的树莓派镜像文件

**of** : 指定u盘被识别的设备文件, 注意是主设备名, 例如 /dev/sdb, 而不是分区的设备名, 例如 /dev/sdb1, /dev/sdb2

- windows

  参考: `树莓派SD卡烧录指导 <https://gitee.com/openeuler/raspberrypi/blob/master/documents/%E5%88%B7%E5%86%99%E9%95%9C%E5%83%8F.md#%E5%88%B7%E5%86%99-sd-%E5%8D%A1>`_

2.镜像使用

1) 镜像烧录前查看/修改文件

- 使用 losetup 将磁盘镜像文件虚拟成块设备

.. code-block:: console

  losetup -f --show openeuler-image-raspberrypi4-64-*.rootfs.rpi-sdimg

例如，显示结果为 /dev/loop0

- 使用 kpartx 创建分区表 /dev/loop0 的设备映射

.. code-block:: console

  kpartx -va /dev/loop0
    
得到结果是 /dev/loop0 的两个分区设备

.. code-block:: console

  add map loop0p1
  add map loop0p2

运行 ls /dev/mapper/loop0p* 可以看到对应的两个分区

.. code-block:: console

  /dev/mapper/loop0p1 /dev/mapper/loop0p2

- 分区挂载

创建挂载目录

.. code-block:: console

  mkdir ${WORKDIR}/boot ${WORKDIR}/root

挂载boot分区

.. code-block:: console

  mount -t vfat -o uid=root,gid=root,umask=0000 /dev/mapper/loop0p1 ${WORKDIR}/boot

挂载root分区

.. code-block:: console

  mount -t ext4 /dev/mapper/loop0p2 ${WORKDIR}/root

挂载完成后，可以查看boot分区和root分区下树莓派镜像的文件，其中boot分区为启动引导分区，包含了引导程序，内核镜像，设备树，config.txt和cmdline等配置文件，root分区为根文件系统分区。

2) 镜像烧录后查看/修改文件

镜像烧录完成后, 此时插入的读卡器会被识别成两个分区设备, 例如/dev/sdb1, /dev/sdb2

- 分区挂载

创建挂载目录

.. code-block:: console

  mkdir ${WORKDIR}/boot ${WORKDIR}/root

挂载boot分区

.. code-block:: console

  mount -t vfat -o uid=root,gid=root,umask=0000 /dev/sdb1 ${WORKDIR}/boot

挂载root分区

.. code-block:: console

  mount -t ext4 /dev/sdb2 ${WORKDIR}/root

有些情况下(linux系统配置), 分区设备/dev/sdb1, /dev/sdb2会自动挂载, 可以略过分区挂载步骤直接查看/修改文件.

基于openEuler Embedded树莓派使用
**********************************************

**启用树莓派**

硬件版本要求：树莓派4B

默认用户名：root，密码：第一次启动没有默认密码，需重新配置，且密码强度有相应要求， 需要数字、字母、特殊字符组合最少8位，例如openEuler@2022。

将刷写镜像后的SD卡插入树莓派，通电启用。

**分区扩容**

在完成烧录镜像后，首次启动树莓派会自动进行分区扩容，将根目录分区扩展到SD卡的大小。

**树莓派登录方式**

1.本地登录

a.使用串口登录：

镜像使能了串口登录功能，按照树莓派的串口连接方式，如下图，可以启用串口操作。

示例：使用ttyusb转接器，将树莓派串口通过USB连接到putty：

.. image:: ../../image/raspberrypi/rasp-ttyusb-connect.png

putty配置参考： Serial line:ttyUSB0 speed:115200 Connection type:Serial

.. image:: ../../image/raspberrypi/putty_config.png

b.使用HDMI登录：

树莓派连接显示器（树莓派视频输出接口为 Micro HDMI）、键盘、鼠标后，启动树莓派，可以看到树莓派启动日志输出到显示器上。待树莓派启动成功，输入用户名（root）和密码登录。

2.ssh 远程登录

网络配置:

参考 :ref:`网络配置/openEuler Embedded网络配置<network_config>`

使用ssh命令登录:

.. code-block:: console

   ssh root@x.x.x.x

树莓派镜像特性介绍
**************************

1.树莓派硬件特性，参考:`树莓派使用:GPIO介绍 <https://gitee.com/openeuler/raspberrypi/blob/master/documents/%E6%A0%91%E8%8E%93%E6%B4%BE%E4%BD%BF%E7%94%A8.md#gpio>`_

目前已使能串口设备，可以访问mini-uart，其他硬件特性暂不支持。

2.支持百级嵌入式软件包，见软件包功能列表。

3.支持部署rt实时内核。

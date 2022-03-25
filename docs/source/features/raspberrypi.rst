.. raspberrypi:

openEuler嵌入式树莓派系统
#############

树莓派镜像构建指导
************
**构建环境**

1.构建环境推荐：openEuler-20.03 LTS

2.准备好openEuler Embedded 64位镜像发布件，本次版本使用22.03版本，获取地址:`openeuler嵌入式镜像获取 <https://www.openeuler.org/zh/download/>`_

3.构建指导: `参考容器构建指导 <https://openeuler.gitee.io/yocto-meta-openeuler/getting_started/container-build.html>`_

- 构建命令示例:

.. code-block:: console

  su openeuler

  source /usr1/openeuler/src/yocto-meta-openeuler/scripts/compile.sh raspberrypi4-64 /usr1/openeuler/src/build/build-raspberrypi4-64/

  bitbake openeuler-image

- 构建镜像生成目录(示例)：

.. code-block:: console

  /usr1/openeuler/src/build/build-raspberrypi4-64/output


- 二进制介绍：

  1. Image: 树莓派内核镜像

  2. openeuler-glibc-x86-64-openeuler-image-cortexa72-raspberrypi4-64-toolchain-22.03.30.sh: sdk工具链

  3. openeuler-image-raspberrypi4-64-*.rootfs.rpi-sdimg: 树莓派支持sd卡镜像
  

**镜像使用方法**

1.镜像烧录:

参考: `树莓派烧录指导 <https://gitee.com/openeuler/raspberrypi/blob/master/documents/%E5%88%B7%E5%86%99%E9%95%9C%E5%83%8F.md>`_

2.镜像使用

- 使用losetup将磁盘镜像文件虚拟成块设备

.. code-block:: console

  lossetup -f --show openEuler_embedded_raspi.img

例如，显示结果为/dev/loop0

- 使用kpartx创建分区表/dev/loop0的设备映射

.. code-block:: console

  kpartx -va /dev/loop0
    
得到结果将/dev/loop0两个分区设备

.. code-block:: console

  add map loop0p1
  add map loop0p2

运行 ls /dev/mapper/loop0p*可以看到分区分别对应两个分区

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

树莓派镜像使用
************

**启用树莓派**

版本要求:树莓派4B

默认用户名:root，密码:第一次启动需重新配置，长度大于14位，格式：特殊字符+英文字符+数字

将刷写镜像后的SD卡插入树莓派，通电启用

**树莓派登陆方式**

1.本地登陆

a.使用串口登陆：

镜像使能了串口登陆功能，按照树莓派的串口连接方式，如下图，可以启用串口操作；

示例：使用ttyusb转接器，将树莓派串口通过usb连接到putty：

.. image:: ../../image/rasp/rasp-ttyusb-connect.webp

putty配置参考： Serial line:ttyUSB0 speed:115200 Connection type:Serial

b.使用hdmi登陆：

树莓派连接显示器（树莓派视频输出接口为 Micro HDMI）、键盘、鼠标后，启动树莓派，可以看到树莓派启动日志输出到显示器上。待树莓派启动成功，输入用户名（root）和密码登录。

注意：当前镜像默认使能usb串口登陆，如果需要通过hdmi，需要修改相关配置：

（1）修改boot分区下的cmdline参数，添加 console=tty1

（2）将root分区下的/etc/inittab ttyS0修改为tty1
        

2.ssh 远程登录

参考: `树莓派使用:启用树莓派:ssh登陆 <https://gitee.com/openeuler/raspberrypi/blob/master/documents/%E6%A0%91%E8%8E%93%E6%B4%BE%E4%BD%BF%E7%94%A8.md>`_

**分区扩容**

以下内容引用: `树莓派使用:启用树莓派:分区扩容 <https://gitee.com/openeuler/raspberrypi/blob/master/documents/%E6%A0%91%E8%8E%93%E6%B4%BE%E4%BD%BF%E7%94%A8.md>`_

默认根目录分区空间比较小，在使用之前，需要对分区进行扩容。

1.查看磁盘分区信息

.. code-block:: console

  执行 fdisk -l 命令查看磁盘分区信息。回显如下：

  Device        Boot StartCHS   EndCHS        StartLBA  EndBLA  Sectors size Id  Type

  /dev/mmcblk0p1 *   64,0,1     831,3,32      8192      106495  98304   48.0M c  Win95 FAT32(LBA)

  /dev/mmcblk0p2     832,0,1    1023,3,32     106496    360447  253952  124M  83 Linux

SD 卡对应盘符为 /dev/mmcblk0，包括 2 个分区，分别为

.. code-block:: console

  /dev/mmcblk0p1：引导分区

  /dev/mmcblk0p2：根目录分区

这里我们需要将根目录分区 /dev/mmcblk0p2 进行扩容。

2.分区扩容

- 对根目录/dev/mmcblk0p2进行扩容

.. code-block:: console
   
  执行 fdisk /dev/mmcblk0 命令进入到交互式命令行界面，按照以下步骤扩展分区，如下图所示。

  输入 p，查看分区信息。

  记录分区 /dev/mmcblk0p2 的起始扇区号，即 /dev/mmcblk0p2 分区信息中 Start 列的值，示例中为 106496。

  输入 d，删除分区。

  输入 2 或直接按 Enter，删除序号为 2 的分区，即 /dev/mmcblk0p2 分区。

  输入 n，创建新的分区。

  输入 p 或直接按 Enter，创建 Primary 类型的分区。

  输入 2 或直接按 Enter，创建序号为 2 的分区，即 /dev/mmcblk0p2 分区。

  输入新分区的起始扇区号，即第 1 步中记录的起始扇区号，示例中为 106496。

  须知：

  请勿直接按“Enter”或使用默认参数。

  按 Enter，使用默认的最后一个扇区号作为新分区的终止扇区号。

  输入 w，保存分区设置并退出交互式命令行界面。
        
-增大未加载的文件系统大小

.. code-block:: console

   resize2fs /dev/mmcblk0p2

树莓派镜像特性介绍
************

1.树莓派硬件特性，参考:`树莓派使用:GPIO介绍 <https://gitee.com/openeuler/raspberrypi/blob/master/documents/%E6%A0%91%E8%8E%93%E6%B4%BE%E4%BD%BF%E7%94%A8.md#%E5%90%AF%E7%94%A8%E6%A0%91%E8%8E%93%E6%B4%BE>`_

目前已使能串口设备，可以访问mini-uart，其他硬件特性暂不支持。

2.支持百级嵌入式软件包，见软件包功能列表

3.支持部署rt实时内核

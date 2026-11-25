.. _zedboard-boot:

镜像构建与启动流程
##################

构建镜像
========

在 oebuild 工作目录中：

.. code:: bash

   # 初始化（已有工作目录可跳过）
   oebuild init <work_dir>
   cd <work_dir>
   oebuild update

   # 生成 ZedBoard 构建环境
   oebuild generate -p zedboard

   # 构建镜像
   cd build/zedboard
   oebuild bitbake openeuler-image

产物为 ``tmp/deploy/images/zedboard/openeuler-image-zedboard.wic.bz2``，解压后
写入 SD 卡（见 :ref:`zedboard-update`）。

构建配置要点见 ``bsp/meta-zedboard/conf/machine/zedboard.conf``：

- 外部工具链 ``arm-openeuler-linux-gnueabi``，``DEFAULTTUNE = "armv7a"``
  并追加 ``cortexa9``、去掉 ``vfp``，关闭非对齐访问
- 内核镜像 ``zImage``，设备树 ``zynq-zed.dtb``
- U-Boot 使用 ``xilinx_zynq_virt_defconfig``，``DEVICE_TREE=zynq-zed``
- 镜像格式 ``wic.bz2``，分区表 ``sdimage-zedboard.wks``

启动链
======

.. code::

   Zynq BootROM
     -> BOOT.BIN            U-Boot SPL（mkimage -T zynqimage）
     -> u-boot.img          U-Boot proper
     -> boot.scr            mmc rescan; load; source
     -> zImage + zynq-zed.dtb
     -> Linux

关键点：

- BootROM 只识别 FAT32 分区根目录下 **大写** 的 ``BOOT.BIN``，因此 SD 卡第一个
  分区必须是 FAT32，镜像布局使用 ``--mkfs-extraopts="-F 32"``。
- openEuler 的 U-Boot 默认走 bootmenu/EFI 流程，会忽略 ``boot.scr``。
  BSP 在 ``do_compile:prepend`` 中重写 ``CONFIG_BOOTCOMMAND``，把命令固定为
  ``mmc rescan; load mmc 0:1 0x100000 boot.scr; source 0x100000``，并关闭
  ``CONFIG_AUTOBOOT_MENU_SHOW``。
- ``boot.scr`` 由 ``boot.cmd`` 经 ``mkimage`` 生成，内容为：

.. code:: bash

   setenv bootargs console=ttyPS0,115200 net.ifnames=0 root=/dev/mmcblk0p2 rootwait rw
   fatload mmc 0:1 0x00200000 zImage
   fatload mmc 0:1 0x01000000 zynq-zed.dtb
   bootz 0x00200000 - 0x01000000

- 进入 Linux 后，systemd 依次运行 ``zedboard-pl.service`` 编程 PL 并加载 OLED 驱动，
  ``zedboard-oled-banner.service`` 显示横幅，``zedboard-marquee.timer``
  在开机 5 秒后启动跑马灯。

SD 卡布局
=========

.. list-table::
   :header-rows: 1
   :widths: 12 20 30 38

   * - 分区
     - 文件系统
     - 挂载点
     - 内容
   * - 1
     - FAT32（64 MB）
     - ``/boot``
     - ``BOOT.BIN``、``u-boot.img``、``zImage``、``zynq-zed.dtb``、``boot.scr``
   * - 2
     - ext4
     - ``/``
     - openEuler rootfs

第一次启动
==========

1. 用 USB-UART 连接板子，串口参数 115200 8N1，上电后可在 ``ttyPS0`` 看到
   U-Boot 与内核日志，登录用户为 ``root``。
2. 网络默认已配置为静态地址 ``192.168.7.2/24``、网关 ``192.168.7.1``，
   主机侧把对应网卡配置到同一网段即可 SSH 登录。
3. 确认 PL 与显示：

.. code:: bash

   cat /sys/class/fpga_manager/fpga0/state    # operating
   systemctl status zedboard-pl.service
   systemctl status zedboard-marquee.service  # active (running)
   ls /dev/zed_oled
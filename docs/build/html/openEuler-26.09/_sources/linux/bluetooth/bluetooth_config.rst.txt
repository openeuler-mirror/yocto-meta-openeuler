.. _bluetooth_config:

openEuler Embedded蓝牙配置
##########################

本文档介绍如何在openEuler Embedded系统中开启蓝牙，以树莓派4B为例。

环境/工具准备
========================

设备：建议树莓派4B的出厂配置，包括树莓派4B基础套件和SD卡

编译openEuler Embedded版本的树莓派镜像, 并烧录进SD卡中, 参考 :ref:`关键特性/树莓派4B支持/树莓派镜像构建指导<board_raspberrypi4_build>`

蓝牙服务说明
============

openEuler Embedded默认使用 ``systemd`` 作为系统初始化管理器（``INIT_MANAGER = "systemd"``），
因此蓝牙服务由systemd统一管理，而非传统的SysV init脚本。树莓派镜像中与蓝牙相关的systemd服务如下：

- ``bluetooth.service``：由bluez5提供，负责启动 ``bluetoothd`` 守护进程（D-Bus服务，PID 1为systemd）
- ``hciuart.service``：由pi-bluetooth提供，负责配置蓝牙UART串口（由 ``dev-serial1.device`` 自动触发）
- ``bthelper@.service``：由pi-bluetooth提供，当udev检测到HCI设备时自动触发

.. attention::

   树莓派镜像中 **不存在** ``/etc/init.d/bluetooth`` 脚本。openEuler Embedded使用systemd且不在
   ``DISTRO_FEATURES`` 中包含 ``sysvinit``，Yocto的 ``systemd.bbclass`` 会在打包阶段通过
   ``rm_sysvinit_initddir`` 删除冗余的SysV init脚本，仅保留systemd service文件。
   因此请使用 ``systemctl`` 命令而非 ``/etc/init.d/`` 脚本来管理蓝牙服务。

蓝牙使用说明
============

使用如下命令开启蓝牙：

- 开启蓝牙

  ``bluetooth.service`` 默认已启用（preset为enable），系统启动时 ``bluetoothd`` 会自动启动。
  如果服务未运行，可手动启动：

  .. code-block:: console

    # 启动蓝牙守护进程
    $ systemctl start bluetooth

    # 查看蓝牙服务状态
    $ systemctl status bluetooth

    # 启动蓝牙设备（将hci0接口up），必须执行
    $ hciconfig hci0 up

  如果开启成功，则可以使用hciconfig命令查看蓝牙设备信息，表示设备已经启动：

  .. code-block:: console

    $ hciconfig
    hci0:	Type: Primary  Bus: UART
    BD Address: xx:xx:xx:xx:xx:xx  ACL MTU: 1021:8  SCO MTU: 64:1
    UP RUNNING
    ...

- 扫描设备

  .. code-block:: console

    $ bluetoothctl
    $ scan on

  扫描到的设备会显示在终端上，如下所示：

  .. code-block:: console

    [NEW] Device xx:xx:xx:xx:xx:xx xx:xx:xx:xx:xx:xx
    [CHG] Device xx:xx:xx:xx:xx:xx RSSI: -79
    ...

- 开启被发现

  .. code-block:: console

    $ bluetoothctl discoverable on

  开启后可以被其他设备发现。正常的输出如下：

  .. code-block:: console

    Changing discoverable on succeeded

  开启后，在其他设备的蓝牙搜索列表中可以看到本设备。

.. attention::

   **关于蓝牙设备名称：**

   BlueZ在 ``/etc/bluetooth/main.conf`` 中的 ``Name`` 配置项被注释掉时（默认状态），
   蓝牙适配器名称会回退为系统主机名（hostname）。树莓派镜像的主机名默认为
   ``raspberrypi4-64``，因此其他设备搜索到的名称为 ``raspberrypi4-64``，
   而非 ``BlueZ <版本号>``。

   若希望显示为 ``BlueZ``，需编辑 ``/etc/bluetooth/main.conf``，取消注释 ``Name`` 项：

  .. code-block:: ini

    # /etc/bluetooth/main.conf
    [General]
    Name = BlueZ

  修改后重启蓝牙服务使配置生效：

  .. code-block:: console

    $ systemctl restart bluetooth

.. attention::

   1. 当前openEuler Embedded版本蓝牙暂不支持配对和链接，在后续版本提供支持

   2. 软总线ble发现只需要开启蓝牙即可。另外软总线ble发现部分未对资源回收，一旦服务端和客户端退出后再次使用ble发现需要关闭后再开启蓝牙，即hciconfig hci0 down/up。

.. _bluetooth_config:

openEuler Embedded蓝牙配置
##########################

本文档介绍如何在openEuler Embedded系统中开启蓝牙，以树莓派4B为例。

环境/工具准备
========================

设备：建议树莓派4B的出厂配置，包括树莓派4B基础套件和SD卡

编译openEuler Embedded版本的树莓派镜像, 并烧录进SD卡中, 参考 :ref:`关键特性/树莓派4B支持/树莓派镜像构建指导<board_raspberrypi4_build>`

蓝牙使用说明
============

使用如下命令开启蓝牙：

- 开启蓝牙

  .. code-block:: console

    # 默认系统启动的时候bluetooth进程已经启动
    # 如果没有启动，可以使用如下命令启动
    $ /etc/init.d/bluetooth start

    # 启动蓝牙设备，必须执行
    $ hciconfig hci0 up

  如果开启成功，则可以使用hciconfig命令查看蓝牙设备信息,表示设备已经启动：

  .. code-block:: console

    $ hciconfig
    hci0:	Type: Primary  Bus: UART
    BD Address: xx:xx:xx:xx:xx:xx  ACL MTU: 1021:8  SCO MTU: 64:1
    UP RUNNING
    ...

- 扫描设备

  .. code-block:: console

    $ bluetoothctl scan on

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

  并且，利用其他设备，打开蓝牙搜索选项，可以看到名为“BlueZ [current version number]”的设备。

.. attention::

   1. 当前openEuler Embedded版本蓝牙暂不支持配对和链接，在后续版本提供支持
   
   2. 软总线ble发现只需要开启蓝牙即可。另外软总线ble发现部分未对资源回收，一旦服务端和客户端退出后再次使用ble发现需要关闭后再开启蓝牙，即hciconfig hci0 down/up。

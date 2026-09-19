.. _rpi4_mcs_zephyr:

树莓派4B MCS + Zephyr 使用指南
##################################

概述
====

树莓派4B（raspberrypi4-64）支持 MCS（混合关键性系统）特性，可同时运行 Linux 和
实时操作系统（RTOS）。目前支持以下三种 RTOS：

================== ============== ===========================
RTOS               模式           说明
================== ============== ===========================
UniProton          openamp        轻量级实时操作系统
UniProton-GDB      openamp        UniProton 的 GDB 调试版本
Zephyr             openamp        Zephyr RTOS（需启用 zephyr 特性）
================== ============== ===========================

构建 MCS 镜像
=============

1. 构建 MCS 基础镜像（包含 UniProton）
----------------------------------------

.. code-block:: console

   $ oebuild generate -p raspberrypi4-64 -f mcs -d <build_mcs>
   $ oebuild bitbake -d <build_mcs> openeuler-image

2. 构建 MCS + Zephyr 镜像
---------------------------

若需要在镜像中额外包含 Zephyr RTOS 固件（``zephyr.elf``），需在 ``compile.yaml``
中将 ``zephyr`` 添加到 ``MCS_FEATURES``，并添加 ``meta-zephyr`` layer：

.. code-block:: yaml

   local_conf: |
     MCS_FEATURES ?= "openamp lopper-devicetree zephyr"
     DISTRO_FEATURES:append = " mcs"
     RPI_USE_UEFI:raspberrypi4-64 = "1"
   layers:
   - yocto-meta-raspberrypi
   - yocto-meta-openeuler/rtos/meta-openeuler-rtos
   - yocto-meta-openeuler/rtos/meta-zephyr

.. note::

   ``MCS_FEATURES`` 可包含以下值（以空格分隔）：

   - ``openamp``：裸金属部署模式（默认）
   - ``jailhouse``：Jailhouse 虚拟化模式（与 ``openamp`` 互斥）
   - ``zephyr``：构建 Zephyr RTOS 固件
   - ``lopper-devicetree``：使用 lopper 处理设备树

   构建 Zephyr 需要额外添加 ``meta-zephyr`` layer。

使用 mica 管理 RTOS
===================

镜像烧录到树莓派后，启动系统，可通过 ``mica`` 命令管理 RTOS。

查看状态
--------

.. code-block:: console

   # 查看所有 RTOS 状态
   mica status

   # 输出示例：
   # Name                          Assigned CPU        State               Service
   # uniproton                     3                   Offline
   # uniproton-gdb                 3                   Offline
   # rpi4-zephyr                   3                   Offline

启动 RTOS
---------

.. code-block:: console

   # 启动 UniProton
   mica start uniproton

   # 启动 UniProton-GDB 调试版本
   mica start uniproton-gdb

   # 启动 Zephyr
   mica start rpi4-zephyr

启动成功后，``mica status`` 会显示 ``Running`` 状态，并列出可用的 RPMsg 服务
（如 ``rpmsg-tty``、``rpmsg-rpc``、``rpmsg-umt``）。

停止 RTOS
---------

.. code-block:: console

   mica stop uniproton
   mica stop rpi4-zephyr
   mica stop uniproton-gdb

Mica 配置文件
-------------

RTOS 的 mica 配置文件位于 ``/etc/mica/`` 目录下：

.. list-table::
   :header-rows: 1

   * - 配置文件
     - RTOS
     - 运行模式
   * - ``rpi4-uniproton.conf``
     - UniProton
     - openamp（裸金属）
   * - ``rpi4-uniproton-gdb.conf``
     - UniProton (GDB 调试)
     - openamp（裸金属）
   * - ``rpi4-zephyr.conf``
     - Zephyr
     - openamp（裸金属）

.. note::

   ``rpi4-zephyr-ivshmem.conf``（Jailhouse 模式）仅在 ``MCS_FEATURES`` 包含
   ``jailhouse`` 时才会安装。默认 openamp 模式下不安装此配置。

.. warning::

   目前 rpi_4b 仅支持 ``remote``（openamp）板型变体。``ivshmem``（jailhouse）
   板型变体尚未实现，因为 rpi4 的 PCIe 硬件配置与 QEMU 不同，需要额外的
   设备树节点和驱动适配。使用 ``jailhouse`` 模式构建 Zephyr 会在配置阶段
   报错 "Board qualifiers not found"。

树莓派4B PSCI 限制
===================

**重要**：树莓派4B 的 UEFI 固件 PSCI 实现存在限制，**CPU_OFF 后无法再次 CPU_ON**。

原因分析
--------

- 树莓派4B 的 BCM2711 SoC 四个 Cortex-A72 核共享同一电源域，无法真正单独断电
- UEFI 固件的 PSCI ``CPU_OFF`` 仅让 CPU 进入 WFI 睡眠状态，但不清除内部 ``cpu_on``
  状态标记
- 后续 ``CPU_ON`` 检查发现状态仍为 "ON"，返回 ``ALREADY_ON (-4)`` 错误

影响
----

- 从干净重启状态启动任意 RTOS **可成功**
- 停止 RTOS（``mica stop``）后，**无法再次启动任何 RTOS**
- 需要重启树莓派才能切换到另一个 RTOS

正确使用方式
------------

1. 重启树莓派
2. 启动需要的 RTOS：``mica start <rtos_name>``
3. 使用完毕后停止：``mica stop <rtos_name>``
4. 如需切换 RTOS，请**先重启树莓派**，再重复步骤 2-3

.. warning::

   请勿在未重启的情况下尝试启动第二个 RTOS，``mica status`` 可能会显示
   ``Running``，但实际 CPU 未启动成功，且无 RPMsg 服务。

固件地址布局
============

Zephyr 固件的内存布局（在 Linux 端通过 ``readelf -l`` 查看）：

=================== ====================== ===========================
段                  物理地址                说明
=================== ====================== ===========================
IPC 共享内存        0x70000000-0x700fffff  1MB，用于 Linux 与 RTOS 通信
Zephyr 代码段       0x7a000000-0x7a0459f0  text/data
UniProton 代码段    0x7b000000             text/data
=================== ====================== ===========================

上述地址均在 Linux 端通过 DTS overlay 预留的 ``mcs_baremetal_mem`` 区域内。


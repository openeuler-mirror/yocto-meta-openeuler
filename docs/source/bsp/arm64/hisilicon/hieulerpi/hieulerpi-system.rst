.. _hieulerpi_system:

海鸥派系统架构、启动流程与内存/存储布局
##########################################

.. contents::
   :local:

海鸥派主控 SS928 内置四核 Cortex-A55@1.4GHz 和一颗 32bit RISC-V
MCU@500MHz，同时提供 NPU、DSP 等异构算力。Linux 运行在 A55 上，
RISC-V MCU 运行 LiteOS，二者通过 IPCM 通信。硬件规格见
:ref:`board_hieulerpi_hardware_features`。

一、启动流程
============

1. **BootROM**：上电后 SS928 BootROM 初始化时钟/DDR/eMMC，并从 eMMC
   用户区偏移 0（p1 ``boot``\ ）加载 ``boot_image_8G.bin``\ （U-Boot
   2020.01）。

2. **U-Boot**：从 p2 ``env`` 读取环境变量，默认 ``boot_media=emmc``\ 。

3. **preboot**：扫描 SD 卡（\ ``mmc 1``\ ）各分区的
   ``/boot/env_append.txt``\ ，找到后导入环境变量。若 ``update=yes``\ ，
   执行 ``updatecmd`` 将 SD 中的镜像写入 eMMC，然后执行
   ``setenv update no; saveenv``\ 。

4. **bootcmd**：从 eMMC 2MiB 处（p3 ``kernel``\ ）读取 16MiB 到
   ``0x42000000``\ ，追加 ``mem``/``total_mem_size``/``root`` 启动参数
   后执行 ``bootm``\ ：

   .. code-block:: console

      mmc read 0 0x42000000 0x1000 0x8000
      setenv bootargs "... root=/dev/mmcblk0p4"
      bootm 0x42000000

5. **FIP**：p3 中是 ``kernel-pi``\ （FIP 镜像），包含 TF-A BL31（EL3）
   和 BL33（Linux 内核 + DTB）。BL31 先运行，随后启动 Linux。

6. **Linux**：根据启动参数 ``blkdevparts`` 创建 p1-p4（eMMC 没有
   分区表），挂载 p4 ext4 为根文件系统，启动 systemd。

7. **BSP/systemd**：\ ``hieulerpi1-bsp.service`` 执行
   ``S90AutoRun``/``pinmux.sh``\ ，加载 IPCM/NPU/DSP 并启动 RISC-V
   LiteOS；\ ``hieulerpi1-set-mac.service`` 设置稳定 MAC；
   ``hieulerpi1-clear-update.service`` 兜底清除升级标志。

.. note::

   U-Boot 默认从 eMMC 启动。\ ``boot_media=sd`` 时从 SD 卡 p1 加载
   kernel、根文件系统指向 ``/dev/mmcblk1p2``\ ，需要单独准备 SD 启动卡，
   见 :ref:`SD卡启动`。

二、内存布局
============

DDR 起始地址为 ``0x40000000``\ ，各硬件单元使用固定 carveout。以本板
8GB 内存、Linux 侧 ``mem=6144M`` 为例：

.. list-table::
   :header-rows: 1
   :widths: 18 16 66

   * - 起始地址
     - 大小
     - 用途
   * - ``0x40000000``
     - 2 MiB
     - IPCM 共享内存
   * - ``0x40200000``
     - 62 MiB
     - DSP
   * - ``0x44000000``
     - 192 MiB
     - RISC-V MCU，LiteOS 加载地址
   * - ``0x50000000``
     - 6144 MiB（本板）
     - Linux 内核/OS
   * - ``0x1D0000000``
     - 1792 MiB（8GB 总量时）
     - MMZ（NPU/媒体内存池）

本板启动脚本根据 ``/proc/cmdline`` 中的 ``mem=6144M`` 和
``total_mem_size=8G`` 设置内存切分：

.. code-block:: console

   ./load_ss928v100 -i -total 8192 -osmem 6144

``load_ss928v100`` 的默认配置为 4GB 总内存、512MB OS 内存；本板计算
得到的 MMZ 起始地址/大小如下：

.. code-block:: console

   mmz_start: 0x1d0000000, mmz_size: 1792M

即 IPCM/DSP/MCU 位于 Linux 内核起始地址 ``0x50000000`` 以下，Linux
使用 6GB OS 内存，剩余约 1792MB 作为 MMZ 供 NPU/媒体使用。

三、eMMC 分区布局
=================

eMMC 没有 GPT/MBR 分区表，\ ``sfdisk``/``parted`` 会报
``unrecognized disk label``\ 。p1-p4 由内核启动参数创建：

.. code-block:: console

   blkdevparts=mmcblk0:1M(boot),1M(env),16M(kernel),-(rootfs)
   root=/dev/mmcblk0p4

.. list-table::
   :header-rows: 1
   :widths: 16 16 20 48

   * - 偏移
     - 大小
     - 设备
     - 作用
   * - ``0x0000000``
     - 1 MiB
     - ``mmcblk0p1``
     - ``boot``\ ：\ ``boot_image_8G.bin``\ （U-Boot 引导镜像）
   * - ``0x0100000``
     - 1 MiB
     - ``mmcblk0p2``
     - ``env``\ ：U-Boot 环境变量
   * - ``0x0200000``
     - 16 MiB
     - ``mmcblk0p3``
     - ``kernel``\ ：\ ``kernel-pi``\ （FIP：BL31 + Linux + DTB）
   * - ``0x1200000``
     - 剩余
     - ``mmcblk0p4``
     - ``rootfs``\ ：ext4 根文件系统

补充说明：

- ``mmcblk0boot0``/``mmcblk0boot1``\ （各 4MiB）为 eMMC 硬件 Boot
  Partition，本方案中为空，未参与启动。
- ``mmcblk0rpmb``\ （4MiB）为 RPMB 安全存储，当前系统未使用。
- U-Boot 环境通过 ``/etc/fw_env.config`` 访问
  ``/dev/mmcblk0p2 0x0 0x100000``\ 。
- U-Boot ``updatecmd`` 按固定偏移写入：\ ``boot_image``\ @0、
  ``boot_env``\ @1MiB、\ ``kernel``\ @2MiB、\ ``rootfs``\ @18MiB。
- p3 固定 16MiB，\ ``kernel-pi`` 必须小于 16MiB。
- 不要使用 ``sfdisk``/``parted`` 重新分区 eMMC；修改布局需要同步修改
  ``blkdevparts``\ 、U-Boot ``part_*`` 和升级脚本。

四、RISC-V 小核（MCU/LiteOS）
=============================

- 硬件：SS928 内置一颗 **32bit RISC-V MCU@500MHz**。
- 内存：MCU carveout 为 192MiB，起始地址 ``0x44000000``\ 。
- 固件：\ ``/firmware/LiteOS.bin``\ ，约 173KB，是裸 RISC-V 二进制。
- 加载：

  .. code-block:: console

     load_riscv 0x44000000 /firmware/LiteOS.bin

  ``load_riscv`` 通过 ``/dev/mem`` 把固件复制到 MCU 区域并启动 RISC-V
  核，成功时输出 ``The RISCV started!`` / ``SUCCESS START RISCV``\ 。
  该过程没有 Linux remoteproc/rpmsg 驱动参与。

- 开机初始化：\ ``hieulerpi1-bsp.service`` 执行 ``S90AutoRun``\ ；
  ``S90AutoRun`` 在加载 IPCM/NPU/DSP 模块后执行上述 ``load_riscv``\ 。

- IPC：

  - IPCM 控制器：\ ``ipcm@11031000``\ ；共享内存 2MiB @ ``0x40000000``\ 。
  - Linux 侧：\ ``ipcm.ko``\ ，设备节点 ``/dev/ipcm``\ 。
  - LiteOS 侧：\ ``/dev/ipcm``\ 、\ ``/proc/ipcm``\ 、\ ``proc_ipcm`` 命令。

- 虚拟串口：

  - 内核模块 ``virt-tty.ko`` 依赖 ``ipcm.ko``\ ，创建
    ``/dev/virt-tty/riscv``\ 。
  - 在 Linux 中执行 ``virt-tty riscv`` 可进入 LiteOS shell，提示符为
    ``Huawei LiteOS #``\ 。常用命令包括 ``help``\ 、\ ``systeminfo``\ 、
    ``uname``\ 、\ ``free``\ 、\ ``task``\ 、\ ``proc_ipcm``\ 、\ ``i2c_read``\ 、
    ``i2c_write``\ 、\ ``ssp_read``\ 、\ ``ssp_write`` 等。
  - ``virt-tty`` 是单客户端设备；异常断开后如果无法再次连接，可重启
    板卡恢复。

- NPU/DSP 是独立的 carveout/模块，由 ``load_ss928v100`` 加载；
  RISC-V MCU 与它们通过 IPCM/共享内存协作。

五、BSP 服务
============

.. list-table::
   :header-rows: 1
   :widths: 34 66

   * - 服务
     - 作用
   * - ``hieulerpi1-bsp.service``
     - 执行 ``S90AutoRun``/``pinmux.sh``\ ，加载 BSP 模块、IPCM、NPU、
       DSP，启动 RISC-V LiteOS
   * - ``hieulerpi1-fb.service``
     - 启动 FB 示例工具；兼容 kernel5 的
       ``/root/device_sample/ss928_fb_tool/ss928_fb_tool`` 和 kernel6 的
       ``/root/sample/ss928_fb_tool``
   * - ``hieulerpi1-set-mac.service``
     - 从 eMMC CID 派生每板唯一的稳定 MAC
   * - ``hieulerpi1-clear-update.service``
     - 升级后兜底清除 U-Boot ``update`` 标志，防止重复刷写

这些服务在 systemd 镜像中默认启用（kernel5/kernel6 均适用）。
kernel5 与 kernel6 的 ``S90AutoRun`` 内容不同：kernel5 使用厂商脚本，
kernel6 使用 ``load_sdk_driver -i``\ ，但 systemd 服务本身与内核版本无关。

.. note::

   在线升级镜像的完整步骤见 :ref:`hieuler_update`。
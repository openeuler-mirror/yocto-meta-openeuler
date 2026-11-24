.. _zedboard-hardware:

ZedBoard 硬件资源
#################

PS 侧资源
=========

PS（Processing System）外设由 openEuler Embedded 的 5.10 内核直接支持，
内核配置片段见 ``bsp/meta-zedboard/recipes-kernel/linux/files/zedboard.cfg``，
设备树在 ``zynq-zed.dtb`` 基础上由
``0001-ARM-dts-zynq-zed-add-PL-design-nodes.patch`` 补充 PL 节点。

.. list-table::
   :header-rows: 1
   :widths: 22 30 48

   * - 外设
     - 驱动
     - 说明
   * - CPU
     - ``ARCH_ZYNQ`` / ``SMP`` / ``CACHE_L2X0``
     - 双核 Cortex-A9，armv7a、soft-float
   * - DDR3
     - 设备树内存节点
     - 512 MB
   * - SD 卡
     - ``MMC_SDHCI_OF_ARASAN``
     - ``/dev/mmcblk0``，系统启动与根文件系统
   * - 以太网
     - ``MACB`` + ``MARVELL_PHY``
     - ``eth0``，1 Gbps；MAC 固定为 ``00:0a:35:00:01:22``
   * - 串口
     - ``SERIAL_XILINX_PS_UART``
     - 控制台 ``ttyPS0``，115200 8N1
   * - USB
     - ``USB_CHIPIDEA`` 模块
     - USB OTG/Host
   * - I2C
     - ``I2C_CADENCE`` 模块
     - ``i2c0``/``i2c1`` 设备树已使能
   * - SPI
     - ``SPI_CADENCE`` 模块
     - PS SPI 控制器可用；QSPI Flash 暂未适配（探测返回 EINVAL）
   * - XADC
     - ``XILINX_XADC``
     - ``/sys/bus/iio/devices/iio:device0``
   * - 看门狗
     - ``CADENCE_WATCHDOG``
     - ``/dev/watchdog``
   * - PL 编程
     - ``FPGA_MGR_ZYNQ_FPGA``
     - ``/sys/class/fpga_manager/fpga0``
   * - RTC
     - 无
     - PS RTC 无主线驱动，系统时间由用户态设置

.. note::

   启动参数带 ``net.ifnames=0``，网卡固定命名为 ``eth0``，默认静态地址
   ``192.168.7.2/24``，与 openEuler Embedded 其他板卡保持一致。

预编译 PL 逻辑
==============

镜像使用 **原厂（Digilent ZedBoard OOB）预编译 bitstream**，不在 openEuler 侧
做 PL 开发。PL 的主要作用是把板载按键、LED、拨码开关和 Pmod OLED 通过
**EMIO GPIO** 暴露给 PS，这些信号全部由 PS GPIO 控制器直接驱动，PL 内没有
AXI GPIO、SPI 等 IP。

.. list-table::
   :header-rows: 1
   :widths: 26 26 48

   * - 功能
     - EMIO GPIO
     - 设备树/驱动
   * - OLED ``VBAT``/``VDD``/``RES``/``DC``
     - 55/56/57/58
     - ``zed_oled`` 节点，驱动 ``pmodoled-gpio``
   * - OLED ``SCLK``/``SDIN``
     - 59/60
     - GPIO 模拟 SPI（mode 0）
   * - LED ``ld0``–``ld7``
     - 61–68
     - ``gpio-leds``
   * - 拨码开关 ``sw0``–``sw7``
     - 69–76
     - ``gpio-keys``，对应 ``BTN_0``–``BTN_7``

PL 侧能力说明：

- **没有 SPI master**：Pmod 引脚只连到 EMIO GPIO，因此 OLED 由内核模块
  ``pmodoled-gpio`` 用 GPIO 模拟 SPI（512 字节/帧，约 166 kHz，一帧约 25 ms）。
  想改用硬件 SPI 必须重做 PL，把 PS SPI 路由到 EMIO 或加入 AXI Quad SPI IP。
- **按键 BTN0–BTN4 不可用**：当前 bitstream 未把这 5 个板载按键路由到 PS
  GPIO，Linux 侧没有输入事件源。
- **HDMI 与音频未启用**：原厂设计中的 HDMI（ADV7511）和音频（ADAU1761）
  相关逻辑为私有 IP，5.10 内核没有对应驱动，镜像不做支持。
- PL 内部时钟：设备树打开了 4 路 FCLK，设备树中为 ``fclk-enable = <0xf>``。

bitstream 的安装与加载
======================

- bitstream 文件不随仓库分发（``bsp/meta-zedboard/files/bitstream/*.bin``
  被 gitignore），构建时通过 ``ZEDBOARD_BITSTREAM`` 指向实际文件，默认路径为
  ``bsp/meta-zedboard/files/bitstream/system.bit.bin``。
- ``zedboard-plfw`` 把它安装到 ``/lib/firmware/system.bit.bin``。
- 开机由 ``zedboard-pl.service`` 加载 ``zedboard-pl`` 模块，模块通过
  ``fpga_mgr_load()`` 把 bitstream 写入 ``fpga0``，完成后
  ``/sys/class/fpga_manager/fpga0/state`` 为 ``operating``。
- 同一服务随后加载 ``pmodoled-gpio``，OLED 横幅服务在设备节点就绪后显示
  “openEuler Embedded”。

已知限制
========

- 5 个板载按键（BTN0–BTN4）没有 PS GPIO 通路。
- HDMI、音频不使用（私有 IP，无 5.10 驱动）。
- QSPI Flash 暂未适配，系统只使用 SD 卡。
- 没有 PS RTC 驱动，断电后系统时间需要重新设置。
.. _zedboard-usage:

板载功能使用
############

开机自启的服务
==============

.. list-table::
   :header-rows: 1
   :widths: 34 26 40

   * - 服务
     - 类型
     - 作用
   * - ``zedboard-pl.service``
     - oneshot
     - 加载 ``zedboard-pl`` 编程 PL，随后加载 ``pmodoled-gpio``
   * - ``zedboard-oled-banner.service``
     - oneshot
     - 把 ``/usr/share/zedboard/oled-banner.bin`` 写入 OLED
   * - ``zedboard-marquee.timer``
     - timer
     - 开机 5 秒后触发跑马灯服务
   * - ``zedboard-marquee.service``
     - simple
     - 持续运行 LED 跑马灯，直到服务停止

LED 跑马灯
==========

``/usr/bin/zed-marquee [steps] [delay_seconds]``：8 个 LED 依次点亮，默认每个
位置停留 1 秒；``steps`` 为 0 表示一直运行，服务使用
``zed-marquee 0 1`` 持续跑马灯。

.. code:: bash

   zed-marquee 16 1     # 走 16 步后退出（结束时全部熄灭）
   zed-marquee 0 0.5    # 持续运行，每步 0.5 秒
   systemctl stop zedboard-marquee.service   # 停止并熄灭所有 LED

拨码开关映射
============

``/usr/bin/zed-switch-led`` 读取 ``/dev/input/event0`` 上的 ``BTN_0``–``BTN_7``
事件，把 8 个拨码开关的状态实时映射到 ``ld0``–``ld7``。该工具 **不随系统自启**，
需要手动运行：

.. code:: bash

   zed-switch-led &

开关拨到 1 时对应 LED 点亮，拨到 0 时熄灭；程序启动时会先同步一次当前状态。

OLED
====

OLED 是 SSD1306 兼容的 128x32 单色屏，通过 ``/dev/zed_oled`` 访问：

- 一帧 512 字节，按 4 页 × 128 列组织；
- 写入一次即整帧刷新，例如 ``cat frame.bin > /dev/zed_oled``；
- 读回得到当前帧（最多 512 字节）。

开机横幅 “openEuler Embedded” 由 ``zedboard-plfw`` 安装的位图显示。面板存在
水平镜像，位图已预翻转；需要修改文字时重新生成：

.. code:: bash

   python3 bsp/meta-zedboard/tools/gen-oled-banner.py "openEuler" "Embedded" \
       > bsp/meta-zedboard/recipes-bsp/plfw/files/oled-banner.bin

网络与控制台
============

- 控制台：``ttyPS0``，115200 8N1，登录用户 ``root``
- 网络：``eth0`` 固定命名，由 ``net.ifnames=0`` 控制，静态地址
  ``192.168.7.2/24``，网关 ``192.168.7.1``，MAC 固定为
  ``00:0a:35:00:01:22``
- 主机侧建议使用 USB-UART 作为托底通道：网络异常时仍可通过串口登录排查

免责提示
========

在线更新会整盘覆盖 SD 卡，属于不可逆操作；执行前确认镜像来源正确，并保留
离线刷写这一兜底手段。
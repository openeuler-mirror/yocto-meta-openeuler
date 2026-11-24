.. _zedboard-update:

镜像更新
########

提供两种方式： **在线更新** （不拔卡，通过 kexec 进入更新器）和
**离线刷写** （把 SD 卡插入主机直接写）。在线更新失败或写坏时，以离线刷写托底。

在线更新（kexec + initramfs）
=============================

设计
----

不经过 U-Boot，也不使用 NFS 或桥接网络。板上正在运行的系统通过 SSH 接收一个
kexec 内核与最小 initramfs，切换到更新器后由主机把新镜像推过去，全部连接都由
主机主动发起，因此虚拟机可以保持 NAT 网络。

.. code::

   主机: 上传 uImage + updater.cpio.gz -> kexec 载入 -> kexec -e
   更新器: 静态 192.168.7.2，TCP 9000 监听
   主机: 推送 openeuler-image-zedboard.wic.bz2
   更新器: 缓存到 RAM -> bzip2 -t -> 写 /dev/mmcblk0 -> 回读 sha256 -> 重启

安全不变量：

1. 整条流先缓存到内存，``bzip2 -t`` 校验通过之前不碰 SD 卡；
2. 传输 60 秒无进展或超过上限时放弃，SD 卡保持原状；
3. 写完后从块设备读回整段镜像计算 sha256，与主机比较，不一致则等待重试；
4. 只有校验通过才自动重启；失败或写入一半中断时走离线刷写；
5. 更新器由 kexec 从内存启动，写卡时根分区没有挂载。

镜像大小限制
------------

更新器把收到的压缩流缓存到内存（initramfs 的 ``/tmp``，内存文件系统），
``bzip2 -t`` 校验通过后才开始写 SD 卡。因此可在线更新的镜像大小受板端可用
内存限制：

- 板载 512 MB DDR，内核与 initramfs 启动后 ``MemTotal`` 约 497 MB，可用
  内存约 450–480 MB；
- 更新器默认硬上限为 ``upd_max=400000000``，约 381 MiB，超过立即中止
  传输，SD 卡不会被改动；
- 当前镜像压缩后约 90 MB（解压后约 549 MB），远低于上限。

压缩镜像超出内存时的行为：写满内存或触发 ``upd_max`` 后传输失败，归档校验
不通过，更新器记录日志并等待重试，SD 卡保持原状；此时应改用离线刷写。
如果将来镜像超过该限制，可改为“边接收边写 + 写后 sha256 校验”的流式方案，
但校验失败时卡片已被覆盖，只能依赖离线刷写兜底。当前实现选择优先保证 SD 卡
不被写坏，而不是支持任意大小的在线更新。

准备更新器文件，放在 ``output/zedboard/updater/`` 目录下
----------------------------------------------------------------------

.. code:: bash

   # 静态 busybox：在 oebuild 构建容器内执行
   # 工具链前缀：/usr1/openeuler/gcc/openeuler_gcc_arm32le/bin/arm-openeuler-linux-gnueabi-
   bsp/meta-zedboard/tools/remote-update/build-busybox.sh \
       --tarball /usr1/openeuler/src/openeuler/busybox/busybox-1.36.1.tar.bz2 \
       --config /usr1/openeuler/src/openeuler/busybox/busybox-static.config \
       --cross /usr1/openeuler/gcc/openeuler_gcc_arm32le/bin/arm-openeuler-linux-gnueabi- \
       --out /home/openeuler/build/zedboard/busybox-arm-static

   # 更新器 initramfs
   bsp/meta-zedboard/tools/remote-update/build-initramfs.sh \
       --busybox output/zedboard/updater/busybox-arm-static \
       --out output/zedboard/updater/updater.cpio.gz

   # kexec 只接受 uImage；zImage 会静默挂起
   uboot-mkimage -A arm -O linux -T kernel -C none \
       -a 0x00200000 -e 0x00200000 -n openEuler-zedboard-updater \
       -d zImage output/zedboard/updater/uImage

执行更新
--------

.. code:: bash

   # 预演：上传、kexec、推送、归档校验全部执行，但只写 /dev/null
   python3 bsp/meta-zedboard/tools/remote-update/zedboard-remote-update.py \
       --image output/zedboard/openeuler-image-zedboard.wic.bz2 \
       --updater-dir output/zedboard/updater

   # 真正写卡，校验通过后板子自动重启
   python3 bsp/meta-zedboard/tools/remote-update/zedboard-remote-update.py \
       --image output/zedboard/openeuler-image-zedboard.wic.bz2 \
       --updater-dir output/zedboard/updater --write

说明：

- 默认是 dry run，必须显式加 ``--write`` 才会覆盖 SD 卡。
- 需要 SSH 公钥登录 ``root@192.168.7.2``，用 ``--ssh-key`` 指定私钥，默认
  ``~/.ssh/id_ed25519``；读取串口进度需要 ``python3-pyserial``，
  ``--serial ""`` 可禁用。
- 更新过程中不要断电。若输出 ``update NOT verified``，检查串口日志，
  必要时使用下面的离线刷写。

离线刷写
========

把 SD 卡插入主机后，将 wic 镜像解压并整体写入卡设备（**整盘写入，不是分区**）。

.. code:: bash

   # 确认卡设备，务必核对容量和型号，写错设备会丢失主机数据
   lsblk -o NAME,SIZE,MODEL

   bzip2 -dc openeuler-image-zedboard.wic.bz2 | \
       sudo dd of=/dev/sdX bs=4M conv=fsync status=progress
   sync

- ``/dev/sdX`` 是整张 SD 卡设备，例如 ``/dev/sdc``，不要写 ``/dev/sdc1``。
- 写完后安全弹出，插回板子上电即可。
- 校验写入结果时不要用运行中的系统整卡哈希（rootfs 会写日志而改变内容），
  可以对比 boot 分区（卡起始 64 MiB）与主机镜像的哈希，或重新离线读取校验。

更新后确认
==========

.. code:: bash

   uptime -p
   cat /sys/class/fpga_manager/fpga0/state          # operating
   systemctl is-active zedboard-pl.service \
       zedboard-oled-banner.service zedboard-marquee.service
   systemctl --failed --no-legend                    # 输出为空
   ip -br addr show eth0                             # 192.168.7.2/24

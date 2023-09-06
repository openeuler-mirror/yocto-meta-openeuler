轻量级虚拟化工具 Jailhouse
##########################

总体介绍
========

   Jailhouse 是一种轻量级虚拟化工具，与传统的全功能虚拟化解决方案（如 KVM 和 Xen）不同，它不提供完整的虚拟机管理和抽象功能，
   而是一种基于Linux的静态分区虚拟化方案。Jailhouse 不支持任何设备模拟，不同客户虚拟机之间也不共享任何 CPU，所以也没有调度器。

   Jailhouse 的工作是将硬件资源进行静态分区，每个分区称为一个 cell，每个 cell 之间是相互隔离开的，并且拥有自己的硬件资源(CPU、内存、外设等)，
   运行在 cell 内的裸机应用程序或操作系统称为 inmate。
   Jailhouse 的第一个 cell 叫 Root Cell，这是一个特权Cell，内部运行的是一个 Linux 系统，依赖该 Linux 接管系统硬件资源，以及进行硬件的初始化和启动。
   除了 Root Cell 的其它 cell 统一称为 Non-root Cell，从 Root Cell 中获取系统资源，可独占或与 Root Cell 共享。

____

Jailhouse 构建指导
==================

   openEuler Embedded 目前支持在 qemu-arm64 和 RPI4 上运行 Jailhouse，默认集成到了 openeuler-image-mcs 镜像，构建方法可参考 :ref:`mcs镜像构建指导 <mcs_build>`。

____

Jailhouse 使用指导
==================

   Jailhouse 构建完成后，生成文件分为三部分：

   - Jailhouse 驱动和固件: ``jailhouse.ko, jailhouse.bin``，提供用户态接口并初始化 hypervisor；
   - cell 和 guest 镜像：cell是镜像运行所需的系统资源的描述；guest镜像运行在cell内，包括裸机，RTOS等；
   - 用户态工具 ``jailhouse``：负责加载cell，运行镜像，查看运行状态等。

   openeuler-image-mcs 镜像中安装了可用的 cell 和 inmates-demo，下面以 ``qemu-arm64`` 为例，介绍 Jailhouse 的使用。

   1. 启动 QEMU

      .. code-block:: console

         qemu-system-aarch64 -machine virt,gic-version=3,virtualization=on,its=off \
            -cpu cortex-a57 -nographic -smp 4 -m 2G  \
            -append "console=ttyAMA0 loglevel=8 mem=1G" \
            -kernel zImage \
            -initrd openeuler-image-mcs-qemu-aarch64-*.rootfs.cpio.gz

   2. 初始化 Root Cell

      .. code-block:: console

         jailhouse enable /usr/share/jailhouse/cells/qemu-arm64-openeuler-demo.cell

   3. 初始化 Non-root Cell

      .. code-block:: console

         jailhouse cell create /usr/share/jailhouse/cells/qemu-arm64-inmate-demo.cell

   4. 加载 inmate

      .. code-block:: console

         jailhouse cell load 1 /usr/share/jailhouse/inmates/uart-demo.bin
         jailhouse cell start 1

   之后可以看到 uart-demo 的打印：

      .. code-block:: console

         Started cell "inmate-demo"
         ======= 0x0Hello 1 from cell!
         Hello 2 from cell!
         Hello 3 from cell!
         Hello 4 from cell!
         Hello 5 from cell!
         Hello 6 from cell!
         Hello 7 from cell!
         ... ...

   .. note::

      树莓派4B上 Jailhouse 的使用方法与 QEMU 类似，但需要提前分配保留内存（openeuler-image-mcs 默认已保留了 0x10000000-0x20000000）。

____

使用 Jailhouse 运行 FreeRTOS
============================

   目前仅支持在 qemu-arm64 上通过 Jailhouse 运行 FreeRTOS。

   1. 添加 FreeRTOS 的构建

      根据 :ref:`mcs镜像构建指导 <mcs_build>`，使用 oebuild 初始化编译环境。

      .. code-block:: shell

         # qemu-arm64
         oebuild generate -p qemu-aarch64 -f openeuler-mcs -d <build_arm64_mcs>

      进入 ``<build>`` 目录，添加 ``meta-freertos``

      .. code-block:: shell

         # BBLAYERS 中添加 meta-freertos
         vi conf/bblayers.conf

         BBLAYERS ?= " \
           ... ...
         /usr1/openeuler/src/yocto-poky/../yocto-meta-openeuler/rtos/meta-freertos \
         "

   2. 构建 jailhouse-freertos

      .. code-block:: shell

         oebuild bitbake jailhouse-freertos

   3. 加载 FreeRTOS

      构建完成后，oebuild 构建目录下可以获取 ``FreeRTOS.bin``，放到 qemu 上通过 Jailhouse 加载运行：

      .. code-block:: shell

         # 获取 FreeRTOS.bin
         find . -name FreeRTOS.bin

         # 放到 qemu 上，通过 Jailhouse 加载运行
         jailhouse cell load 1 FreeRTOS.bin
         jailhouse cell start 1

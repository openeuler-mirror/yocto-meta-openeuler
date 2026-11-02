.. _xen:

嵌入式实时虚拟机XEN
###################

总体介绍
========

Xen 是开源的 Type-1 型虚拟机管理器（HyperVisor），属于 Linux 基金会 `Xen Project <https://xenproject.org/>`_ 的重要部分。

Xen 包含以下核心组件：

- Xen Core：Xen 的虚拟化层，负责 CPU 调度、内存分配、中断处理等
- 特权域（Dom0）：唯一拥有硬件驱动访问权的管理虚拟机，负责创建和管理其他虚拟机（DomU）
- 一个或多个用户域（DomU）：各种用户/应用程序域。这些域运行用户应用程序和操作系统

在混合关键性系统中，Dom0 运行 openEuler Embedded，由 MICA 管理端负责创建和管理
Client OS；DomU 运行实时操作系统，例如 Zephyr。MICA 通过 ``xen-mcsback.ko``
作为 Xen backend，在 Dom0 与 DomU 之间建立基于 grant table 的共享内存和事件通道，
并在其上运行 OpenAMP rpmsg 通信。

MCS 的 Xen 数据通路具有以下特点：

- ``xen-mcsback.ko`` 在 Dom0 侧申请 32 页（128 KiB）grant 共享池，其中第 0 页
  用于存放 resource table；
- backend 将共享页的 gref、事件通道号等发布到
  ``/local/domain/0/backend/mica/<domid>/0/``，DomU 从 xenstore 获取这些信息后
  映射共享内存并建立 vring；
- MICA 先通过 ``xl create -p`` 创建处于暂停状态的 DomU，完成 backend 配置和
  resource table 拷贝后再解除暂停，因此 Client OS 的配置需要同时提供 ELF 和
  原始二进制镜像。

____

Xen 构建指导
============

目前已在 yocto-meta-openeuler 中实现了对 QEMU-ARM64 和 KP920 的支持。
QEMU-ARM64 的 Client OS 以外部 Zephyr 4.5 工作区构建的固件为例。

构建 Zephyr 固件
----------------

MCS Xen 的 Client OS 使用 Zephyr 的 ``openamp_rsc_table`` 样例，板级配置为
``xenvm/xenvm/gicv3``。在已合入 MCS Xen transport 补丁的 Zephyr 4.5 工作区中执行：

.. code-block:: console

   $ west build -b xenvm/xenvm/gicv3 -d build-xen \
       zephyr/samples/subsys/ipc/openamp_rsc_table

构建产物为：

- ``build-xen/zephyr/zephyr_openamp_rsc_table.elf``：MICA 解析 resource table 使用；
- ``build-xen/zephyr/zephyr_openamp_rsc_table.bin``：Xen 引导 DomU 使用的原始镜像。

该样例的板级配置文件 ``boards/xenvm_xenvm_gicv3.conf`` 已使能 Xen transport：

.. code-block:: console

   CONFIG_IPM=n
   CONFIG_OPENAMP_RSC_TABLE_XEN=y
   CONFIG_OPENAMP_RSC_TABLE_TTY_ECHO=n
   CONFIG_SHELL_RPMSG_INIT_LOG_LEVEL_NONE=y
   CONFIG_SHELL_BACKEND_RPMSG_FORCE_TX_BLOCKING_MODE=y
   CONFIG_HEAP_MEM_POOL_SIZE=262144

其中 ``CONFIG_OPENAMP_RSC_TABLE_XEN`` 会同时使能
``CONFIG_OPENAMP_RSC_TABLE_VRING_OFFSET`` 和 ``CONFIG_XEN_STORE_COMMON``；
``CONFIG_OPENAMP_RSC_TABLE_TTY_ECHO=n`` 用于避免 echo 端点与 shell 争用
``rpmsg-tty`` 服务。

构建 MCS 镜像
-------------

1. 根据 :ref:`mcs镜像构建指导 <mcs_build>`，使用 oebuild 初始化编译环境。

2. 推荐直接使用 Xen 样例工程
   ``.oebuild/samples/aarch64/qemu-aarch64-mcs-xen.yaml``，或参考其中的配置创建
   构建目录。样例的关键配置如下：

   .. code-block:: yaml

      MCS_FEATURES ?= "external-firmware xen"
      DISTRO_FEATURES:append = " mcs xen"
      MCS_FIRMWARE_ELF ?= "/path/to/zephyrproject/build-xen/zephyr/zephyr_openamp_rsc_table.elf"
      MCS_FIRMWARE_BIN ?= "/path/to/zephyrproject/build-xen/zephyr/zephyr_openamp_rsc_table.bin"

   ``external-firmware`` 表示 Client OS 使用外部工作区构建的固件（样例为 Zephyr）；
   ``MCS_FIRMWARE_ELF`` 和 ``MCS_FIRMWARE_BIN`` 需要指向实际产物，并确保
   该路径在 oebuild 构建容器内可见（可以将 Zephyr 工作区只读挂载到容器中）。
   固件不限于 Zephyr：任何实现 MCS Client 接口（OpenAMP resource table 与
   micad 使用的 rpmsg 端点）的 RTOS 或裸机程序都可以通过 ``external-firmware``
   安装。产物默认安装为 ``zephyr.elf``/``zephyr.bin``，可用
   ``MCS_FIRMWARE_NAME`` 修改，此时需同步修改下文 Xen 配置中的 kernel 路径。

   .. note::

      不要将 ``openamp`` 加入 ``MCS_FEATURES``。``openamp`` 会使镜像同时继承
      ``qemuboot-mcs-dtb``，覆盖 Xen 使用的 qemuboot 设备树和启动参数。

   也可以使用 oebuild 的样例选择功能，选择 ``qemu-aarch64-mcs-xen``：

   .. code-block:: console

      $ oebuild samples

3. 进入构建目录，编译 MCS 镜像和 SDK：

   .. code-block:: console

      $ oebuild bitbake
      # 进入容器后
      $ bitbake openeuler-image-mcs
      $ bitbake openeuler-image-mcs -c do_populate_sdk

   构建完成后，在 ``output`` 目录下可以看到 ``xen-qemu-aarch64``、
   ``openeuler-image-mcs-qemu-aarch64-*.rootfs.cpio.gz`` 和
   ``openeuler-image-mcs-qemu-aarch64-*.qemuboot.dtb`` 等产物。如需构建包含更多
   基础软件包的完整镜像，可将 ``openeuler-image-mcs`` 替换为 ``openeuler-image``。

4. KP920 平台仍可使用以下命令生成构建配置，并正常安装 ISO 镜像：

   .. code-block:: console

      $ oebuild generate -p kp920 -f mcs -f xen -d kp920-xen

____

Xen 使用指导
============

在 QEMU-ARM64 上启动
--------------------

1. 构建完成后，可以在构建目录下使用 ``runqemu`` 启动 QEMU：

   .. code-block:: console

      $ oebuild runqemu nographic

   镜像默认使用 2G 内存，Xen 为 Dom0 分配 512M 内存，Dom0 控制台为 ``hvc0``。

2. 如果不使用 runqemu，也可以参考以下命令手工启动：

   .. code-block:: console

      $ sudo qemu-system-aarch64 -machine virt,gic-version=3 \
          -machine virtualization=true -cpu cortex-a53 -smp 4 -m 2048 \
          -nographic \
          -device virtio-net-pci,netdev=net0 \
          -netdev tap,id=net0,ifname=tap0,script=/etc/qemu-ifup \
          -device loader,file=Image,addr=0x45000000 \
          -kernel xen-qemu-aarch64 \
          -initrd openeuler-image-mcs-qemu-aarch64-*.rootfs.cpio.gz \
          -dtb openeuler-image-mcs-qemu-aarch64-*.qemuboot.dtb \
          -append 'root=/dev/ram0 rw debugshell mem=2048M console=hvc0 net.ifnames=0'

   ``qemuboot.dtb`` 中包含 Xen 与 Dom0 的启动参数以及 Dom0 内核的 multiboot
   模块信息，必须使用与镜像同一次构建生成的 dtb。``dom0_mem=512M`` 来自该 dtb，
   Dom0 实际使用的内存以 Xen 的配置为准。

   .. note::

      低版本 QEMU 存在影响 Xen 的缺陷，可能造成 Xen 镜像卡死，建议使用较新版本的
      qemu-system-aarch64。

3. Dom0 启动后，确认 Xen backend 已加载：

   .. code-block:: console

      qemu-aarch64:~$ lsmod | grep xen_mcsback
      xen_mcsback             ...
      qemu-aarch64:~$ ls /dev/mcs_xen
      /dev/mcs_xen

部署 Zephyr 4.5 Client OS
-------------------------

MCS 镜像默认安装 ``/etc/mica/qemu-zephyr-xen.conf``，其内容如下：

.. code-block:: console

   [Mica]
   Name=qemu-zephyr-xen
   CPU=1-3
   ClientPath=/lib/firmware/zephyr.elf
   AutoBoot=no
   Pedestal=xen
   PedestalConf=/lib/firmware/zephyr.bin
   Memory=256
   VCPU=1
   CPUCapacity=100

其中 ``zephyr.bin`` 由 Xen 作为 DomU kernel 引导，``zephyr.elf`` 由 MICA 解析
resource table；两者必须来自同一次 Zephyr 构建。``CPU=1-3`` 是可供 DomU 使用的
物理 CPU 范围，``VCPU=1`` 与 xenvm 设备的单 CPU 配置保持一致；
``CPUCapacity=100`` 表示占满 1 个 vCPU 的算力。

1. 查看实例状态：

   micad 启动时会根据 ``/etc/mica/*.conf`` 自动创建实例，无需手工执行
   ``mica create``。通过 ``mica status`` 可以确认实例处于 Offline 状态：

   .. code-block:: console

      qemu-aarch64:~$ mica status
      Name                          Assigned CPU        State               Service
      qemu-zephyr-xen               1-3                 Offline

2. 启动实例：

   .. code-block:: console

      qemu-aarch64:~$ mica start qemu-zephyr-xen
      starting qemu-zephyr-xen...
      start qemu-zephyr-xen successfully!

   ``mica start`` 内部会先通过 ``xl create -p`` 创建 DomU，配置 Xen backend 的
   grant table 和事件通道，然后解除 DomU 暂停。

   启动成功后，``mica status`` 会显示 Running 状态和 rpmsg-tty 服务：

   .. code-block:: console

      qemu-aarch64:~$ mica status
      Name                          Assigned CPU        State               Service
      qemu-zephyr-xen               1-3                 Running             rpmsg-tty(/dev/ttyRPMSG0)

   也可以通过 ``xl list`` 确认 DomU 资源：

   .. code-block:: console

      qemu-aarch64:~$ xl list
      Name                                        ID   Mem VCPUs      State   Time(s)
      Domain-0                                     0   512     4     r-----       ...
      qemu-zephyr-xen                              1   256     1     -b----       ...

3. 访问 Zephyr shell：

   .. code-block:: console

      qemu-aarch64:~$ screen /dev/ttyRPMSG0

      ... ...
      uart:~$ kernel version
      Zephyr version 4.5.99

   之后可以通过 ``Ctrl-a k`` 或 ``Ctrl-a Ctrl-k`` 组合键退出 shell，参考
   `screen(1) — Linux manual page <https://man7.org/linux/man-pages/man1/screen.1.html#DEFAULT_KEY_BINDINGS>`_ 。

4. 停止与销毁实例：

   .. code-block:: console

      qemu-aarch64:~$ mica stop qemu-zephyr-xen
      stopping qemu-zephyr-xen...
      stop qemu-zephyr-xen successfully!
      qemu-aarch64:~$ mica rm qemu-zephyr-xen
      removing qemu-zephyr-xen...
      rm qemu-zephyr-xen successfully!
      qemu-aarch64:~$ mica create qemu-zephyr-xen.conf
      Creating qemu-zephyr-xen...
      Successfully created qemu-zephyr-xen!

   ``mica stop`` 会销毁对应的 Xen DomU，``mica rm`` 会移除 MICA 实例。实例被移除后，
   如需再次部署，可执行 ``mica create qemu-zephyr-xen.conf`` 重新创建。

.. note::

   镜像中还提供了 UniProton 的 Xen 配置 ``/etc/mica/qemu-uniproton-xen.conf``，
   可以通过相同的 ``mica start`` / ``mica stop`` 流程部署，其 rpmsg-tty 绑定
   UniProton 的 shell。

引导 Linux DomU
---------------

除了通过 MICA 部署实时操作系统，也可以直接使用 ``xl`` 创建 Linux DomU。
通过以下 config 配置，并执行 ``xl create xen-linux.cfg`` 启动 Linux DomU：

.. code-block:: console

   $ cat xen-linux.cfg
   name = "domU"
   memory = 512
   vcpus = 1
   kernel = "Image"
   ramdisk = "rootfs.cpio.gz"
   extra = "console=hvc0 root=/dev/xvda rw"

如果需要退出 DomU 的 shell，可以通过 ``ctrl + ]`` 组合键切换回 Dom0，通过
``xl console domU`` 可以重新进入。

示例：基于KP920引导一个实时OS作为DomU
--------------------------------------

1. KP920 使能 xen 的镜像已默认打包一个实时 OS 的示例，包括 xen config 和使能
   xen 的 Zephyr 镜像。该示例基于 Zephyr 3.7.1。

    .. code-block:: console

        kp920 ~ # cat /etc/xen/xen-kp920-zephyr.cfg
        name = "zephyr"
        memory = 512
        vcpus = 1
        kernel = "/lib/firmware/zephyr.bin"
        gic_version = "v3"

        kp920 ~ # ls /lib/firmware/zephyr.bin
        /lib/firmware/zephyr.bin

2. 根据上述引导流程，可按需引导该实时OS示例：

    .. code-block:: console

        kp920 ~ # xl create -c /etc/xen/xen-kp920-zephyr.cfg
        Parsing config from /etc/xen/xen-kp920-zephyr.cfg
        libxl: info: libxl_create.c:122:libxl__domain_build_info_setdefault: qemu-xen is unavailable, using qemu-xen-traditional instead: No such file or directory
        [00:00:00.000,000] <inf> xen_events: xen_events_init: events inited

        [00:00:00.000,000] <inf> uart_hvc_xen: Xen HVC inited successfully

        *** Booting Zephyr OS build 3.7.1 ***
        thread_a: Hello World from cpu 0 on xenvm!
        thread_b: Hello World from cpu 0 on xenvm!
        thread_a: Hello World from cpu 0 on xenvm!
        thread_b: Hello World from cpu 0 on xenvm!
        thread_a: Hello World from cpu 0 on xenvm!

        kp920 ~ # xl list
        Name                                        ID   Mem VCPUs	State	Time(s)
        Domain-0                                     0  1024     4     r-----       7.0
        zephyr                                       3   512     1     -b----       1.1

        kp920 ~ # xl console zephyr
        thread_b: Hello World from cpu 0 on xenvm!
        thread_a: Hello World from cpu 0 on xenvm!
        thread_b: Hello World from cpu 0 on xenvm!
        thread_a: Hello World from cpu 0 on xenvm!
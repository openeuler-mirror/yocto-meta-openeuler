嵌入式实时虚拟机XEN
###################

总体介绍
========

Xen 是开源的 Type-1 型虚拟机管理器（HyperVisor），属于 Linux 基金会 `Xen Project <https://xenproject.org/>`_ 的重要部分。

Xen 包含以下核心组件：

- Xen Core：Xen 的虚拟化层，负责CPU 调度、内存分配、中断处理等
- 特权域（Dom0）：唯一拥有硬件驱动访问权的管理虚拟机，负责创建和管理其他虚拟机（DomU）
- 一个或多个用户域（DomU）：各种用户/应用程序域。这些域运行用户应用程序和操作系统

____

Xen 构建指导
============

使用 oebuild 构建
-------------------------

目前已经在 yocto-meta-openeuler 中实现了对 QEMU-ARM64、KP920 的支持。

1. 根据 :ref:`mcs镜像构建指导 <mcs_build>`，使用 oebuild 初始化编译环境。

2. 进入oebuild工作目录，创建编译配置文件 ``compile.yaml`` :

    .. code-block:: console

        # 构建 qemu-aarch64 镜像，包含mcs和xen特性，此处构建目录名为 build_xen
        oebuild generate -p qemu-aarch64 -f mcs -f xen -d qemu-xen

        # 或者，构建 KP920 镜像，包含mcs和xen特性，此处构建目录名为 build_xen
        oebuild generate -p kp920 -f mcs -f xen -d kp920-xen

3. 进入 ``build_xen`` 目录使用oebuild容器构建:

    .. code-block:: console

        oebuild bitbake
        # 进入容器后
        bitbake openeuler-image

4. 构建完成后，在 output 目录下有对应的部署件：KP920提供iso镜像，QEMU提供zImage和initrd。

____

Xen 使用指导
==================

引导Xen、Dom0和DomU流程
-------------------------

1. 构建完成后使用 ``runqemu`` 启动 QEMU，或者是在 KP920 上正常安装 ISO 镜像，之后默认会通过 qemu 参数或 grub 配置完成 Xen 和 Dom0 的引导。

2. 之后，可以通过以下 config 配置，并执行 ``xl create xen-linux.cfg`` 启动 Linux DomU：

    .. code-block:: console

        $ cat xen-linux.cfg
        name = "domU"
        memory = 512
        vcpus = 1
        kernel = "Image"
        ramdisk = "rootfs.cpio.gz"
        extra = "console=hvc0 root=/dev/xvda rw"

如果需要退出 DomU 的 shell，可以通过 ``ctrl + ]`` 组合键切换回 Dom0，通过 ``xl console domU`` 可以重新进入。

示例：基于KP920引导一个实时OS作为DomU
---------------------------------

1. KP920使能xen的镜像已默认打包一个实时OS的示例，包括xen config和使能xen的zephyr镜像。

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


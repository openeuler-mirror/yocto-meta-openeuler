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

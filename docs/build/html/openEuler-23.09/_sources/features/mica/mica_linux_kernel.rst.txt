基于 RemoteProc & RPMsg 框架的混合部署框架
******************************************

openEuler Embedded 当前支持通过 Linux 的 RemoteProc 和 RPMsg 框架实现混合部署，能够在 Linux 上启动 Client OS，允许两端相互通信。

____

构建说明
========

   .. seealso::

      目前仅支持 ``arm64(aarch64) qemu``，参考 :ref:`openEuler Embedded MCS镜像构建指导 <mcs_build>`。

____

如何在ARM64 QEMU上运行
======================

1. 制作 dtb

  部署 Client OS 需要在 Linux 的设备树中添加 ``mcs-remoteproc`` 设备节点，为 Client OS 预留出必要的保留内存。具体的节点配置在下文 **Linux端驱动的工作内容** 会进行详细介绍。
  当前，可以通过 mcs 仓库提供的 `create_dtb.sh <https://gitee.com/openeuler/mcs/blob/master/tools/create_dtb.sh>`_ 脚本生成对应的 dtb：

  .. code-block:: console

     # create a dtb for qemu_cortex_a53
     $ ./create_dtb.sh qemu-a53

  成功执行后，会在当前目录下生成 ``qemu.dtb`` 文件，对应 QEMU 配置为：`2G RAM, 4 cores`。

2. 启动 QEMU

  .. note::

     下文的QEMU启动命令默认使能 ``virtio-net``，请先阅读 :ref:`QEMU 使用指导 <qemu_enable_net>` 了解如何开启网络。

  使用生成出来的 ``qemu.dtb``，按照以下命令启动 QEMU，注意 `-m` 和 `-smp` 要与 dtb 的配置(2G RAM, 4 cores)保持一致，否则会启动失败：

  .. code-block:: console

     $ sudo qemu-system-aarch64 -M virt,gic-version=3 -cpu cortex-a53 -nographic \
         -device virtio-net-device,netdev=tap0 \
         -netdev tap,id=tap0,script=/etc/qemu-ifup \
         -m 2G -smp 4 \
         -kernel zImage \
         -initrd openeuler-image-*.cpio.gz \
         -dtb qemu.dtb

3. 部署 Client OS

  使用 ``mica start { CLIENT }`` 启动 Client OS，目前在 MCS 镜像中安装了可用的 ``qemu-zephyr-rproc.elf``：

  .. code-block:: console

     qemu-aarch64:~$ mica start qemu-zephyr-rproc.elf
     Starting qemu-zephyr-rproc.elf on CPU3
     Please open /dev/ttyRPMSG0 to talk with client OS

4. 打开 Client OS 的 shell

  Linux 侧可以通过 screen 可以接入 Client OS 的 shell：

  .. code-block:: console

     # 通过 SSH 登录 QEMU
     $ ssh root@192.168.10.8

     ... ...

     # 打开 Client OS 的 shell
     qemu-aarch64:~$ screen /dev/ttyRPMSG0

     ... ...

     uart:~$ kernel uptime
     Uptime: 8963940 ms
     uart:~$ kernel version
     Zephyr version 3.2.0

  可以通过 ``Ctrl-a k`` 或 ``Ctrl-a Ctrl-k`` 组合键退出shell，参考 `screen(1) — Linux manual page <https://man7.org/linux/man-pages/man1/screen.1.html#DEFAULT_KEY_BINDINGS>`_ 。

____

client OS端的配置
=================

要想实现混合部署，我们需要依赖于Linux的remoteproc框架和RPMsg协议。remoteproc框架实现了对远程处理器的生命周期控制，
而RPMsg协议则是一个用于使能CPU之间通信的传输层协议。

remoteproc框架中的每一个实例除了对应了物理CPU，还有这个CPU上运行的固件（firmware）。这个固件的格式必须是elf，
并且必须包含通过一个名为\ ``.resource_table`` \的特殊section。资源表的数据结构的定义存在于内核头文件：
/include/linux/remoteproc.h。定义如下：

.. code-block:: 

  // 资源表的数据结构
  struct resource_table {
    u32 ver; // 版本号
    u32 num; // 资源的数量
    u32 reserved[2]; // 保留字段，默认为0
    u32 offset[]; // 资源条目的入口在资源表中的偏移量，以及资源的数据内容
  } __packed;

  // 每个资源条目的数据结构，跟在资源表的offset后面
  struct fw_rsc_hdr {
        u32 type; // 资源的种类
        u8 data[0]; // 数据内容，每个资源都有自定义的数据内容的结构
  } __packed;

  // 当前资源表支持的所有资源种类
  enum fw_resource_type {
        RSC_CARVEOUT            = 0, // 请求分配的连续内存空间
        RSC_DEVMEM              = 1, // 请求在iommmu中进行映射的设备地址和物理地址
        RSC_TRACE               = 2, // trace buffer，用于写入log信息
        RSC_VDEV                = 3, // 请求创建的virtio device
        RSC_LAST                = 4, // 标识符，表示标准资源列表的结束
        RSC_VENDOR_START        = 128, // 标识符，表示自定义资源列表的开始
        RSC_VENDOR_END          = 512, // 标识符，表示自定义资源列表的结束
  };

.. note:: 

    resource table并不是一个单向传递信息的数据结构。由于资源是需要master，也就是Linux侧进行分配，
    所以一开始resource table中填入的只有资源数量，而资源地址的信息需要Linux分配后再填入。

由于我们需要使能RPMsg，但是RPMsg只是一个传输层协议，底层需要有链路层和物理层的支持。物理层就是我们的共享内存，
而链路层则是virtio。我们必须在资源表中填入底层支持的virtio device的资源信息，
然后由Linux端分配virtio device。下面的代码是资源表中virtio device相关的数据结构：

.. code-block:: 

  // virtio device的资源信息
  struct fw_rsc_vdev {
    u32 id; // virtio设备类型，参见Linux头文件virtio_ids.h
    u32 notifyid; // 当提醒远端处理器的时候，使用这个告知对端这个设备发生了变化（整个rproc实例唯一）
    u32 dfeatures; // virtio设备支持的特性
    u32 gfeatures; // host写入的协商后的双方都支持的特性
    u32 config_len; // 配置空间的长度。配置空间也存在于资源表中，在这个virtio设备后面
    u8 status; // host会将设备初始化进程利用这个变量进行同步
    u8 num_of_vrings; // 设备包含的vring总数
    u8 reserved[2];
    struct fw_rsc_vdev_vring vring[];
  } __packed;
  
  // virtio device的每个vring的资源信息，紧跟在virtio device资源信息之后
  struct fw_rsc_vdev_vring {
    u32 da; // 设备（虚拟）地址
    u32 align; // 内存对齐方式
    u32 num; // buffer的数量
    u32 notifyid; // notifyid也就是vring的id
    u32 pa; // 物理地址
  } __packed;

Linux侧根据资源表中的信息分配好相关资源后，会将资源地址写入resource table中。因此，
client OS端的程序还需要支持从elf文件中的\ ``.resource_table`` \section读取相应的信息，
比如vring的地址。

下面的代码定义了一个只包含virtio device的资源表：

.. code-block:: 

  static struct fw_resource_table __resource resource_table = {
    .ver = 1,
    .num = 1,
    .offset = {
      offsetof(struct fw_resource_table, vdev),
    },
    /* Virtio device entry */
    .vdev = {
      RSC_VDEV, // 资源描述符，表示这是一个virtio device
      VIRTIO_ID_RPMSG, // 表明这个virtio设备用于RPMsg通信
      0, 
      RPMSG_IPU_C0_FEATURES, 0, 0, 0,
      VRING_COUNT, {0, 0},
    },

    /* Vring rsc entry - part of vdev rsc entry */
    .vring0 = {-1, // remoteproc框架中的FW_RSC_ADDR_ANY，表示由Linux进行资源分配
        -1, // 表明对齐也由硬件指定
        8, // 8个buffer
        0, // vring0的id就是0
        0 // 物理地址
    },
    .vring1 = {-1, -1, 8, 1, 0},
  };

定义好了数据结构以后，还需要将这部分内容编译链接到client OS的ELF可执行文件中。
此外，client OS需要有读取ELF中资源表的相关函数，
从而能从virtio设备的status字段中获取host配置的进度，以及从资源表中获取资源的地址。

配置好了virtio device后，client OS还需要配置核间中断，用于RPMsg的通信。之后，
再添加一些与RPMsg相关的代码就可以正常通信了。
新MICA框架对于client OS来说的不同之处主要在于需要使用资源表配置底层的virtio
device，其他的上层应用不需要有太多的变化。

Linux端驱动的工作内容
====================================

内核驱动的probe函数
----------------------

为了更好的理解驱动（driver）的工作内容，我们从一个驱动最开始执行的代码开始：probe函数。原本最开始执行的函数是初始化函数，
当我们插入该驱动时，Linux会通过带有\ ``MODULE_INIT`` \字段的函数执行初始化流程，主要用于做一些特殊的配置，
然后调用\ ``platform_driver_register`` \函数注册驱动。由于目前我们的驱动并不需要在初始化时做特别的事情，
所以我们并没有init函数。\ ``MODULE_PLATFORM_DRIVER`` \这个宏定义会调用\ ``platform_driver_register`` \函数注册驱动，
之后系统的总线会遍历注册到总线上的设备（device），查看是否有和本驱动匹配的设备。
如果有，则将本驱动和设备绑定在一起，并执行驱动的probe函数，检查硬件资源是否符合要求，并进行相应的配置和准备工作。
而probe函数的执行由于已经发现了设备，此时的工作内容主要是初始化设备，分配硬件和软件资源，以及将设备注册到kernel中。
接下来是probe函数的主要工作内容：

1. 创建remoteproc实例

  remoteproc框架对于远端处理器的管理，从某种程度上来说，是面向对象的。当需要在一个或一组远端处理器上运行一个固件（firmware），
  我们需要创建一个remoteproc实例，之后的生命周期管理都是通过与这个实例进行交互的方式进行的。
  所以，首先我们需要先通过\ ``devm_rproc_alloc`` \这一API分配一个remoteproc实例。此时，这个实例还没有被注册到
  remoteproc框架，因为我们还有一些其他的信息需要配置。

2. 配置电源管理

  由于我们需要启动CPU，需要用到ARM提供的电源管理接口（Power State Coordination Interface）。在ARMv8架构下，
  非安全世界的特权等级一共分为4层。位于EL2的虚拟机和EL3的安全监视器都可以对硬件资源进行直接的控制，根据启动方式的不同，
  最终控制硬件资源的特权等级也不同。比如，如果混合部署系统运行在QEMU上，由于底层是虚拟机，对于QEMU中的Linux来说是EL2层。
  如果Linux希望启动CPU，则需要依赖EL2层的固件执行电源管理相关指令，所以需要生成EL2层的exception，
  使得系统下陷（trap）到EL2层，由EL2的固件调用PSCI接口启动CPU。而如果在某个支持TrustZone的机器上运行混合部署系统，
  由于需要经过ATF（ARM Trusted Firmware）对硬件进行配置，这是一个运行在EL3的固件，
  所以我们在配置电源管理的时候就需要生成能让系统下陷到EL3层的指令，由EL3的固件启动CPU。
  目前我们通过设备树指定支持的psci接口版本和直接调用psci接口的方式（hvc或smc），
  这样我们在驱动中就可以解析设备树来配置相关的电源管理方法。

3. 初始化内存

  在当前的内核驱动实现中，client OS运行的时候可执行文件存放的内存（名为client_os_reserved），
  以及Linux和client OS通信的物理层也就是共享内存（名为client_os_dma_memory_region）
  都在设备树中进行了定义。然后，在remoteproc实例对应的设备rproc_demo中将这两段内存区间加入到
  ``memory-region`` 字段中。

  .. code-block:: 

    reserved-memory {
      #address-cells = <0x02>;
      #size-cells = <0x02>;
      ranges;

      // 可执行文件存放的内存区域
      client_os_reserved: client_os_reserved@7a000000 {
        compatible = "mcs_mem"; 
        reg = <0x00 0x7a000000 0x00 0x4000000>;
        no-map;
      };

      // 共享内存区域
      client_os_dma_memory_region: client_os-dma-memory@70000000 {
        compatible = "shared-dma-pool";
        reg = <0x00 0x70000000 0x00 0x100000>;
        no-map;
      };
    };

    rproc_demo {
      compatible = "oe,mcs_remoteproc";
      memory-region = <&client_os_dma_memory_region>,
      <&client_os_reserved>;
    };

  由于我们目前使用的client OS可执行文件是位置相关的二进制文件（Position Dependent Code），
  其中的相关变量和函数地址都是固定地址，
  所以必须得加载到client OS指定的地址运行，否则程序无法正常执行。
  因此，我们需要通过设备树预留client OS指定的内存作为其加载地址。
  此外，remoteproc框架和Linux kernel中对于RPMsg协议的实现中，
  都是使用DMA API为virtio device分配vring和vring buffer的，
  而\ ``dma_alloc_coherent`` \这一API的底层实现方式为，如果device本身有保留内存，
  则优先从保留内存的区域中分配一段内存；如果没有保留内存，则直接从系统内存中分配一段内存。
  由于我们必须将vring和vring buffer分配到共享内存中，我们通过
  \ ``of_reserved_mem_device_init_by_idx`` \
  API将设备树中compatible字段为 ``shared-dma-pool`` 的共享内存添加到device的保留内存中，
  这样系统在分配内存的时候就会从指定的共享内存中分配内存，
  client OS和Linux都可以直接访问到vring和vring buffer。

4. 将remoteproc实例注册到remoteproc框架
   
  调用\ ``devm_rproc_add`` \API将remoteproc实例注册到remoteproc框架。首先会先通过\ ``device_add`` \将device添加到kobject层级结构中，
  然后添加到驱动模型中其他的子系统。然后，添加debugfs的入口，并且为这个remoteproc实例添加相应的char device。
  char device会被用来进行后续的对此实例的操作，比如指定固件的名称，发送启动和停止命令等。

remoteproc实例的钩子函数
------------------------------

此外，还有一些比较重要的remoteproc框架中的钩子函数，会影响到框架的正常使用：

1. start

  当用户通过命令行输入启动命令时，remoteproc框架会将可执行文件拷贝到预设的启动地址，并调用这个函数。
  当前内核驱动实现的start函数主要做的事情，一方面初始化核间中断，并配置相关的中断处理函数。
  一方面通过电源管理启动CPU。

2. da_to_va

  这个函数主要做的事情，是将resource table中的地址，也称为device (virtual) address，
  转换为Linux中CPU的virtual address。如果用户实现了相关的钩子函数，则调用用户的钩子函数。
  如果用户没有实现相关函数，它则遍历resource
  table中的carveout，找到已经做了映射的合适区间的内存区域，将它的CPU virtual address返回。

  目前我们没有使用carveout这一resource table的选项，
  因为我们不希望Linux随机为我们分配一块内存，而是希望使用指定的内存区间。因此，
  我们将elf文件加载的内存区域在设备树中进行指定，
  并且在内核驱动的初始化内存的函数中进行了内存映射，
  将映射后的CPU虚拟地址放在我们自己创建的私有数据结构 ``struct mcs_rproc_pdata`` 中。
  所以，我们需要编写自己的da_to_va函数，在解析da的时候遍历私有数据结构中的内存映射，
  并将相应CPU virtual address返回。

3. kick
   
  kick函数主要作用就是提供一种提醒远端处理器的方法。目前我们配置的方法是核间中断。这个方法在发送RPMsg信息的时候被调用，
  通知远端处理器获取vring中的信息。

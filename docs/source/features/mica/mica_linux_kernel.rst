.. _mica_linux_kernel:

基于Linux kernel的混合部署实现
###################################

使用方法
====================================

目前暂时仅支持在QEMU中的aarch64架构下实现与zephyr的混合部署。我们可以通过OeBuild生成支持混合部署的Linux内核和zephyr镜像。

1. 生成kernel和rootfs 
  
  首先，在OeBuild目录下，输入命令\ ``oebuild generate -f openeuler-mcs -d [directory-name]`` \。
  生成了构建目录以后，接着运行\ ``oebuild bitbake`` \，OeBuild会启动一个构建容器。进入容器中，运行\ ``bitbake openeuler-image-mcs`` \
  生成Linux内核镜像和rootfs。

2. 制作一份设备树文件
   
  首先，我们需要生成一份基于QEMU支持的硬件架构的设备树，输入如下命令，可以获得基于GICv3，1G RAM，4核Cortex-A57的硬件架构的设备树：

  .. code-block:: 

    qemu-system-aarch64 -M virt,gic-version=3 -m 1G -cpu cortex-a57 -nographic -smp 4 -M dumpdtb=qemu.dtb
  
  dtb是设备树的二进制文件，我们需要将其转换为可读的源代码文件：

  .. code-block:: 

    dtc -I dtb -O dts -o qemu.dts qemu.dtb
  
  接下来，在已有的设备树文件中的一层结构下添加保留内存节点和remoteproc实例的节点：

  .. code-block:: 

    reserved-memory {
      #address-cells = <0x02>;
      #size-cells = <0x02>;
      ranges;

      // 可执行文件存放的内存区域
      zephyr_reserved: zephyr_reserved@7a000000 {
        compatible = "mcs_mem"; 
        reg = <0x00 0x7a000000 0x00 0x4000000>;
        no-map;
      };

      // 共享内存区域
      zephyr_dma_memory_region: zephyr-dma-memory@70000000 {
        compatible = "shared-dma-pool";
        reg = <0x00 0x70000000 0x00 0x100000>;
        no-map;
      };
    };

    rproc_demo {
      compatible = "oe,mcs_remoteproc";
      memory-region = <&zephyr_dma_memory_region>,
      <&zephyr_reserved>;
    };

  将修改后的dts文件重新生成dtb文件：

  .. code-block:: 

    dtc -I dts -O dtb -o qemu.dtb qemu.dts

3. 使用QEMU启动系统

  .. code-block:: 

      sudo qemu-system-aarch64 -M virt,gic-version=3 -m 1G -cpu cortex-a57 -nographic \
      -append 'maxcpus=3' -smp 4 -kernel zImage -initrd openeuler-image.cpio.gz -dtb qemu_mcs.dtb \
      -device virtio-net-device,netdev=tap0 -netdev tap,id=tap0,script=./qemu-ifup

4. 安装内核驱动

   进入QEMU中的Linux，通过命令行输入\ ``modprobe mcs_remoteproc`` \命令安装内核驱动mcs_remoteproc.ko。

5. 配置remoteproc实例

  此时，我们已经有了一个remoteproc实例，并且它的char device的接口位于
  ``/sys/class/remoteproc/`` 目录下面，名称为 ``remoteproc[X]`` ，X是数字。
  此时，我们需要指定remoteproc实例运行的固件名称，
  然后remoteproc框架会默认从\ ``/lib/firmware/`` \目录下寻找指定名称的固件。
  指定firmware名称的命令是：

  .. code-block:: 
      
    echo [firmware name] > /sys/class/remoteproc/remoteproc[X]/firmware
    # the following bash command is an example
    echo zephyr-image.elf > /sys/class/remoteproc/remoteproc0/firmware

  .. note:: 

    当前框架下要求client OS的可执行文件必须为elf格式的文件。
  
  当然，我们也可以指定存放firmware的路径（不包括firmware自己的文件名），
  如下命令可以增加一个查找固件的路径：

  .. code-block:: 
      
      echo [firmware path] > /sys/module/firmware_class/parameters/path
      # the following bash command is an example, /firmware is a directory
      # holding OS firmware
      echo /firmware > /sys/module/firmware_class/parameters/path


6. 现在，一切都准备就绪了，我们可以启动这个remoteproc实例：

  .. code-block:: 
      
      echo start > /sys/class/remoteproc/remoteproc[X]/state

7. 当remoteproc实例启动后，Linux中的\ ``\dev`` \目录下会出现名为\ ``ttyRPMsg[X]`` \的RPMsg设备的tty接口，X是数字。
   我们只需要使用screen命令打开这个设备就可以与client OS通过命令行进行交互：

  .. code-block:: 
      
      screen /dev/ttyRPMsg[X]

8. 如果我们想停止remoteproc实例，可以使用如下命令：

  .. code-block:: 
      
      echo stop > /sys/class/remoteproc/remoteproc[X]/state

client OS端的配置
====================================

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

为了更好的理解驱动（Driver）的工作内容，我们从一个驱动最开始执行的代码开始：probe函数。原本最开始执行的函数是初始化函数，
当我们插入这个驱动的时候，Linux会通过带有\ ``MODULE_INIT`` \字段的函数执行初始化流程，主要用于做一些特殊的配置，
然后调用\ ``platform_driver_register`` \函数注册驱动。由于目前我们的驱动并不需要在初始化的时候做特别的事情，
所以我们并没有init函数。\ ``MODULE_PLATFORM_DRIVER`` \这个宏定义会调用\ ``platform_driver_register`` \函数注册驱动，
之后系统的总线会遍历注册到总线上的设备（Device），查看是否有和本驱动匹配的设备。
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

  在当前的内核驱动实现中，client OS运行的时候可执行文件存放的内存（名为zephyr_reserved），
  以及Linux和client OS通信的物理层也就是共享内存（名为zephyr_dma_memory_region）
  都在设备树中进行了定义。然后，在remoteproc实例对应的设备rproc_demo中将这两段内存区间加入到
  ``memory-region`` 字段中。

  .. code-block:: 

    reserved-memory {
      #address-cells = <0x02>;
      #size-cells = <0x02>;
      ranges;

      // 可执行文件存放的内存区域
      zephyr_reserved: zephyr_reserved@7a000000 {
        compatible = "mcs_mem"; 
        reg = <0x00 0x7a000000 0x00 0x4000000>;
        no-map;
      };

      // 共享内存区域
      zephyr_dma_memory_region: zephyr-dma-memory@70000000 {
        compatible = "shared-dma-pool";
        reg = <0x00 0x70000000 0x00 0x100000>;
        no-map;
      };
    };

    rproc_demo {
      compatible = "oe,mcs_remoteproc";
      memory-region = <&zephyr_dma_memory_region>,
      <&zephyr_reserved>;
    };

  由于我们目前使用的zephyr可执行文件是位置相关的二进制文件（Position Dependent Code），
  其中的相关变量和函数地址都是固定地址，
  所以必须得加载到zephyr指定的地址运行，否则程序无法正常执行。
  因此，我们需要通过设备树预留zephyr指定的内存作为其加载地址。
  此外，remoteproc框架和Linux kernel中对于RPMsg协议的实现中，
  都是使用DMA API为virtio device分配vring和vring buffer的，
  而\ ``dma_alloc_coherent`` \这一API的底层实现方式为，如果device本身有保留内存，
  则优先从保留内存的区域中分配一段内存；如果没有保留内存，则直接从系统内存中分配一段内存。
  由于我们必须将vring和vring buffer分配到共享内存中，我们通过
  \ ``of_reserved_mem_device_init_by_idx`` \
  API将设备树中compatible字段为 ``shared-dma-pool`` 的共享内存添加到device的保留内存中，
  这样系统在分配内存的时候就会从指定的共享内存中分配内存，
  zephyr和Linux都可以直接访问到vring和vring buffer。

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

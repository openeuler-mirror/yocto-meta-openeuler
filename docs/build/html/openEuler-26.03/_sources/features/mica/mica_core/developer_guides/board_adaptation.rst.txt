.. _board_adaptation:

开发板适配指南
##############

本文档用于指导开发者将新开发板接入MICA框架，提供从前期准备到调试验证的完整步骤。


____

前期准备
********

选择部署底座
============

MICA支持多种部署底座，包括baremetal、jailhouse、xen、hetero。在选择部署底座时，建议考虑以下因素：

- baremetal: 裸核运行RTOS，适合对性能要求极高的场景
- jailhouse: 基于Jailhouse静态分区虚拟化，提供隔离性
- xen: 基于Xen虚拟化，提供更强的隔离和资源管理能力（如灵活分配、在线扩缩）
- hetero: 在ARM64主机上运行RISC-V架构MCU上的RTOS，需要开发板具备异构能力

.. note::

   如果选择jailhouse或xen，建议先确保虚拟化基础功能正常。
   
   例如oebuild构建时开启对应虚拟化特性，以及Linux作为root cell或domain 0启动正常，RTOS作为non-root cell或domU启动正常。

   可参考 :ref:`Jailhouse <jailhouse>` 和 :ref:`Xen <xen>` 相关文档。

选择RTOS
========

根据应用需求选择合适的RTOS：

- 如果是全新的RTOS，请参考 :ref:`RTOS适配指南 <rtos_adaptation>` 完成RTOS侧的适配工作
- 如果是 :ref:`支持列表 <supported_lists>` 中已支持MICA框架的RTOS，可复用其现有代码流程

.. important::

   对于已支持MICA的RTOS，需要确认RTOS已使能MICA框架。RTOS通常通过宏配置决定是否使能MICA。

   使能MICA框架后，编译出的RTOS ELF镜像应包含.resource_table段，详见 :ref:`RTOS适配指南 <rtos_adaptation>` 中资源表介绍。

资源预留规划
============

Linux侧资源预留
-----------------

本节按照部署底座的不同，分别说明Linux侧资源静态预留的方法和配置要点。

.. tabs::

   .. tab:: baremetal部署

      **1. CPU预留**

      在部署client OS到目标核前，须确保该核未上线。两种方法选其一：

      - 启动参数maxcpus：

        例如某开发板总共有4个核，在bootargs/cmdline中加上 ``maxcpus=3`` ，表示只启动核0、1、2，核3不上线，那么client OS就可以部署于核3。

        注意，DTS中的CPU节点需要是完整的，否则MICA无法再拉起未上线的核，例如上述例子中的核3。

      - 运行时下线：

        开发板启动后，通过 ``echo 0 > /sys/devices/system/cpu/cpuX/online`` 将核X下线。
        
        如果通过yocto构建镜像，可参考 ``hieulerpi1.conf`` 中的 ``MCS_CPUID_OFFLINE`` 参数，配置启动脚本（暂不支持 ``systemd``）自动下线指定核。

      **2. 中断预留**

      MICA默认使用 ``IPI 7``，无需用户预留中断。

      **3. 共享内存预留**

      两种方法选其一：

      - 设备树（``DTS``）方式（推荐）
      - ko参数方式

      设备树方式示例：

      .. code-block:: dts

         reserved-memory {
             #address-cells = <0x02>;
             #size-cells = <0x02>;
             ranges;

             client_os_reserved: client_os_reserved@7a000000 {
                 reg = <0x00 0x7a000000 0x00 0x4000000>;
                 no-map;
             };

             client_os_dma_memory_region: client_os-dma-memory@70000000 {
                 compatible = "shared-dma-pool";
                 reg = <0x00 0x70000000 0x00 0x100000>;
                 no-map;
             };
         };

         mcs-remoteproc {
             compatible = "oe,mcs_remoteproc";
             memory-region = <&client_os_dma_memory_region>,
                             <&client_os_reserved>;
         };

      ``mcs_km.ko`` 会根据 ``oe,mcs_remoteproc`` 节点预留内存段。其中：

      - client_os_dma_memory_region: 用于Linux侧和RTOS侧的通信共享内存
      - client_os_reserved: 用于RTOS侧运行系统的地址

      .. important::

         ``oe,mcs_remoteproc`` 节点中的 ``memory-region`` 属性，必须将通信共享内存放在第一个。

      如果开发板无法修改DTS（如基于ACPI），可以使用ko参数方式：

      .. code-block:: console

         insmod mcs_km.ko rmem_base=0x70000000 rmem_size=0x100000

      .. warning::

         使用内核模块参数方式时，仅支持传入通信共享内存地址，且MICA不会自动预留内存，需要用户自行预留通信共享内存和RTOS运行系统的内存段，例如通过 ``request_mem_region`` 。

      **4. 验证预留结果**

      .. code-block:: console

         $ cat /proc/cpuinfo
         processor	: 0
         BogoMIPS	: 48.00
         Features	: fp asimd evtstrm aes pmull sha1 sha2 crc32 atomics fphp asimdhp cpuid asimdrdm lrcpc dcpop asimddp
         CPU implementer	: 0x41
         CPU architecture: 8
         CPU variant	: 0x2
         CPU part	: 0xd05
         CPU revision	: 0

         processor	: 1
         BogoMIPS	: 48.00
         Features	: fp asimd evtstrm aes pmull sha1 sha2 crc32 atomics fphp asimdhp cpuid asimdrdm lrcpc dcpop asimddp
         CPU implementer	: 0x41
         CPU architecture: 8
         CPU variant	: 0x2
         CPU part	: 0xd05
         CPU revision	: 0

         processor	: 2
         BogoMIPS	: 48.00
         Features	: fp asimd evtstrm aes pmull sha1 sha2 crc32 atomics fphp asimdhp cpuid asimdrdm lrcpc dcpop asimddp
         CPU implementer	: 0x41
         CPU architecture: 8
         CPU variant	: 0x2
         CPU part	: 0xd05
         CPU revision	: 0

         $ cat /proc/interrupts
                    CPU0       CPU1       CPU2
         8:          0          0          0     GICv3   7 Edge      MCS IPI

         $ cat /proc/iomem
         ...
         70000000-700fffff : mcs_baremetal_mem
         7a000000-7dffffff : mcs_baremetal_mem
         ...

   .. tab:: jailhouse部署

      CPU、中断、共享内存都通过cell文件预留。具体配置方法可参考：

      - :ref:`openEuler Embedded Jailhouse文档 <jailhouse>`
      - `openEuler Embedded  cell配置示例 <https://atomgit.com/openeuler/yocto-meta-openeuler/tree/master/meta-openeuler/recipes-mcs/jailhouse/files/cells>`_
      - `Jailhouse官方cell配置示例 <https://github.com/siemens/jailhouse/tree/master/configs/>`_

   .. tab:: xen部署

      CPU、中断、共享内存由MICA自行分配，无需用户静态预留。
      
      CPU绑定也可通过 :ref:`MICA命令与配置文件介绍 <mica_ctl>` 动态配置。

   .. tab:: hetero部署

      **1. 运行核**

      暂时只支持部署到一个RISCV MCU核，无需指定。

      **2. 中断和共享内存预留**

      中断和共享内存都通过DTS预留。配置示例如下：

      .. code-block:: dts

         reserved-memory {
             #address-cells = <0x2>;
             #size-cells = <0x2>;
             ranges;

             riscv_os_reserved: riscv_os_reserved@44000000 {
                 reg = <0x00 0x44000000 0x00 0x4000000>;
                 no-map;
             };

             riscv_os_dma_memory_region: riscv-os-dma-memory@40000000 {
                 compatible = "shared-dma-pool";
                 reg = <0x00 0x40000000 0x00 0x3000000>;
                 no-map;
             };
         };

         mcs-riscv-remoteproc {
             compatible = "oe,mcs_riscv_remoteproc";
             memory-region = <&riscv_os_dma_memory_region>,
                             <&riscv_os_reserved>;

             /* RISCV核中断寄存器 */
             reg = <0x00 0x11031000 0x00 0x1000>;

             /* 0: GIC_SPI */
             /* 26: 中断号偏移 (58 - 32 = 26) */
             /* 4: IRQ_TYPE_LEVEL_HIGH */
             interrupts = <0 26 4>;
             interrupt-parent = <0x01>;
         };

      ``mcs_km.ko`` 会根据 ``oe,mcs_riscv_remoteproc`` 节点预留内存段。其中：

      - riscv_os_dma_memory_region: 用于Linux侧和RTOS侧的通信共享内存
      - riscv_os_reserved: 用于RTOS侧运行系统的地址

      .. important::

         ``oe,mcs_riscv_remoteproc`` 节点中的 ``memory-region`` 属性，必须将通信共享内存放在第一个。

      **3. 验证预留结果**

      .. code-block:: console

         $ cat /proc/interrupts
                      CPU0       CPU1       CPU2       CPU3
         ...
          54:          0          0          0          0     GICv3  58 Level     MCS RISCV IRQ

         $ cat /proc/iomem
         ...
         40000000-42ffffff : mcs_riscv_mem
         44000000-47ffffff : mcs_riscv_mem
         ...

RTOS侧资源预留
--------------

对于baremetal/hetero/jailhouse：需要RTOS侧配置好与Linux约定的共享内存（包括通信共享内存和系统运行地址）和中断。

对于xen：中断和共享内存都由Linux动态分配，RTOS通过XenBus动态获取event channel port和grant table reference。

不同RTOS请根据系统类型选择不同的配置方法。

____

MICA组件安装
************

MICA组件概述
=================

MICA框架由以下核心组件组成：

内核态驱动

- baremetal/hetero: ``mcs_km.ko``
- jailhouse: ``jailhouse.ko``
- xen: ``xen-mcsback.ko``

用户态守护进程

- ``micad``

用户态命令行工具

- ``mica.py``

开发支持库

- ``libmica.a``
- ``libmica.so``

使用Yocto构建的镜像
====================

如果使用yocto构建的mcs镜像（参考 :ref:`MCS镜像构建指导 <mcs_build>`），开发板启动后MICA服务通常会自动运行。

.. note::

   如果MICA服务没有正常运行，或者需要自行编译和调试MICA组件，请参考下一节。

自行编译和安装
================

编译MICA组件
----------------

参考 `MCS <https://atomgit.com/openeuler/mcs>`_ 编译出以下组件并上传到开发板：

- ``micad``
- ``mcs_km.ko`` 或 ``xen-mcsback.ko``
- ``mica.py``
- ``libmica.so`` （如果用户应用基于动态库开发）

注：jailhouse的ko需要通过yocto编译

安装步骤
-----------------------------

不同部署模式的ko名称不同。以下示例以baremetal为例。

busybox环境：

.. code-block:: console

   ps | grep micad | grep -v grep | awk '{print $1}' | xargs kill -9
   rmmod mcs_km
   rm -rf /run/mica*
   cp mica.py /usr/lib64/python3.11/site-packages/mica.py
   cp micad /usr/bin/micad
   cp mcs_km.ko /lib/modules/$(uname -r)/updates/
   modprobe mcs_km
   micad &
   ps | grep micad | grep -v grep

systemd环境：

.. code-block:: console

   systemctl stop micad
   rmmod mcs_km
   cp mica.py /usr/lib64/python3.11/site-packages/mica.py
   cp micad /usr/bin/micad
   cp mcs_km.ko /lib/modules/$(uname -r)/updates/
   modprobe mcs_km
   systemctl start micad

验证安装结果
----------------

如果运行micad或插入内核模块有报错，请根据具体报错信息进行定位。

正常运行时：

- ``ps | grep micad`` 或 ``systemctl status micad`` 中显示 ``micad`` 正常运行
- ``lsmod`` 显示 ``mcs_km``/ ``jailhouse``/ ``xen-mcsback`` 已插入

____

创建和启动client OS
*******************

创建配置文件
============

参考 :ref:`MICA配置文件介绍 <mica_ctl>` ，创建开发板专用的配置文件，放置在 ``/etc/mica`` 目录下。

配置要点：

- client Name必须唯一
- 使用的CPU必须是Linux和RTOS侧约定好的
- 镜像路径必须是准确的绝对路径

创建和启动实例
================

参考 :ref:`MICA命令行介绍 <mica_ctl>` 创建和启动client OS实例：

.. code-block:: console

   mica create <conf>
   mica start <name>

如果有报错，请根据具体报错信息进行定位。

____

调试和验证
**********

确认RTOS运行状态
==================

如果 ``mica start`` 执行成功，说明MICA已下发指令去拉起client OS镜像，但需要确认client OS运行到了哪一步。

在调试初期，MICA通信可能不会直接建立（即 ``/dev/ttyRPMSGx`` 未创建出来，tty服务不可用），需要使用其他方式进行client OS侧的调试。

调试方法
========

方法一：串口输出
-------------------

如果是baremetal部署，可以尝试让client OS的串口驱动直接使用用户可访问的串口寄存器。理想情况下，client OS可以直接print到用户可访问的串口，便于调试。

方法二：内存打点
------------------

如果串口方法不可行，可以使用内存打点的方式进行调试。在开发板上找一块空闲的内存，该内存地址需要client侧和Linux侧都能读写。

不同的client OS访问内存的接口不同，例如 ``UniProton`` 可参考 ``GIC_REG_WRITE(addr, data)`` 的定义。

Linux侧如果构建镜像时开启了debug feature，会有 ``devmem`` 命令行工具。

示例：

- RTOS侧向 ``0xABCD0000`` 写入数据 ``0xAAAAAAAA``
- Linux侧拉起RTOS后执行 ``devmem 0xABCD0000`` 返回 ``0xAAAAAAAA``

如果两边内存打点方式通了，虽然没有print方便，但至少Linux能逐步看到RTOS侧的运行状态。

逐步验证RTOS启动流程
======================

1. 确认RTOS开始运行

   根据不同RTOS的启动流程，在RTOS刚开始运行的函数、时钟中断中进行打点，确认RTOS确实开始运行。

2. 确认通信用的共享内存和中断是通的，TX和RX都需验证

   在两边都能运行到的函数中，通过通信共享内存地址的互相读写来验证共享内存，以及通过发起中断后能触发对面的中断处理函数来验证中断。

3. 确认MICA框架初始化

   确认RTOS在运行并基础功能没问题后，逐步打点直到进入RTOS侧MICA框架和服务的初始化流程，即 :ref:`RTOS适配指南 <rtos_adaptation>` 里描述的OpenAMP初始化。
   
   如果有异常，请根据具体打点信息进行定位。

4. 验证MICA通信

   当MICA的服务都初始化完成后，尝试在Linux侧通过 ``screen /dev/ttyRPMSGx`` 访问RTOS侧的shell或标准输出。
   
   如果设备存在且可访问，说明MICA基础通信已建立。

后续开发
========

MICA基础通信建立后，可以根据用户应用的需要，通过 :ref:`RPC服务 <mica_rpc>`、 :ref:`UMT服务 <mica_umt>` 进一步开发所需功能。

____

常见调试问题
************

通用问题
========

1. 看不到MICA的维测日志
------------------------------

**原因**: 不同系统的syslog日志会被配置输出到不同的路径，常见路径包括 ``/var/log/syslog``、 ``/var/log/messages`` 等。

**解决**: 查看syslog日志路径是否正确，或者使用 ``grep`` 等工具过滤 ``micad`` ``mcs`` 相关日志。

另外如果需要使能micad中的debug打印，可在cmake时添加 ``-DCMAKE_BUILD_TYPE=Debug`` 选项。

2. 编译MICA组件或运行部署时，提示 ``libmetal`` ``openamp`` 相关库、头文件未找到
--------------------------------------------------------------------------------

**原因**: MICA依赖 ``libmetal`` ``openamp`` 等库，而开启了mcs镜像的 `SDK <https://pages.openeuler.openatom.cn/embedded/docs/build/html/master/getting_started/index.html#sdk>`_ ，会包含这些库的头文件和库。

如果在编译MICA组件或运行部署时提示这些库或头文件未找到，可能是因为这些库未被正确安装或配置。

**解决**: 如果是编译阶段，请确认使用的是oEE SDK，且对应镜像开启了mcs特性；

如果是运行部署阶段，请确认开发板rootfs打包了 ``libmetal`` ``openamp`` 等库，且路径正确，例如 ``/usr/lib64/libmetal.so.1`` ``/usr/lib64/libopen_amp.so.1``。

3. ``mica create/start`` 时报错，通过syslog查看报错信息，提示 ``failed to parse rsc table, please check the rsctable``
----------------------------------------------------------------------------------------------------------------------------

**原因**: MICA拉起client前会解析ELF镜像并获取资源表，如果不存在则直接返回失败。

**解决**: 根据 :ref:`RTOS适配指南 <rtos_adaptation>` 适配资源表，确保RTOS ELF镜像中有 ``.resource_table`` 段。

4. 首次通过oebuild generate构建选择feature时，发现mcs不可选
-----------------------------------------------------------------

**原因**: 新开发板未在MCS特性支持列表中。

**解决**: 在 ``src/yocto-meta-openeuler/.oebuild/features/mcs.yaml`` 中的 ``support`` 字段后面新增你的开发板名称。

5. ``mica status/create`` 时报错 ``Error occurred! please check if micad is running``
------------------------------------------------------------------------------------------------

**原因**: ``mica.py`` 通过 ``/run/mica/mica-create.socket`` 与 ``micad`` 守护进程通信，socket通信失败通常有以下原因：

- ``micad`` 未启动或已停止，导致socket未创建。
- ``mica`` 命令行未通过 ``root`` 用户执行，访问socket时因权限不足被拒绝。

**解决**:

- 检查 ``micad`` 是否正常运行（使用 ``ps | grep micad`` 或 ``systemctl status micad`` 查看）。
- 使用 ``sudo`` 提升权限或切换到 ``root`` 用户后再执行 ``mica`` 命令。

6. ``mica create`` 时报错 ``No such file`` ，后面为空或一些不符合预期的字符
------------------------------------------------------------------------------------------------

**原因**: 该打印检查的是MICA conf中的RTOS镜像路径是否存在，如果确实是个文件路径，那么就是该路径下的文件不存在。如果是空或不符合预期的字符，则是组件功能问题。

``mica.py`` 通过socket与 ``micad`` 守护进程通信，而socket传输的消息格式是两边约定好的结构体。

然而若用户调试时，仅在环境中更新了其中一者（ ``mica.py`` 或 ``micad`` ），另一方未更新，且当两个版本间刚好有消息格式的差异，就会导致socket数据解析有误。

若用户使用自己的编译链环境，也有小概率会导致编译选项导致的结构体对齐差异。

**解决**: 如果不确定运行环境和本地源码是否存在版本差异，建议同时更新 ``mica.py`` 和 ``micad`` 。另外建议使用oEE SDK编译MICA组件，以确保使用的是一致的编译选项和环境。

7. RTOS执行完MICA框架和服务的初始化了，但Linux侧tty设备仍未创建，或screen后无反应。
---------------------------------------------------------------------------------------------

**原因**: 无论是tty、rpc、umt还是其他自定义的服务，都依赖openamp endpoint的牵手。如果ept未成功握手，就无法正常使用这些服务。

ept的握手通常依赖：(1) Linux侧和RTOS侧ept名称一致；(2) TX和RX的共享内存和中断是通的。

**解决**: 

(1) 确认Linux侧和RTOS侧ept名称可以匹配 ``rpmsg-tty*`` ``rpmsg-rpc`` ``rpmsg-umt``
(2) 通过串口打印或内存打点，确认TX和RX的共享内存和中断是通的。

8. 通过打点发现，RTOS在 ``rproc_virtio_wait_remote_ready`` 函数处卡住，无法继续初始化。
---------------------------------------------------------------------------------------------

**原因**: 在MICA初始化阶段，Linux侧和RTOS侧会通过资源表互通状态信息。而RTOS执行到 ``rproc_virtio_wait_remote_ready`` 时，则表示需要先等待Linux侧完成rpmsg设备初始化，保障初始化时序。

然而，若Linux侧未完成rpmsg设备初始化，或者资源表状态未刷新，RTOS侧则会一直卡在 ``rproc_virtio_wait_remote_ready`` 函数处，无法继续初始化。

**解决**: 通常如果Linux侧未报错并且确实拉起了RTOS，rpmsg设备也会继续初始化，可通过维测打印确认。

常见问题在于资源表的状态刷新，当前baremetal的资源表直接使用RTOS ELF镜像的.resource_table段，RTOS也直接通过该段的地址访问。
而其他底座（jailhouse、xen、hetero）的资源表会被搬运到通信共享内存的第一个页中，因此需要确保RTOS通过资源表在等待Linux状态时，用的是正确的资源表地址。

baremetal使用问题
==================

1. ``mica start`` 时报错 boot clientos failed(-4)
------------------------------------------------------------

**原因**: MICA驱动在拉起client OS时，会通过PSCI发起SMC或HVC调用。-4（``ALREADY_ON``）是PSCI定义的错误码，表示在拉起一个核时发现目标核已在线。

**解决**: 使用baremetal时，把client OS部署在目标核前，须确保该核未上线。

2. 编译 ``mcs_km.ko`` 时提示 ``cpu_logical_map`` 符号未定义/导出
-------------------------------------------------------------------

**原因**: ``mcs_km.ko`` 依赖内核的 ``cpu_logical_map`` 符号来发起PSCI操作，而该符号在某些内核版本中未被导出。

通常通过oebuild构建的mcs镜像会做定制化适配，但如果用户使用的内核未使用嵌入式的 `补丁 <https://atomgit.com/openeuler/yocto-meta-openeuler/tree/master/meta-openeuler/recipes-kernel/linux/files/meta-data/features/mcs>`_ ，则可能出现 ``cpu_logical_map`` 符号未导出的问题。

**解决**: 如果是用户自行构建的内核，请在内核中导出 ``cpu_logical_map`` 符号，或开启 ``CONFIG_KPROBES`` 宏配置。


jailhouse使用问题
==================

欢迎补充


xen使用问题
============

欢迎补充


hetero使用问题
===============

欢迎补充

.. _mica_ctl:

mica命令与配置文件
##################

mica命令介绍
************

.. code-block:: console

   qemu-aarch64:~$ mica --help
   usage: mica [-h] {create,start,stop,rm,set,status,gdb} ...

   Query or send control commands to the micad.

   positional arguments:
     {create,start,stop,rm,set,status,gdb}
                           the command to execute
       create              Create a new mica client
       start               Start a client
       stop                Stop a client
       rm                  Remove a client
       set                 Update settings for a client
       status              query the mica client status
       gdb                 Start GDB client
       ...

   options:
     -h, --help            show this help message and exit

``mica create <conf>``
    根据配置文件创建一个 mica 实例，该实例会关联一个实时OS，以及该实时OS运行的系统资源，包括 CPU 等。

``mica start <name>``
    启动名字为 <name> 的实例。

``mica stop <name>``
    停止名字为 <name> 的实例。

``mica rm <name>``
    销毁名字为 <name> 的实例。

``mica status``
    查询各个实例的状态信息，以及关联的服务信息。

``mica gdb <name>``
    如果名字为 <name> 的实例支持调试，可以通过该命令启动 GDB Client 开始调试。

``mica set <name> <resource> <value>``
    在线更新名字为 <name> 的实例的 <resource> 为 <value>。

    当前仅支持xen部署时配置CPU、VCPU、CPUWeight、CPUCapacity、Memory资源项，<value>和实例配置文件的入参要求保持一致。

    例如：

    ``mica set qemu-uniproton-xen Memory 1024`` 表示将名字为 ``qemu-uniproton-xen`` 的实例的内存更新为1024MB。

    ``mica set qemu-uniproton-xen CPUCapacity 100`` 表示将名字为 ``qemu-uniproton-xen`` 的实例的CPU算力更新为1个物理CPU。

____

实例配置文件介绍
****************

配置文件用于创建实例，通过不同的选项参数承载该实例对应的实时OS、CPU 等信息。**所有的选项需要放在** ``[Mica]`` **段中配置**：

  +--------------------+----------------------------------------+------------------------------+----------+
  |      配置项        |           配置内容                     |           入参要求           | 底座支持 |
  +====================+========================================+==============================+==========+
  |``Name=``           |实例名称，必须唯一                      |str（长度<32）                |ALL       |
  +--------------------+----------------------------------------+------------------------------+----------+
  |``CPU=``            |为实时OS分配的核号，范围 0 ~ nproc - 1  |str（长度<128）               | ALL      |
  +--------------------+----------------------------------------+------------------------------+----------+
  |``ClientPath=``     |实时OS的镜像路径，需要配置为绝对路径，  |str（长度<128）               |ALL       |
  |                    |且仅支持elf                             |                              |          |
  +--------------------+----------------------------------------+------------------------------+----------+
  |``AutoBoot=``       |是否在micad启动时自动拉起该实例，       |yes/no                        |ALL       |
  |                    |默认为no                                |                              |          |
  +--------------------+----------------------------------------+------------------------------+----------+
  |``Pedestal=``       |指定部署底座，默认为baremetal，即在裸核 |str（长度<128）               |ALL       |
  |                    |运行RTOS；支持配置为jailhouse/xen       |                              |          |
  +--------------------+----------------------------------------+------------------------------+----------+
  |``PedestalConf=``   |指定部署底座关联的配置文件              |str（长度<128）               |ALL       |
  +--------------------+----------------------------------------+------------------------------+----------+
  |``Debug=``          |表示OS二进制是否支持调试，默认为no      |yes/no                        |ALL       |
  |                    |                                        |                              |          |
  |                    |如果支持调试，可以通过mica gdb命令启动  |                              |          |
  |                    |GDB Client开始调试                      |                              |          |
  +--------------------+----------------------------------------+------------------------------+----------+
  |``VCPU=``           |为实时OS分配的虚拟CPU数量               |int（范围1~nproc）            |xen       |
  +--------------------+----------------------------------------+------------------------------+----------+
  |``MaxVCPU=``        |在线扩容时可为实时OS分配                |int（范围1~nproc）            |xen       |
  |                    |的最大虚拟CPU数量，默认和VCPU一致       |                              |          |
  +--------------------+----------------------------------------+------------------------------+----------+
  |``CPUWeight=``      |为实时OS分配的CPU算力权重，             |int（范围1~65535）            |xen       |
  |                    |默认256                                 |                              |          |
  +--------------------+----------------------------------------+------------------------------+----------+
  |``CPUCapacity=``    |为实时OS分配的CPU算力（百分比）         |int（范围0~100*nproc）        |xen       |
  |                    |                                        |                              |          |
  |                    |例如100表示1个物理CPU，50表示           |                              |          |
  |                    |半个物理CPU，默认0即不限制              |                              |          |
  +--------------------+----------------------------------------+------------------------------+----------+
  |``Memory=``         |为实时OS分配的内存大小（MB）            |int                           |xen       |
  +--------------------+----------------------------------------+------------------------------+----------+
  |``MaxMemory=``      |在线扩容时可为实时OS分配                |int（>= Memory）              |xen       |
  |                    |的最大内存大小（MB），默认等于Memory    |                              |          |
  +--------------------+----------------------------------------+------------------------------+----------+

**各底座的配置说明**

**``CPU=`` 参数：**

- baremetal：仅支持单核，范围 0 ~ nproc - 1
- hetero：指定为 riscv
- jailhouse：实际由cell文件配置
- xen：支持多核，范围 0 ~ nproc - 1，例如 1-3 表示使用 CPU1、CPU2、CPU3 这三个物理核

**``PedestalConf=`` 参数：**

- baremetal：不涉及
- hetero：指定用于引导RTOS的bin文件
- jailhouse：指定RTOS所需的 Non-Root Cell配置文件
- xen：指定用于引导RTOS的bin文件


以下为一些配置文件样例：

示例一：

   .. code-block:: console

      [Mica]
      Name=qemu-zephyr
      CPU=3
      ClientPath=/lib/firmware/qemu-zephyr-rproc.elf
      AutoBoot=yes

   该配置文件表明，micad启动时，会默认启动一个名为 qemu-zephyr 的实例，即在 CPU3 上加载 `/lib/firmware/qemu-zephyr-rproc.elf` 并启动。

示例二：

   .. code-block:: console

      [Mica]
      Name=qemu-zephyr-ivshmem
      CPU=3
      ClientPath=/lib/firmware/qemu-zephyr-ivshmem.elf
      AutoBoot=no
      Pedestal=jailhouse
      PedestalConf=/usr/share/jailhouse/cells/qemu-arm64-zephyr-mcs-demo.cell

   该配置文件定义了一个名为 qemu-zephyr-ivshmem 的实例，并指定使用 jailhouse 作为部署底座，同时该实例使用的 jailhouse Non-Root Cell 为 `/usr/share/jailhouse/cells/qemu-arm64-zephyr-mcs-demo.cell`。

示例三：

    .. code-block:: console

       [Mica]
       Name=rpi4-uniproton-debug
       CPU=3
       ClientPath=/lib/firmware/rpi4-uniproton-debug.elf
       AutoBoot=yes
       Debug=yes

    该配置文件定义了一个名为 rpi4-uniproton-debug 的实例，并指定该实例实现了GDB stub，支持调试。

示例四：

    .. code-block:: console

       [Mica]
        Name=qemu-uniproton-xen
        CPU=1-3
        ClientPath=/lib/firmware/qemu-uniproton-xen.elf
        AutoBoot=no
        Pedestal=xen
        PedestalConf=/lib/firmware/qemu-uniproton-xen.bin
        Memory=1024
        VCPU=1
        CPUCapacity=50

    该配置文件定义了一个名为 qemu-uniproton-xen 的实例，并指定使用 xen 作为部署底座，同时该实例使用的 xen 引导文件为 `/lib/firmware/qemu-uniproton-xen.bin`，RTOS运行在核1、2、3。

示例五：

    .. code-block:: console

       [Mica]
       Name=liteos
       CPU=riscv
       ClientPath=/lib/firmware/liteos.elf
       AutoBoot=no
       Pedestal=hetero
       PedestalConf=/lib/firmware/liteos.bin

    该配置文件定义了一个名为 liteos 的实例，并指定使用 hetero 作为部署底座，表示在RISC-V核上运行RTOS，同时该实例使用的引导文件为 `/lib/firmware/liteos.bin`。
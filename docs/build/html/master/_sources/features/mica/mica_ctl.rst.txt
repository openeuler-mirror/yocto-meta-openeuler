.. _mica_ctl:

mica命令与配置文件
##################

mica命令介绍
************

.. code-block:: console

   qemu-aarch64:~$ mica --help
   usage: mica [-h] {create,start,stop,rm,status} ...

   Query or send control commands to the micad.

   positional arguments:
     {create,start,stop,rm,status...}
                           the command to execute
       create              Create a new mica client
       start               Start a client
       stop                Stop a client
       rm                  Remove a client
       status              query the mica client status
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

____

实例配置文件介绍
****************

配置文件用于创建实例，通过不同的选项参数承载该实例对应的实时OS、CPU 等信息。**所有的选项需要放在** ``[Mica]`` **段中配置**：

``Name=``
    实例名称，必须唯一。

``CPU=``
    为实时OS分配的核号，范围：0 到 nproc - 1。

``ClientPath=``
    实时OS的镜像路径，需要配置为绝对路径，且仅支持 elf 格式的镜像。

``AutoBoot=``
    是否在 micad 启动时自动拉起该实例，默认为 no。

``Pedestal=``
    指定部署底座，默认为 bare-metal，即在裸核上运行 RTOS。当前支持在 QEMU 上配置为 jailhouse，以使用 jailhouse 部署。

``PedestalConf=``
    指定部署底座关联的配置文件。例如 Jailhouse 部署时，需要通过 PedestalConf 指定 RTOS 所需的 Non-Root Cell 配置文件。

``Debug=``
    bool类型，表示OS二进制是否支持调试，默认为 no。如果支持调试，可以通过 mica gdb 命令启动 GDB Client 开始调试。

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

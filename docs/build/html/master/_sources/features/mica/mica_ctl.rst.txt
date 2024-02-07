.. _mica_ctl:

mica命令与配置文件
##################

mica命令介绍
************

.. code-block:: console

   qemu-aarch64:~$ mica --help
   usage: mica [-h] {create,start,stop,status} ...

   Query or send control commands to the micad.

   positional arguments:
     {create,start,stop,status...}
                           the command to execute
       create              Create a new mica client
       start               Start a client
       stop                Stop a client
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

``mica status``
    查询各个实例的状态信息，以及关联的服务信息。

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
    是否在创建实例时，自动拉起该实例，默认为 no。

以下为一个配置文件样例：

.. code-block:: console

   [Mica]
   Name=qemu-zephyr
   CPU=3
   ClientPath=/lib/firmware/qemu-zephyr-rproc.elf
   AutoBoot=yes


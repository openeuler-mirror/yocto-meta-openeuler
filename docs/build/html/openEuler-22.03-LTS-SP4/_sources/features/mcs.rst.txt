.. _mixed_critical_system:

混合关键性系统
##############


混合关键性系统特性介绍
======================

在嵌入式场景中，虽然Linux已经得到了广泛应用，但并不能覆盖所有需求，例如高实时、高可靠、高安全的场合。这些场合往往是实时操作系统的用武之地。有些应用场景既需要Linux的管理能力、丰富的生态又需要实时操作系统的高实时、高可靠、高安全，那么一种典型的设计是采用一颗性能较强的处理器运行Linux负责富功能，一颗微控制器/DSP/实时处理器运行实时操作系统负责实时控制或者信号处理，两者之间通过I/O、网络或片外总线的形式通信。这种方式存在的问题是，硬件上需要两套系统、集成度不高，通信受限与片外物理机制的限制如速度、时延等、软件上Linux和实时操作系统两者之间是割裂的，在灵活性上、可维护性上存在改进空间。

受益于硬件技术的快速发展，嵌入式系统的硬件能力越来越强大，如单核能力不断提升、单核到多核、异构多核乃至众核的演进，虚拟化技术和可信执行环境(TEE)技术的发展和应用，未来先进封装技术会带来更高的集成度等等，使得在一个片上系统中（SoC）部署多个OS具备了坚实的物理基础。

同时，受应用需求的推动，如物联网化、智能化、功能安全与信息安全等等，整个嵌入式软件系统也越发复杂，全部由单一OS承载所有功能所面临的挑战越来越大。解决方式之一就是不同系统负责所各自所擅长的功能，如Windows的UI、Linux的网络通信与管理、实时操作系统的高实时与高可靠等，而且还要易于开发、部署、扩展，实现的形式可以是容器、虚拟化等。

面对上述硬件和应用的变化，结合自身原有的特点，嵌入式系统未来演进的方向之一就是 **混合关键性系统(MCS, Mixed Criticality System)**, 这可以从典型的嵌入式系统-汽车电子的最近发展趋势略见一斑。

    .. figure:: ../../image/mcs/mcs_architecture.png
        :align: center

        图 1 openEuler Embedded中的混合关键性系统大致架构

从openEuler Embedded的角度，混合关键性系统的大致架构如上图所示，所面向的硬件是具有同构或异构多核的片上系统，从应用的角度看会同时部署多个OS/运行时，例如Linux负责系统管理与服务、1个实时操作系统负责实时控制、1个实时操作系统负责系统可靠、1个裸金属运行时运行专用算法，全系统的功能是由各个OS/运行时协同完成。中间的 **混合部署框架** 和 **嵌入式虚拟化** 是具体的支撑技术。关键性（Criticality）狭义上主要是指功能安全等级，参考泛功能安全标准IEC-61508，Linux可以达到SIL1或SIL2级别，实时操作系统可以达到最高等级SIL3；广义上，关键性可以扩展至实时等级、功耗等级、信息安全等级等目标。

在这样的系统中，需要解决如下几个问题：

* **高效地混合部署问题**：如何高效地实现多OS协同开发、集成构建、独立部署、独立升级

* **高效地通信与协作问题**：系统的整体功能由各个域协同完成，因此如何高效地实现不同域之间高效、可扩展、实时、安全的通信

* **高效地隔离与保护问题**：如何高效地实现多个域之间的强隔离与保护，使得出故障时彼此不互相影响，以及较小的可信基（Trust Compute Base）

* **高效地资源共享与调度问题**：如何在满足不同目标约束下（实时、功能安全、性能、功耗），高效地管理调度资源，从而提升硬件资源利用率

对于上述问题，openEuler Embedded的当前思路是 **混合关键性系统 = 部署 + 隔离 + 调度** ，即首先实现多OS的混合部署，再实现多OS之间的隔离与保护，最后通过混合关键性调度提升资源利用率， 具体可以映射到 **混合部署框架** 和 **嵌入式虚拟化**。混合部署框架解决 **高效地混合部署问题** 和 **高效地通信与协作问题**，嵌入式虚拟化解决 **高效地隔离与保护问题** 和 **高效地资源共享与调度问题**。


多OS混合部署框架
===================

openEuler Embedded中多OS混合部署框架的架构图如下所示，引入了开源框架 `OpenAMP <https://www.openampproject.org/>`_ 作为基础， 并结合自身需要
进一步创新。

    .. figure:: ../../image/mcs/openamp_architecture.png
        :align: center

        图 2 多OS混合部署框架的基础架构

在上述架构中，libmetal提供屏蔽了不同系统实现的细节提供了统一的抽象，virtio queue相当于网络协议中的MAC层提供高效的底层通信机制，rpmsg相当于网络协议中的传输层提供了基于端点（endpoint）与通道（channel）抽象的通信机制，remoteproc提供生命周期管理功能包括初始化、启动、暂停、结束等。

目前，混合部署框架不仅能在qemu上进行仿真验证，还支持在树莓派实际硬件上部署运行。未来，openEuler Embedded的混合部署框架还会继续演进，包括对接更多的实时操作系统，如国产开源实时操作系统 `RT-Thread <https://www.rt-thread.org/>`_，实现如下图所示的多OS服务化部署并适时引入基于虚拟化技术的嵌入式弹性底座。

    .. figure:: ../../image/mcs/os_services.png
        :align: center

        图 3 多OS服务化部署架构

在上述多OS服务化部署架构中，openEuler Embedded是中心，主要对其他OS提供管理、网络、文件系统等通用服务，其他OS可以专注于其所擅长的领域提供诸如实时控制、监控等服务，并通过shell、log和debug等通道与Linux丰富而强大维测体对接从而简化开发工作。


.. _mcs_build:

构建指南
========

openEuler Embedded 不仅支持混合关键性系统特性的单独构建，还实现了集成构建，能够使用同一套工具链一键式构建出包含linux, zephyr的部署镜像。

.. note:: 单独构建混合关键系统特性的方法请参考 `mcs 构建安装指导 <https://gitee.com/openeuler/mcs#%E6%9E%84%E5%BB%BA%E5%AE%89%E8%A3%85%E6%8C%87%E5%AF%BC>`_

**集成构建指导**

1. 根据 :ref:`oebuild快速构建 <openeuler_embedded_oebuild>` ，初始化oebuild工作目录；

   .. code-block:: shell

      oebuild init <directory>
      cd <directory>
      oebuild update

2. 下载依赖代码：

   zephyr 的构建包含核心部分和外部 zephyr modules 部分，由于全部代码较大，需要从 `src-openEuler/zephyr <https://gitee.com/src-openeuler/zephyr>`_ 中的百度网盘路径下载 zephyr_project_v3.2.0.tar.gz，并放在构建代码目录下的 zephyrproject 子目录中（对应oebuild工作目录的<workspace>/src/zephyrproject）

   python3-pykwalify 在 openeuler 社区尚无相应的源码包，需要从上游下载 `Download pykwalify-1.8.0.tar.gz <https://pypi.org/project/pykwalify/1.8.0/#files>`_ ，并放在构建代码目录下的 python3-pykwalify 子目录中（对应oebuild工作目录的<workspace>/src/python3-pykwalify）

3. 进入oebuild工作目录，创建对应的编译配置文件，**mcs镜像需要添加** ``-f openeuler-mcs``：

   .. code-block:: shell

      # qemu-arm64
      oebuild generate -p qemu-aarch64 -f openeuler-mcs -d <build_arm64_mcs>

      # RPI4
      oebuild generate -p raspberrypi4-64 -f openeuler-mcs -d <build_rpi_mcs>

      # ok3568
      oebuild generate -p ok3568 -f openeuler-mcs -d <build_ok3568_mcs>

      # hi3093
      oebuild generate -p hi3093 -f openeuler-mcs -d <build_hi3093_mcs>

4. 进入 ``<build>`` 目录，编译 ``openeuler-image-mcs`` ：

   .. code-block:: shell

      oebuild bitbake openeuler-image-mcs

.. note::

   **注意**：构建 openeuler-image-mcs 需要在 oebuild 初始化时添加 ``-f openeuler-mcs``。

使用方法
========

目前混合关键性系统（mcs）支持在qemu-aarch64和树莓派上部署运行，部署mcs需要预留出必要的内存、CPU资源，并且还需要bios提供psci支持。

1.镜像启动
  - **对于树莓派:**

     集成构建出来的 openeuler-image-mcs 已经通过 dt-overlay 等方式预留了相关资源，并且默认使用了支持psci的uefi引导固件。因此只需要根据 :ref:`openeuler-image-uefi启动使用指导 <raspberrypi4-uefi-guide>` 进行镜像启动，再部署mcs即可。
  - **对于qemu:**

     需要准备一份dtb文件，dtb文件的制作可参考 `配置dts预留出mcs_mem <https://gitee.com/openeuler/mcs#%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E>`_ ，并通过以下命令启动qemu：

     .. code-block:: console

       $ qemu-system-aarch64 -M virt,gic-version=3 -m 1G -cpu cortex-a57 -nographic \
       -append 'maxcpus=3' -smp 4 \
       -kernel zImage \
       -initrd *.rootfs.cpio.gz \
       -dtb qemu_mcs.dtb
  - **对于ok3568:**

     已经通过条件判断的形式把预留内存加入了设备树，构建出来即可使用。
  - **对于hi3093:**

     hi3093需要在boot以后限制maxcpus=3预留出一个cpu跑uniproton

     .. code-block:: console

       # 使用在ctrl+b进入uboot，并限制启动的cpu数量
       setenv bootargs "${bootargs} maxcpus=3"

2.部署mcs
  - **step1: 调整内核打印等级并插入内核模块**

     .. code-block:: console

        # 为了不影响shell的使用，先屏蔽内核打印：
        $ echo "1 4 1 7" > /proc/sys/kernel/printk

        # 插入内核模块
        $ modprobe mcs_km.ko

        # 备注：ok3568与hi3093已经实现了开机自动加载内核模块，无需重复此步骤

     插入内核模块后，可以通过 `cat /proc/iomem` 查看预留出来的 mcs_mem，如：

     .. code-block:: console

        qemu-aarch64 ~ # cat /proc/iomem
        ...
        70000000-7fffffff : reserved
        70000000-7fffffff : mcs_mem
        ...

     若mcs_km.ko插入失败，可以通过dmesg看到对应的失败日志，可能的原因有：1.使用的交叉工具链与内核版本不匹配；2.未预留内存资源；3.使用的bios不支持psci

  - **step2: 运行rpmsg_main程序，启动client os**

     - **qemu-arm64 和 RPI4：**

       .. code-block:: console

          $ rpmsg_main -c [cpu_id] -t [target_binfile] -a [target_binaddress]
          eg:
          $ rpmsg_main -c 3 -t /firmware/zephyr-image.bin -a 0x7a000000

       若rpmsg_main成功运行，会有如下打印：

       .. code-block:: console

          # rpmsg_main -c 3 -t /firmware/zephyr-image.bin -a 0x7a000000
          ...
          start client os
          ...
          pls open /dev/pts/1 to talk with client OS
          pty_thread for uart is runnning
          ...

       此时， **按ctrl-c可以通知client os下线并退出rpmsg_main** ，下线后支持重复拉起。
       也可以根据打印提示（ ``pls open /dev/pts/1 to talk with client OS`` ），
       通过 /dev/pts/1 与 client os 进行 shell 交互，例如：

       .. code-block:: console

          # 新建一个terminal，登录到运行环境
          $ ssh user@ip

          # 连接pts设备
          $ screen /dev/pts/1

          # 敲回车后，可以打开client os的shell，对client os下发命令，例如
          uart:~$ help
          uart:~$ kernel version

          #在ok3568上拉起rt-thread
          $ rpmsg_main -c 3 -t /firmware/rtthread-ok3568.bin -a 0x7a000000

          #在hi3093上拉起uniproton
          $ rpmsg_main -c 3 -t /firmware/Uniproton_hi3093.bin -a 0x93000000

     - **ok3568 开发板：**

       ok3568支持通过mcs拉起 RT-Thread，步骤如下：

       .. code-block:: console

          # 拉起RTT；
          ok3568 ~ # ./rpmsg_main -c 3 -t /firmware/rtthread-ok3568.bin -a 0x7a000000
          ...
          start client os
          ...

       ok3568支持通过输入功能编号进行交互、下线、重新拉起:

       .. code-block:: console

          # 输入h查看用法
          h
          please input number:<1-8>
          1. test echo
          2. send matrix
          3. start pty
          4. close pty
          5. shutdown clientOS
          6. start clientOS
          7. test ping
          8. test flood-ping
          9. exit

     - **hi3093 开发板：**

       hi3093目前支持 uniproton 的拉起，查看串口输出。

       .. code-block:: console

          # 拉起 uniproton
          $ ./rpmsg_main -c 3 -t /firmware/hi3093_ut.bin -a 0x93000000 &

          ...
          start client os
          ...
          pls open /dev/pts/1 to talk with client OS
          pty_thread for console is runnning
          ...

       此时， 根据打印提示（ ``pls open /dev/pts/1 to talk with client OS`` ），
       通过 /dev/pts/1 可以与 uniproton 进行交互，例如：

       .. code-block:: console

          # 连接pts设备
          $ screen /dev/pts/1

          # 敲回车后，可以查看uniproton输出信息


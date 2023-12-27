.. _preempt_rt:

软实时系统介绍
################################

本章主要介绍openEuler Embedded软实时系统的特性说明，构建方式和性能测试。

软实时特性介绍
**************

**实时性简介**

  实时的诉求通常是事件的响应时间不能超过规定的期限，一个事件的最大响应时间应该是确定的、可以预测的。

**PREEMPT_RT补丁简介**

  PREEMPT_RT补丁（以下简称RT补丁）可直接打在内核源码上，并通过内核配置选项 CONFIG_PREEMPT_RT=y 使能软实时功能。RT补丁实现的核心在于最小化内核中不可抢占部分的代码，从而使高优先级任务就绪时能及时抢占低优先级任务，减少切换时延。除此之外，补丁通过多种降低时延的措施，对锁、驱动等模块也进行了优化。

**补丁关键功能举例**

  - 增加中断程序的可抢占性（中断线程化、软中断线程化）
  - 增加临界区的可抢占性（如自旋锁）
  - 增加关中断代码的可抢占性
  - 解决优先级反转问题（优先级继承）

____

软实时镜像构建指导
******************

1. 根据 :ref:`oebuild快速构建 <openeuler_embedded_oebuild>` ，初始化oebuild工作目录；

   .. code-block:: shell

      oebuild init <directory>
      cd <directory>
      oebuild update

2. 进入oebuild工作目录，创建对应的编译配置文件，软实时镜像需要添加 ``-f openeuler-rt``：

   .. code-block:: shell

      # arm64
      oebuild generate -p qemu-aarch64 -f openeuler-rt -d <build_arm64_rt>

      # RPI4
      oebuild generate -p raspberrypi4-64 -f openeuler-rt -d <build_rpi_rt>

      # x86
      oebuild generate -p x86-64 -f openeuler-rt -d <build_x86_rt>

3. 进入 ``<build>`` 目录，编译openeuler-image：

   .. code-block:: shell

      oebuild bitbake openeuler-image

   .. note::

      1. openEuler Embedded 软实时特性当前不支持 arm32 架构

____

验证软实时是否使能
******************

   使能软实时特性后，系统会带有 ``PREEMPT_RT`` 字样，可以通过以下命令进行判断：

   .. code-block:: shell

      $ uname -a
      Linux openeuler ... SMP PREEMPT_RT Fri Mar 25 03:58:22 UTC 2022 aarch64 GNU/Linux

____

软实时性能测试
**************

**软实时相关测试**

参考 `RT-Tests 指导 <https://wiki.linuxfoundation.org/realtime/documentation/howto/tools/rt-tests>`_ 进行软实时相关测试，用例包括但不限于：
   1. cyclictest 时延性能测试
   2. pi_stress 优先级继承测试
   3. hackbench 负载构造工具

下面以cyclictest 时延性能测试为例进行说明。

**cyclictest 时延性能测试**

   .. note::
      | **对于x86架构**：
      |     cyclictest工具依赖 ``libnuma.so`` ，而SDK中未提供该库，建议使用openEuler-Embedded构建容器（或其它x86环境）编译cyclictest，并将libnuma.so上传到环境的 ``/lib64/`` 目录。
      |
      | **对于arm64架构**：
      |     可以参考下述步骤，使用SDK进行交叉编译。

   1. 准备开发环境

      参考 :ref:`安装SDK <install-openeuler-embedded-sdk>`

      .. code-block:: console

         sh openeuler-glibc-x86_64-openeuler-image-aarch64-qemu-aarch64-toolchain-22.03.sh

         . /path/to/sdk/environment-setup-aarch64-openeuler-linux

   2. 编译用例

      .. code-block:: console

         git clone https://git.kernel.org/pub/scm/utils/rt-tests/rt-tests.git
         cd rt-tests
         git checkout stable/v1.0
         make all

   3. 执行用例

      编译完成后生成二进制 :file:`cyclictest`，传入单板环境后可查看执行cyclictest时可配置的参数：

      .. code-block:: console

         ./cyclictest --help

      cyclictest有多种参数配置方法，用例具体的入参设计可参考：`test-design <https://wiki.linuxfoundation.org/realtime/documentation/howto/tools/cyclictest/test-design>`_

      输入示例：

      .. code-block:: console

         ./cyclictest -p 90 -m -i 100 -n -h 100 -l 10000000

      输出示例：

      .. code-block:: console

         # /dev/cpu_dma_latency set to 0us
         policy: fifo: loadavg: 2.32 1.99 1.58 1/95 311

         T: 0 (  311) P:90 I:100 C:10000000 Min:      7 Act:    9 Avg:    8 Max:      16

      即用例循环1000万次后，平均时延为8us，最坏时延为16us（该数据仅为示例，具体以环境实测为准）。

      .. attention::

         如果树莓派4B的空载情况下，平均时延较差（如超过20us），可查看使用的树莓派固件是否将CPU频率配置为了节能模式，并根据需要将CPU频率配置为最高运行频率。如无cpufreq相关接口，则不涉及。

         输入示例：

         .. code-block:: console

            cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

         输出示例：

         .. code-block:: console

            powersave

         如上结果表示CPU频率为节能模式。

         配置CPU最高运行频率，输入示例：

         .. code-block:: console

            echo performance > /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

____

.. _realtime_tuning:

软实时性能优化
**************

性能优化的原则是：降低不确定性，提高可预期性。实时性能的优化是非常复杂的，涉及硬件底层架构特征、内核采用的机制策略，以及上层软件的编程设计等。以下介绍了x86平台的一些性能优化措施：

- 调整BIOS配置：
  关闭 ``Hyper-Threading``, ``Intel SpeendStep``.

- 添加内核启动参数：

   .. list-table::
      :header-rows: 1

      * - Kernel Command Line
        - Description

      * - intel_pstate=disable
        - 禁用intel调频

      * - nohalt idle=poll intel_idle.max_cstate=0 processor.max_cstate=1
        - 避免CPU陷入深层次的省电睡眠状态

      * - nowatchdog
        - 关闭softlockup和hardlockup

      * - mce=ignore_ce
        - 忽略mce

      * - clocksource=tsc tsc=reliable
        - 指定tsc作为系统clocksource

- 修改虚拟内存统计周期：
  ``sysctl -w vm.stat_interval=120``

- 除了上述的针对系统全局的配置修改外，还可以为某些核进行单独配置：

   .. list-table::
      :header-rows: 1

      * - Kernel Command Line
        - Description

      * - isolcpus=<cpu number>,...,<cpu number>
        - 避免普通任务在指定CPU上调度运行

      * - nohz_full=<cpu number>,...,<cpu number>
        - 关闭指定CPU的tick

      * - rcu_nocbs=<cpu number>,...,<cpu number>
        - 卸载指定CPU的RCU回调任务

      * - irqaffinity=<cpu number>,...,<cpu number>
        - 配置中断亲缘性，默认由指定核处理中断

   可以为某些核进行以上配置，再将实时任务进行绑核，以减少实时任务受到的干扰。例如：

   .. code-block:: shell

      Step1:
        # 修改cmdline以隔离出cpu2及cpu3:
        "isolcpus=2,3 nohz_full=2,3 rcu_nocbs=2,3 irqaffinity=0,1"

      Step 2:
        # 将实时任务绑定到2核或3核
        taskset -c 2 ./realtime_task1
        taskset -c 3 ./realtime_task2

  .. note::
     openEuler-Embedded 可以通过修改boot分区的 ``grub.cfg`` 配置内核启动参数，例如：

     .. code-block:: shell

        vi /run/media/sda1/efi/boot/grub.cfg

        # cmdline 为 "rw quiet"
        menuentry 'boot'{
            linux /bzImage  root=PARTUUID=eaecae14-7021-4551-9183-29b0d210222f rw quiet
        }

     如果没有``/run/media/sda1/efi/boot/grub.cfg``可以使用``fdisk -l``查看磁盘情况，使用``mount``自行挂载。

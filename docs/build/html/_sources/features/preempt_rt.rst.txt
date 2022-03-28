.. preempt_rt:

openEuler嵌入式软实时系统
#########################

软实时特性介绍
**************

**实时性简介**

实时的诉求通常是事件的响应时间不能超过规定的期限，一个事件的最大响应时间应该是确定的、可以预测的。

**PREEMPT_RT补丁简介**

PREEMPT_RT补丁（以下简称RT补丁）可直接打在内核源码上，并通过内核配置 CONFIG_PREEMPT_RT 使能软实时功能。RT补丁实现的核心在于最小化内核中不可抢占部分的代码，从而使高优先级任务就绪时能及时抢占低优先级任务，减少切换时延。除此之外，还对锁、驱动等模块进行优化，采取多种降低时延的措施。

openEuler嵌入式版本中可使用的RT补丁请参考：

1. qemu：

- `patch-5.10.0-60.10.0-rt62.patch <https://gitee.com/src-openeuler/kernel/blob/openEuler-22.03-LTS/patch-5.10.0-60.10.0-rt62.patch>`_

- `patch-5.10.0-60.10.0-rt62_openeuler_defconfig.patch <https://gitee.com/src-openeuler/kernel/blob/openEuler-22.03-LTS/patch-5.10.0-60.10.0-rt62_openeuler_defconfig.patch>`_

2. raspberrypi：

- `0000-raspberrypi-kernel.patch （树莓派补丁） <https://gitee.com/src-openeuler/kernel/blob/openEuler-22.03-LTS/0000-raspberrypi-kernel.patch>`_

- `0001-add-preemptRT-patch.patch <https://gitee.com/src-openeuler/kernel/blob/openEuler-22.03-LTS/0001-add-preemptRT-patch.patch>`_

- `0002-modifty-bcm2711_defconfig-for-rt-rpi-kernel.patch <https://gitee.com/src-openeuler/kernel/blob/openEuler-22.03-LTS/0002-modifty-bcm2711_defconfig-for-rt-rpi-kernel.patch>`_

**关键功能**

1. 增加中断程序的可抢占性（中断线程化、软中断线程化）

2. 增加临界区的可抢占性（如自旋锁）

3. 增加关中断代码的可抢占性

4. 解决优先级反转问题（优先级继承）

等降低时延的措施。

软实时镜像构建指导
******************

具体下载源码和编译流程建议参考：`openEuler Embedded容器构建指导 <https://openeuler.gitee.io/yocto-meta-openeuler/yocto/quickbuild/container-build.html>`_

**通用构建方式**

如需构建openEuler嵌入式软实时镜像，可以根据所需BSP，在内核源码打入上述补丁后进行编译和调试。

- 步骤：

下载源码 --> 从源码仓 :file:`src-kernel-5.10` 获取RT补丁 --> 在内核  :file:`kernel-5.10`  打入RT补丁 --> 编译构建

- 以树莓派为例，打补丁方法示例：

.. code-block:: console

  cd /path/to/src/kernel-5.10/

  cp ../src-kernel-5.10/*.patch ./

  patch -p1 < 0000-raspberrypi-kernel.patch

  patch -p1 < 0001-add-preemptRT-patch.patch

  patch -p1 < 0002-modifty-bcm2711_defconfig-for-rt-rpi-kernel.patch

- 注意：

1. 如果开发人员使用的内核配置不是RT补丁中修改的defconfig（qemu：:file:`arch/arm64/configs/openeuler_defconfig`，树莓派：:file:`arch/arm64/configs/bcm2711_defconfig`），则需要在自己的defconfig中开启内核配置选项 CONFIG_PREEMPT_RT

2. 当前仅支持 arm64 架构

**aarch64-pro一键式构建方式**

yocto-meta-openeuler中也提供了一个可直接构建RT镜像的架构，便于开发人员一键式构建，无需再手动打RT补丁。通过 `编译构建 <https://openeuler.gitee.io/yocto-meta-openeuler/yocto/quickbuild/container-build.html#id10>`_ 中选择 **aarch64-pro** 架构，即可编译出支持树莓派的RT镜像。

- 构建命令示例:

.. code-block:: console

  cd /usr1/openeuler/src/yocto-meta-openeuler/scripts

  source compile.sh aarch64-pro /usr1/build /usr1/openeuler/gcc/openeuler_gcc_arm64le

  bitbake openeuler-image

- 构建镜像生成目录：

  :file:`/usr1/build/output/`

- 二进制介绍：

  1. :file:`Image-5.10.0-rt62-v8`: 树莓派RT内核镜像

  2. :file:`openeuler-image-qemu-aarch64-<时间戳>.rootfs.cpio.gz`：树莓派RT文件系统

  3. :file:`openeuler-glibc-x86-64-openeuler-image-aarch64-qemu-aarch64-toolchain-22.03.30.sh`: sdk工具链

  4. :file:`zImage`: 树莓派RT内核的压缩镜像

- 验证环境的软实时是否使能，可查看系统是否有PREEMPT_RT字样，示例：

.. code-block:: console

  openeuler ~ # uname -a
  Linux openeuler 5.10.0-rt62-v8 #1 SMP PREEMPT_RT Fri Mar 25 03:58:22 UTC 2022 aarch64 GNU/Linux

软实时性能测试
**************

**软实时相关测试**

参考 `RT-Tests 指导 <https://wiki.linuxfoundation.org/realtime/documentation/howto/tools/rt-tests>`_ 进行软实时相关测试，例如：

1. cyclictest 时延性能测试

2. pi_stress 优先级继承测试

3. hackbench 负载构造工具

等等

**cyclictest 时延性能测试**

1. 准备开发环境

参考 `安装SDK <https://openeuler.gitee.io/yocto-meta-openeuler/getting_started/index.html#sdk>`_，准备编译环境，示例：

.. code-block:: console
  
  sh openeuler-glibc-x86_64-openeuler-image-aarch64-qemu-aarch64-toolchain-22.03.sh

  . /path/to/sdk/environment-setup-aarch64-openeuler-linux

2. 编译用例

.. code-block:: console

  git clone https://git.kernel.org/pub/scm/utils/rt-tests/rt-tests.git

  cd rt-tests

  git checkout stable/v1.0

  make all

3. 用例执行

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


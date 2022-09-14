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

  openEuler Embedded版本中可使用的RT补丁请参考：

  1. qemu：

    1. `patch-5.10.0-60.10.0-rt62.patch <https://gitee.com/src-openeuler/kernel/blob/openEuler-22.03-LTS/patch-5.10.0-60.10.0-rt62.patch>`_

    2. `patch-5.10.0-60.10.0-rt62_openeuler_defconfig.patch <https://gitee.com/src-openeuler/kernel/blob/openEuler-22.03-LTS/patch-5.10.0-60.10.0-rt62_openeuler_defconfig.patch>`_

  2. raspberrypi：

    1. `0000-raspberrypi-kernel.patch （树莓派补丁） <https://gitee.com/src-openeuler/kernel/blob/openEuler-22.03-LTS/0000-raspberrypi-kernel.patch>`_

    2. `0001-add-preemptRT-patch.patch <https://gitee.com/src-openeuler/kernel/blob/openEuler-22.03-LTS/0001-add-preemptRT-patch.patch>`_

    3. `0002-modifty-bcm2711_defconfig-for-rt-rpi-kernel.patch <https://gitee.com/src-openeuler/kernel/blob/openEuler-22.03-LTS/0002-modifty-bcm2711_defconfig-for-rt-rpi-kernel.patch>`_

**补丁关键功能举例**

  1. 增加中断程序的可抢占性（中断线程化、软中断线程化）

  2. 增加临界区的可抢占性（如自旋锁）

  3. 增加关中断代码的可抢占性

  4. 解决优先级反转问题（优先级继承）

软实时镜像构建指导
******************

具体下载源码和编译流程建议参考：`容器环境下的快速构建指导 <https://openeuler.gitee.io/yocto-meta-openeuler/yocto/quickbuild/container-build.html>`_

22.09版本构建方式
-----------------

  对于22.09版本，构建RT镜像可以使用 :file:`oe_helper.sh` ，示例如下：

  .. code-block:: console

    # 进入构建脚本所在路径
    $ cd /usr1/openeuler/src/yocto-meta-openeuler/scripts/

    # 通过 oe_helper.sh 进行构建
    $ source oe_helper.sh
    Invalid input.
    Usage:
    download mode: source oe_helper.sh [-D] [-d DOWNLOAD_DIR] <-b BRANCH> <-m MANIFEST_FILE>
    compile mode: source oe_helper.sh [-C] [-p PLATFORM] [-o BUILD_DIR] <-t TOOLCHAIN_DIR>  <-i INIT_MANAGER> <--enable-rt>
      [] -- need   <> -- Optional
    -------------------------------------------------------
      -h                show this help and exit.
      -D                download mode:
      -d DOWNLOAD_DIR   [top/directory/to/put/your/code]
      -b BRANCH         [branch]
      -m MANIFEST_FILE  <manifest file path>
      -C                compile mode:
      -p PLATFORM       Supportted PLATFORM
                             aarch64-std
                             aarch64-pro
                             arm-std
                             x86-64-std
                             raspberrypi4-64
                             riscv64-std
      -o BUILD_DIR      Build dir:
                        <above dir of yocto-meta-openeuler >/build (defaut)
      -t TOOLCHAIN_DIR  External toolchain dir(absoulte path):
                            /usr1/openeuler/gcc/openeuler_gcc_arm64le (arm64 default)
                            /usr1/openeuler/gcc/openeuler_gcc_arm32le (arm32 default)
                            /usr1/openeuler/gcc/openeuler_gcc_x86_64 (x86_64 default)
      -i INIT_MANAGER   INIT_MANAGER suooprt:
                            busybox (defaut)
                            systemd
      --enable-rt       Enable PREEMPT_RT kernel

    # 根据提示，-p 指定编译的目标镜像，并开启 --enable-rt 选项：
    # 构建树莓派的RT镜像：
    $ source oe_helper.sh -C -p raspberrypi4-64 -o /usr1/build --enable-rt

    # 构建qemu RT镜像：
    $ source oe_helper.sh -C -p aarch64-std -o /usr1/build --enable-rt

22.03版本构建方式
-----------------

  **qemu RT镜像构建方式**

  - 步骤：

  下载源码 --> 修改bb文件打入RT补丁 --> 手动打开CONFIG_PREEMPT_RT --> 编译构建

  - 更改aarch64镜像内核bb文件，使其构建时自动打入RT补丁，示例：

  .. code-block:: console

    cd /usr1/openeuler/src/yocto-meta-openeuler/meta-openeuler/recipes-kernel/linux/

    sed -i '/0001-arm64-add-zImage/a\    file://src-kernel-5.10/patch-5.10.0-60.10.0-rt62.patch \\' linux-openeuler.bb

    sed -i '/patch-5.10.0-60.10.0-rt62.patch/a\    file://src-kernel-5.10/patch-5.10.0-60.10.0-rt62_openeuler_defconfig.patch \\' linux-openeuler.bb

  git diff 输出示例：

  .. code-block:: console

    diff --git a/meta-openeuler/recipes-kernel/linux/linux-openeuler.bb b/meta-openeuler/recipes-kernel/linux/linux-openeuler.bb
    index 77d8717..5a4b2b8 100644
    --- a/meta-openeuler/recipes-kernel/linux/linux-openeuler.bb
    +++ b/meta-openeuler/recipes-kernel/linux/linux-openeuler.bb
    @@ -11,6 +11,8 @@ SRC_URI = "file://kernel-5.10 \
     # add patches only for aarch64
     SRC_URI_append_aarch64 += " \
         file://yocto-embedded-tools/patches/${ARCH}/0001-arm64-add-zImage-support-for-arm64.patch \
    +    file://src-kernel-5.10/patch-5.10.0-60.10.0-rt62.patch \
    +    file://src-kernel-5.10/patch-5.10.0-60.10.0-rt62_openeuler_defconfig.patch \
     "
   
     # add patches for OPENEULER_PLATFROM such as aarch64-pro

  - 打开aarch64镜像defconfig中的CONFIG_PREEMPT_RT，示例：

  .. code-block:: console

    cd /usr1/openeuler/src/yocto-embedded-tools/config/arm64/

    sed -i 's/CONFIG_PREEMPT=y/CONFIG_PREEMPT_RT=y/g' defconfig-kernel

  git diff 输出示例：

  .. code-block:: console

    diff --git a/config/arm64/defconfig-kernel b/config/arm64/defconfig-kernel
    index dece4f7..c4ef7ab 100644
    --- a/config/arm64/defconfig-kernel
    +++ b/config/arm64/defconfig-kernel
    @@ -80,7 +80,7 @@ CONFIG_HIGH_RES_TIMERS=y
   
     # CONFIG_PREEMPT_NONE is not set
     # CONFIG_PREEMPT_VOLUNTARY is not set
    -CONFIG_PREEMPT=y
    +CONFIG_PREEMPT_RT=y
     CONFIG_PREEMPT_COUNT=y
     CONFIG_PREEMPTION=y


  - 编译时选择 aarch64-std 架构，示例：

  .. code-block:: console

    cd /usr1/openeuler/src/yocto-meta-openeuler/scripts

    source compile.sh aarch64-std /usr1/build /usr1/openeuler/gcc/openeuler_gcc_arm64le

    bitbake openeuler-image

  - 构建镜像生成目录：

    :file:`/usr1/build/output/`

  - 二进制介绍：

    1. :file:`Image-5.10.0`: qemu RT内核镜像

    2. :file:`openeuler-image-qemu-aarch64-<时间戳>.rootfs.cpio.gz`：qemu文件系统

    3. :file:`openeuler-glibc-x86-64-openeuler-image-aarch64-qemu-aarch64-toolchain-22.03.sh`: sdk工具链

    4. :file:`zImage`: qemu RT内核的压缩镜像

  **树莓派RT镜像构建方式**

  - 步骤：

  下载源码 --> 修改bb文件打入RT补丁（补丁已自动打开CONFIG_PREEMPT_RT） --> 编译构建

  - 更改raspberrypi镜像内核bb文件，使其构建时自动打入RT补丁并打开CONFIG_PREEMPT_RT，示例：

  .. code-block:: console

    cd /usr1/openeuler/src/yocto-meta-openeuler/bsp/meta-openeuler-bsp/raspberrypi/recipes-kernel/linux/

    sed -i '/0000-raspberrypi-kernel.patch/a\    file://src-kernel-5.10/0001-add-preemptRT-patch.patch \\' linux-openeuler.bbappend

    sed -i '/0001-add-preemptRT-patch.patch/a\    file://src-kernel-5.10/0002-modifty-bcm2711_defconfig-for-rt-rpi-kernel.patch \\' linux-openeuler.bbappend

  git diff 输出示例：

  .. code-block:: console

    diff --git a/bsp/meta-openeuler-bsp/raspberrypi/recipes-kernel/linux/linux-openeuler.bbappend b/bsp/meta-openeuler-bsp/raspberrypi/recipes-kernel/linux/linux-openeuler.bbappend
    index ad6ebab..cf52b3d 100644
    --- a/bsp/meta-openeuler-bsp/raspberrypi/recipes-kernel/linux/linux-openeuler.bbappend
    +++ b/bsp/meta-openeuler-bsp/raspberrypi/recipes-kernel/linux/linux-openeuler.bbappend
    @@ -1,5 +1,7 @@
     SRC_URI += "\
         file://src-kernel-5.10/0000-raspberrypi-kernel.patch \
    +    file://src-kernel-5.10/0001-add-preemptRT-patch.patch \
    +    file://src-kernel-5.10/0002-modifty-bcm2711_defconfig-for-rt-rpi-kernel.patch \
     "
     OPENEULER_KERNEL_CONFIG = "${S}/arch/${ARCH}/configs/bcm2711_defconfig"
     do_configure_prepend() {

  - 编译时选择 raspberrypi4-64 架构，示例:

  .. code-block:: console

    cd /usr1/openeuler/src/yocto-meta-openeuler/scripts

    source compile.sh raspberrypi4-64 /usr1/build /usr1/openeuler/gcc/openeuler_gcc_arm64le

    bitbake openeuler-image

  - 构建镜像生成目录：

    :file:`/usr1/build/output/`

  - 二进制介绍：

    1. :file:`Image`: 树莓派RT内核镜像

    2. :file:`openeuler-image-raspberrypi4-64-<时间戳>.rootfs.rpi-sdimg`：树莓派RT支持SD卡镜像

    3. :file:`openeuler-glibc-x86-64-openeuler-image-cortexa72-raspberrypi4-64-toolchain-22.03.sh`: sdk工具链

  树莓派4B的具体使用方法请参考：`树莓派4B的支持 <https://openeuler.gitee.io/yocto-meta-openeuler/features/raspberrypi.html>`_

.. note::

  1. 如果开发人员使用的内核配置不是RT补丁中修改的defconfig（qemu：:file:`arch/arm64/configs/openeuler_defconfig`，树莓派：:file:`arch/arm64/configs/bcm2711_defconfig`），则需要在自己的defconfig中开启内核配置选项 CONFIG_PREEMPT_RT，例如上面qemu构建方式中的 yocto-embedded-tools/config/arm64/defconfig-kernel

  2. openEuler Embedded 软实时特性当前不支持 arm 架构

验证环境的软实时是否使能
************************

- 查看系统是否有PREEMPT_RT字样：

  输入示例：

  .. code-block:: console

    uname -a

  输出示例：

  .. code-block:: console

    Linux openeuler 5.10.0-rt62-v8 #1 SMP PREEMPT_RT Fri Mar 25 03:58:22 UTC 2022 aarch64 GNU/Linux

软实时性能测试
**************

**软实时相关测试**

参考 `RT-Tests 指导 <https://wiki.linuxfoundation.org/realtime/documentation/howto/tools/rt-tests>`_ 进行软实时相关测试，用例包括但不限于：

1. cyclictest 时延性能测试

2. pi_stress 优先级继承测试

3. hackbench 负载构造工具

下面以cyclictest 时延性能测试为例进行说明。

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

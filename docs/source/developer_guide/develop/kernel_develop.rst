Linux内核开发指导
#################

在使用 openEuler Embedded 时，通常需要对内核进行定制。目前，meta-openeuler 提供了一系列与 Linux kernel 相关的配方，借助 Yocto 的支持，用户可以在 meta-openeuler 的基础上，高效地调试并定制所需的内核。

本章节内容会基于 meta-openeuler 介绍如何进行内核开发指导，包括如何下载内核代码以及修改内核代码、选项配置等内容，其它更详细的流程，可以参阅 `Yocto Project Linux Kernel Development Manual <https://docs.yoctoproject.org/kernel-dev/index.html#>`_ 进一步了解。

内核代码修改指导
****************

目前，openEuler Embedded 提供了两种内核配方：``linux-openeuler.bb`` 和 ``linux-openeuler-rt.bb``。在使用 oebuild 构建时，如果通过 ``-f rt`` 选项指定构建 Preempt RT 版本，会通过设置 ``PREFERRED_PROVIDER_virtual/kernel = "linux-openeuler-rt"`` 来选择 ``linux-openeuler-rt.bb``。
实际上，这两种配方的构建流程基本一致，区别在于构建 Preempt RT 版本时，会额外应用一些内核补丁并调整部分内核配置。因此，下文将以 ``linux-openeuler-rt.bb`` 为例进行详细说明。

内核代码下载
============

执行以下命令下载内核代码：

.. code-block:: none

  # 由于内核构建配方名称为 linux-openeuler-rt.bb，因此下载命令为：
  $ bitbake linux-openeuler-rt -c do_fetch


当前openEuler Embedded的代码下载流程如下：

.. code-block:: none

  ┌───────────────────────────────┐
  │          触发内核构建          │
  │   bitbake linux-openeuler-rt  │
  └───────────────┬───────────────┘
                  │
                  │
                  ▼
  ┌───────────────────────────────┐
  │      触发 do_openeuler_fetch  │
  │          下载内核代码          │
  └───────────────┬───────────────┘
                  │
                  │
                  ▼
  ┌───────────────────────────────┐
  │  根据 OPENEULER_REPO_NAMES和  │
  │   manifest.yaml 完成代码下载   │
  └───────────────────────────────┘

以目前 openEuler Embedded 的内核配置为例；

.. code-block:: shell

    # 内核大版本号，为 5.10 或 6.6
    PV = "${LINUX_VERSION}"

    ...

    OPENEULER_LOCAL_NAME = "kernel-${PV}"
    OPENEULER_REPO_NAMES = "src-kernel-${PV} kernel-${PV}"

    ...

    SRC_URI = " \
      file://kernel-${PV} \
      file://src-kernel-${PV}/0001-apply-preempt-RT-patch.patch \
      ...
      "

- **OPENEULER_LOCAL_NAME**：

  内核源码目录名称。例如，构建 5.10 版本的内核时，PV为 5.10，因此会使用 oebuild 代码目录下的 src/kernel-5.10 作为构建代码来源。

- **OPENEULER_REPO_NAMES**：

  触发 do_openeuler_fetch 任务时自动下载的代码仓库名称。例如，构建 5.10 版本内核时，会触发下载 src-kernel-5.10 以及 kernel-5.10 两个仓库。

  do_openeuler_fetch 任务会根据 yocto-meta-openeuler 仓库的 .oebuild/manifest.yaml 文件下载这两个仓库：

  .. code-block:: yaml

      # .oebuild/manifest.yaml

      kernel-5.10:
        remote_url: https://gitee.com/openeuler/kernel.git
        version: 920880cbeb4a3390da6f9e95508b29abbf45140d


      src-kernel-5.10:
        remote_url: https://gitee.com/src-openeuler/kernel.git
        version: 8020b640cad7531b50bbd356a06c9fcf6265ac21

  .. note::

      **kernel-5.10** 的上游仓库是 **openeuler/kernel**，即 openeuler 内核源码仓库，用于存放由 openeuler 社区维护的 Linux 内核代码。

      **src-kernel-5.10** 的上游仓库是 **src-openeuler/kernel**，即 openeuler 内核制品仓库，用于构建 openeuler 社区各发行版本的内核发布包，并存放一些尚未合并到源码仓库的补丁，例如树莓派补丁、软实时补丁等。

      在 **src-openeuler/kernel** 仓库中，**kernel.spec** 或 **kernel-rt.spec** 文件会指定使用 **openeuler/kernel** 仓库中某个特定 tag 的源码来构建和发布内核。openEuler Embedded 会根据 **kernel.spec** 和 **kernel-rt.spec** 文件来选择用于构建的内核版本。

      因此，在 **.oebuild/manifest.yaml** 文件中，**kernel-5.10** 的 **version** 字段对应于 **openeuler/kernel** 仓库中某个特定 tag 的 commit ID，而 **src-kernel-5.10** 的 **version** 字段则对应于 **src-openeuler/kernel** 仓库中某个发布分支的 commit ID。


 当需要升级 openEuler 的内核版本时，可以通过修改 **version** 值来使用其他发布版本。如果需要替换整个内核源码仓库，建议单独指定 **PV** 值，并在 **manifest.yaml** 文件中添加对应的仓库路径。具体实现可以参考 **yocto-meta-openeuler** 中树莓派或 Hi3093 的相关配置。

____

内核代码修改
============

1. 源码修改
------------

- **场景一：为内核应用补丁**

   如果需要为内核应用补丁进行构建，可以将补丁文件放置于 ``meta-openeuler/recipes-kernel/linux/files/patches`` 目录中，并在 ``SRC_URI`` 中指定该补丁文件。例如：

   .. code-block:: shell

      ## 假设代码补丁文件路径为： meta-openeuler/recipes-kernel/linux/files/patches/0001-kernel.patch

      SRC_URI:append = " \
          file://patches/0001-kernel.patch \
      "

- **场景二：修改内核源码进行调试**

   如果希望能够直接修改内核源码进行内核调试，建议按照以下步骤进行：

   1. 执行以下命令触发内核源码下载

    .. code-block:: shell

      # 以 linux-openeuler-rt 内核为例，其它内核（如linux-openeuler）请根据实际名称进行操作。
      $ bitbake linux-openeuler-rt -c do_fetch

    此时，会根据 manifest.yaml 文件自动触发内核下载，假设 PV 为 5.10，则会下载内核源码到 src/kernel-5.10 目录中。

   2. 进入到oebuild工作目录的 src/kernel-5.10，修改内核代码

    .. code-block:: shell

      $ cd src/kernel-5.10
      # 在此目录中进行内核代码的修改

   3. 进入到oebuild工作目录的 src/yocto-meta-openeuler，注释 manifest.yaml 中对应的仓库地址

    .. code-block:: shell

      $ vim .oebuild/manifest.yaml

      # 注释掉以下内容：
      #kernel-5.10:
      #  remote_url: https://gitee.com/openeuler/kernel.git
      #  version: 920880cbeb4a3390da6f9e95508b29abbf45140d

    这是因为，当 manifest.yaml 中指定了仓库地址时，在 do_openeuler_fetch 过程中会将仓库代码还原到 version 指定的 commit ID 节点。为了避免本地修改被删除，需要将其注释。


   4. 构建内核

    .. code-block:: shell

      $ bitbake linux-openeuler-rt


2. 设备树指定
-------------

在 Yocto 工程里，可以通过 ``KERNEL_DEVICETREE`` 来指定DTB，具体的用法如下：

.. code-block:: shell

   # 在 machine.conf 里，指定 KERNEL_DEVICETREE
   # 例如：bsp/meta-openeuler-bsp/conf/machine/orangepi5.conf

   # 方式一：只需要单独的设备树
   # 设备树源码 dts 文件可以通过 patch 的方式将其应用到内核源码中的 arch/arm64/boot/dts/ 目录下，KERNEL_DEVICETREE 指定对应的 dtb 文件名
   KERNEL_DEVICETREE = "rockchip/opi5.dtb"           # 将会使用 arch/arm64/boot/dts/rockchip/opi5.dts 生成 DTB


   # 方式二：需要多份设备树
   DTB_FILES = "am335x-bone.dtb am335x-boneblack.dtb am335x-bonegreen.dtb"
   KERNEL_DEVICETREE = '${@' '.join('ti/omap/%s' % d for d in '${DTB_FILES}'.split())}'

____

内核选项配置
============

1. 指定内核CONFIG文件
---------------------

- **场景一：使用内核源码树外的config文件**

   如果需要使用的 config 文件不放在内核源码树中，可以通过以下步骤将其指定给内核构建过程：

   1. 准备 config 文件

    将所需的 config 文件放置在 ``meta-openeuler/recipes-kernel/linux/files/config`` 目录中。例如，假设文件名为 test_config。

   2. 指定 OPENEULER_KERNEL_CONFIG

    在内核配方文件（如 linux-openeuler-rt.bb）中，通过 ``OPENEULER_KERNEL_CONFIG`` 变量指定所需的config。例如：

    .. code-block:: shell

      # linux-openeuler-rt.bb
      # test_config 为需要使用的config文件

      OPENEULER_KERNEL_CONFIG = "file://config/test_config"

- **场景二：使用内核源码树内的config文件**

   如果需要构建的内核源码树中有所需要的config文件，可以在内核配方文件（如 linux-openeuler-rt.bb）中，通过 ``KBUILD_DEFCONFIG`` 变量指定所需的 config。例如：

   .. code-block:: shell

      # 由于config文件直接由内核源码仓库提供，不需要使用 meta-openeuler 仓库的 config，需要注释该变量
      OPENEULER_KERNEL_CONFIG = ""

      # 将其指定为内核源码树内的 config 文件，例如使用 arch/arm64/configs/openeuler_defconfig
      KBUILD_DEFCONFIG = "openeuler_defconfig"

2. 调整内核CONFIG选项
---------------------

在 Yocto 工程中，可以通过多种方式进行内核的CONFIG调整，以下为详细介绍：

方式一：通过 menuconfig 调整
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

执行以下命令打开 menuconfig 窗口：

.. code-block:: shell

   $ bitbake linux-openeuler-rt -c menuconfig

在打开的 menuconfig 窗口中，根据需要修改内核CONFIG选项。修改完成后，menuconfig 会在yocto构建目录下生成一个 .config 文件，文件路径大致为：`tmp/work/<name>-openeuler-linux/linux-openeuler/5.10-r0/build` 。

这里需要注意的是：menuconfig 作为内核构建工程中的一个子任务，它产生的 .config 文件是一个中间文件，当 Yocot 重新触发内核构建工程时，所有的中间文件都会被清除（包括.config文件）。
因此建议通过 menuconfig 修改后，及时保存生成的 .config 文件，并按照上文《使用内核源码树外的config文件》来指定每次构建内核时都采用该文件。

.. code-block:: shell

   $ cp tmp/work/<name>-openeuler-linux/linux-openeuler/5.10-r0/build/.config \
        <oebuild_workdir>/src/yocto-meta-openeuler/meta-openeuler/recipes-kernel/linux/files/config/new_config

   $ vim <oebuild_workdir>/src/yocto-meta-openeuler/meta-openeuler/recipes-kernel/linux/linux-openeuler.bb
     # 指定 config 文件
     OPENEULER_KERNEL_CONFIG = "file://config/new_config"

.. note::

   不建议通过手动修改 defconfig 文件来进行内核选项配置，因为内核配置选项之间存在复杂的依赖关系。例如，选项 A 依赖于选项 B。如果只在 defconfig 文件中手动启用选项 A，而没有启用选项 B，那么在内核配置解析阶段，由于依赖关系未满足，选项 A 也不会被启用。

方式二：通过 kernel_metadata 调整
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Yocto提供了 `Kernel Metadata <https://docs.yoctoproject.org/kernel-dev/advanced.html#configuration>`_ 机制，metadata 包含配置一个或多个配置片段文件(.cfg)以及一个描述这些配置片段的文件(.scc)组成。

例如，可以将与 Preempt RT 相关的选项，通过 ``preempt-rt.scc`` 和 ``preempt-rt.cfg`` 来承载：

.. code-block:: shell

   meta-data/features/preempt-rt/preempt-rt.scc:
     define KFEATURE_DESCRIPTION "Enable preempt related configs"
     define KFEATURE_COMPATIBILITY all

     kconf non-hardware preempt-rt.cfg


   meta-data/features/preempt-rt/preempt-rt.cfg:
     #
     #  preempt-rt related kernel config
     #
     CONFIG_PREEMPT_RT=y

之后，需要在 linux-openeuler-rt.bb 中使能该特性：

.. code-block:: shell

   ## Preempt-RT
   KERNEL_FEATURES:append =  " features/preempt-rt/preempt-rt.scc"

建议将某些特性功能强相关的 config 选项通过 kernel_metadata 来承载，便于维护。

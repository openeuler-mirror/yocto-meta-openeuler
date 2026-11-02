.. _mcs_build:

构建指导
########

  .. seealso::

     混合关键性部署框架作为 openEuler Embedded 的特性，可以按需集成到 openEuler Embedded 镜像中。

     请参考 :ref:`南向支持章节 <bsp>` 构建不同平台的镜像，只需要在使用 ``oebuild generate`` 时选择 ``mcs`` 即可。

  以下为 qemu-aarch64 平台的构建步骤，其它平台的构建步骤与之类似：

  1. 根据 :ref:`oebuild安装介绍 <oebuild_install>` ，安装好oebuild，并初始化oebuild工作目录；

     .. code-block:: console

        $ oebuild init <directory>
        $ cd <directory>
        $ oebuild update

  2. 进入oebuild工作目录，创建编译配置文件 ``compile.yaml``：

     .. code-block:: console

        $ oebuild generate -p <platform> -f mcs -d <build_mcs>

        # 以 qemu-arm64 为例，platform 可以指定为 qemu-aarch64
        # 其它平台请运行 oebuild generate -l 查看

        $ oebuild generate -p qemu-aarch64 -f mcs -d <build_mcs>

     之后，在 ``<build_mcs>`` 目录下，会生成编译配置文件 ``compile.yaml``。

     .. note::

        MICA 支持在 `bare-metal`、`hetero`、`jailhouse`、`xen` 四种不同的环境上运行，默认构建 `bare-metal`。

        `hetero` 也是裸金属部署的一种，用于在ARM64主机上运行RISC-V架构MCU上的RTOS，与 `bare-metal` 共用相同的构建流程。

        若需要支持 `jailhouse`，请在 oebuild generate 时添加 ``-f mcs/jailhouse``（无需手改 ``compile.yaml``）。

        若需要支持 `xen`，推荐直接使用样例工程
        ``.oebuild/samples/aarch64/qemu-aarch64-mcs-xen.yaml``，或参考其中的配置创建
        构建目录。Xen 部署的 Client OS 使用外部工作区构建的固件（样例为 Zephyr），需要在
        ``compile.yaml`` 的 ``local_conf`` 中设置：

        .. code-block:: yaml

           MCS_FEATURES ?= "external-firmware xen"
           DISTRO_FEATURES:append = " mcs xen"
           MCS_FIRMWARE_ELF ?= "/path/to/zephyrproject/build-xen/zephyr/zephyr_openamp_rsc_table.elf"
           MCS_FIRMWARE_BIN ?= "/path/to/zephyrproject/build-xen/zephyr/zephyr_openamp_rsc_table.bin"

        ``MCS_FIRMWARE_ELF`` 和 ``MCS_FIRMWARE_BIN`` 必须指向实际构建产物，并确保
        该路径在 oebuild 构建容器内可见（可以将 Zephyr 工作区只读挂载到容器中）。
        固件不限于 Zephyr：任何实现 MCS Client 接口（OpenAMP resource table 与
        micad 使用的 rpmsg 端点）的 RTOS 或裸机程序都可以通过 ``external-firmware``
        安装。产物默认安装为 ``zephyr.elf``/``zephyr.bin``，可用
        ``MCS_FIRMWARE_NAME`` 修改，此时需同步修改 mica/Xen 配置中的路径。

        .. note::

           不要将 ``openamp`` 加入 ``MCS_FEATURES``。``openamp`` 会使镜像继承
           ``qemuboot-mcs-dtb``，覆盖 Xen 使用的 qemuboot 设备树和启动参数。

  3. 进入 ``<build_mcs>`` 目录，编译 openeuler-image 或 openeuler-image-mcs，两个镜像都会安装 mcs 组件，但 openeuler-image-mcs 仅包含少量的基础软件包：

     .. code-block:: shell

        # 进入构建容器
        $ oebuild bitbake

        # 构建完整镜像
        $ bitbake openeuler-image

        # 构建SDK
        $ bitbake openeuler-image -c do_populate_sdk


        # 或者，构建只覆盖基础软件包的裁剪镜像
        $ bitbake openeuler-image-mcs

____

  - 构建完成后，在 ``<build_mcs>/output`` 目录下可以看到镜像，如：

    .. code-block:: shell

      $ tree
      .
      └── 20230315093436
          ├── Image-5.10.0-openeuler
          ├── openeuler-image-mcs-qemu-aarch64-20230920084840.rootfs.cpio.gz
          ├── vmlinux-5.10.0-openeuler
          └── zImage-5.10.0-openeuler


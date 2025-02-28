.. _mcs_build:

构建指导
########

  .. seealso::

     混合关键性部署框架作为 openEuler Embedded 的特性，可以按需集成到 openEuler Embedded 镜像中。

     请参考 :ref:`南向支持章节 <bsp>` 构建不同平台的镜像，只需要在使用 ``oebuild generate`` 时选择 ``openeuler-mcs`` 即可。

  以下为 qemu-aarch64 平台的构建步骤，其它平台的构建步骤与之类似：

  1. 根据 :ref:`oebuild安装介绍 <oebuild_install>` ，安装好oebuild，并初始化oebuild工作目录；

     .. code-block:: console

        $ oebuild init <directory>
        $ cd <directory>
        $ oebuild update

  2. 进入oebuild工作目录，创建编译配置文件 ``compile.yaml``：

     .. code-block:: console

        $ oebuild generate -p <platform> -f openeuler-mcs -d <build_mcs>

        # 以 qemu-arm64 为例，platform 可以指定为 qemu-aarch64
        # 其它平台请运行 oebuild generate -l 查看

        $ oebuild generate -p qemu-aarch64 -f openeuler-mcs -d <build_mcs>

     之后，在 ``<build_mcs>`` 目录下，会生成编译配置文件 ``compile.yaml``。

     .. note::

        MICA 支持在 `bare-metal` 和 `jailhouse` 两种不同的环境上运行，默认构建 `bare-metal`。

        若需要支持 `jailhouse`，请修改编译配置文件 ``compile.yaml``，把 **MCS_FEATURES 中的 openamp 改成 jailhouse**。

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


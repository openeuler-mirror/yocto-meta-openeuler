.. _board_hieulerpi_build:

海鸥派镜像构建与使用
##########################################

本章主要介绍海鸥派的镜像构建，使用和特性介绍。


海鸥派镜像构建指导
====================================

1. 参照 :ref:`oebuild_install` 完成oebuild安装，并详细了解构建过程

   .. code-block:: console

      # 例
      oebuild init my_workspace
      # 上述命令没有指定分支，使用默认分支master
      cd xxx/my_workspace
      oebuild update

2. 依次执行以下命令完成构建

   .. code-block:: console

      # 生成hieulerpi1构建配置文件，若需额外加入特性，见-f列表(oebuild generate -l)，下例启用必备的ros功能
      oebuild generate -p hieulerpi1 -f openeuler-ros

      # 按提示进入构建目录，执行如下命令进入bitbake环境，进入构建交互终端
      oebuild bitbake

      # 构建镜像
      bitbake openeuler-image

      # 构建sdk
      bitbake openeuler-image -c populate_sdk

   二进制产物介绍（对应output目录）：

   - ``openeuler-glibc-x86_64-openeuler-image-aarch64-hieulerpi1-toolchain-24.03.sh``: SDK工具链

   - ``kernel-pi``: 适用于海欧派1的openEuler内核镜像（由Image + header + dtb + atf合成），可直接用于单板部署

   - ``openeuler-image-hieulerpi1-[时间戳].rootfs.ext4``: 适用海鸥派1的根文件系统，可直接用于单板部署

   - ``vmlinux-5.10.0``: 备用调试内核

   - ``Image-5.10.0``: 备用原始Image内核

.. note::

   需要其他功能时，请在oebuild初始化时通过 ``-f features`` 添加对应的 feature。见-f列表(oebuild generate -l)

   若不使能-f openeuler-ros，将生成基础镜像，仅包含hieuler的BSP驱动，无ROS框架和demo

____

海鸥派其他镜像说明
===========================

   参考: :ref:`hieulerpi-image`


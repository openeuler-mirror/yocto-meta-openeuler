.. _board_hieulerpi_build:

欧拉派海鸥系列镜像构建与使用
##########################################

本章主要介绍openEuler Embedded中欧拉派海欧系列的镜像构建，使用和特性介绍。


欧拉派海鸥系列镜像构建指导
====================================

1. 参照 :ref:`oebuild_install` 完成oebuild安装，并详细了解构建过程

   .. code-block:: console

      # 例
      oebuild init build_3403 -b openEuler-23.09
      cd xxx/build_3403
      oebuild update

2. 依次执行以下命令完成构建

   .. code-block:: console

      # 生成ss928构建配置文件，若需额外加入特性，见-f列表(oebuild generate -l)，下例启用必备的ros功能
      oebuild generate -p sd3403 -f openeuler-ros

      # 按提示进入构建目录，执行如下命令进入bitbake环境，进入构建交互终端
      oebuild bitbake

      # 构建镜像
      bitbake openeuler-image-ros

      # 构建sdk
      bitbake openeuler-image-ros -c populate_sdk

   二进制产物介绍（对应output目录）：

   - ``openeuler-glibc-x86_64-openeuler-image-ros-aarch64-sd3403-toolchain-23.09.sh``: SDK工具链

   - ``kernel-pi``: 适用于ss928海欧派的openEuler内核镜像（由Image + header + dtb + atf合成），可直接用于单板部署

   - ``openeuler-image-ros-sd3403-20231102014821.rootfs.ext4``: 适用ss928海鸥派的根文件系统，可直接用于单板部署

   - ``vmlinux-5.10.0``: 备用调试内核

   - ``Image-5.10.0``: 备用原始Image内核

.. note::

   需要其他功能时，请在oebuild初始化时通过 ``-f features`` 添加对应的 feature。见-f列表(oebuild generate -l)

____

欧拉派海鸥系列镜像烧写方法
===========================

1. 烧录工具烧录

参考: `待更新  <https://www.ebaina.com/>`_

2. SD卡烧录

参考: `<https://gitee.com/HiEuler/doc/blob/master/02_SD%E5%8D%A1%E5%90%AF%E5%8A%A8%E4%B8%8E%E5%8D%87%E7%BA%A7%E6%93%8D%E4%BD%9C%E6%8C%87%E5%8D%97.md>`_

____

欧拉派海鸥系列其他用法
=======================

   1. 欧拉派海鸥系列硬件特性，参考: :ref:`board_hieulerpi_hardware_features`

   2. 敬请期待其他功能说明。


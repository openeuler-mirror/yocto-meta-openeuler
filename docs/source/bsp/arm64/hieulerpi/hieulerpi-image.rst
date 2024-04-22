.. _hieulerpi-quick-start:

欧拉派镜像获取
#####################

.. contents::

镜像内容
==========

镜像主要内容包括以下四个文件:

1. ``boot_image_[MEM_SIZE].bin`` u-boot镜像，其中MEM_SIZE是开发板的内存大小
2. ``boot_env_[MEM_SIZE].bin`` u-boot环境变量分区
3. ``kernel-pi`` Linux内核
4. ``openeuler-image-hieulerpi1-[时间戳].rootfs.ext4`` 根文件系统

除了以上四个文件还有两个烧录固件的辅助文件:

1. ``env_append.txt`` 用于SD卡升级
2. ``parttable.xml`` 用于ToolPlatform工具升级

u-boot镜像获取
================

此链接可获取以下文件：

1. ``boot_image_4G.bin``
2. ``boot_env_4G.bin``
3. ``boot_image_8G.bin``
4. ``boot_env_8G.bin``
5. ``env_append.txt``

`u-boot v2.0.0 发行版 <https://gitee.com/HiEuler/u-boot/releases/tag/v2.0.0>`__

.. note::

    如果需要通过源码构建可通过以下链接获取源码：

    `u-boot源码 <https://gitee.com/HiEuler/u-boot>`__

    具体构建方式参考仓库中的README文件

内核与根文件系统镜像获取
============================

`openeuler 每日构建 <http://121.36.84.172/dailybuild/EBS-openEuler-Mainline/>`__

进入网站后可看到如下目录结构,网站保存最近10天的构建镜像。

.. code:: 

    EBS-openEuler-Mainline/
    obs_master_rpm/
    openeuler-2024-04-13-07-39-19/
    openeuler-2024-04-14-07-39-19/
    openeuler-2024-04-15-07-39-20/
    openeuler-2024-04-16-07-39-19/
    openeuler-2024-04-17-07-39-20/
    openeuler-2024-04-18-07-39-20/
    openeuler-2024-04-19-07-39-20/
    openeuler-2024-04-20-07-39-20/
    openeuler-2024-04-21-07-39-20/
    openeuler-2024-04-22-07-39-19/
    openeuler_ARM64/
    openeuler_X86/
    python3/

海鸥派的镜像在以下路径: ``openeuler-[时间戳]/embedded_img/aarch64/hieulerpi1/``，该目录有以下文件（除了.sha256sum为后缀的校验文件）

.. code::

    Image
    Image-5.10.0-openeuler
    kernel-pi
    openeuler-glibc-x86_64-openeuler-image-aarch64-hieulerpi1-toolchain-24.03-LTS.sh
    openeuler-image-hieulerpi1-20240422000025.rootfs.ext4
    vmlinux-5.10.0-openeuler

需要下载 ``kernel-pi`` 和 ``openeuler-image-hieulerpi1-[时间戳].rootfs.ext4`` 文件

.. note::

    如果需要通过源码构建可参考 :ref:`board_hieulerpi_build`
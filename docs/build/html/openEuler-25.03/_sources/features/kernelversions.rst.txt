.. _kernelversions_intro:

内核多版本支持（5.10/6.6）介绍
####################################

openEuler社区主线已作为主流版本支持Linux 6.6内核，考虑到有部分厂商驱动更新到新版本内核（6.6）存在一定难度，openEuler Embedded 24.03在发布时保留5.10内核的支持，同步支持6.6内核的框架构建，提供相关厂商及合作伙伴适配6.6内核的支持空间。现阶段已支持的单板/镜像如下，并已支持preempt-rt特性。

+---------------+
| 单板          |
+---------------+
| aarch64(qemu) |
+---------------+
| x86_64        |
+---------------+
| 树莓派4B      |
+---------------+


构建5.10内核配套镜像
====================================

当前默认情况下，构建的内核版本即为5.10，在此不做额外说明


构建6.6内核配套镜像
=====================================

可在构建之前，在初始化平台时候，追加-f kernel6，案例命令如下：

.. code-block:: console

    # 构建x86_64的6.6内核镜像、不开启其他特性
    $ oebuild generate -p x86-64 -f kernel6

    # 构建x86_64的6.6内核镜像，同时启用preempt-rt
    $ oebuild generate -p x86-64 -f kernel6 -f openeuler-rt

    # 构建树莓派的6.6内核镜像，不开启其他特性
    $ oebuild generate -p raspberrypi4-64 -f kernel6

    # 构建树莓派的6.6内核镜像，同时启用preempt-rt
    $ oebuild generate -p raspberrypi4-64 -f kernel6 -f openeuler-rt


其他构建过程不变，以x86_64为例，6.6内核镜像构建的完整命令如下：

.. code-block:: console

    # 所有的构建工作都需要在 oebuild 工作目录下进行（前置步骤需已完成oebuild init）
    $ cd <work_dir>
    
    # 为镜像创建配置文件compile.yaml（打开6.6内核特性，打开preempt-rt特性，打开hmi特性）
    $ oebuild generate -p x86-64 -f kernel6 -f openeuler-rt -f hmi -d build_example_x86
    
    # 根据提示，切换到包含 compile.yaml 的编译空间目录，如 build/build_example_x86/
    $ cd build/build_example_x86/
    
    # 进入oebuild初始化的bitbake环境并开始构建
    $ oebuild bitbake 
    $ bitbake openeuler-image



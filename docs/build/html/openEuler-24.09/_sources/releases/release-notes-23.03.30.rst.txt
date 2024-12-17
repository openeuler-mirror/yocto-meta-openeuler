:orphan:

.. _openeuler_embedded_23_03_30:

openEuler Embedded 23.03
###########################

openEuler Embedded 23.03是openEuler Embedded第三个创新版本，从本次发布版本开始，引入release manager，包含内容大概如下：

* release manager：

  - 姓名：李新宇

  - gitee ID：alichinese

* 基础设施
   
  - 更多的meta层引入，meta-openembedded，更好的对接生态

  - 完善nativesdk使其有更好的兼容性，容器工具化，更好的与开发环境结合

  - oebuild一站式工具，大幅提升易用性

  - 更完善的CI/CD，使能sstate cache，大幅缩短门禁构建时间

* Linux框架

  - 内核与社区紧密在5.10.x内核上保持同步

  - 支持更多架构，x86-64，riscv-64

  - 总体软件包数量250+

  - 嵌入式图形，包管理，systemd，python

  - 基于LLVM的镜像，相对GCC有更好的性能或更小的镜像大小

* 关键特性
  
  - 混合关键性部署框架(MICA)
    
    - 更加完善的服务化部署，文件系统，RPC，生命周期管理

    - System DTS的探索

    - 更多的RTOS支持，UniProton，RT-Thread

  - 嵌入式弹性底座的探索

    - Jailhouse的支持

    - ZVM的孵化

  - 分布式软总线

    - 改善Wi-Fi传输的性能

    - 蓝牙的初步支持

* 南北向生态

  - 轻量级ROS2运行时

    - 竞争力：可裁剪，高效，实时

    - meta-ROS，ros-core，ros-base的支持

    - 基于Priginbot的激光雷达导航Demo

  - 南向BSP

    - x86-64工控机：HVAEIPC-M10

    - RK3568：飞凌OK3568，RYD-3568

    - 更多BSP正在路上

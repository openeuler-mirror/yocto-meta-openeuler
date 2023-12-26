:orphan:

.. _openeuler_embedded_23_06_30:

openEuler Embedded 22.03-LTS-sp2
#################################

openEuler Embedded 22.03-LTS-sp2是基于openEuler Embedded 22.03-LTS-sp1的维护更新版本。本次发布版本包含内容大概如下：

* release manager：

  - 姓名：郑立铭

  - gitee ID：soulpoet

* 基础设施

  - 完善nativesdk使其有更好的兼容性，容器工具化，更好的与开发环境结合

  - oebuild一站式工具易用性提升

    - 重新设计了update等逻辑

    - 引入manifest

    - 初步支持容器管理能力

  - 重构了标准镜像中的构建和重新整理其8个package-group

  - 总体软件包数量350+

  - 文档内容增强，特别是针对开发者角色的说明

    - BSP适配说明

    - yocto相关指导说明

* linux框架

  - 内核与社区紧密在5.10.x内核上保持同步，目前同步更新到5.10.0-153.12.0版本

  - 支持更多架构，x86-64，riscv-64

  - 嵌入式图形，初步的包管理

* 关键特性
  
  - 混合关键性部署框架(MICA)
    
    - 更加完善的服务化部署，文件系统，RPC，生命周期管理

    - System DTS的探索

    - 更多的RTOS支持，UniProton，RT-Thread

  - 嵌入式弹性底座的探索

    - Jailhouse的支持

    - ZVM的孵化

  - 分布式软总线

    - 改善WI-FI传输的性能，提升流数据传输速率

    - 初步支持树莓派的蓝牙以及蓝牙发现

  - 轻量级ROS2运行时

    - ROS2从foxy更新至humble版本

    - 引入100+软件包

* 南北向生态

  - 南向BSP

    - x86-64工控机：HVAEIPC-M10

    - RK3568：飞凌OK3568，RYD-3568

    - 更多BSP正在路上

:orphan:

.. _openeuler_embedded_23_09_30:

openEuler Embedded 23.09
###########################

openEuler Embedded 23.03是openEuler Embedded第四个创新版本，本版本的主要更新如下

* release manager：

  - 姓名：郑立铭

  - gitee ID：soulpoet

* 基础设施
   
  - 为了openEuler Embedded下一个LTS做准备，yocto-poky从3.3.6升级到了4.0.10, yocto-poky 4.0.x也是yocto上游社区的LTS版本

  - 进一步完善了openEuler Embedded元工具oebuild, 23.09版本发布时，对应的oebuild版本是0.0.32，具体功能可以参见文档 :ref:`oebuild_userguide`
  
  - 完善了CI/CD框架，CI/CD相关流程的控制文件位于 :file:`.oebuild/workflows` 目录下

  - 使能了Yocto内核meta机制，可以更加灵活的配置内核， 具体可见 `上游社区的文档 <https://docs.yoctoproject.org/current/kernel-dev/advanced.html>`_ 。

  - 完善了软件包manifest机制, 把软件包的版本与软件包仓库的的commit绑定，并持续完善对应do_openeuler_fetch机制

  - 不断完善的文档

* Linux框架

  - 内核与社区紧密在5.10内核上保持同步, 内核版本为5.10.153

* 关键特性
  
  - 混合关键性部署框架(MICA)
    
    - 实现了位于Linux内核态的remote_proc和rpmsg框架的支持，为更好地支持异构多核处理器中混合部署打下了基础

    - 实现了与Jailhouse虚拟机的初步融合

    - 完善了用户态基于OpenAMP的实现，支持与UniProton配合的gdb调试

  - 嵌入式弹性底座的探索

    - 对Jailhouse更好的支持，已经实现了基于Jailhouse的openEuler Embedded与UniProton和Zephyr在多种平台下混合部署，并实现OS间的
      有效隔离

  - 轻量级ROS2运行时的支持也升级到ROS2-humble，并基本实现了核心软件包的支持，可以更好的开发ROS2应用

* 南北向生态

  - 南向BSP：

    - 通过引入meta-rockcip, 实现了更多的Rockchip硬件支持，包括RK3588， RK3399, 并完善了RK3568的支持
    
    - 支持RISC-V架构的赛昉JH7110x芯片的visionfive2开发板

    - 规划了部分BSP平台的命名，例如qemu平台全部以qemu开头

  - 北向软件：

     - 软件包数量支持达到450+，同时完善或者重构了很多软件包的支持

     - 完善了isulad的支持，isulad的大部分功能在本版本中都可用

     - 完善了嵌入式图形的支持，已经可以在x86平台上运行许多轻量级桌面组件


:orphan:

.. _openeuler_embedded_24_03_30:

openEuler Embedded 24.03
###########################

openEuler Embedded 24.03是openEuler Embedded第二个LTS版本，本版本的主要更新如下

* release manager：

  - 姓名：魏钰宸

  - gitee ID：weiyuchen2013

* 基础设施

  - 进一步完善了openEuler Embedded元工具oebuild, 24.03版本发布时，对应的oebuild版本是0.1，新增LLVM镜像支持、一键式快速构建支持、软件包快速部署调试、预构建工具构建、命令行菜单模式等新功能，具体功能可以参见文档 :ref:`oebuild_userguide`
  
  - 完善了CI/CD框架，支持gcc/llvm编译链及预构建工具版本自动发布能力，CI/CD相关流程的控制文件位于 :file:`.oebuild/workflows` 目录下

  - 不断完善的文档

* Linux框架

  - 内核与社区紧密保持同步，支持5.10与6.6双版本内核

* 关键特性
  
  - 混合关键性部署框架(MICA)
    
    - 实现了可靠性增强，在混合部署框架异常退出后，支持重新启动MICA并恢复OS间的通信链路

    - 实现了多实例部署能力，支持在linux上部署多个RTOS

    - 实现了易用性完善，提供简单的命令行工具，支持创建、启动、停止 RTOS，支持通过配置文件管理实时OS，实现 RTOS 的开机自启动

    - 增强gdb调试能力，GDB调试时r可以重新运行程序，bt打印调用栈、watch监视变量改变时断点、ctrl+C可以停止运行退出到gdb交互模式

  - 嵌入式弹性底座的探索

    - 对Jailhouse更好的支持，已经实现了基于Jailhouse的openEuler Embedded与Zephyr在多种平台下混合部署，并实现OS间的有效隔离

  - 轻量级ROS2运行时的支持也升级到ROS2-humble，并基本实现了核心软件包的支持，可以更好的开发ROS2应用

  - 基于LLVM编译工具链，支持标准镜像构建。包括使用C/C++编译器clang/clang++，编译器基础设施llvm，链接器lld

  - 嵌入式领域分布式软总线升级至3.2版本，保证接口兼容，同时使用binder作为IPC底层驱动，降低80%的静默时CPU资源占用

  - 支持嵌入式极简镜像（iSula），最小容器镜像体积小于5M


* 南北向生态

  - 南向BSP：

    - 联合海思、启诺（ebaina）、鼎桥通信、菁蓉联创等合作伙伴共同打造了新硬件海鸥派，原生使用openEuler Embedded系统，支持环境感知，机器视觉，ROS应用，工业控制等能力，详细介绍参见 :ref:`board_hieulerpi`

    - 实现了myir-remi，myd-ym62x等新硬件的支持，详细介绍参见 :ref:`board_myir_remi`

  - 北向软件：

     - 软件包数量支持达到800+，同时完善或者重构了很多软件包的支持

     - 完善了ROS2的支持，ROS2的大部分功能在本版本中都可用

     - 基于wayland，支持轻量图形组合器和窗口应用，包括图片浏览工具、文件编辑器、文件浏览器、任务管理器、配置面板，在QT功能方面，新增完善了qtwebengine（嵌入式网页浏览）等组件

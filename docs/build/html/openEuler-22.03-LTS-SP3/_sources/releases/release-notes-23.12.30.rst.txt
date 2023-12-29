:orphan:

.. _openeuler_embedded_23_12_30:

openEuler Embedded 22.03-LTS-SP3
#################################

* release manager：

  - 姓名：罗永茂

  - gitee ID：yongmao_luo

openEuler Embedded 22.03-LTS-SP3是基于openEuler Embedded 22.03-LTS-SP2的维护更新版本。
本次发布版本包含内容大概如下：

* 基础设施

  - 复用了openEuler 22.03-LTS-SP3的构建容器，保证稳定性。

  - 进一步完善了openEuler Embedded元工具oebuild, 23.09版本发布时，对应的oebuild版本是0.0.38，具体功能可以参见oebuild在master分支中的文档。

  - 回合master的do_openeuler_fetch相关代码，以完全依赖于manifest的方式进行软件包的下载。
    同时修正了do_openeuler_fetch中的一些bug，减少了不必要的构建时代码下载。

* linux框架

  - 内核与社区紧密在5.10.x内核上保持同步，目前同步更新到5.10.0-177.0.0版本。性能总体提升约2%。

  - qemu-aarch64架构下的内核config关闭了ARCH_HISI，以避免在qemu-aarch64上编译时出现错误。

* 关键特性
  
  - 混合关键性部署框架(MICA)

    - 保持与22.03-LTS-SP2一致，仅有基于openAMP的MICA框架，为v0.0.2版本。

    - 嵌入式弹性底座方面，与SP2保持一致，支持Jailhouse的构建。

  - 分布式软总线保持与SP2一致，支持树莓派4B的蓝牙和WiFi。

  - 轻量级ROS2运行时保持与SP2一致，使用humble版本，并支持ros-slam和ros-carema相关的基本功能。

* 南北向生态

  - 南向BSP

    - qemu相关的架构名称规范化：由aarch64-std更改为qemu-aarch64；由x86-64-std更改为x86_64。

    - x86-64相关的BSP：
    
      - HVAEIPC-M10
    
    - aarch64相关的BSP：

      - RK3568：飞凌OK3568，RYD-3568

      - RK3588：OK3588

      - RK3399：OK3399
  
    - arm相关的BSP：
    
      - 全志A40i。

  - 北向软件：

    - 总体支持的openEuler源软件包数量390+，软件包的版本会对齐openEuler社区中的openEuler-22.03-LTS-SP3分支中最新的commit并记录在manifest中。

    - 完善了isulad的支持，isulad的大部分功能在本版本中都可用。

    - 正确安装了社区的CA根证书集合，以支持https的下载。
    
    - 新增en_US.UTF-8的locale支持。从性能角度考虑，预制LC_ALL=C，使用ASCII字符集以保证部分shell命令执行性能。用户可以根据自己的需求进行修改。
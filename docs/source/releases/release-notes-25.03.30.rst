:orphan:

.. _openeuler_embedded_25_03_30:

openEuler Embedded 25.03
###########################

openEuler Embedded 25.03特性上最大亮点是率先支持了openEuler新一代软件包机制epkg，同时本版本对以往遗留的深层次的问题做了系统性的清理
本版的主要更新如下：

* 基础设施

  - 修复工具链对C++编译由于使能了--disable-libstdcxx-dual-abi造成ABI不兼容的问题

  - 除软件包配方外，升级Yocto Kirkstone版本到4.0.26

  - 完善构建容器的稳定性和兼容性，容器中的glibc版本降级到2.28

* Linux框架

  - 清理和完善systemd的支持

  - 以鲲鹏920和x86为例子，清理内核配置

  - 例行的内核版本更新

* 关键特性

  - 新增对epkg的支持, 可以在镜像中直接集成epkg, 无需额外的安装，具体使用参考 `epkg使用说明 <https://gitee.com/openeuler/epkg/blob/master/doc/epkg-usage.md>`_

  - 混合关键性部署框架(MICA)

    - 实现对Zephy的从源代码开始的端到端集成

  - 嵌入式弹性底座的探索

    - 完善XEN的支持

* 南北向生态

  - 南向BSP：

    - 新增意法半导体STM32MP257的支持，详见 :ref:`board_myir_myd_ld25x`

    - 新增嘉立创泰山派的支持，详见 :ref:`board_tspi_3566_build`

    - 完善鲲鹏920及鲲鹏模组的支持

    - 完善已有的BSP支持

  - 北向软件：

     - 清理和升级部分软件包支持


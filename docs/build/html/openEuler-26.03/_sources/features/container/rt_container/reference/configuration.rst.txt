.. _micrun_configuration:

MicRun 配置参考手册
####################

概述
====

MicRun 支持多种配置方式，按优先级从高到低：

1. **注解** (Pod/Container annotations) - 最高优先级
2. **配置文件** (INI/TOML)
3. **环境变量**
4. **默认值** - 最低优先级

配置文件
========

配置文件位置
------------

.. list-table::
   :widths: 20 80
   :header-rows: 1

   * - 优先级
     - 配置来源
   * - 1
     - ``MICRUN_CONF_FILE`` 环境变量指定的文件
   * - 2
     - ``MICRUN_CONF_DIR`` 环境变量指定的目录（读取所有 .conf/.toml 文件）
   * - 3
     - ``/etc/mica/micrun/conf.d/*.conf`` (drop-in 目录)
   * - 4
     - ``/etc/mica/micrun/micrun.conf`` (默认配置文件)

配置文件格式
------------

支持两种格式：

.. list-table::
   :widths: 20 25 55
   :header-rows: 1

   * - 格式
     - 扩展名
     - 说明
   * - INI
     - ``.ini``, ``.conf``
     - 传统 INI 格式
   * - TOML
     - ``.toml``
     - TOML 格式

INI 配置示例
-------------

.. code-block:: ini

   [Mica]
   # 调试模式
   debug = false

   # 最大客户端数量
   max_client_number = 8

   # 默认固件路径
   firmware_path = /usr/local/share/mica/firmware.elf

   [Resource]
   # 容器最大 vCPU 数
   max_container_vcpu = 4

   # 容器最大内存 (MiB)
   container_maxmem = 512

   # 容器最小内存 (MiB)
   container_minmem = 32

   # 静态资源管理
   static_resource = false

   # 共享 CPU 池（Xen平台）
   shared_cpu_pool = false

   # HugePage 支持
   hugepage_enable = false

   [Xen]
   # Sandbox 最小 vCPU 数
   sandbox_minimum_vcpu = 1

   # Dom0 CPU 独占
   exclusive_dom0_cpu = false

   # Xen 镜像路径
   image_path = /usr/local/share/mica/xen-image.bin

   # 辅助文件路径
   aux_file_path = /usr/local/share/mica/xen-aux.bin

TOML 配置示例
--------------

.. code-block:: toml

   [mica]
   debug = false
   max_client_number = 8
   firmware_path = "/usr/local/share/mica/firmware.elf"

   [resource]
   max_container_vcpu = 4
   container_maxmem = 512
   container_minmem = 32
   static_resource = false
   shared_cpu_pool = false
   hugepage_enable = false

   [xen]
   sandbox_minimum_vcpu = 1
   exclusive_dom0_cpu = false
   image_path = "/usr/local/share/mica/xen-image.bin"
   aux_file_path = "/usr/local/share/mica/xen-aux.bin"

环境变量
========

.. list-table::
   :widths: 30 40 30
   :header-rows: 1

   * - 环境变量
     - 说明
     - 默认值
   * - ``MICRUN_CONF_FILE``
     - 指定配置文件路径
     - -
   * - ``MICRUN_CONF_DIR``
     - 指定配置目录路径
     - -
   * - ``CONTAINERD_NAMESPACE``
     - 容器命名空间
     - ``default``

配置项详解
==========

Mica 节配置
-----------

.. list-table::
   :widths: 30 15 20 35
   :header-rows: 1

   * - 配置项
     - 类型
     - 默认值
     - 说明
   * - ``debug``
     - 布尔
     - ``false``
     - 启用调试模式
   * - ``max_client_number``
     - 整数
     - ``0`` (无限制)
     - 最大客户端数量（0表示无限制）
   * - ``firmware_path``
     - 字符串
     - -
     - 默认固件路径

Resource 节配置
---------------

.. list-table::
   :widths: 30 15 25 30
   :header-rows: 1

   * - 配置项
     - 类型
     - 默认值
     - 说明
   * - ``max_container_vcpu``
     - 整数
     - ``8``
     - 容器最大 vCPU 数（配置为0时使用默认值8）
   * - ``container_maxmem``
     - 整数
     - *系统相关*
     - 容器最大内存 (MiB)，默认使用系统内存高阈值
   * - ``container_minmem``
     - 整数
     - ``32``
     - 容器最小内存预留 (MiB)
   * - ``static_resource``
     - 布尔
     - *平台相关*
     - 静态资源管理（禁止动态更新），Baremetal平台默认为true，其他平台为false
   * - ``shared_cpu_pool``
     - 布尔
     - ``false``
     - 共享 CPU 池模式（Xen cpupool管理）
   * - ``hugepage_enable``
     - 布尔
     - ``false``
     - 启用 HugePage 支持（仅 Xen）

Static Resource Management
^^^^^^^^^^^^^^^^^^^^^^^^^^

启用后：

- ``UpdateContainer`` API 将被忽略
- 资源在容器创建时固定
- 适用于资源固定的生产环境

Shared CPU Pool
^^^^^^^^^^^^^^^

.. list-table::
   :widths: 20 80
   :header-rows: 1

   * - 模式
     - 说明
   * - ``true``
     - 所有容器共享 CPU 池，cpuset 合并
   * - ``false``
     - 每个容器使用独立的 cpuset

Xen 节配置
----------

.. list-table::
   :widths: 30 15 20 35
   :header-rows: 1

   * - 配置项
     - 类型
     - 默认值
     - 说明
   * - ``sandbox_minimum_vcpu``
     - 整数
     - ``1``
     - Sandbox 最小 vCPU 数量
   * - ``exclusive_dom0_cpu``
     - 布尔
     - ``false``
     - Dom0 CPU 独占
   * - ``image_path``
     - 字符串
     - -
     - Xen 镜像路径
   * - ``aux_file_path``
     - 字符串
     - -
     - Xen 辅助文件路径

配置优先级示例
==============

示例 1：注解覆盖配置文件
------------------------

.. code-block:: yaml

   # Pod 注解
   metadata:
     annotations:
       org.openeuler.micrun.container.min_memory_mb: "64"  # 覆盖配置文件

优先级：注解 (64 MiB) > 配置文件 (32 MiB) > 默认值 (16 MiB)

示例 2：环境变量指定配置文件
----------------------------

.. code-block:: bash

   # 使用自定义配置文件
   export MICRUN_CONF_FILE=/etc/mica/micrun/custom.conf

优先级：``$MICRUN_CONF_FILE`` > ``$MICRUN_CONF_DIR`` > ``/etc/mica/micrun/conf.d/`` > ``/etc/mica/micrun/micrun.conf``

Drop-in 目录
============

Drop-in 目录允许将配置拆分为多个文件：

.. code-block:: text

   /etc/mica/micrun/conf.d/
   ├── 00-base.conf      # 基础配置
   ├── 10-resource.conf  # 资源配置
   └── 99-local.conf     # 本地覆盖配置

加载顺序：按文件名字母序加载，后加载的配置覆盖先加载的配置。

配置验证
========

检查当前配置
------------

.. code-block:: bash

   # 查看使用的配置文件
   journalctl -u containerd | grep "micrun config"

   # 查看 shim 进程的环境变量
   cat /proc/$(pgrep containerd-shim-mica-v2)/environ | tr '\0' '\n' | grep MICRUN

常见配置错误
------------

.. list-table::
   :widths: 30 30 40
   :header-rows: 1

   * - 错误
     - 原因
     - 解决方案
   * - ``config file not found``
     - 配置文件路径错误
     - 检查 ``MICRUN_CONF_FILE`` 环境变量
   * - ``invalid config format``
     - 配置文件格式错误
     - 检查 INI/TOML 语法
   * - ``value out of range``
     - 配置值超出有效范围
     - 检查数值是否合理

生产环境配置示例
================

高性能配置
----------

.. code-block:: ini

   [Mica]
   debug = false
   max_client_number = 16
   firmware_path = /usr/local/share/mica/firmware.elf

   [Resource]
   max_container_vcpu = 8
   container_maxmem = 2048
   container_minmem = 64
   static_resource = true
   shared_cpu_pool = false
   hugepage_enable = true

   [Xen]
   sandbox_minimum_vcpu = 2
   exclusive_dom0_cpu = true
   image_path = /usr/local/share/mica/xen-image.bin

低资源配置
----------

.. code-block:: ini

   [Mica]
   debug = false
   max_client_number = 4
   firmware_path = /usr/local/share/mica/firmware.elf

   [Resource]
   max_container_vcpu = 2
   container_maxmem = 256
   container_minmem = 16
   static_resource = false
   shared_cpu_pool = true
   hugepage_enable = false

   [Xen]
   sandbox_minimum_vcpu = 1
   exclusive_dom0_cpu = false
   image_path = /usr/local/share/mica/xen-image.bin

开发调试配置
------------

.. code-block:: ini

   [Mica]
   debug = true
   max_client_number = 4
   firmware_path = /usr/local/share/mica/firmware.elf

   [Resource]
   max_container_vcpu = 2
   container_maxmem = 256
   container_minmem = 16
   static_resource = false
   shared_cpu_pool = false
   hugepage_enable = false

   [Xen]
   sandbox_minimum_vcpu = 1
   exclusive_dom0_cpu = false
   image_path = /usr/local/share/mica/xen-image.bin

日志配置
========

日志配置位于 ``/etc/mica/micrun/config.json``，由 logger 包读取。

配置结构:

.. code-block:: json

   {
     "Log": {
       "level": "info",
       "file": "/var/log/mica/mica-runtime.log",
       "color": false,
       "caller": true
     }
   }

.. list-table::
   :widths: 20 15 30 35
   :header-rows: 1

   * - 配置项
     - 类型
     - 默认值
     - 说明
   * - ``level``
     - 字符串
     - ``info``
     - 日志级别 (debug, info, warn, error)
   * - ``file``
     - 字符串
     - ``/var/log/mica/mica-runtime.log``
     - 日志文件路径
   * - ``color``
     - 布尔
     - ``false``
     - 是否启用颜色输出
   * - ``caller``
     - 布尔
     - ``true``
     - 是否显示调用位置

相关文档
========

- :doc:`annotations` - 注解配置
- :doc:`resources` - 资源限制规则
- :doc:`troubleshooting` - 配置问题排查

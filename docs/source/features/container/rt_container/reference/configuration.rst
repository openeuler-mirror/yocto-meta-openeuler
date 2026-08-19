.. _micrun_configuration:

MicRun 配置参考手册
####################

概述
====

MicRun 当前的运行时配置解析分成两步：

1. **先决定读取哪份运行时配置**
2. **再把 annotations 作为最终 overlay 叠加到解析结果上**

以 ``internal/adapters/config/runtimeconfig/resolver.go`` 为准，当前实际顺序如下：

1. 调用方已传入 ``current *RuntimeConfig`` 时，直接复用
2. 注解里指定的 sandbox config path
3. CRI runtime options 中的 ``ConfigPath``
4. 环境变量 ``MICRUN_CONF_FILE``
5. 自动发现配置文件集合

   - ``MICRUN_CONF_DIR``
   - ``/etc/mica/micrun/conf.d/*.conf|*.toml``
   - ``/etc/mica/micrun/micrun.conf``
6. 最后统一叠加 annotations

这里要特别注意：**环境变量主要用于选择配置文件来源，不是直接承载 workload 参数值。**

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
     - 注解指定的 config path
   * - 2
     - CRI runtime options 中的 ``ConfigPath``
   * - 3
     - ``MICRUN_CONF_FILE`` 环境变量指定的文件
   * - 4
     - ``MICRUN_CONF_DIR`` 环境变量指定的目录（读取所有 ``.conf``/``.toml`` 文件）
   * - 5
     - ``/etc/mica/micrun/conf.d/*.conf`` 或 ``.toml`` (drop-in 目录)
   * - 6
     - ``/etc/mica/micrun/micrun.conf`` (默认配置文件)

补充说明：

- 当 ``MICRUN_CONF_FILE`` 指向的文件解析失败时，当前实现会记录告警并回退默认配置栈。
- 当注解或 CRI options 指定的配置文件解析失败时，当前创建链路会直接报错返回。
- 无论配置文件从哪里来，annotations 都会在最后一步覆盖最终值。
- 注解来源的配置文件属于 pod 作者可控输入：其中的宿主机路径类键
  （``state_dir``、``firmware_path``）会被忽略并回退默认值，防止非特权 pod 驱动
  root 权限的 shim 在任意宿主机位置创建目录、写入状态/缓存文件或读取任意文件。
  标量类键（如 ``debug``、``container_minmem``）不受影响。CRI runtime options、
  环境变量和默认发现等管理员侧来源保留全部键。
- **``state_dir`` 的恢复发现**：若 ``state_dir`` 只通过 CRI RuntimeClass
  ``ConfigPath`` 配置（宿主机文件未固定同名值），shim 重启做恢复时拿不到
  Create 请求、看不到该值。为避免恢复在默认 ``/run/micrun`` 扑空，shim 每次
  绑定非默认 ``state_dir`` 时会在默认状态根下记录指针文件
  ``/run/micrun/state-dir``，重启恢复与 one-shot ``delete`` 清理会优先采纳该指针
  （宿主机显式配置仍然优先）。指针位于 tmpfs：shim 重启（domain 存活、恢复
  有意义）时可用；guest 整机重启后随 domain 一起消失，空状态即为正确结果。
  如需绝对确定性，仍建议在宿主机配置文件固定 ``state_dir``。

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

   # 启用主机容器
   enable_host_container = false

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
     - 指定单个运行时配置文件路径
     - -
   * - ``MICRUN_CONF_DIR``
     - 指定运行时配置目录路径
     - -
   * - ``MICRUN_LOG_CONFIG``
     - 指定日志配置文件路径（覆盖 ``/etc/mica/micrun/config.json``）
     - ``/etc/mica/micrun/config.json``
   * - ``MICRUN_LOG_FILE``
     - 指定日志文件路径（仅 debug 版本）
     - ``/var/log/mica/mica-runtime.log``
   * - ``MICRUN_CONTAINERD_LOG_PATH``
     - 指定 containerd 日志输出路径（默认 shim 工作目录下 ``log``）
     - ``./log``
   * - ``CONTAINERD_NAMESPACE``
     - 容器命名空间
     - ``default``

说明：

- ``MICRUN_CONF_FILE`` 与 ``MICRUN_CONF_DIR`` 影响的是"加载哪份运行时配置"。
- workload 级细项（如固件、pedestal、资源限制覆盖）仍以 annotations 和 OCI spec 为主。

配置项详解
==========

Mica 节配置
-----------

.. note::

   ``max_client_number``、``enable_host_container``、``image_path``、``aux_file_path``
   为 micad 侧配置键（与本文件同处一份配置时由 micad 消费），MicRun 读取配置时不解析这些键。

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
     - 最大客户端数量（0表示无限制）。**由 micad 消费，MicRun 忽略**
   * - ``firmware_path``
     - 字符串
     - -
     - 默认固件路径
   * - ``pause_image``
     - 字符串
     - ``registry.k8s.io/pause``
     - sandbox pause 镜像（配置占位，暂无下游消费）
   * - ``state_dir``
     - 字符串
     - ``/run/micrun``
     - 运行时状态根目录；亦可通过 CRI RuntimeClass ``ConfigPath`` 配置
   * - ``enable_host_container``
     - 布尔
     - ``false``
     - 启用主机容器。**由 micad 消费，MicRun 忽略**

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
     - **尚未接线**：解析后无消费点，不会形成容器内存上限；实际生效的只有"限制不得超过宿主总内存"校验
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
     - **配置文件形态尚未接线**：实际 HugePage 开关来自宿主探测（气球驱动等），仅注解 ``org.openeuler.micrun.runtime.hugepage_enable`` 可覆盖；此配置键的值当前不被读取

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
     - Xen 镜像路径。MicRun 运行时不读取此键，Xen 底座镜像实际取自容器镜像内的 ``image.bin``；该键供 MICA 工具链使用
   * - ``aux_file_path``
     - 字符串
     - -
     - Xen 辅助文件路径。**由 MICA 侧消费，MicRun 解析但不使用**

配置优先级示例
==============

示例 1：注解覆盖最终配置值
--------------------------

.. code-block:: yaml

   # Pod 注解
   metadata:
     annotations:
       org.openeuler.micrun.container.min_memory_mb: "64"  # 覆盖配置文件

优先级：注解最终 overlay > 已解析出的 ``RuntimeConfig`` > 默认值

示例 2：环境变量选择配置文件
----------------------------

.. code-block:: bash

   # 使用自定义配置文件
   export MICRUN_CONF_FILE=/etc/mica/micrun/custom.conf

优先级：注解 config path > runtime options ``ConfigPath`` > ``$MICRUN_CONF_FILE`` > ``$MICRUN_CONF_DIR`` > ``/etc/mica/micrun/conf.d/`` > ``/etc/mica/micrun/micrun.conf``

示例 3：当前解析顺序
--------------------

.. code-block:: text

   current RuntimeConfig
     -> annotation config path
     -> CRI options ConfigPath
     -> MICRUN_CONF_FILE
     -> MICRUN_CONF_DIR / conf.d / default file
     -> annotations overlay

Drop-in 目录
============

Drop-in 目录允许将配置拆分为多个文件：

.. code-block:: text

   /etc/mica/micrun/conf.d/
   |-- 00-base.conf      # base config
   |-- 10-resource.conf  # resource config
   `-- 99-local.conf     # local overrides

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
     "log": {
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

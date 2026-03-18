.. _micrun_annotations:

MicRun 注解参考
################

本文档列出 MicRun 支持的核心注解(annotations),这些注解用于配置 RTOS 容器的行为。

注解通过 Pod/容器的 ``metadata.annotations`` 字段设置,**不支持通过环境变量配置**。

注解速查表
==========

.. list-table::
   :widths: 40 30 30
   :header-rows: 1

   * - 注解名称
     - 类型
     - 默认值
   * - **常用注解**
     - **类型**
     - **默认值**
   * - :ref:`org.openeuler.micrun.container.os <micrun_container_os>`
     - 字符串
     - ``uniproton``
   * - :ref:`org.openeuler.micrun.container.firmware_path <firmware_path>`
     - 字符串
     - ``firmware.elf``
   * - :ref:`org.openeuler.micrun.container.auto_close <auto_close>`
     - 布尔值
     - ``true``
   * - :ref:`org.openeuler.micrun.container.auto_close_timeout <auto_close_timeout_annotation>`
     - 时长/整数
     - ``30s``
   * - **资源配置**
     - **类型**
     - **默认值**
   * - :ref:`org.openeuler.micrun.container.min_memory_mb <min_memory_mb>`
     - 整数
     - ``32``
   * - :ref:`org.openeuler.micrun.container.max_vcpu_num <max_vcpu_num>`
     - 整数
     - 从运行时配置读取
   * - **Hypervisor 配置**
     - **类型**
     - **默认值**
   * - :ref:`org.openeuler.micrun.ped.pedestal <ped_pedestal>`
     - 字符串
     - 主机 Hypervisor 类型
   * - :ref:`org.openeuler.micrun.ped.conf <ped_conf>`
     - 字符串
     - ``image.bin``
   * - **运行时配置**
     - **类型**
     - **默认值**
   * - :ref:`org.openeuler.micrun.runtime.debug <runtime_debug>`
     - 布尔值
     - ``false``
   * - :ref:`org.openeuler.micrun.runtime.exclusive_dom0_cpu <exclusive_dom0_cpu>`
     - 布尔值
     - ``false``
   * - ``org.openeuler.micrun.runtime.vcpu_pcpu_binding``
     - 布尔值
     - ``false``

.. note::

   点击注解名称可跳转到详细说明。

注解前缀
========

.. list-table::
   :widths: 50 50
   :header-rows: 1

   * - 前缀
     - 说明
   * - ``org.openeuler.micrun.``
     - MicRun 通用注解前缀
   * - ``org.openeuler.micrun.ped.``
     - Hypervisor (Pedestal) 相关配置
   * - ``org.openeuler.micrun.runtime.``
     - 运行时相关配置
   * - ``org.openeuler.micrun.container.``
     - 容器相关配置

容器配置注解
==============

.. _micrun_container_os:

org.openeuler.micrun.container.os
----------------------------------

指定 RTOS 类型。

.. list-table::
   :widths: 30 70
   :header-rows: 1

   * - 值
     - 说明
   * - ``zephyr``
     - Zephyr RTOS
   * - ``uniproton``
     - UniProton RTOS (默认)


**示例**:

.. code-block:: yaml

   metadata:
     annotations:
       org.openeuler.micrun.container.os: "zephyr"

.. _firmware_path:

org.openeuler.micrun.container.firmware_path
----------------------------------------------

指定 RTOS 固件文件的路径(相对于容器 rootfs)。

.. list-table::
   :widths: 30 70
   :header-rows: 1

   * - 属性
     - 值
   * - 类型
     - 字符串
   * - 默认值
     - ``firmware.elf``
   * - 解析位置
     - ``<bundle>/rootfs/<firmware_path>``

**示例**:

.. code-block:: yaml

   metadata:
     annotations:
       org.openeuler.micrun.container.firmware_path: "images/zephyr.elf"

**路径解析规则**:

1. 如果使用绝对路径(以 ``/`` 开头),会去掉前缀 ``/``,然后相对于 rootfs 解析
2. 如果使用相对路径,直接相对于 rootfs 解析
3. 如果注解不存在,会尝试查找 ``*.elf`` 文件或使用默认值 ``firmware.elf``

org.openeuler.micrun.container.firmware_hash
---------------------------------------------

指定 RTOS 固件的 SHA-256 哈希值，用于验证固件完整性。

**示例**:

.. code-block:: yaml

   metadata:
     annotations:
       org.openeuler.micrun.container.firmware_hash: "a1b2c3d4e5f6..."

.. _min_memory_mb:

org.openeuler.micrun.container.min_memory_mb
--------------------------------------------

指定 RTOS 容器的初始内存分配(单位:MiB)。

.. list-table::
   :widths: 30 70
   :header-rows: 1

   * - 属性
     - 值
   * - 类型
     - 整数
   * - 单位
     - MiB
   * - 默认值
     - ``32``

**说明**:

* 这是容器的**预留内存** (memory reservation)
* 实际分配的内存不会低于此值
* 如果 OCI spec 中设置了 ``memory.reservation``,会覆盖此注解
* 可通过运行时配置 ``container_minmem`` 覆盖默认值

**示例**:

.. code-block:: yaml

   metadata:
     annotations:
       org.openeuler.micrun.container.min_memory_mb: "32"

.. _max_vcpu_num:

org.openeuler.micrun.container.max_vcpu_num
--------------------------------------------

覆盖容器的最大 vCPU 数量。

.. list-table::
   :widths: 30 70
   :header-rows: 1

   * - 属性
     - 值
   * - 类型
     - 整数
   * - 默认值
     - 从运行时配置读取

**示例**:

.. code-block:: yaml

   metadata:
     annotations:
       org.openeuler.micrun.container.max_vcpu_num: "4"

.. _auto_close:

容器自动关闭控制
=================

MicRun 提供了两个注解来控制容器的自动关闭行为，适用于调试、测试和生产场景。

.. _auto_close_annotation:

org.openeuler.micrun.container.auto_close
------------------------------------------

控制容器是否在 IO 关闭后自动退出。

.. list-table::
   :widths: 30 70
   :header-rows: 1

   * - 属性
     - 值
   * - 类型
     - 布尔值
   * - 默认值
     - ``true``
   * - 可选值
     - ``"true"`` / ``"false"``

**行为说明**：

* ``true``: 启用自动关闭，客户端断开后容器会在超时后自动退出
* ``false``: 禁用自动关闭（除非设置了 ``auto_close_timeout``）

.. warning::

   ⚠️ **重要**：此注解是布尔值，**不要使用数字值** （如 ``"60"``）。
   如需设置超时时长，请使用 :ref:`auto_close_timeout <auto_close_timeout_annotation>` 注解。

   **所有 IO 模式** （TTY/Non-TTY、前台/后台）默认都启用 30 秒超时机制。
   只有显式设置 ``auto_close=false`` 或 ``auto_close_timeout=0`` 才能禁用超时。

   **示例**：

**示例**：

.. code-block:: yaml

   metadata:
     annotations:
       org.openeuler.micrun.container.auto_close: "true"

.. _auto_close_timeout_annotation:

org.openeuler.micrun.container.auto_close_timeout
--------------------------------------------------

指定自动关闭的超时时间。

.. list-table::
   :widths: 30 70
   :header-rows: 1

   * - 属性
     - 值
   * - 类型
     - 持续时间字符串或整数秒
   * - 默认值
     - ``30s``
   * - 优先级
     - **最高** （覆盖 ``auto_close``）
   * - 适用范围
     - **所有 IO 模式**

**格式支持**：

.. list-table::
   :widths: 30 70
   :header-rows: 1

   * - 格式
     - 示例
   * - 持续时间字符串
     - ``"60s"``, ``"5m"``, ``"1h"``
   * - 整数秒
     - ``"60"`` （等价于 60s）
   * - 禁用超时
     - ``"0"`` 或 ``"0s"`` （无限连接）

**超时机制说明**：

* 默认情况下，**所有容器** 都会在 30 秒后自动关闭（无论 TTY/Non-TTY、前台/后台）
* 这是为防止测试/调试会话资源泄漏而设计的保护机制
* 如需长期运行服务，请显式设置 ``auto_close=false`` 或 ``auto_close_timeout=0``

**示例**：

.. code-block:: yaml

   metadata:
     annotations:
       org.openeuler.micrun.container.auto_close_timeout: "60s"

两个注解的对比
==============

.. list-table::
   :widths: 25 25 25 25
   :header-rows: 1

   * - 注解
     - 类型
     - 优先级
     - 用途
   * - ``auto_close``
     - 布尔值
     - 低
     - 控制是否启用自动关闭
   * - ``auto_close_timeout``
     - 时长
     - **高**
     - 设置具体的超时时长

**优先级规则**：

1. 如果设置了 ``auto_close_timeout``，则无论 ``auto_close`` 为何值，都使用此超时
2. 如果 ``auto_close_timeout`` 为 ``"0"``，则禁用自动关闭
3. 否则，使用 ``auto_close`` 的值（``true`` = 30秒超时，``false`` = 禁用）

**使用场景**：

.. list-table::
   :widths: 30 70
   :header-rows: 1

   * - 场景
     - 推荐配置
   * - **调试/测试**
     - 使用默认配置（30 秒自动关闭）
   * - **长时间运行的服务**
     - ``auto_close: "false"`` 或 ``auto_close_timeout: "0"``
   * - **自定义超时**
     - ``auto_close_timeout: "120s"``
   * - **需要多次 attach**
     - ``auto_close: "false"``

.. important::

   **超时机制使用注意**：

   * ⚠️ ``auto_close`` 是布尔值注解，**不要** 使用数字（如 ``auto_close=60``）
   * 需要设置超时时长时，使用 ``auto_close_timeout`` 注解（如 ``auto_close_timeout=60s``）
   * **所有 IO 模式默认启用 30 秒超时**，防止资源泄漏
   * 长期运行服务需显式禁用：``auto_close=false`` 或 ``auto_close_timeout=0``

Hypervisor 配置注解
====================

.. _ped_pedestal:

org.openeuler.micrun.ped.pedestal
----------------------------------

指定 Hypervisor (Pedestal) 类型。

.. list-table::
   :widths: 30 70
   :header-rows: 1

   * - 属性
     - 值
   * - 类型
     - 字符串
   * - 默认值
     - 主机 Hypervisor 类型
   * - 可选值
     - ``xen`` (完整功能), ``baremetal`` (基础功能)

**说明**:

* 如果指定的类型与主机不匹配,容器创建会失败
* 通常不需要设置,自动使用主机 Hypervisor

**示例**:

.. code-block:: yaml

   metadata:
     annotations:
       org.openeuler.micrun.ped.pedestal: "xen"

.. _ped_conf:

org.openeuler.micrun.ped.conf
------------------------------

指定 Hypervisor 配置文件的路径(相对于容器 rootfs)。

.. list-table::
   :widths: 30 70
   :header-rows: 1

   * - 属性
     - 值
   * - 类型
     - 字符串
   * - 默认值
     - ``image.bin`` (Xen)

**示例**:

.. code-block:: yaml

   metadata:
     annotations:
       org.openeuler.micrun.ped.conf: "images/xen-image.bin"

.. _ped_compatibility:

org.openeuler.micrun.ped.compatibility
----------------------------------------

.. warning::

   ⚠️ **已弃用**，请使用 ``org.openeuler.micrun.compatibility.*`` 前缀。

兼容性选项配置（格式：``^versionX``）。

运行时配置注解
==============

.. _runtime_debug:

org.openeuler.micrun.runtime.debug
-----------------------------------

启用调试模式。

.. list-table::
   :widths: 30 70
   :header-rows: 1

   * - 属性
     - 值
   * - 类型
     - 布尔值
   * - 默认值
     - ``false``

**示例**:

.. code-block:: yaml

   metadata:
     annotations:
       org.openeuler.micrun.runtime.debug: "true"

.. _exclusive_dom0_cpu:

org.openeuler.micrun.runtime.exclusive_dom0_cpu
------------------------------------------------

控制是否保持 Dom0 CPU 独占(Xen 专用)。

.. list-table::
   :widths: 30 70
   :header-rows: 1

   * - 属性
     - 值
   * - 类型
     - 布尔值
   * - 默认值
     - ``false``
   * - 仅适用于
     - Xen Hypervisor

**示例**:

.. code-block:: yaml

   metadata:
     annotations:
       org.openeuler.micrun.runtime.exclusive_dom0_cpu: "true"

org.openeuler.micrun.runtime.disable_new_netns
----------------------------------------------

禁用创建新的网络命名空间。

.. list-table::
   :widths: 30 70
   :header-rows: 1

   * - 属性
     - 值
   * - 类型
     - 布尔值
   * - 默认值
     - ``false``

**示例**:

.. code-block:: yaml

   metadata:
     annotations:
       org.openeuler.micrun.runtime.disable_new_netns: "true"

org.openeuler.micrun.runtime.pipe_size
-----------------------------------------

指定 IO 管道的大小(字节)。

.. list-table::
   :widths: 30 70
   :header-rows: 1

   * - 属性
     - 值
   * - 类型
     - 整数
   * - 单位
     - 字节
   * - 默认值
     - 系统默认

**示例**:

.. code-block:: yaml

   metadata:
     annotations:
       org.openeuler.micrun.runtime.pipe_size: "65536"

org.openeuler.micrun.runtime.experimental
-----------------------------------------

启用实验性功能。

.. list-table::
   :widths: 30 70
   :header-rows: 1

   * - 属性
     - 值
   * - 类型
     - 布尔值
   * - 默认值
     - ``false``

**示例**:

.. code-block:: yaml

   metadata:
     annotations:
       org.openeuler.micrun.runtime.experimental: "true"

org.openeuler.micrun.runtime.vcpu_pcpu_binding
-----------------------------------------------

启用 VCPU 到 PCPU 的绑定。

.. list-table::
   :widths: 30 70
   :header-rows: 1

   * - 属性
     - 值
   * - 类型
     - 布尔值
   * - 默认值
     - ``false``
   * - 说明
     - 启用后，容器的 vCPU 会绑定到指定的物理 CPU
   * - 要求
     - 需要配合 OCI spec 的 ``cpuset.cpus`` 使用

**示例**:

.. code-block:: yaml

   metadata:
     annotations:
       org.openeuler.micrun.runtime.vcpu_pcpu_binding: "true"

Sandbox 级别注解
================

以下注解用于配置整个 Sandbox。

org.openeuler.micrun.runtime.enable_vcpus_pinning
-------------------------------------------------

启用 Sandbox 级别的 VCPU 亲和性设置。

.. list-table::
   :widths: 30 70
   :header-rows: 1

   * - 属性
     - 值
   * - 类型
     - 布尔值
   * - 默认值
     - ``false``
   * - 级别
     - Sandbox

**示例**:

.. code-block:: yaml

   metadata:
     annotations:
       org.openeuler.micrun.runtime.enable_vcpus_pinning: "true"

org.openeuler.micrun.runtime.static_resource
-----------------------------------------------

启用静态资源管理模式。

.. list-table::
   :widths: 30 70
   :header-rows: 1

   * - 属性
     - 值
   * - 类型
     - 布尔值
   * - 默认值
     - ``false``
   * - 级别
     - Sandbox
   * - 说明
     - 静态模式下，资源更新(``UpdateContainer`` API)将被忽略

**示例**:

.. code-block:: yaml

   metadata:
     annotations:
       org.openeuler.micrun.runtime.static_resource: "true"

org.openeuler.micrun.runtime.hugepage_enable
-----------------------------------------------

启用 HugePage 支持。

.. list-table::
   :widths: 30 70
   :header-rows: 1

   * - 属性
     - 值
   * - 类型
     - 布尔值
   * - 默认值
     - ``false``
   * - 级别
     - Sandbox
   * - 仅适用于
     - Xen Hypervisor

**示例**:

.. code-block:: yaml

   metadata:
     annotations:
       org.openeuler.micrun.runtime.hugepage_enable: "true"

内部注解
============

以下注解由 MicRun 内部使用，通常不需要手动设置。

.. list-table::
   :widths: 40 60
   :header-rows: 1

   * - 注解
     - 说明
   * - ``org.openeuler.micrun.pkg.oci.bundle_path``
     - OCI bundle 路径(读取 OCI spec)
   * - ``org.openeuler.micrun.pkg.oci.container_type``
     - 容器类型
   * - ``org.openeuler.micrun.config_path``
     - Sandbox 配置路径

Kubernetes 使用示例
====================

RuntimeClass 配置
-----------------

.. code-block:: yaml

   apiVersion: node.k8s.io/v1
   kind: RuntimeClass
   metadata:
     name: micrun
   handler: micrun

Pod 配置
--------

.. code-block:: yaml

   apiVersion: v1
   kind: Pod
   metadata:
     name: rtos-pod
     annotations:
       # 容器配置
       org.openeuler.micrun.container.os: "zephyr"
       org.openeuler.micrun.container.firmware_path: "images/zephyr.elf"
       org.openeuler.micrun.container.min_memory_mb: "32"
       org.openeuler.micrun.container.auto_close_timeout: "60s"

       # Hypervisor 配置
       org.openeuler.micrun.ped.pedestal: "xen"

       # 运行时配置
       org.openeuler.micrun.runtime.disable_new_netns: "true"
       org.openeuler.micrun.runtime.vcpu_pcpu_binding: "true"
   spec:
     runtimeClassName: micrun
     containers:
     - name: rtos-app
       image: localhost:5000/zephyr-app:latest
       resources:
         limits:
           memory: "64Mi"
           cpu: "2"
         requests:
           memory: "32Mi"

使用 ctr
---------

.. code-block:: bash

   ctr run --runtime io.containerd.mica.v2 \
     --annotation org.openeuler.micrun.container.os=zephyr \
     --annotation org.openeuler.micrun.container.firmware_path=images/zephyr.elf \
     --annotation org.openeuler.micrun.container.auto_close=false \
     --annotation org.openeuler.micrun.runtime.disable_new_netns=true \
     --annotation org.openeuler.micrun.runtime.vcpu_pcpu_binding=true \
     localhost:5000/zephyr-app:latest zephyr-container

使用 nerdctl
------------

.. code-block:: bash

   nerdctl run --runtime io.containerd.mica.v2 \
     -l org.openeuler.micrun.container.os=zephyr \
     -l org.openeuler.micrun.container.firmware_path=images/zephyr.elf \
     -l org.openeuler.micrun.container.auto_close_timeout=0 \
     localhost:5000/zephyr-app:latest

注意事项
========

1. **注解 vs 环境变量**: MicRun 只通过 Pod/容器的 ``metadata.annotations`` 读取配置，不支持通过环境变量配置。

2. **优先级**: 注解配置 > 运行时配置文件 > 默认值

3. **类型转换**: 布尔值使用 ``"true"``/``"false"`` 字符串，整数使用数字字符串

4. **路径解析**: 固件和配置文件路径相对于容器 rootfs (``<bundle>/rootfs/``)

5. **资源限制**: OCI spec 中的资源限制(``resources.limits``)与注解配置会互相影响。

6. **超时机制使用注意**:

   * ⚠️ ``auto_close`` 是布尔值注解，**不要** 使用数字（如 ``auto_close=60``）
   * 如需设置超时时长，使用 ``auto_close_timeout`` 注解（如 ``auto_close_timeout=60s``）
   * **所有 IO 模式默认启用 30 秒超时**，防止资源泄漏
   * 长期运行服务需显式禁用：``auto_close=false`` 或 ``auto_close_timeout=0``

.. seealso::

   关于超时机制的详细说明，请参考 :ref:`容器自动关闭控制 <auto_close>` 章节。

下一步
======

* :doc:`../quick-start` - 快速入门指南
* :doc:`../kubernetes/index` - Kubernetes 集成指南

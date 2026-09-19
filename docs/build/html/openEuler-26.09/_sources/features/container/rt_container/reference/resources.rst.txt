.. _micrun_resources:

MicRun 资源映射参考
###################

概述
====

本文档详细说明 MicRun 如何将容器资源（来自 Kubernetes/containerd）映射到 RTOS 客户机的资源配置。

当前实现中，资源解析链路已经收敛为：

1. ``internal/adapters/hypervisor/pedestal/planner.go`` 负责把 OCI 资源转换为 pedestal 侧基础资源视图
2. ``internal/domain/container/container_resource_parse.go`` 负责把资源计划并入容器领域配置
3. ``internal/domain/container/container_resource_cpu.go`` 负责 CPU mask 归一化、越界过滤与 VCPU 回退策略
4. ``internal/adapters/config/oci/resource_defaults.go`` 负责运行时默认值与内存阈值补全

CPU 资源映射
============

核心概念
--------

.. list-table::
   :widths: 20 80
   :header-rows: 1

   * - 概念
     - 说明
   * - **pCPU**
     - 物理 CPU 核心，实际的硬件计算单元
   * - **vCPU**
     - 虚拟 CPU，Hypervisor 呈现给客户机的 CPU 抽象
   * - **cpuset**
     - CPU 亲和性设置，限制进程/客户机只能在指定的 pCPU 上运行

映射关系
--------

::

   Container CPU Share (cpu.shares) <==(放缩比例 1024:256)==> RTOS Client CPU Weight
   Container Quota/Period (cpu.quota/cpu.period) <==(放缩比例 1:100)==> RTOS Client CPU Capacity
   Container cpuset (cpu.cpus) <====> RTOS Client CPUS (CPU 亲和性)

详细映射规则
------------

CPU Shares (权重)
^^^^^^^^^^^^^^^^^

.. list-table::
   :widths: 40 30 30
   :header-rows: 1

   * - 容器侧
     - RTOS 侧
     - 转换公式
   * - ``cpu.shares`` (默认 1024, 范围 2-262144)
     - ``CPUWeight`` (默认 256, 范围 1-65535)
     - ``weight = max(1, min(shares / 4, 65535))``

CPU Quota/Period (绝对限制)
^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. list-table::
   :widths: 35 30 35
   :header-rows: 1

   * - 容器侧
     - RTOS 侧
     - 说明
   * - ``cpu.quota`` (微秒)
     - ``CPUCapacity`` (%)
     - 容量 = (quota × 100) / period
   * - ``cpu.period`` (微秒，通常 100000)
     - -
     - 调度周期长度

**核心约束规则**：

::

   effective_capacity = min(
       (quota × 100) / period,   # quota/period 转换的百分比容量
       cpuset_size × 100          # cpuset 核心数 × 100%
   )

CPU Set (亲和性)
^^^^^^^^^^^^^^^^

.. list-table::
   :widths: 40 30 30
   :header-rows: 1

   * - 容器侧
     - RTOS 侧
     - 格式
   * - ``cpu.cpus`` ("0-3" 或 "0,1,3")
     - ``ClientCpuSet``
     - 直接传递 CPU 亲和性设置

VCPU 数量策略
-------------

.. list-table::
   :widths: 25 75
   :header-rows: 1

   * - 策略
     - 说明
   * - **默认**
     - 无 ``cpuset`` 时，``VCPU = max(1, ceil(CPUCapacity / 100))``，保证客户机可见的 vCPU 数能覆盖请求的 CPU 容量
   * - **设置了 cpuset**
     - ``VCPU = cpuset_size``，并受 ``cpuset`` 物理核心数量约束
   * - **vcpu_pcpu_binding=true**
     - VCPUs : PCPUs = 1:1，每个 vCPU 绑定到物理核心

Shared CPU Pool
---------------

- **shared_cpu_pool** 选项：sandbox 内的所有容器都只能运行在指定的 CPU pool 上
- **注意**：机器上可能有多个 sandbox，它们的 CPU pool 范围可能重合

cpuset 归一化与越界处理
-----------------------

MicRun 当前会在容器领域层对 ``cpu.cpus`` 做一次本地归一化，而不是把该逻辑下沉到 guest adapter：

1. 先按 ``cpuset`` 语法解析 CPU mask
2. 若存在超出宿主机物理 CPU 上限的条目，则过滤这些条目
3. 过滤后若仍有合法 CPU，则使用过滤后的 mask，并将 ``VCPU`` 数同步为合法 CPU 个数
4. 若过滤后已无合法 CPU，则清空 ``cpuset``，并回退到基于 ``quota/period`` 推导的 ``VCPU = ceil(capacity / 100)``

这意味着：

- ``0,2,9`` 在 4 物理核机器上会被归一化为 ``0,2``
- ``8,9`` 这类全越界配置会清空 ``cpuset``，再按 CPU capacity 决定 VCPU 数
- ``0,,2``、``-1`` 这类非法 mask 会被视为解析错误，不进入归一化成功路径

内存资源映射
============

映射关系
--------

::

   无容器内存限制                     <====> RTOS Client pedestal max memory
   Container memory limit            <====> RTOS Client memory limit
   Container memory reservation      <====> RTOS Client memory min

术语说明
--------

.. list-table::
   :widths: 30 70
   :header-rows: 1

   * - 术语
     - 说明
   * - **Container 语境**
     - 使用 container memory limit, minimal memory
   * - **libmica 语境**
     - 使用 RTOS Client memory resource
   * - ``memorymaxmb``
     - 对应 OCI spec 中的 ``mem.Limit``
   * - ``mem min``
     - 对应 OCI spec 中的 ``mem.Reservation``

内存阈值管理
------------

- ``memoryThreshold`` 单调递增，只能增加不能减少
- 确保 ``memory threshold >= container memory limit``
- ``memorymaxmb`` 对应 mica create message 中的 memory

不支持/忽略的资源
==================

.. list-table::
   :widths: 30 30 40
   :header-rows: 1

   * - 资源类型
     - 处理方式
     - 原因
   * - ``oom_score_adj``
     - 部分忽略
     - RTOS 无 OOM killer 概念
   * - ``hugepage_limits``
     - 暂时忽略
     - 依赖 RTOS 支持
   * - ``unified`` (cgroup v2)
     - 完全忽略
     - 不适用于 RTOS 环境
   * - ``memory_swap_limit_in_bytes``
     - 忽略
     - Xen 环境下不支持 swap
   * - ``cpu.mems`` (NUMA)
     - 暂时不处理
     - 未来可扩展

Kubernetes 资源映射
====================

K8s 到 cgroup 的转换
--------------------

.. list-table::
   :widths: 30 30 40
   :header-rows: 1

   * - K8s 字段
     - cgroup 字段
     - 转换方式
   * - ``requests.cpu``
     - ``cpu.shares``
     - ``MilliCPUToShares()`` 转换
   * - ``limits.cpu``
     - ``cpu.quota/period``
     - ``MilliCPUToQuota()`` 转换
   * - ``limits.memory``
     - ``memory.limit_in_bytes``
     - 直接转换

权重转换公式
------------

.. math::

   W(S) = \max\left\{1,\ \min\left\{\frac{S}{R},\ 65535\right\}\right\},\quad R = 4

其中 :math:`S` 为 cgroup ``cpu.shares`` 值（2-262144），与"CPU Shares (权重)"一节的转换公式一致。

配置优先级
==========

资源相关配置在当前实现里分成"运行时配置来源选择"和"最终值覆盖"两层：

1. 先选择运行时配置来源

   - annotation 指定的 config path
   - CRI runtime options 的 ``ConfigPath``
   - ``MICRUN_CONF_FILE``
   - ``MICRUN_CONF_DIR``
   - ``/etc/mica/micrun/conf.d/*``
   - ``/etc/mica/micrun/micrun.conf``

2. 再由 annotations 对最终值做 overlay

因此更准确的理解应该是：

- **Annotation** - 最终覆盖值，优先级最高
- **Config Files** - 运行时默认值来源
- **Environment Variables** - 主要决定读取哪份配置文件，不直接承载资源值
- **Default Values** - 最后兜底

注解配置示例
------------

.. code-block:: yaml

   apiVersion: v1
   kind: Pod
   metadata:
     name: rtos-pod
     annotations:
       io.kubernetes.cri.cpuset-cpus: "0-3"
       org.openeuler.micrun.runtime.vcpu_pcpu_binding: "true"
   spec:
     containers:
     - name: rtos-app
       image: localhost:5000/mica-rtos-app:latest
       resources:
         limits:
           cpu: "1000m"
           memory: "512Mi"

高级配置选项
============

静态资源管理
------------

.. list-table::
   :widths: 60 20 20
   :header-rows: 1

   * - 注解
     - 值
     - 说明
   * - ``org.openeuler.micrun.runtime.static_resource``
     - ``true``/``false``
     - 启用后资源热更新将被忽略

vCPU 固定
---------

.. list-table::
   :widths: 60 20 20
   :header-rows: 1

   * - 注解
     - 值
     - 说明
   * - ``org.openeuler.micrun.runtime.enable_vcpus_pinning``
     - ``true``/``false``
     - 每个 vCPU 绑定到物理核心

共享 CPU 池
-----------

通过配置文件 ``shared_cpu_pool = true`` 启用共享 CPU 池模式，允许多个 RTOS 容器共享 CPU 资源。此选项在 ``/etc/mica/micrun/micrun.conf`` 中配置，不是注解。

大页支持
--------

.. list-table::
   :widths: 60 20 20
   :header-rows: 1

   * - 注解
     - 值
     - 说明
   * - ``org.openeuler.micrun.runtime.hugepage_enable``
     - ``true``/``false``
     - 启用大页内存支持

代码实现
========

关键文件
--------

.. list-table::
   :widths: 50 50
   :header-rows: 1

   * - 文件
     - 说明
   * - ``internal/adapters/hypervisor/pedestal/planner.go``
     - 资源解析，``(*PedestalFacade).PlanEssentialResources()``, ``linuxResourceToEssential()``
   * - ``internal/adapters/hypervisor/pedestal/resources.go``
     - 资源结构定义 ``EssentialResource``
   * - ``internal/domain/container/container_resource_parse.go``
     - ``ParseOCIResourcesWithPolicy()``、``ValidateResourceLimitsWithPolicy()``、CPU/Memory 解析编排
   * - ``internal/domain/container/container_resource_cpu.go``
     - CPU capacity、cpuset 归一化、越界 CPU 过滤
   * - ``internal/domain/container/container_resource_memory.go``
     - memory limit / reservation 映射
   * - ``internal/adapters/config/oci/resource_defaults.go``
     - 内存阈值计算 ``calculateClientMemThreshold()``

关键函数
--------

.. code-block:: go

   // pedestal 资源规划 (internal/adapters/hypervisor/pedestal/planner.go)
   func (f *PedestalFacade) PlanEssentialResources(spec *specs.Spec) *EssentialResource
   func linuxResourceToEssential(spec *specs.Spec, convertShares bool) *EssentialResource

   // 容器领域资源解析 (internal/domain/container/container_resource_parse.go)
   func (r *ContainerConfig) ParseOCIResourcesWithPolicy(ctx context.Context, spec *specs.Spec, policy ResourcePolicy) error
   func ValidateResourceLimitsWithPolicy(ctx context.Context, config *ContainerConfig, policy ResourcePolicy) error

   // 容器领域 CPU mask 归一化 (internal/domain/container/container_resource_cpu.go)
   func normalizeCPUSetWithLimit(mask string, fallbackVCPUs uint32, maxCPUs uint32) normalizedCPUSet

   // 内存阈值管理 (internal/adapters/config/oci/resource_defaults.go)
   func calculateClientMemThreshold(config *cntr.ContainerConfig, runtimeCfg *RuntimeConfig) uint32

测试验证
========

测试场景
--------

.. list-table::
   :widths: 30 40 30
   :header-rows: 1

   * - 场景
     - 配置
     - 预期结果
   * - cpuset 更严格
     - quota=200%, cpuset="0"
     - capacity=100%
   * - quota 更严格
     - quota=50%, cpuset="0-3"
     - capacity=50%
   * - 只有 cpuset
     - 无 quota, cpuset="0-1"
     - capacity=200%
   * - 只有 quota
     - quota=150%, 无 cpuset
     - capacity=150%

与 runc 语义对齐
----------------

MicRun 实现了与 ``runc`` 相同的资源限制语义：

- **cpuset**：作为物理天花板
- **quota/period**：作为逻辑上限
- **最终限制**：取两者的最小值

另外，MicRun 会额外做一层 RTOS/Xen 场景下的防御性处理：

- 过滤超出宿主机物理 CPU 范围的 ``cpuset``
- 在 ``cpuset`` 完全失效时回退到 capacity 导出的 ``VCPU``
- 在 guest 侧通过 ``memoryThreshold >= memory limit`` 保持内存扩容路径稳定

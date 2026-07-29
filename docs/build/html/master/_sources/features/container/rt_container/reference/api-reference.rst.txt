.. _micrun_api_reference:

MicRun API 参考文档
####################

概述
====

本文档描述 MicRun 当前代码中的核心接口与主要调用链。重点不是列出所有导出符号，而是回答三个问题：

1. 当前有哪些稳定的内部边界
2. 这些边界分别位于哪里
3. 从 ``containerd`` 请求进入后，主要调用链如何流转

总体分层
========

.. code-block:: text

   containerd runtime v2 RPC
           |
           v
   internal/transport/shimv2
           |
           v
   internal/application
           |
           v
   internal/domain/container
           |
           v
   internal/ports
           |
           v
   internal/adapters

对应代码落点：

.. list-table::
   :widths: 20 50
   :header-rows: 1

   * - 层
     - 代码路径
   * - transport
     - ``internal/transport/shimv2``
   * - application
     - ``internal/application``
   * - domain
     - ``internal/domain/container``
   * - ports
     - ``internal/ports``
   * - adapters
     - ``internal/adapters``

Domain 接口
===========

ContainerTraits
---------------

定义位置：``internal/domain/container/interfaces.go``

它描述"单个 RTOS workload 容器"对外暴露的最小能力，包括：

.. list-table::
   :widths: 30 70
   :header-rows: 1

   * - 方法
     - 说明
   * - ``ID()``
     - 标识
   * - ``GetAnnotations()``
     - 注解
   * - ``Sandbox()``
     - sandbox 归属
   * - ``Status()`` / ``State()``
     - 状态
   * - ``GetMemoryLimit()`` / ``GetClientCPU()``
     - 资源
   * - ``SaveState()``
     - 状态持久化
   * - ``Signal(...)``
     - 控制

这层接口仍然贴近当前实现，没有刻意追求更抽象的 runtime model。

SandboxTraits
-------------

定义位置：``internal/domain/container/interfaces.go``

它是 application / transport 层感知 sandbox 的主要入口，能力包括：

.. list-table::
   :widths: 30 70
   :header-rows: 1

   * - 分类
     - 方法
   * - sandbox 生命周期
     - ``Start`` / ``Stop`` / ``Delete``
   * - container 生命周期
     - ``CreateContainer`` / ``StartContainer`` / ``StopContainer`` / ``DeleteContainer`` / ``KillContainer``
   * - 状态与查询
     - ``GetState`` / ``GetAllContainers`` / ``StatusContainer`` / ``StatsContainer``
   * - IO
     - ``IOStream`` / ``OpenTTYs`` / ``WinResize`` / ``WaitContainerExit``
   * - 资源更新
     - ``UpdateContainer``

实现主体位于：

- ``internal/domain/container/sandbox.go``
- ``internal/domain/container/sandbox_factory.go``
- ``internal/domain/container/sandbox_loader.go``
- ``internal/domain/container/sandbox_lifecycle.go``

Ports
=====

MicRun 当前比较重要的 ports 如下。

GuestControl
------------

定义位置：``internal/ports/guest.go``

负责 guest 生命周期和状态交互：

.. list-table::
   :widths: 25 75
   :header-rows: 1

   * - 方法
     - 说明
   * - ``Start``
     - 启动 guest
   * - ``Stop``
     - 停止 guest
   * - ``Remove``
     - 移除 guest
   * - ``Pause``
     - 暂停 guest
   * - ``Resume``
     - 恢复 guest
   * - ``Exists``
     - 查询 guest 是否存在
   * - ``Status``
     - 查询 guest 状态

当前默认实现链路：

.. code-block:: text

   shimv2 -> buildContainerDependencies() -> guest/micad -> libmica

HypervisorControl
-----------------

定义位置：``internal/ports/hypervisor.go``

负责宿主 / hypervisor 的控制面：

.. list-table::
   :widths: 25 75
   :header-rows: 1

   * - 方法
     - 说明
   * - ``Type``
     - 返回 Hypervisor 类型
   * - ``MaxCPUNum``
     - 最大 CPU 数量
   * - ``DomainState``
     - 查询 domain 状态
   * - ``SetVCPUCount``
     - 设置 VCPU 数量
   * - ``Pause``
     - 暂停
   * - ``Resume``
     - 恢复

当前默认实现来自 pedestal adapter。

StateStore
----------

定义位置：``internal/ports/state_store.go``

用于持久化 runtime snapshot：

.. list-table::
   :widths: 25 75
   :header-rows: 1

   * - 方法
     - 说明
   * - ``Load``
     - 加载 snapshot
   * - ``Save``
     - 保存 snapshot
   * - ``Delete``
     - 删除 snapshot

当前文件实现位于：``internal/adapters/state/file/store.go``

IOSessionFactory
----------------

定义位置：``internal/ports/io.go``

用于 application 层创建 attach/session：

.. list-table::
   :widths: 30 70
   :header-rows: 1

   * - 方法
     - 说明
   * - ``NewSession``
     - 创建新会话
   * - ``IsValidFIFOPath``
     - 检查是否为有效 FIFO 路径
   * - ``GenerateFIFOPath``
     - 生成 FIFO 路径

TaskRuntime
-----------

定义位置：``internal/ports/task.go``

这是 application 层看到的 "runtime-facing shim 接口"，由 ``shimService`` 实现。
它不是 domain 接口，而是 transport/application 之间的编排边界。

``TaskRuntime`` 由 6 个基础子接口组合：

.. list-table::
   :widths: 30 70
   :header-rows: 1

   * - 子接口
     - 说明
   * - ``TaskLocker``
     - 任务锁
   * - ``TaskIdentity``
     - 任务标识
   * - ``TaskStore``
     - 任务存储
   * - ``TaskFactory``
     - 任务创建
   * - ``TaskSandboxAccess``
     - sandbox 访问
   * - ``TaskStatusOps``
     - 任务状态操作

application/task 的方法不直接要求完整 ``TaskRuntime``，而是按用例接收更窄的复合接口：

- ``TaskCreateRuntime``
- ``TaskStartRuntime``
- ``TaskDeleteRuntime``
- ``TaskQueryRuntime``
- ``TaskWaitRuntime``
- ``TaskSignalRuntime``
- ``TaskIORuntime``

``TaskLifecycleRuntime`` 和 ``TaskAttachRuntime`` 仍分别服务于 lifecycle/attach 子应用。
metrics 采集已经回收到 ``transport/shimv2`` 内部，不再属于 application/task 的 runtime port。
在 ``taskManager`` 内部，transport 读写视图继续按用途拆分为 process、metrics、task presence、events、shutdown。
这样 ``Stats``、``Pids``/``Connect``、``Shutdown`` 和事件发布不会共享一个全能 transport runtime 接口。

实现位置：``internal/transport/shimv2/runtime_ports.go``

GuestExecutor
-------------

定义位置：``internal/ports/guest_executor.go``

``GuestExecutor`` 是一个复合接口，由三个子接口按 Interface Segregation Principle 组合而成：

GuestResourceReader
^^^^^^^^^^^^^^^^^^^

读取当前资源状态：

.. list-table::
   :widths: 35 65
   :header-rows: 1

   * - 方法
     - 说明
   * - ``ReadResource() *ResourceSnapshot``
     - 读取资源快照
   * - ``CurrentMaxMem() uint32``
     - 当前最大内存
   * - ``MemoryThresholdMB() uint32``
     - 内存阈值（MB）

GuestResourceUpdater
^^^^^^^^^^^^^^^^^^^^

应用资源变更：

.. list-table::
   :widths: 50 50
   :header-rows: 1

   * - 方法
     - 说明
   * - ``UpdateCPUCapacity(capacity uint32) error``
     - 更新 CPU 容量上限
   * - ``UpdateCPUWeight(weight uint32) error``
     - 更新 CPU 调度权重
   * - ``UpdateVCPUNum(vcpu uint32) (oldCPUs, newCPUs uint32, err error)``
     - 更新 VCPU 数量
   * - ``UpdatePCPUConstraints(cpuSet string) error``
     - 更新 PCPU 约束
   * - ``EnsureMemoryLimit(mb uint32) error``
     - 确保内存上限
   * - ``UpdateMemoryThreshold(memMiB uint32) error``
     - 更新内存阈值
   * - ``UpdateMemory(memMiB uint32) error``
     - 更新内存
   * - ``RecordMemoryState(current, threshold uint32)``
     - 记录内存状态
   * - ``VCPUPin(cpuList []int) error``
     - VCPU 绑核

GuestResourceDiff
^^^^^^^^^^^^^^^^^

检查是否需要资源更新：

.. list-table::
   :widths: 45 55
   :header-rows: 1

   * - 方法
     - 说明
   * - ``NeedUpdateCPUCap(target uint32) bool``
     - 是否需要更新 CPU 容量
   * - ``NeedUpdateMemLimit(target uint32) bool``
     - 是否需要更新内存上限
   * - ``NeedUpdateCPUSet(oldSet, newSet string) bool``
     - 是否需要更新 CPU 集合
   * - ``NeedUpdateCPUShare(target uint32) bool``
     - 是否需要更新 CPU share
   * - ``NeedUpdateVCPUs(target uint32) bool``
     - 是否需要更新 VCPU 数量

关联类型：

- ``ResourceSnapshot``：guest 当前资源状态快照（``CPUCapacity``、``CPUWeight``、``ClientCPUSet``、``VCPU``、``MemoryMaxMB``）

当前默认实现：``adapters/guest/libmica.MicaExecutor``

Application 层服务
==================

task.Service
------------

定义位置：``internal/application/task/service.go``

职责：

- 聚合 attach + lifecycle 能力
- 为 transport 层提供 task 语义编排入口

attach.Service
--------------

定义位置：``internal/application/attach/service.go``

职责：

- attach / reattach
- resize 前的会话准备
- stdin close 语义
- detach 后会话状态维护

lifecycle.Service
-----------------

定义位置：``internal/application/lifecycle/service.go``

职责：

- 启动任务时的 IO 与 exit orchestration
- 退出等待与退出事件关联

recovery.Service
----------------

定义位置：``internal/application/recovery/service.go``

职责：

- orphan cleanup
- sandbox/task reconstruction

Transport 层关键入口
====================

Shim 启动
---------

入口：``internal/transport/shimv2/shim_bootstrap.go``

关键步骤：

1. ``bootstrapPlatformBindings()``

   - 返回 ``runtimeEnvironment`` （封装宿主平台探测结果）

2. ``buildContainerDependencies(bindings)``
3. ``buildRuntimeDependencies(bindings, containerDeps)``
4. 创建 one-shot 或 daemon shim service

相关代码：

- ``internal/transport/shimv2/platform_bindings.go``
- ``internal/transport/shimv2/container_dependencies.go``
- ``internal/transport/shimv2/runtime_dependencies.go``

创建链路
--------

大致路径：

.. code-block:: text

   Create RPC
    -> shimv2/create
    -> buildCreatePlan
    -> loadRuntimeConfig
    -> createSandboxContainer / createPodContainer
    -> oci.ParseContainerCfg / oci.SandboxConfig
    -> domain/container.CreateSandbox / CreateContainer

代码落点：

- ``internal/transport/shimv2/create_plan.go``
- ``internal/transport/shimv2/runtime_config_helpers.go``
- ``internal/transport/shimv2/create_sandbox_runtime.go``
- ``internal/transport/shimv2/create_pod_runtime.go``

恢复链路
--------

大致路径：

.. code-block:: text

   shim daemon start
    -> application/recovery.Service
    -> shimRecoveryBackend.Restore
    -> domain/container.LoadSandboxWithDependencies
    -> StateStore runtime snapshot (runtime.json)
    -> state.json compatibility fallback

代码落点：

- ``internal/transport/shimv2/recovery_backend.go``
- ``internal/domain/container/sandbox_loader.go``
- ``internal/domain/container/state_repository.go``
- ``internal/domain/container/state_legacy.go``

配置与资源相关接口
==================

RuntimeConfig
-------------

定义位置：``internal/adapters/config/oci/runtime_setup.go``

作用：

- 管理 MicRun 运行时默认值
- 解析 INI / annotations
- 承载 ``HostProfile``

HostProfile
-----------

定义位置：``internal/adapters/config/oci/host_profile.go``

作用：

- 显式携带宿主平台画像
- 供 ``RuntimeConfig`` / ``SandboxConfig`` / 容器配置解析使用
- 避免 ``oci`` 链路里直接读取 ``pedestal.Host``

ResourcePolicy
--------------

定义位置：``internal/domain/container/deps.go``

作用：

- 从 ``Dependencies`` 中抽取资源规划和资源校验所需能力
- 从 ``shimv2`` 显式传到 ``oci`` 配置解析链
- ``PlanEssentialRes`` 接收 ``*specs.Spec``，资源规划边界不再使用 ``any`` 后做运行时类型断言

依赖注入
========

所有创建和恢复链路通过显式注入完成：

- ``containerDeps`` （``Dependencies`` 结构体，包含 ``StateStoreFactory``、``GuestExecutorFactory`` 等 9 个必需字段）
- ``resourcePolicy`` （从 ``Dependencies`` 中提取的资源规划能力子集）
- ``runtimeResolver`` （运行时配置解析器）
- ``HostProfile`` （宿主平台画像）

默认 bootstrap 通过 ``pedestal.DetectHost()`` 检测宿主类型，依赖由 ``SandboxConfig.Dependencies`` 显式注入。

相关文档
========

- :doc:`annotations` - 注解配置
- :doc:`resources` - 资源限制映射规则

.. _micrun_api_reference:

MicRun API 参考文档
####################

概述
====

本文档描述 MicRun 的核心 API 接口。MicRun 采用分层架构设计，接口分为：

1. **Sandbox 层** (``SandboxTraits``) - 管理 Sandbox 和容器生命周期
2. **Container 层** (``ContainerTraits``) - 管理单个容器
3. **Pedestal 层** (``Pedestal``) - 抽象 Hypervisor 接口
4. **IO 层** (``Session``, ``Copier``, ``EventBus``) - 管理 IO 流

Sandbox 层 API
==============

SandboxTraits 接口
-------------------

``SandboxTraits`` 是 Sandbox 的核心接口，位于 ``pkg/micantainer/interfaces.go``。

标识和状态方法
^^^^^^^^^^^^^^

.. list-table::
   :widths: 25 25 50
   :header-rows: 1

   * - 方法
     - 返回类型
     - 说明
   * - ``SandboxID()``
     - ``string``
     - 返回 Sandbox ID
   * - ``Annotation(key string)``
     - ``(string, error)``
     - 获取指定注解的值
   * - ``GetState()``
     - ``StateString``
     - 获取当前状态
   * - ``GetNetNamespace()``
     - ``string``
     - 获取网络命名空间
   * - ``NetnsHolderPID()``
     - ``int``
     - 获取网络命名空间持有者 PID
   * - ``GetAllContainers()``
     - ``[]ContainerTraits``
     - 获取所有容器列表

Sandbox 生命周期方法
^^^^^^^^^^^^^^^^^^^^

.. list-table::
   :widths: 25 20 15 40
   :header-rows: 1

   * - 方法
     - 参数
     - 返回
     - 说明
   * - ``Start(ctx)``
     - ``context.Context``
     - ``error``
     - 启动 Sandbox 和所有容器
   * - ``Stop(ctx, force)``
     - ``context.Context, bool``
     - ``error``
     - 停止所有容器和 Sandbox
   * - ``Delete(ctx)``
     - ``context.Context``
     - ``error``
     - 删除 Sandbox，清理资源

**状态要求**：

- ``Start()``: 当前状态必须为 ``Ready`` 或 ``Running``
- ``Stop()``: 任何状态（幂等）
- ``Delete()``: 当前状态必须为 ``Ready``/``Paused``/``Stopped``

容器管理方法
^^^^^^^^^^^^

.. list-table::
   :widths: 30 25 15 30
   :header-rows: 1

   * - 方法
     - 参数
     - 返回
     - 说明
   * - ``CreateContainer(ctx, config)``
     - ``context.Context, ContainerConfig``
     - ``(ContainerTraits, error)``
     - 创建新容器
   * - ``DeleteContainer(ctx, id)``
     - ``context.Context, string``
     - ``(ContainerTraits, error)``
     - 删除指定容器
   * - ``StartContainer(ctx, id)``
     - ``context.Context, string``
     - ``(ContainerTraits, error)``
     - 启动指定容器
   * - ``StopContainer(ctx, id, force)``
     - ``context.Context, string, bool``
     - ``(ContainerTraits, error)``
     - 停止指定容器
   * - ``KillContainer(ctx, id)``
     - ``context.Context, string``
     - ``(ContainerTraits, error)``
     - 强制终止容器
   * - ``StatusContainer(id)``
     - ``string``
     - ``(ContainerStatus, error)``
     - 获取容器状态
   * - ``StatsContainer(ctx, id)``
     - ``context.Context, string``
     - ``(ContainerStats, error)``
     - 获取容器统计信息

资源更新方法
^^^^^^^^^^^^

.. list-table::
   :widths: 30 30 15 25
   :header-rows: 1

   * - 方法
     - 参数
     - 返回
     - 说明
   * - ``UpdateContainer(ctx, id, resources)``
     - ``context.Context, string, LinuxResources``
     - ``error``
     - 更新容器资源限制

**注意**：如果 ``StaticResourceMgmt`` 为 true，此操作将被忽略。

IO 和控制方法
^^^^^^^^^^^^^

.. list-table::
   :widths: 30 35 15 20
   :header-rows: 1

   * - 方法
     - 参数
     - 返回
     - 说明
   * - ``IOStream(containerID, taskID)``
     - ``string, string``
     - ``(WriteCloser, Reader, Reader, error)``
     - 获取 stdin, stdout, stderr
   * - ``WaitContainerExit(ctx, id)``
     - ``context.Context, string``
     - ``(int32, error)``
     - 等待容器退出
   * - ``WinResize(ctx, containerID, height, width)``
     - ``context.Context, string, uint32, uint32``
     - ``error``
     - 调整终端窗口大小
   * - ``OpenTTYs(ctx, containerID)``
     - ``context.Context, string``
     - ``(*os.File, *os.File, error)``
     - 打开新的 TTY 句柄
   * - ``PauseContainer(ctx, id)``
     - ``context.Context, string``
     - ``error``
     - 暂停容器
   * - ``ResumeContainer(ctx, id)``
     - ``context.Context, string``
     - ``error``
     - 恢复容器

Container 层 API
================

ContainerTraits 接口
--------------------

``ContainerTraits`` 是单个容器的接口，位于 ``pkg/micantainer/interfaces.go``。

.. list-table::
   :widths: 30 25 45
   :header-rows: 1

   * - 方法
     - 返回类型
     - 说明
   * - ``ID()``
     - ``string``
     - 容器 ID
   * - ``GetPid()``
     - ``int``
     - 容器 PID（RTOS 可能是虚拟值）
   * - ``Sandbox()``
     - ``SandboxTraits``
     - 所属 Sandbox
   * - ``GetAnnotations()``
     - ``map[string]string``
     - 容器注解
   * - ``Status()``
     - ``StateString``
     - 容器状态
   * - ``State()``
     - ``*ContainerState``
     - 容器详细状态
   * - ``GetMemoryLimit()``
     - ``uint64``
     - 内存限制（字节）
   * - ``GetClientCPU()``
     - ``string``
     - CPU 亲和性配置
   * - ``SaveState()``
     - ``error``
     - 保存容器状态
   * - ``Signal(ctx, signal)``
     - ``error``
     - 发送信号到容器

Pedestal 层 API
===============

Pedestal 接口
-------------

``Pedestal`` 是 Hypervisor 的抽象接口，位于 ``pkg/pedestal/interface.go``。

核心方法
^^^^^^^^

.. list-table::
   :widths: 25 25 50
   :header-rows: 1

   * - 方法
     - 返回类型
     - 说明
   * - ``Type()``
     - ``PedType``
     - 返回 Hypervisor 类型（Xen, Baremetal）
   * - ``String()``
     - ``string``
     - 返回字符串表示
   * - ``GeneratePedConf()``
     - ``string``
     - 生成 Hypervisor 配置路径

主机资源查询
^^^^^^^^^^^^

.. list-table::
   :widths: 30 40 30
   :header-rows: 1

   * - 方法
     - 返回类型
     - 说明
   * - ``MaxCPUNum()``
     - ``uint32``
     - 最大 CPU 数量
   * - ``MemoryMB()``
     - ``(free, total uint32)``
     - 可用和总内存（MiB）
   * - ``MemLowThreshold()``
     - ``uint32``
     - 内存低阈值
   * - ``MemHighThreshold()``
     - ``uint32``
     - 内存高阈值
   * - ``HostCPUSeta()``
     - ``CPUSet``
     - 主机 CPU 集合

可选扩展接口
------------

CPUScheduler
^^^^^^^^^^^^

CPU 调度操作（可选）：

.. list-table::
   :widths: 35 25 15 25
   :header-rows: 1

   * - 方法
     - 参数
     - 返回
     - 说明
   * - ``SetCPUAffinity(clientID, cpus)``
     - ``string, CPUSet``
     - ``error``
     - 设置 CPU 亲和性
   * - ``SetCPUWeight(clientID, weight)``
     - ``string, uint32``
     - ``error``
     - 设置 CPU 调度权重
   * - ``SetCPUCapacity(clientID, capacity)``
     - ``string, uint32``
     - ``error``
     - 设置 CPU 容量上限

LifecycleManager
^^^^^^^^^^^^^^^^

生命周期管理（可选）：

.. list-table::
   :widths: 25 20 15 40
   :header-rows: 1

   * - 方法
     - 参数
     - 返回
     - 说明
   * - ``Pause(clientID)``
     - ``string``
     - ``error``
     - 暂停客户端
   * - ``Resume(clientID)``
     - ``string``
     - ``error``
     - 恢复客户端

StateQuerier
^^^^^^^^^^^^

状态查询（可选）：

.. list-table::
   :widths: 30 20 20 30
   :header-rows: 1

   * - 方法
     - 参数
     - 返回
     - 说明
   * - ``ClientState(clientID)``
     - ``string``
     - ``(string, error)``
     - 获取客户端状态

MemoryManager
^^^^^^^^^^^^^

内存管理（可选）：

.. list-table::
   :widths: 25 25 15 35
   :header-rows: 1

   * - 方法
     - 参数
     - 返回
     - 说明
   * - ``SetMemory(clientID, memMB)``
     - ``string, uint32``
     - ``error``
     - 设置内存
   * - ``SetMaxMemory(clientID, memMB)``
     - ``string, uint32``
     - ``error``
     - 设置最大内存

IO 层 API
=========

Session
-------

``Session`` 管理 IO 会话，位于 ``pkg/io/session.go``。

构造函数
^^^^^^^^

.. list-table::
   :widths: 30 25 20 25
   :header-rows: 1

   * - 函数
     - 参数
     - 返回
     - 说明
   * - ``NewSession(config)``
     - ``Config``
     - ``(*Session, error)``
     - 创建新会话

实例方法
^^^^^^^^

.. list-table::
   :widths: 25 15 15 45
   :header-rows: 1

   * - 方法
     - 参数
     - 返回
     - 说明
   * - ``Start()``
     - -
     - ``error``
     - 创建 FIFO，启动 Copier
   * - ``Stop()``
     - -
     - -
     - 停止 Copier，关闭 FIFO
   * - ``Restart()``
     - -
     - ``error``
     - 平滑切换到新 FIFO（支持 attach）
   * - ``GetCopier()``
     - -
     - ``*Copier``
     - 获取 Copier（设置回调）

辅助函数
^^^^^^^^

.. list-table::
   :widths: 35 25 15 25
   :header-rows: 1

   * - 函数
     - 参数
     - 返回
     - 说明
   * - ``GenerateStandardFIFOPath(ns, id, stream)``
     - ``string, string, string``
     - ``string``
     - 生成标准 FIFO 路径
   * - ``IsValidFIFOPath(path)``
     - ``string``
     - ``bool``
     - 检查是否为有效 FIFO 路径

Config 结构
^^^^^^^^^^^

.. code-block:: go

   type Config struct {
       // 标识
       ContainerID string

       // FIFO 路径（来自 containerd）
       StdinFIFO  string
       StdoutFIFO string
       StderrFIFO string

       // TTY 接口（来自 RPMSG）
       TTYIn  io.WriteCloser  // stdin to TTY
       TTYOut io.Reader       // stdout from TTY
       TTYErr io.Reader       // stderr from TTY (optional)

       // 配置选项
       Terminal       bool
       StdinBufSize   int
       StdoutBufSize  int
       EventBus       *EventBus
       FilterNUL      bool
       ExecMode       bool
       DetachKeys     string  // detach key sequence (e.g., "ctrl-p,ctrl-q")
   }

Copier
------

``Copier`` 负责双向数据复制，位于 ``pkg/io/copier.go``。

构造函数
^^^^^^^^

.. list-table::
   :widths: 25 20 20 35
   :header-rows: 1

   * - 函数
     - 参数
     - 返回
     - 说明
   * - ``NewCopier(config)``
     - ``Config``
     - ``*Copier``
     - 创建新 Copier

实例方法
^^^^^^^^

.. list-table::
   :widths: 30 45 15 10
   :header-rows: 1

   * - 方法
     - 参数
     - 返回
     - 说明
   * - ``SetTTYs(ttyIn, ttyOut, ttyErr)``
     - ``io.WriteCloser, io.Reader, io.Reader``
     - -
     - 设置 TTY 句柄
   * - ``SetStdin(fifo)``
     - ``io.ReadCloser``
     - -
     - 设置 stdin FIFO
   * - ``SetStdout(fifo)``
     - ``io.WriteCloser``
     - -
     - 设置 stdout FIFO
   * - ``SetStderr(fifo)``
     - ``io.WriteCloser``
     - -
     - 设置 stderr FIFO
   * - ``SetStdoutFifoForEcho(stdout)``
     - ``io.WriteCloser``
     - -
     - 设置 stdout FIFO 用于 TTY 模式本地回显
   * - ``Start()``
     - -
     - ``error``
     - 启动数据复制
   * - ``Stop()``
     - -
     - ``error``
     - 停止复制

EventBus
--------

``EventBus`` 提供事件发布/订阅机制，位于 ``pkg/io/events.go``。

事件类型
^^^^^^^^

.. list-table::
   :widths: 30 15 55
   :header-rows: 1

   * - 常量
     - 值
     - 说明
   * - ``ExitCommandDetected``
     - 0
     - 用户输入 "exit" 命令
   * - ``IOError``
     - 1
     - IO 错误
   * - ``TTYReady``
     - 2
     - TTY 准备就绪
   * - ``StdinClosed``
     - 3
     - stdin FIFO 被关闭
   * - ``DetachDetected``
     - 4
     - 用户输入 detach 序列

构造函数
^^^^^^^^

.. list-table::
   :widths: 25 25 20 30
   :header-rows: 1

   * - 函数
     - 参数
     - 返回
     - 说明
   * - ``NewEventBus(ctx)``
     - ``context.Context``
     - ``*EventBus``
     - 创建新 EventBus

实例方法
^^^^^^^^

.. list-table::
   :widths: 25 20 15 40
   :header-rows: 1

   * - 方法
     - 参数
     - 返回
     - 说明
   * - ``Subscribe(eventType)``
     - ``EventType``
     - ``EventSubscriber``
     - 订阅事件类型
   * - ``Publish(event)``
     - ``Event``
     - -
     - 发布事件
   * - ``Close()``
     - -
     - -
     - 关闭 EventBus（无返回值）

Event 结构
^^^^^^^^^^

.. code-block:: go

   type Event struct {
       Type        EventType
       ContainerID string
       Data        interface{}
       Timestamp   time.Time
   }

状态常量
========

Sandbox 状态
------------

.. list-table::
   :widths: 25 20 55
   :header-rows: 1

   * - 常量
     - 值
     - 说明
   * - ``StateCreating``
     - ``"creating"``
     - 创建中
   * - ``StateReady``
     - ``"ready"``
     - 已就绪
   * - ``StateRunning``
     - ``"running"``
     - 运行中
   * - ``StateStopped``
     - ``"stopped"``
     - 已停止
   * - ``StatePaused``
     - ``"paused"``
     - 已暂停

容器状态
--------

容器状态使用以下状态常量：

.. list-table::
   :widths: 25 20 55
   :header-rows: 1

   * - 常量
     - 值
     - 说明
   * - ``StateReady``
     - ``"ready"``
     - 已就绪
   * - ``StateRunning``
     - ``"running"``
     - 运行中
   * - ``StateStopped``
     - ``"stopped"``
     - 已停止
   * - ``StatePaused``
     - ``"paused"``
     - 已暂停
   * - ``StateDown``
     - ``"down"``
     - 已退出

使用示例
========

创建和使用 Sandbox
------------------

.. code-block:: go

   import (
       "context"
       "micrun/pkg/micantainer"
   )

   func example() {
       ctx := context.Background()

       // 创建 Sandbox 配置
       config := micantainer.SandboxConfig{
           ID:       "my-sandbox",
           Hostname: "rtos-host",
           // ... 其他配置
       }

       // 创建 Sandbox
       sandbox, err := micantainer.CreateSandbox(ctx, &config)
       if err != nil {
           // 处理错误
       }

       // 启动 Sandbox
       if err := sandbox.Start(ctx); err != nil {
           // 处理错误
       }

       // 创建容器
       containerConfig := micantainer.ContainerConfig{
           ID:    "my-container",
           // ... 其他配置
       }
       container, err := sandbox.CreateContainer(ctx, containerConfig)
       if err != nil {
           // 处理错误
       }

       // 启动容器
       if _, err := sandbox.StartContainer(ctx, container.ID()); err != nil {
           // 处理错误
       }

       // 获取 IO 流
       stdin, stdout, stderr, err := sandbox.IOStream(container.ID(), "")
       if err != nil {
           // 处理错误
       }

       // 使用 IO 流...

       // 停止 Sandbox
       if err := sandbox.Stop(ctx, false); err != nil {
           // 处理错误
       }

       // 删除 Sandbox
       if err := sandbox.Delete(ctx); err != nil {
           // 处理错误
       }
   }

使用 IO Session
---------------

.. code-block:: go

   import (
       "context"
       "micrun/pkg/io"
   )

   func example() {
       ctx := context.Background()

       // 创建 IO 配置
       config := io.Config{
           ContainerID:  "my-container",
           StdinFIFO:    "/run/containerd/.../stdin",
           StdoutFIFO:   "/run/containerd/.../stdout",
           StderrFIFO:   "/run/containerd/.../stderr",
           TTYIn:        ttyIn,
           TTYOut:       ttyOut,
           TTYErr:       ttyErr,
           Terminal:     true,
           FilterNUL:    true,
       }

       // 创建 Session
       session, err := io.NewSession(config)
       if err != nil {
           // 处理错误
       }

       // 启动 Session
       if err := session.Start(); err != nil {
           // 处理错误
       }

       // 获取 Copier 用于后续操作
       // Copier 提供了 SetTTYs、SetStdin、SetStdout、SetStderr 等方法
       copier := session.GetCopier()
       _ = copier // 通过 EventBus 监听事件来处理 IO 状态变化

       // ... 使用 IO ...

       // 停止 Session
       session.Stop()
   }

使用 EventBus
-------------

.. code-block:: go

   import (
       "context"
       "micrun/pkg/io"
   )

   func example() {
       ctx := context.Background()

       // 创建 EventBus
       eventBus := io.NewEventBus(ctx)

       // 订阅事件
       ch := eventBus.Subscribe(io.StdinClosed)
       go func() {
           for event := range ch {
               // 处理事件
               log.Printf("Event: %v for container %s", event.Type, event.ContainerID)
           }
       }()

       // 发布事件
       eventBus.Publish(io.Event{
           Type:        io.TTYReady,
           ContainerID: "my-container",
       })

       // 关闭 EventBus
       defer eventBus.Close()
   }

相关文档
========

- :doc:`annotations` - 注解配置
- :doc:`resources` - 资源限制映射规则

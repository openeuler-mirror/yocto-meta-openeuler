.. _micrun_intro:

MicRun 简介
############

读者要求
========

在阅读本文档前，建议具备以下基础知识：

**必需知识**：

* 容器技术基础：了解容器、镜像的基本概念
* Linux 系统管理：熟悉命令行操作和系统服务管理
* RTOS 基础：了解实时操作系统(RTOS)的基本概念

**可选知识**：

* Kubernetes：如需使用 K8s 编排功能
* Yocto/OpenEmbedded：如需从源码构建系统
* Xen 虚拟化：如需深入理解底层虚拟化机制

术语表
======

本文档使用以下核心术语：

.. list-table::
   :widths: 30 70
   :header-rows: 1

   * - 术语
     - 说明
   * - **RTOS**
     - Real-Time Operating System，实时操作系统，如 Zephyr、UniProton
   * - **Hypervisor**
     - 虚拟化管理程序，用于在同一硬件上运行多个操作系统，如 Xen
   * - **Shimv2**
     - Containerd shim API v2，容器运行时与容器引擎之间的接口标准
   * - **注解 (Annotation)**
     - Kubernetes/Pod 的元数据字段，用于传递配置信息
   * - **MCS**
     - Mixed Criticality System，混合关键性系统
   * - **边缘节点**
     - 部署在边缘侧的计算节点，运行 RTOS 容器的设备

什么是 MicRun
==============

MicRun 是一个基于 containerd shimv2 的容器运行时，专为 Mica 项目设计，用于在同一 SoC 的不同 CPU 核上运行 RTOS(实时操作系统)。它是 openEuler Embedded 混合关键性系统(MCS)生态的重要组成部分。

核心特性
--------

* **RTOS 容器化**: 将 Zephyr、UniProton 等 RTOS 作为容器运行在异构计算平台上
* **混合部署**: 通过 Xen、Baremetal 等 hypervisor 在不同 CPU 核上运行 RTOS,实现实时与非实时系统共存
* **云原生集成**: 实现 containerd shimv2 API,与 Kubernetes 生态无缝集成
* **资源映射**: 将容器资源限制(CPU、内存)转换为底层 hypervisor 的资源分配
* **镜像分发**: 利用容器镜像仓库管理 RTOS 固件，简化部署流程

技术架构
========

整体架构层次
------------

MicRun 采用 ``transport/shimv2 -> application -> domain -> ports -> adapters`` 的分层结构。``shimv2`` 是 containerd runtime-v2 的语义边界与系统总入口，``application`` 负责把 containerd 请求翻译成 MicRun 内部动作序列，``domain`` 承载容器聚合与输入输出规则，``ports`` 定义跨层稳定接口，``adapters`` 把端口落到外部系统(micad、Xen/pedestal、文件状态、FIFO/TTY)。各层之间通过显式依赖注入协作，``HostProfile``、``ResourcePolicy``、``Dependencies`` 等关键对象在 transport 装配后贯穿创建与恢复链路。

::

    +--------------------------------------------------------------------------------+
    |                            Kubernetes CRI Interface                            |
    +--------------------------------------------------------------------------------+
    |                                        |                                       |
    +----------------------------------------v---------------------------------------+
    |                          Containerd Container Engine                           |
    +--------------------------------------------------------------------------------+
    |                         runtime: io.containerd.mica.v2                         |
    +--------------------------------------------------------------------------------+
    |                                        |  ttrpc                                |
    +----------------------------------------v---------------------------------------+
    |                  Transport Layer    internal/transport/shimv2                  |
    +--------------------------------------------------------------------------------+
    |                         containerd runtime-v2 boundary                         |
    |                                                                                |
    |                 TaskService RPC    one-shot    recovery entry                  |
    |                         event bridge    error mapping                          |
    +--------------------------------------------------------------------------------+
    |                                        |                                       |
    +----------------------------------------v---------------------------------------+
    |                   Application Layer    internal/application                    |
    +--------------------------------------------------------------------------------+
    |                                                                                |
    |  +--------------+    +--------------+    +--------------+    +--------------+  |
    |  |   runtime    |    |     task     |    |  lifecycle   |    |    attach    |  |
    |  |  svc graph   |    | create / del |    |  start/stop  |    |    resize    |  |
    |  | consistency  |    | orchestrate  |    |     wait     |    | stdin close  |  |
    |  +--------------+    +--------------+    +--------------+    +--------------+  |
    |                                                                                |
    |                +----------------------------------------------+                |
    |                |                   recovery                   |                |
    |                |       restore + task registry rebuild        |                |
    |                +----------------------------------------------+                |
    |                                                                                |
    +--------------------------------------------------------------------------------+
    |                                        |                                       |
    +----------------------------------------v---------------------------------------+
    |                        Domain Layer    internal/domain                         |
    +--------------------------------------------------------------------------------+
    |                                                                                |
    |  +----------------------------------+    +----------------------------------+  |
    |  |            container             |    |             console              |  |
    |  |  Sandbox / Container aggregate   |    |         input semantics          |  |
    |  |          state machine           |    |    detach / interrupt / exit     |  |
    |  |             validate             |    |         output normalize         |  |
    |  |          snapshot load           |    |          state machine           |  |
    |  +----------------------------------+    +----------------------------------+  |
    |                                                                                |
    +--------------------------------------------------------------------------------+
    |                                        |                                       |
    +----------------------------------------v---------------------------------------+
    |                         Ports Layer    internal/ports                          |
    +--------------------------------------------------------------------------------+
    |                                                                                |
    |  +----------------------+  +----------------------+  +----------------------+  |
    |  |     GuestControl     |  |      StateStore      |  |     TaskRuntime      |  |
    |  |    GuestExecutor     |  |   IOSessionFactory   |  | create/start/delete  |  |
    |  |  HypervisorControl   |  |      IOManager       |  |  query/wait/signal   |  |
    |  +----------------------+  +----------------------+  +----------------------+  |
    |                                                                                |
    +--------------------------------------------------------------------------------+
    |                                        |  explicit DI                          |
    +----------------------------------------v---------------------------------------+
    |                      Adapters Layer    internal/adapters                       |
    +--------------------------------------------------------------------------------+
    |                                                                                |
    |  +--------------+    +--------------+    +--------------+    +--------------+  |
    |  |    guest/    |    |  hypervisor  |    | state / file |    |    config    |  |
    |  |   libmica    |    |   pedestal   |    |  authority   |    | oci / stack  |  |
    |  | micad proto  |    |   Xen / bm   |    | /run/micrun  |    |   overlay    |  |
    |  +--------------+    +--------------+    +--------------+    +--------------+  |
    |                                                                                |
    |                +----------------------------------------------+                |
    |                |                      io                      |                |
    |                |   FIFO / TTY / copier / epoll / event bus    |                |
    |                +----------------------------------------------+                |
    |                                                                                |
    +--------------------------------------------------------------------------------+
    |                                        |                                       |
    +----------------------------------------v---------------------------------------+
    |                            micad + Xen / Baremetal                             |
    +--------------------------------------------------------------------------------+
    |                        MICA daemon  +  Hypervisor base                         |
    +--------------------------------------------------------------------------------+
    |                                        |  RPMSG TTY / lifecycle events         |
    +----------------------------------------v---------------------------------------+
    |                                   RTOS Layer                                   |
    +--------------------------------------------------------------------------------+
    |                                                                                |
    |  +----------------------------------+    +----------------------------------+  |
    |  |              Zephyr              |    |            UniProton             |  |
    |  |              - App               |    |              - App               |  |
    |  |             - Shell              |    |             - Shell              |  |
    |  +----------------------------------+    +----------------------------------+  |
    |                                                                                |
    +--------------------------------------------------------------------------------+

核心设计原则
------------

.. list-table::
   :widths: 25 75
   :header-rows: 1

   * - 原则
     - 说明
   * - **分层隔离**
     - ``transport/application/domain/ports/adapters`` 各司其职，``application`` 只编排用例，不直接操作文件、TTY、micad socket 或 Xen 命令
   * - **显式依赖注入**
     - ``HostProfile``、``ResourcePolicy``、``Dependencies`` 从 transport 装配后显式注入创建与恢复链路，``newSandbox`` 要求非空依赖
   * - **StateStore 权威状态源**
     - 运行时快照统一写入 ``/run/micrun/runtime/.../runtime.json``，作为容器状态与恢复的权威数据源
   * - **端口隔离外部依赖**
     - ``ports`` 接口(GuestControl / HypervisorControl / StateStore / IOSessionFactory / TaskRuntime 等)隔离 ``application`` 与 ``libmica``、``pedestal``、``state/file``、``io`` 等具体实现
   * - **1:1:1 模型**
     - 一个 shim 实例管理一个容器，运行一个 RTOS 实例
   * - **资源映射**
     - 将 Kubernetes/containerd 的资源限制(cgroup)通过 ``HostProfile``/``ResourcePolicy`` 转换为 hypervisor 的资源分配配置
   * - **配置解析顺序可文档化**
     - ``RuntimeConfig`` 解析顺序: 显式传入 > 注解 sandbox config path > CRI ConfigPath > ``MICRUN_CONF_FILE`` > ``MICRUN_CONF_DIR`` 等自动发现 > 注解 overlay

与 MICA 的关系
==============

MicRun 是 MICA(Mixed Criticality System,混合关键性系统)框架的容器运行时层。

**MicRun 的职责**：

.. list-table::
   :widths: 30 70
   :header-rows: 1

   * - 功能
     - 说明
   * - **生命周期管理**
     - RTOS 容器的创建、启动、停止、销毁
   * - **资源调度**
     - 将 Kubernetes 资源请求映射到 hypervisor 配置
   * - **IO 处理**
     - 终端、日志、信号等 IO 流的转发
   * - **网络集成**
     - 与 CNI 插件配合，实现容器网络管理

**MICA 框架的其他组件**：

.. list-table::
   :widths: 30 70
   :header-rows: 1

   * - 组件
     - 职责
   * - **micad**
     - MCS 特性的守护进程，负责 RTOS 的整体管理和监控
   * - **Xen**
     - 作为 MCS 底座的虚拟化层，提供硬件虚拟化支持
   * - **mica-image-builder**
     - RTOS 镜像构建工具，将固件打包为容器镜像

技术栈
======

* **语言**: Go 1.22+ (静态链接，无 CGO)
* **容器运行时接口**: containerd shimv2 API
* **通信协议**: ttrpc (轻量 RPC)
* **pedestal 支持**:

  - Xen (完整功能，支持自动检测)
  - Baremetal (基础功能，需显式启用)

* **RTOS 支持**: Zephyr、UniProton（端到端验证记录目前为 UniProton；
  Zephyr 固件需经 meta-zephyr layer 自行构建，测试入口已就绪）
* **OCI 规范**: 遵循 OCI runtime-spec
* **构建系统**: Yocto(openEuler yocto 工程集成相关组件进入镜像)

.. note::

   **Hypervisor 检测说明**:

   - **自动检测**: 仅 Xen hypervisor 支持自动检测（通过检查 ``/proc/xen/xenbus``）
   - **Baremetal**: 不会自动探测；需要在宿主环境显式设置环境变量 ``MICRUN_ENABLE_BAREMETAL=1``，同时通过注解 ``org.openeuler.micrun.ped.pedestal: "baremetal"`` 指定

使用场景
========

* **工业控制**: 实时控制任务容器化部署
* **车载系统**: 混合关键性车载软件管理
* **边缘 AI**: AI 推理与实时控制任务共存
* **物联网网关**: 多协议适配与实时数据处理

项目状态
========

当前处于 Preview 阶段，支持 Xen 为主要 hypervisor,已实现基本容器生命周期管理。

下一步
======

* :doc:`quick-start` - 快速入门指南，了解如何部署 MicRun 并运行第一个 RTOS 容器
* :doc:`kubernetes/index` - Kubernetes 集成指南，实现云边协同部署
* :doc:`reference/index` - 配置和注解参考文档



推理服务概述
============

.. raw:: html

   <details>

相关源文件

以下文件用作生成此 wiki 页面的上下文：

-  `README.en.md <README.en.md>`__
-  `README.md <README.md>`__
-  `docs/architecture.md <docs/architecture.md>`__
-  `/image/architecture.png </image/architecture.png>`__
-  `docs/roadmap.md <docs/roadmap.md>`__
-  `scripts/build.sh <scripts/build.sh>`__
-  `src/README.md <src/README.md>`__
-  `src/action_dispatch/README.en.md <src/action_dispatch/README.en.md>`__
-  `src/action_dispatch/README.md <src/action_dispatch/README.md>`__
-  `src/action_dispatch/action_dispatch/action_dispatcher_node.py <src/action_dispatch/action_dispatch/action_dispatcher_node.py>`__
-  `src/dataset_tools/dataset_tools/bag_to_lerobot.py <src/dataset_tools/dataset_tools/bag_to_lerobot.py>`__
-  `src/dataset_tools/dataset_tools/episode_recorder.py <src/dataset_tools/dataset_tools/episode_recorder.py>`__
-  `src/inference_service/README.en.md <src/inference_service/README.en.md>`__
-  `src/inference_service/README.md <src/inference_service/README.md>`__
-  `src/inference_service/inference_service/lerobot_policy_node.py <src/inference_service/inference_service/lerobot_policy_node.py>`__
-  `src/robot_config/launch/robot.launch.py <src/robot_config/launch/robot.launch.py>`__
-  `src/robot_config/robot_config/config.py <src/robot_config/robot_config/config.py>`__
-  `src/robot_config/robot_config/contract_builder.py <src/robot_config/robot_config/contract_builder.py>`__
-  `src/robot_config/robot_config/contract_utils.py <src/robot_config/robot_config/contract_utils.py>`__
-  `src/robot_config/robot_config/launch_builders/execution.py <src/robot_config/robot_config/launch_builders/execution.py>`__
-  `src/robot_config/robot_config/launch_builders/recording.py <src/robot_config/robot_config/launch_builders/recording.py>`__

.. raw:: html

   </details>

推理服务是 IB-Robot 的 AI 执行子系统，负责加载 LeRobot 策略模型并将实时传感器观测转换为机器人动作。它实现了契约驱动架构，通过与数据集转换流水线相同的数据处理逻辑，确保训练-部署的一致性。

关于训练数据准备，请参阅 `数据集转换 (bag_to_lerobot) <#9.3>`__。关于动作执行和时间平滑，请参阅 `动作分发 <#8>`__。

**来源**：`src/inference_service/README.en.md:1-27 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/README.en.md#L1-L27>`__,
`README.md:33-35 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L33-L35>`__

--------------

系统目的与范围
--------------

推理服务包（``inference_service``）连接训练好的 LeRobot 策略与实时机器人控制。其核心职责包括：

1. **模型加载**：加载 ACT、Diffusion Policy、VLA 及其他 LeRobot 兼容的检查点文件
2. **观测处理**：使用契约定义的转换规则，将 ROS 2 传感器流（相机、关节状态）转换为模型就绪的张量
3. **GPU 推理**：以最小延迟执行策略前向传播
4. **动作生成**：将输出张量转换为 ``action_dispatch`` 可执行的动作命令
5. **部署灵活性**：支持单机（零拷贝）和分布式（边-云）执行

该流水线**不**处理动作执行、时间平滑或电机控制——这些是 `动作分发 <#8>`__ 系统的职责。

**来源**：`src/inference_service/README.en.md:1-13 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/README.en.md#L1-L13>`__,
`src/inference_service/inference_service/lerobot_policy_node.py:1-34 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/lerobot_policy_node.py#L1-L34>`__

--------------

三组件架构
----------

推理服务遵循严格的关注点分离设计，将 AI 执行工作流分解为三个独立、可组合的组件：

组件图
~~~~~~

.. mermaid::

   graph TB
       subgraph "Core Components (inference_service.core)"
           Preprocessor["TensorPreprocessor<br/>(CPU)"]
           Engine["PureInferenceEngine<br/>(GPU)"]
           Postprocessor["TensorPostprocessor<br/>(CPU)"]
       end
       
       subgraph "ROS Integration Layer"
           PolicyNode["LeRobotPolicyNode"]
           Coordinator["InferenceCoordinator"]
       end
       
       subgraph "External Systems"
           Contract["robot_config.yaml<br/>(Contract)"]
           Dispatch["action_dispatcher_node"]
           Sensors["ROS Sensors<br/>(cameras, joint_states)"]
       end
       
       Contract --> PolicyNode
       Sensors --> PolicyNode
       PolicyNode --> Coordinator
       Coordinator --> Preprocessor
       Preprocessor --> Engine
       Engine --> Postprocessor
       Postprocessor --> PolicyNode
       PolicyNode --> Dispatch

**来源**：`src/inference_service/README.en.md:8-13 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/README.en.md#L8-L13>`__,
`src/inference_service/inference_service/lerobot_policy_node.py:69-77 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/lerobot_policy_node.py#L69-L77>`__

TensorPreprocessor
~~~~~~~~~~~~~~~~~~

将原始 ROS 观测字典转换为模型就绪的 PyTorch 张量。此组件是无状态的，运行在 CPU 上。

**主要职责**：

- 应用契约定义的图像缩放、归一化和编码转换
- 堆叠时间历史（用于需要观测窗口的模型）
- 应用模型 ``config.json`` 中的归一化统计量
- 与训练一致地处理灰度、深度和 RGB 图像编码

**实现**：``inference_service/core/preprocessor.py``

**来源**：
`src/dataset_tools/dataset_tools/bag_to_lerobot.py:9-19 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/dataset_tools/bag_to_lerobot.py#L9-L19>`__,
`src/inference_service/README.en.md:8 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/README.en.md#L8>`__

PureInferenceEngine
~~~~~~~~~~~~~~~~~~~

完全独立于 ROS 的无状态 GPU 执行引擎。它加载策略检查点并执行前向传播。

**主要特性**：

- **零 ROS 依赖**：可在纯 Python 脚本中导入使用
- **设备无关**：自动处理 CPU/CUDA 张量放置
- **策略类型检测**：读取 ``config.json`` 确定块大小、动作维度和策略架构（ACT、Diffusion 等）

**实现**：``inference_service/core/engine.py``

**来源**：`src/inference_service/README.en.md:9 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/README.en.md#L9>`__,
`src/inference_service/inference_service/lerobot_policy_node.py:69-74 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/lerobot_policy_node.py#L69-L74>`__

TensorPostprocessor
~~~~~~~~~~~~~~~~~~~

使用模型的归一化统计量，将输出动作张量反归一化为物理关节位置/速度。

**主要职责**：

- 应用逆归一化：``action_physical = action_normalized * std + mean``
- 根据契约动作规范验证输出张量形状
- 如已配置，将值钳位到安全范围

**实现**：``inference_service/core/postprocessor.py``

**来源**：`src/inference_service/README.en.md:10 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/README.en.md#L10>`__,
`src/inference_service/inference_service/lerobot_policy_node.py:76 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/lerobot_policy_node.py#L76>`__

--------------

执行模式
--------

推理服务支持两种部署架构，可通过 ``robot_config.yaml`` 中的 ``execution_mode`` 参数选择。两种模式向下游系统暴露**相同**的 ``DispatchInfer`` Action 接口。

模式对比表
~~~~~~~~~~


.. list-table::
   :header-rows: 1

   * - 方面
     - 单体模式
     - 分布式模式
   * - **目标硬件**
     - 配备板载高性能 GPU 的机器人
     - 轻量级机器人 （仅 CPU 的边缘设备）
   * - **组件位置**
     - 所有三个组件 在同一进程中
     - Preprocessor+Postprocessor 在边缘端，Engine 在云端
   * - **张量传递**
     - 零拷贝（进程内引用）
     - 通过 ROS 2 话题序列化
   * - **延迟**
     - 最小（总计约 10-50ms）
     - 较高（由于网络， 约 50-200ms）
   * - **配置**
     - ``execution _mode: "monolithic"``
     - ``execu tion_mode: "distributed"``
   * - **需要云端节点**
     - 否
     - 是 （``pure_inference_node``）

**来源**：`src/inference_service/README.en.md:14-48 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/README.en.md#L14-L48>`__,
`README.md:15-16 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L15-L16>`__

单体模式（单进程零拷贝）
~~~~~~~~~~~~~~~~~~~~~~~~

在单体模式下，``LeRobotPolicyNode`` 实例化一个 ``InferenceCoordinator``，在单个进程中串联所有三个组件。

.. mermaid::

   graph TB
       subgraph "lerobot_policy_node Process"
           ActionServer["DispatchInfer<br/>Action Server"]
           Coord["InferenceCoordinator"]
           Pre["TensorPreprocessor"]
           Eng["PureInferenceEngine"]
           Post["TensorPostprocessor"]
           
           ActionServer -->|"obs_frame dict"| Coord
           Coord -->|"zero-copy"| Pre
           Pre -->|"batch tensor"| Eng
           Eng -->|"action tensor"| Post
           Post -->|"denormalized"| Coord
           Coord -->|"VariantsList"| ActionServer
       end
       
       Dispatch["action_dispatcher_node"] -->|"Goal"| ActionServer
       ActionServer -->|"Result"| Dispatch

**关键代码流程**：

1. ``LeRobotPolicyNode._dispatch_infer_callback()`` 接收 ``DispatchInfer.Goal`` `lerobot_policy_node.py:422-457 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/lerobot_policy_node.py#L422-L457>`__
2. 调用 ``self._execute_monolithic(obs_frame)`` `lerobot_policy_node.py:491-493 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/lerobot_policy_node.py#L491-L493>`__
3. 委托给 ``self._coordinator(obs_frame)``（一个 ``InferenceCoordinator`` 实例）`lerobot_policy_node.py:291-299 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/lerobot_policy_node.py#L291-L299>`__
4. 协调器串联：``preprocessor(obs) → engine(batch) → postprocessor(action)`` `inference_service/core/init.py <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/inference_service/core/init.py>`__
5. 返回包含动作张量和延迟指标的 ``CoordinatorResult``

**来源**：`src/inference_service/README.en.md:18-24 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/README.en.md#L18-L24>`__,
`src/inference_service/inference_service/lerobot_policy_node.py:285-299 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/lerobot_policy_node.py#L285-L299>`__,
`src/inference_service/inference_service/lerobot_policy_node.py:491-493 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/lerobot_policy_node.py#L491-L493>`__

分布式模式（设备-边缘-云端）
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

在分布式模式下，``LeRobotPolicyNode`` 在机器人（边缘端）充当**异步代理**，而单独的 ``pure_inference_node`` 运行在云端 GPU 服务器上。

.. mermaid::

   graph TB
       subgraph "Edge Device (Robot CPU)"
           EdgeNode["lerobot_policy_node<br/>(Asynchronous Proxy)"]
           EdgePre["TensorPreprocessor"]
           EdgePost["TensorPostprocessor"]
           
           EdgeNode --> EdgePre
           EdgePost --> EdgeNode
       end
       
       subgraph "Cloud Server (GPU)"
           CloudNode["pure_inference_node"]
           CloudEngine["PureInferenceEngine"]
           
           CloudNode --> CloudEngine
           CloudEngine --> CloudNode
       end
       
       Dispatch["action_dispatcher_node"] -->|"DispatchInfer Goal"| EdgeNode
       EdgeNode -->|"Result"| Dispatch
       
       EdgePre -->|"/preprocessed/batch<br/>(VariantsList)"| CloudNode
       CloudNode -->|"/inference/action<br/>(VariantsList)"| EdgePost

**分布式执行流程**：

1. 边缘节点接收 ``DispatchInfer.Goal`` `lerobot_policy_node.py:422-457 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/lerobot_policy_node.py#L422-L457>`__
2. 调用 ``self._execute_distributed(obs_frame, inference_id)`` `lerobot_policy_node.py:495-554 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/lerobot_policy_node.py#L495-L554>`__
3. 预处理器本地运行：``batch = self._preprocessor(obs_frame)`` `lerobot_policy_node.py:511-513 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/lerobot_policy_node.py#L511-L513>`__
4. 边缘节点将批次发布到 ``/preprocessed/batch``，带有唯一的 ``request_id`` `lerobot_policy_node.py:516-524 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/lerobot_policy_node.py#L516-L524>`__
5. 边缘节点**阻塞在 threading.Event** 上等待云端响应 `lerobot_policy_node.py:526-530 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/lerobot_policy_node.py#L526-L530>`__
6. 云端节点（``pure_inference_node``）接收批次，运行推理，发布到 ``/inference/action``
7. 边缘节点的 ``_cloud_result_callback()`` 接收结果，按 ``request_id`` 匹配，设置 Event `lerobot_policy_node.py:556-584 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/lerobot_policy_node.py#L556-L584>`__
8. 边缘后处理器运行：``action = self._postprocessor(cloud_result["action"])`` `lerobot_policy_node.py:540-542 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/lerobot_policy_node.py#L540-L542>`__
9. 返回 ``CoordinatorResult`` 给 action server

**关键架构说明**：边缘节点的 action 回调在等待云端时**挂起其线程**。这是有意为之——它允许 action server 自然地序列化推理请求，防止多个并发云端调用。

**来源**：`src/inference_service/README.en.md:25-48 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/README.en.md#L25-L48>`__,
`src/inference_service/inference_service/lerobot_policy_node.py:306-351 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/lerobot_policy_node.py#L306-L351>`__,
`src/inference_service/inference_service/lerobot_policy_node.py:495-554 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/lerobot_policy_node.py#L495-L554>`__

--------------

契约驱动的观测过滤
------------------

IB-Robot 的一个关键架构原则是，``robot_config.yaml`` 作为所有硬件能力的**唯一事实来源**，而各个模型定义其特定的观测需求。推理服务协调这两个来源。

观测过滤逻辑
~~~~~~~~~~~~

.. mermaid::

   graph TB
       subgraph "robot_config.yaml"
           AllObs["contract.observations:<br/>- images.top<br/>- images.wrist<br/>- images.front<br/>- observation.state"]
       end
       
       subgraph "Model config.json"
           ModelInputs["input_features:<br/>- images.top<br/>- observation.state"]
       end
       
       subgraph "lerobot_policy_node"
           Filter["Observation Filter"]
           Subs["ROS Subscriptions"]
       end
       
       AllObs --> Filter
       ModelInputs --> Filter
       Filter -->|"Required only"| Subs
       
       Subs -->|"Subscribe to:<br/>/camera/top/image_raw<br/>/joint_states"| Topics["ROS Topics"]

**实现**：`lerobot_policy_node.py:156-159 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/lerobot_policy_node.py#L156-L159>`__ 加载模型的 ``config.json`` 提取 ``input_features``，然后 `lerobot_policy_node.py:205-230 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/lerobot_policy_node.py#L205-L230>`__ 过滤契约观测：

.. code:: python

   # Filter by model's required inputs
   if self._required_inputs:
       self._obs_specs = [
           s for s in all_obs_specs 
           if s.key in self._required_inputs
       ]

此设计允许：

- **单一 robot_config.yaml** 支持具有不同观测需求的多个模型
- **无需手动配置话题** 每个模型
- **自动错误检测** 如果模型需要机器人未提供的观测

**来源**：
`src/inference_service/inference_service/lerobot_policy_node.py:180-203 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/lerobot_policy_node.py#L180-L203>`__,
`src/inference_service/inference_service/lerobot_policy_node.py:205-240 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/lerobot_policy_node.py#L205-L240>`__

--------------

ROS 接口规范
------------

推理服务向动作分发器暴露一个**稳定的 Action 接口**。此接口在单体模式和分布式模式下完全相同。

DispatchInfer Action 接口
~~~~~~~~~~~~~~~~~~~~~~~~~

**Action 定义**：``ibrobot_msgs/action/DispatchInfer``

**Goal 字段**：

::

   builtin_interfaces/Time obs_timestamp    # 采样观测的时间戳
   string inference_id                      # 可选的请求标识符

**Result 字段**：

::

   VariantsList action_chunk                # 序列化的动作张量
   int32 chunk_size                         # 块中的动作数量
   bool success                             # 推理是否成功
   string message                           # 失败时的错误消息
   float64 inference_latency_ms             # 总延迟（毫秒）

**Feedback**：未使用（推理通常太快，无法提供有意义的进度更新）

**来源**：`src/action_dispatch/README.en.md:344-351 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/README.en.md#L344-L351>`__,
`src/inference_service/inference_service/lerobot_policy_node.py:56 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/lerobot_policy_node.py#L56>`__

与动作分发器的通信流程
~~~~~~~~~~~~~~~~~~~~~~

.. mermaid::

   sequenceDiagram
       participant Dispatch as action_dispatcher_node
       participant Policy as lerobot_policy_node
       participant Smoother as TemporalSmoother
       
       Note over Dispatch: Queue length < watermark (20)
       Dispatch->>Policy: DispatchInfer.Goal<br/>(obs_timestamp)
       activate Policy
       Policy->>Policy: Sample obs_frame at timestamp
       Policy->>Policy: Execute inference<br/>(monolithic or distributed)
       Policy-->>Dispatch: DispatchInfer.Result<br/>(action_chunk, chunk_size)
       deactivate Policy
       Dispatch->>Smoother: Update plan with new chunk
       Smoother->>Smoother: Apply temporal smoothing
       Note over Dispatch: Pop actions at 100Hz

**关键时间戳**：

- ``obs_timestamp``：用于从 ``StreamBuffer`` 实例采样观测 `lerobot_policy_node.py:399-420 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/lerobot_policy_node.py#L399-L420>`__
- 确保时间一致性，即使推理耗时不同

**来源**：`src/action_dispatch/README.en.md:79-130 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/README.en.md#L79-L130>`__,
`src/inference_service/inference_service/lerobot_policy_node.py:422-489 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/lerobot_policy_node.py#L422-L489>`__

--------------

观测采样与 StreamBuffer
-----------------------

推理节点使用来自 ``robot_config.contract_utils`` 的 ``StreamBuffer`` 实例维护最近传感器观测的**滑动窗口**。这允许在动作分发器请求的精确时间戳处采样观测。

StreamBuffer 架构
~~~~~~~~~~~~~~~~~

.. mermaid::

   graph TB
       subgraph "Per-Observation StreamBuffer"
           Buffer["Circular Buffer<br/>(recent messages)"]
           Policy["Resample Policy<br/>(hold/asof/drop)"]
           Tol["Tolerance (asof_tol_ms)"]
       end
       
       subgraph "Observation Sources"
           Camera["/camera/top/image_raw"]
           Joints["/joint_states"]
       end
       
       Camera -->|"Push with timestamp"| Buffer
       Joints -->|"Push with timestamp"| Buffer
       
       Dispatcher["action_dispatcher_node"] -->|"obs_timestamp_ns"| Sample["sample(timestamp)"]
       Sample --> Policy
       Policy --> Buffer
       Buffer -->|"Interpolated value"| Frame["obs_frame dict"]

**重采样策略**\ （来自契约）：

- ``hold``：返回时间戳前最近的值（零阶保持）
- ``asof``：如果在 ``asof_tol_ms`` 内则返回值，否则返回 None
- ``drop``：仅返回精确匹配，否则返回 None

**实现**：`lerobot_policy_node.py:381-398 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/lerobot_policy_node.py#L381-L398>`__ 处理观测回调，将值推入缓冲区。`lerobot_policy_node.py:399-420 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/lerobot_policy_node.py#L399-L420>`__ 在请求的时间戳从所有缓冲区采样。

**来源**：
`src/robot_config/robot_config/contract_utils.py:74-90 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/contract_utils.py#L74-L90>`__,
`src/inference_service/inference_service/lerobot_policy_node.py:381-420 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/lerobot_policy_node.py#L381-L420>`__

--------------

启动集成
--------

推理服务由 ``robot_config`` 启动系统根据控制模式配置动态启动。

启动参数流程
~~~~~~~~~~~~

.. mermaid::

   graph TB
       subgraph "robot_config.yaml"
           ControlMode["control_modes.model_inference:<br/>  inference.enabled: true<br/>  inference.execution_mode: monolithic<br/>  inference.model: act_policy_1"]
           ModelDef["models.act_policy_1:<br/>  repo_id: /path/to/checkpoint<br/>  device: cuda<br/>  frequency: 10.0"]
       end
       
       subgraph "Launch System"
           LaunchFile["robot.launch.py"]
           ExecBuilder["execution.py<br/>generate_inference_node()"]
       end
       
       subgraph "Generated Nodes"
           PolicyNode["lerobot_policy_node<br/>(parameters from config)"]
       end
       
       ControlMode --> LaunchFile
       ModelDef --> LaunchFile
       LaunchFile --> ExecBuilder
       ExecBuilder --> PolicyNode
       
       PolicyNode -->|"loads"| Contract["robot_config.yaml<br/>(for observations)"]
       PolicyNode -->|"loads"| Checkpoint["Policy checkpoint<br/>(for model config)"]

**关键启动构建函数**：`robot_config/launch_builders/execution.py:20-58 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/robot_config/launch_builders/execution.py#L20-L58>`__ 中的 ``generate_inference_node()``

**自动检测逻辑**：

1. 检查控制模式是否有 ``inference.enabled: true``
2. 从 ``inference.model`` 字段解析模型引用
3. 提取模型配置（repo_id、device、frequency）
4. 生成带有契约路径的节点用于观测过滤
5. 如果 ``execution_mode: distributed``，还在云端启动 ``pure_inference_node``

**来源**：
`src/robot_config/robot_config/launch_builders/execution.py:20-58 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/launch_builders/execution.py#L20-L58>`__,
`src/robot_config/launch/robot.launch.py:183-196 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/launch/robot.launch.py#L183-L196>`__

--------------

健康监控与诊断
--------------

``LeRobotPolicyNode`` 发布周期性健康状态，以支持运行时监控和调试。

发布话题
~~~~~~~~


.. list-table::
   :header-rows: 1

   * - 话题
     - 消息类型
     - 频率
     - 用途
   * - ``~ /health``
     - ``diagnostic_ms gs/DiagnosticStatus``
     - 1 Hz
     - 节点健康状态、 错误消息、 推理计数
   * - ` `/actions /{name}``
     - ``ibrobo t_msgs/VariantsList``
     - 按需
     - 发布动作块 用于调试

**健康状态级别**：

- **OK** (0)：推理正常运行
- **WARN** (1)：超过预期周期 2 倍时间未推理（可能的分发器问题）
- **ERROR** (2)：致命错误（推理失败、超时）

**诊断键值对** `lerobot_policy_node.py:632-638 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/lerobot_policy_node.py#L632-L638>`__：

- ``inference_count``：已完成的推理总数
- ``model_type``：策略类型（act、diffusion 等）
- ``policy_type``：架构变体
- ``chunk_size``：动作块大小
- ``execution_mode``：单体或分布式

**来源**：
`src/inference_service/inference_service/lerobot_policy_node.py:615-640 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/lerobot_policy_node.py#L615-L640>`__

--------------

配置参数
--------

``LeRobotPolicyNode`` 接受以下 ROS 参数，通常通过 ``robot_config.yaml`` 设置：


.. list-table::
   :header-rows: 1

   * - 参数
     - 类型
     - 默认值
     - 描述
   * - ``name``
     - string
     - ``ler obot_policy``
     - 节点名称后缀
   * - ``node_name``
     - string
     - ``lerobot_ policy_node``
     - 完整节点名称
   * - ``model_type``
     - string
     - ``ler obot_policy``
     - 模型类型标识符
   * - ``repo_id``
     - string
     - -
     - **必需**：策略检查点 目录路径
   * - ``checkpoint``
     - string
     - -
     - ``repo_id`` 的替代
   * - ``ro bot_config_path``
     - string
     - -
     - **必需**：用于契约的 robot_config.yaml 路径
   * - ``device``
     - string
     - ``auto``
     - 计算设备 （``auto``、``cpu``、 ``cuda``、``cuda:0``）
   * - ``frequency``
     - float
     - 10.0
     - 预期推理频率（Hz）
   * - `` use_header_time``
     - bool
     - true
     - 使用消息头时间戳 vs. 接收时间
   * - ` `execution_mode``
     - string
     - ` `monolithic``
     - ``monolithic`` 或 ``distributed``
   * - `` request_timeout``
     - float
     - 5.0
     - 分布式云端响应超时 （秒）
   * - ``cloud_ inference_topic``
     - string
     - ``/preproc essed/batch``
     - 分布式模式下发布批次 的话题
   * - ``clo ud_result_topic``
     - string
     - ``/infer ence/action``
     - 接收云端结果的话题

**来源**：
`src/inference_service/inference_service/lerobot_policy_node.py:88-103 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/lerobot_policy_node.py#L88-L103>`__,
`src/inference_service/inference_service/lerobot_policy_node.py:648-669 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/lerobot_policy_node.py#L648-L669>`__

--------------

总结
----

推理服务是一个契约驱动、执行模式无关的 AI 运行时，具有以下特点：

1. **过滤观测**：根据全局契约中的模型需求过滤观测
2. **采样时间戳数据**：使用 StreamBuffer 确保时间一致性
3. **支持双重部署**：板载 GPU 的零拷贝单体模式，轻量级机器人的分布式边-云模式
4. **暴露稳定 Action 接口**：与 action_dispatch 无缝集成
5. **复用数据集转换逻辑**：消除训练-服务偏差

三组件架构（Preprocessor、Engine、Postprocessor）允许相同代码同时服务于研究（纯 Python 脚本）和部署（ROS 2 节点）场景。

**来源**：`src/inference_service/README.en.md:1-48 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/README.en.md#L1-L48>`__,
`README.md:33-40 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L33-L40>`__

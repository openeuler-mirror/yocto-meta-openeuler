单体执行模式
============

.. raw:: html

   <details>

相关源文件

以下文件用于生成此文档页面：

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

本文档介绍 IB-Robot 推理服务的 **单体执行模式**。此模式在单个进程内运行所有推理组件（预处理、推理和后处理），适用于配备板载高性能 GPU 的机器人。

**范围**：本文档涵盖单体模式特有的架构、数据流、配置和实现细节。有关整体推理管道架构和三组件设计，请参阅 `推理架构 <#7.1>`__。有关将计算卸载到云端节点的分布式模式，请参阅 `分布式执行模式 <#7.3>`__。

--------------

概述
----

单体执行模式专为具有足够板载计算资源（如 NVIDIA RTX 4060 或更高）在本地运行整个推理管道的机器人设计。主要特点如下：

================= =====================================================
特性              描述
================= =====================================================
**部署**          单机、单进程执行
**数据流**        通过 Python 引用的零拷贝张量传递
**延迟**          绝对最小延迟（无序列化开销）
**内存**          所有数据保留在进程 RAM/VRAM 中
**用例**          具有板载高性能 GPU 的机器人
**配置**          robot_config YAML 中设置 ``execution_mode: "monolithic"``
================= =====================================================

主要优势是 **零序列化开销**：张量通过引用在预处理器、推理引擎和后处理器之间传递，完全消除了网络和编组成本。

**源码**：`src/inference_service/README.en.md:18-24 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/README.en.md#L18-L24>`__,
`src/inference_service/inference_service/lerobot_policy_node.py:8-13 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/lerobot_policy_node.py#L8-L13>`__

--------------

架构
----

组件组合
~~~~~~~~

在单体模式下，``lerobot_policy_node`` 实例化一个 ``InferenceCoordinator``，在单个进程中将三个核心组件链接在一起：

.. mermaid::

   graph TB
       subgraph "lerobot_policy_node 进程"
           direction TB
           
           ActionServer["ActionServer<br/>DispatchInfer"]
           
           Coordinator["InferenceCoordinator<br/>(coordinator.py)"]
           
           Pre["TensorPreprocessor<br/>(preprocessor.py)"]
           Infer["PureInferenceEngine<br/>(engine.py)"]
           Post["TensorPostprocessor<br/>(postprocessor.py)"]
           
           ActionServer -->|"execute_callback()"| Coordinator
           Coordinator -->|"1. preprocess(obs_frame)"| Pre
           Pre -->|"2. batch (torch.Tensor)<br/>零拷贝"| Infer
           Infer -->|"3. action (torch.Tensor)<br/>零拷贝"| Post
           Post -->|"4. action_np (numpy.ndarray)"| Coordinator
           Coordinator -->|"CoordinatorResult"| ActionServer
       end
       
       subgraph "外部通信"
           Dispatcher["action_dispatcher_node"]
           Sensors["ROS Topics<br/>/joint_states, /camera/*"]
       end
       
       Sensors -.->|"观测数据"| ActionServer
       ActionServer -->|"VariantsList"| Dispatcher

**关键类与函数**：- ``InferenceCoordinator.__call__()``
[inference_service/core/coordinator.py] - 编排三阶段管道 - ``TensorPreprocessor.__call__()`` - 将原始观测转换为归一化张量 - ``PureInferenceEngine.__call__()`` - 执行 GPU 推理 - ``TensorPostprocessor.__call__()`` - 将动作张量反归一化为物理命令

**源码**：
`src/inference_service/inference_service/lerobot_policy_node.py:285-304 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/lerobot_policy_node.py#L285-L304>`__,
`src/inference_service/README.en.md:6-13 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/README.en.md#L6-L13>`__

--------------

零拷贝数据流
------------

单体模式通过 **零拷贝张量传递** 实现最小延迟。所有张量在整个管道中保持为 GPU 内存中的 PyTorch 对象：

.. mermaid::

   sequenceDiagram
       participant AD as action_dispatcher_node
       participant AS as ActionServer<br/>(DispatchInfer)
       participant EC as _execute_monolithic()
       participant IC as InferenceCoordinator
       participant Pre as TensorPreprocessor
       participant Eng as PureInferenceEngine
       participant Post as TensorPostprocessor
       
       AD->>AS: DispatchInfer.Goal<br/>(obs_timestamp)
       AS->>EC: _dispatch_infer_callback()
       
       Note over EC: 从 StreamBuffers<br/>采样观测
       EC->>EC: _sample_obs_frame()
       
       EC->>IC: coordinator(obs_frame)
       
       IC->>Pre: preprocess(obs_frame)
       Note over Pre: 将图像/状态归一化<br/>为 torch.Tensor
       Pre-->>IC: batch (Dict[str, Tensor])
       
       IC->>Eng: forward(batch)
       Note over Eng: GPU 推理<br/>同一设备上零拷贝
       Eng-->>IC: action (Tensor)
       
       IC->>Post: postprocess(action)
       Note over Post: 反归一化为<br/>物理关节值
       Post-->>IC: action_np (ndarray)
       
       IC-->>EC: CoordinatorResult
       
       Note over EC: 从 action_np<br/>创建 VariantsList
       EC-->>AS: DispatchInfer.Result
       AS-->>AD: action_chunk

**关键性能细节**：在 ``TensorPreprocessor`` 和 ``PureInferenceEngine`` 之间，张量在同一设备（GPU）上 **通过引用传递**。不发生 ``.cpu()`` 或 ``.to()`` 调用，消除了内存拷贝。

**源码**：
`src/inference_service/inference_service/lerobot_policy_node.py:491-493 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/lerobot_policy_node.py#L491-L493>`__,
`src/inference_service/README.en.md:22-24 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/README.en.md#L22-L24>`__

--------------

与动作分发的集成
----------------

单体模式向 ``action_dispatcher_node`` 呈现 **与分布式模式相同的 Action Server 接口**，确保透明性：

.. mermaid::

   graph LR
       subgraph "action_dispatcher_node"
           Loop["控制循环<br/>(100Hz 定时器)"]
           Client["ActionClient<br/>DispatchInfer"]
           Queue["动作队列"]
       end
       
       subgraph "lerobot_policy_node (单体)"
           Server["ActionServer<br/>~/DispatchInfer"]
           Coord["InferenceCoordinator"]
       end
       
       subgraph "硬件"
           Control["ros2_control"]
       end
       
       Loop -->|"queue < watermark"| Client
       Client -->|"Goal"| Server
       Server -->|"_execute_monolithic()"| Coord
       Coord -->|"Result"| Server
       Server -->|"action_chunk"| Client
       Client -->|"入队"| Queue
       Queue -->|"100Hz pop"| Control

**接口契约**：- **Action**：
``ibrobot_msgs/action/DispatchInfer`` - **Goal 字段**：
``obs_timestamp`` (Time) - **Result 字段**：``action_chunk``
(VariantsList)、``chunk_size`` (int)、``success`` (bool)、
``inference_latency_ms`` (float)

分发器无需知道推理节点是在单体模式还是分布式模式下运行。两种模式返回相同的 ``DispatchInfer.Result`` 结构。

**源码**：
`src/action_dispatch/action_dispatch/action_dispatcher_node.py:205-220 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatch/action_dispatcher_node.py#L205-L220>`__,
`src/inference_service/inference_service/lerobot_policy_node.py:422-489 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/lerobot_policy_node.py#L422-L489>`__

--------------

配置
----

机器人配置 YAML
~~~~~~~~~~~~~~~

单体模式通过 ``execution_mode`` 参数在机器人配置文件中启用：

.. code:: yaml

   # src/robot_config/config/robots/so101_single_arm.yaml
   control_modes:
     model_inference:
       inference:
         enabled: true
         execution_mode: "monolithic"  # 关键参数
         model: so101_act
         request_timeout: 5.0  # 单体模式下未使用，保留以保持一致性

启动参数
~~~~~~~~

``generate_monolithic_inference_node()`` 函数提取配置并构建节点：


.. list-table::
   :header-rows: 1

   * - 参数
     - 类型
     - 描述
     - 来源
   * - ``checkpoint``
     - str
     - 策略检查点路径 (.pt 文件)
     - ``models[mod el_name].path``
   * - ``robo t_config_path``
     - str
     - robot_config YAML 的路径 (契约源)
     - ``robot_config ._config_path``
   * - ``e xecution_mode``
     - str
     - 必须为 "monolithic"
     - ``inference.e xecution_mode``
   * - ``device``
     - str
     - PyTorch 设备 ("auto"、 "cuda"、"cpu")
     - 硬编码 "auto"
   * - ` `use_sim_time``
     - bool
     - ROS 仿真时间标志
     - 启动参数 ``use_sim``

**源码**：
`src/robot_config/robot_config/launch_builders/execution.py:61-127 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/launch_builders/execution.py#L61-L127>`__

--------------

实现细节
--------

节点初始化
~~~~~~~~~~

``lerobot_policy_node`` 单体模式的初始化序列：

.. mermaid::

   graph TB
       Init["__init__()"]
       
       Init --> LoadConfig["_load_policy_config()<br/>从 config.json 提取 input_features"]
       LoadConfig --> LoadContract["_load_contract()<br/>加载 robot_config YAML<br/>根据 input_features 过滤观测"]
       LoadContract --> SetupObs["_setup_observation_subscriptions()<br/>为过滤后的观测创建 StreamBuffers"]
       SetupObs --> CheckMode{"execution_mode?"}
       
       CheckMode -->|"monolithic"| SetupMono["_setup_monolithic_mode()"]
       CheckMode -->|"distributed"| SetupDist["_setup_distributed_mode()"]
       
       SetupMono --> CreateCoord["InferenceCoordinator(policy_path, device)"]
       CreateCoord --> ExtractMeta["从协调器提取<br/>policy_type, chunk_size"]
       ExtractMeta --> SetupAction["_setup_action_server()<br/>创建 DispatchInfer server"]
       
       SetupAction --> Ready["节点就绪"]

**关键代码路径**：
`src/inference_service/inference_service/lerobot_policy_node.py:128-179 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/lerobot_policy_node.py#L128-L179>`__

观测过滤
~~~~~~~~

一个关键优化：节点 **仅订阅模型所需的观测**：

.. code:: python

   # lerobot_policy_node.py:216-227
   all_obs_specs = [s for s in iter_specs(self._contract) if not s.is_action]

   if self._required_inputs:
       self._obs_specs = [
           s for s in all_obs_specs 
           if s.key in self._required_inputs
       ]

这允许单个 ``robot_config.yaml``（包含所有可能的观测）支持具有不同观测需求的多个模型。例如：- **ACT 模型**：需要 ``images.top``、``images.wrist``、``observation.state`` - **Diffusion 模型**：仅需要 ``images.top``、``observation.state``

节点读取模型的 ``config.json`` `line 189-203 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/line 189-203>`__，提取 ``input_features``，并相应过滤订阅。

**源码**：
`src/inference_service/inference_service/lerobot_policy_node.py:180-241 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/lerobot_policy_node.py#L180-L241>`__

推理执行
~~~~~~~~

由于协调器抽象，``_execute_monolithic()`` 函数非常简单：

.. code:: python

   # lerobot_policy_node.py:491-493
   def _execute_monolithic(self, obs_frame: Dict[str, Any]) -> CoordinatorResult:
       """在单体模式下执行推理（零拷贝）。"""
       return self._coordinator(obs_frame)

``obs_frame`` 是从 ``StreamBuffers`` 采样的原始观测字典（图像为 numpy 数组，状态为列表）。协调器处理整个管道并返回 ``CoordinatorResult`` dataclass：

.. code:: python

   @dataclass
   class CoordinatorResult:
       action: torch.Tensor  # 最终动作张量 (chunk_size, action_dim)
       chunk_size: int  # 块中的动作数量
       total_latency_ms: float  # 端到端延迟
       preprocess_latency_ms: float  # 预处理时间
       inference_latency_ms: float  # GPU 前向传播时间
       postprocess_latency_ms: float  # 后处理时间
       policy_type: str  # "ACT"、"Diffusion" 等

**源码**：
`src/inference_service/inference_service/lerobot_policy_node.py:491-493 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/lerobot_policy_node.py#L491-L493>`__

--------------

性能特征
--------

延迟分解
~~~~~~~~

RTX 4060 上 ACT 策略的典型延迟（chunk_size=100）：


.. list-table::
   :header-rows: 1

   * - 阶段
     - 延迟
     - 备注
   * - 预处理
     - ~8-12ms
     - 图像调整大小、归一化、拼接
   * - 推理
     - ~15-25ms
     - GPU 上的模型前向传播
   * - 后处理
     - ~2-5ms
     - 反归一化、裁剪
   * - **总计**
     - **~25-40ms**
     - 组件间通信零开销

内存效率
~~~~~~~~

所有张量在整个管道中驻留在 GPU 上：

::

   观测数据 (CPU)
       ↓ (拷贝到 GPU)
   TensorPreprocessor (GPU)
       ↓ (引用)
   PureInferenceEngine (GPU)
       ↓ (引用)
   TensorPostprocessor (GPU)
       ↓ (拷贝到 CPU 用于 ROS 发布)
   动作输出 (CPU)

仅发生 **两次设备传输**：输入到 GPU 和输出到 CPU。无中间 ``.cpu()`` 调用。

**源码**：`src/inference_service/README.en.md:22-24 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/README.en.md#L22-L24>`__

--------------

与分布式模式比较
----------------


.. list-table::
   :header-rows: 1

   * - 方面
     - 单体
     - 分布式
   * - 进程数
     - 1 (lerobot_policy_node)
     - 2（边缘代理 + 云端 推理）
   * - 网络流量
     - 无
     - 每次推理约 500KB (预处理张量)
   * - 延迟
     - 25-40ms
     - 40-80ms（增加网络 + 序列化）
   * - GPU 位置
     - 板载机器人
     - 远程云端服务器
   * - 硬件要求
     - 板载高端 GPU
     - 低功耗 CPU + LAN 到 GPU 服务器
   * - 复杂度
     - 简单（单节点）
     - 较高（分布式协调）
   * - 故障模式
     - 本地进程崩溃
     - 网络超时、 云端节点故障

**何时使用单体模式**：- 机器人有板载 GPU（RTX 3060 Ti 或更高）- 需要绝对最小延迟（<30ms）- 部署简单性是优先考虑 - 网络可靠性不确定

**何时使用分布式模式**：见 `分布式执行模式 <#7.3>`__

**源码**：`src/inference_service/README.en.md:18-37 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/README.en.md#L18-L37>`__,
`src/inference_service/inference_service/lerobot_policy_node.py:8-27 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/lerobot_policy_node.py#L8-L27>`__

--------------

策略节点
========

.. raw:: html

   <details>

相关源文件

以下文件用于生成此文档页面：

-  `src/action_dispatch/action_dispatch/action_dispatcher_node.py <src/action_dispatch/action_dispatch/action_dispatcher_node.py>`__
-  `src/dataset_tools/dataset_tools/bag_to_lerobot.py <src/dataset_tools/dataset_tools/bag_to_lerobot.py>`__
-  `src/dataset_tools/dataset_tools/episode_recorder.py <src/dataset_tools/dataset_tools/episode_recorder.py>`__
-  `src/inference_service/inference_service/lerobot_policy_node.py <src/inference_service/inference_service/lerobot_policy_node.py>`__
-  `src/inference_service/inference_service/pure_inference_node.py <src/inference_service/inference_service/pure_inference_node.py>`__
-  `src/robot_config/launch/robot.launch.py <src/robot_config/launch/robot.launch.py>`__
-  `src/robot_config/robot_config/config.py <src/robot_config/robot_config/config.py>`__
-  `src/robot_config/robot_config/contract_builder.py <src/robot_config/robot_config/contract_builder.py>`__
-  `src/robot_config/robot_config/contract_utils.py <src/robot_config/robot_config/contract_utils.py>`__
-  `src/robot_config/robot_config/launch_builders/execution.py <src/robot_config/robot_config/launch_builders/execution.py>`__
-  `src/robot_config/robot_config/launch_builders/recording.py <src/robot_config/robot_config/launch_builders/recording.py>`__
-  `src/tensormsg/package.xml <src/tensormsg/package.xml>`__

.. raw:: html

   </details>

本文档介绍负责策略推理的两个 ROS 2 节点：``lerobot_policy_node`` 和 ``pure_inference_node``。这些节点加载训练好的 LeRobot 策略，并根据观测数据生成动作预测。有关整体推理架构和执行模式概念，请参阅 `推理架构 <#7.1>`__。有关预处理/后处理组件，请参阅 `7.1 <#7.1>`__ 和 `7.2 <#7.2>`__ 页面。

--------------

概述
----

IB-Robot 推理系统提供两个策略节点，协同支持 **单体模式**\ （单进程）和 **分布式模式**\ （设备-边缘-云端）执行：


.. list-table::
   :header-rows: 1

   * - 节点
     - 包
     - 可执行文件
     - 用途
   * - **ler obot_poli cy_node**
     - ``infe rence_service``
     - ``le robot_policy_node``
     - 主策略节点。向 ``action_dis patcher_node`` 暴露 DispatchInfer Action Server。 处理观测订阅、 基于契约的过滤 以及协调推理。
   * - **pur e_inferen ce_node**
     - ``infe rence_service``
     - ``pu re_inference_node``
     - 分布式模式的 GPU 推理工作 器。订阅预处理 批次，执行推理， 发布原始动作。 不暴露 Action Server。

**执行模式行为：**

.. mermaid::

   graph TB
       subgraph "单体模式"
           direction TB
           LRPN_MONO[lerobot_policy_node]
           COORD[InferenceCoordinator<br/>Pre → Infer → Post]
           
           LRPN_MONO -->|"owns"| COORD
       end
       
       subgraph "分布式模式"
           direction TB
           LRPN_DIST[lerobot_policy_node<br/>Edge Proxy]
           PIN[pure_inference_node<br/>Cloud GPU]
           
           LRPN_DIST -->|"/preprocessed/batch"| PIN
           PIN -->|"/inference/action"| LRPN_DIST
       end
       
       DISPATCHER[action_dispatcher_node]
       
       DISPATCHER -->|"DispatchInfer<br/>Action Client"| LRPN_MONO
       DISPATCHER -->|"DispatchInfer<br/>Action Client"| LRPN_DIST
       
       style LRPN_MONO fill:#e3f2fd
       style LRPN_DIST fill:#e3f2fd
       style PIN fill:#fff9c4

**核心设计原则：** 两种执行模式都向 ``action_dispatcher_node`` 暴露 **相同的** DispatchInfer Action Server 接口。分布式模式对客户端完全透明——客户端无法区分单体执行和分布式执行。

**源码：**
`src/inference_service/inference_service/lerobot_policy_node.py:1-35 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/lerobot_policy_node.py#L1-L35>`__,
`src/inference_service/inference_service/pure_inference_node.py:1-15 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/pure_inference_node.py#L1-L15>`__

--------------

lerobot_policy_node
-------------------

``lerobot_policy_node`` 是与动作分发管道集成的主要推理节点。它加载策略检查点，订阅机器人契约中定义的观测数据，并生成动作预测。

节点架构
~~~~~~~~

.. mermaid::

   graph TB
       subgraph "LeRobotPolicyNode 类"
           direction TB
           
           INIT["__init__<br/>节点初始化"]
           
           subgraph "配置加载"
               LOAD_POLICY["_load_policy_config()<br/>读取 config.json"]
               LOAD_CONTRACT["_load_contract()<br/>robot_config → Contract"]
               FILTER["根据 input_features<br/>过滤观测"]
           end
           
           subgraph "观测系统"
               SETUP_SUBS["_setup_observation_subscriptions()<br/>创建 ROS 订阅"]
               OBS_CB["_obs_cb(msg, spec)<br/>推送到 StreamBuffer"]
               SAMPLE["_sample_obs_frame(ts)<br/>采样所有缓冲区"]
           end
           
           subgraph "执行模式"
               SETUP_MONO["_setup_monolithic_mode()<br/>InferenceCoordinator"]
               SETUP_DIST["_setup_distributed_mode()<br/>预/后处理器"]
           end
           
           subgraph "Action Server"
               ACTION_SERVER["DispatchInfer Action Server"]
               EXEC_CB["_dispatch_infer_callback()<br/>执行推理"]
               EXEC_MONO["_execute_monolithic(obs)"]
               EXEC_DIST["_execute_distributed(obs)"]
           end
           
           INIT --> LOAD_POLICY
           LOAD_POLICY --> LOAD_CONTRACT
           LOAD_CONTRACT --> FILTER
           FILTER --> SETUP_SUBS
           
           SETUP_SUBS --> OBS_CB
           
           INIT --> SETUP_MONO
           INIT --> SETUP_DIST
           
           INIT --> ACTION_SERVER
           ACTION_SERVER --> EXEC_CB
           EXEC_CB --> SAMPLE
           SAMPLE --> EXEC_MONO
           SAMPLE --> EXEC_DIST
       end
       
       ROBOT_CONFIG[robot_config.yaml]
       MODEL_CONFIG[policy/config.json]
       
       ROBOT_CONFIG -->|"load"| LOAD_CONTRACT
       MODEL_CONFIG -->|"load"| LOAD_POLICY

**源码：**
`src/inference_service/inference_service/lerobot_policy_node.py:105-179 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/lerobot_policy_node.py#L105-L179>`__

初始化与配置
~~~~~~~~~~~~

节点从两个来源加载配置：

1. **策略配置**\ （``config.json``）：定义模型架构和所需的输入特征
2. **机器人配置**\ （YAML）：通过契约定义所有可用的观测

.. code:: python

   # 来自 lerobot_policy_node.py:180-203
   def _load_policy_config(self):
       """加载模型 config.json 以获取所需的 input_features。"""
       config_path = Path(policy_path) / "config.json"
       with open(config_path, "r") as f:
           self._policy_config = json.load(f)
       
       # 提取所需的输入特征
       input_features = self._policy_config.get("input_features", {})
       self._required_inputs = set(input_features.keys())

**观测过滤：** 节点根据模型所需的输入过滤观测。这允许单个 ``robot_config.yaml`` 支持具有不同观测需求的多个模型。

.. code:: python

   # 来自 lerobot_policy_node.py:205-240
   def _load_contract(self, robot_config_path: str):
       # 从契约获取所有观测规格
       all_obs_specs = [s for s in iter_specs(self._contract) if not s.is_action]
       
       # 根据模型所需输入过滤
       if self._required_inputs:
           self._obs_specs = [
               s for s in all_obs_specs 
               if s.key in self._required_inputs
           ]


.. list-table::
   :header-rows: 1

   * - 参数
     - 类型
     - 默认值
     - 描述
   * - ``name``
     - str
     - ``"lero bot_policy"``
     - 策略标识符
   * - ``node_name``
     - str
     - ``"lerobot_p olicy_node"``
     - ROS 节点名
   * - ``model_type``
     - str
     - ``"lero bot_policy"``
     - 模型类型描述符
   * - ``repo_id``
     - str
     - None
     - HuggingFace 仓库 ID （检查点的替代方案）
   * - ``checkpoint``
     - str
     - None
     - 策略检查点的本地路径
   * - ``ro bot_config_path``
     - str
     - None
     - robot_config YAML 的路径（必需）
   * - ``device``
     - str
     - ``"auto"``
     - 推理设备 （``"cpu"``、 ``"cuda"``、 ``"auto"``）
   * - ``frequency``
     - float
     - 10.0
     - 预期推理频率（Hz）
   * - `` use_header_time``
     - bool
     - True
     - 使用消息头时间戳 还是接收时间
   * - ` `execution_mode``
     - str
     - ``" monolithic"``
     - ``"monolithic"`` 或 ``"distributed"``
   * - `` request_timeout``
     - float
     - 5.0
     - 云端推理超时时间 （分布式模式）
   * - ``cloud_ inference_topic``
     - str
     - ``"/preproce ssed/batch"``
     - 边缘到云端通信的主题
   * - ``clo ud_result_topic``
     - str
     - ``"/infere nce/action"``
     - 云端到边缘通信的主题

**源码：**
`src/inference_service/inference_service/lerobot_policy_node.py:88-103 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/lerobot_policy_node.py#L88-L103>`__,
`src/inference_service/inference_service/lerobot_policy_node.py:180-240 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/lerobot_policy_node.py#L180-L240>`__

观测订阅
~~~~~~~~

节点为所有过滤后的观测创建 ROS 订阅，每个订阅都有一个 ``StreamBuffer``，实现契约的重采样策略（``hold``、``asof`` 或 ``drop``）。

.. mermaid::

   graph LR
       subgraph "观测流程"
           ROS_TOPIC["/camera/top/image_raw<br/>ROS Topic"]
           SUBSCRIPTION["ROS Subscription<br/>sensor_msgs/Image"]
           OBS_CB["_obs_cb(msg, spec)<br/>解码 + 推送"]
           STREAM_BUF["StreamBuffer<br/>策略: hold<br/>tol_ns: 50ms"]
           SAMPLE["_sample_obs_frame(ts)<br/>采样所有缓冲区"]
           OBS_FRAME["obs_frame dict<br/>{observation.images.top: array}"]
       end
       
       ROS_TOPIC --> SUBSCRIPTION
       SUBSCRIPTION --> OBS_CB
       OBS_CB --> STREAM_BUF
       SAMPLE --> STREAM_BUF
       STREAM_BUF --> OBS_FRAME

**多个 observation.state 规格：** 节点通过以下方式处理来自不同主题的多个 ``observation.state`` 规格：1. 创建唯一的字典键：``observation.state_{topic_suffix}`` 2. 在采样时拼接值：``np.concatenate([buf1.sample(t), buf2.sample(t)])``

.. code:: python

   # 来自 lerobot_policy_node.py:399-420
   def _sample_obs_frame(self, sample_t_ns: Optional[int] = None) -> Dict[str, Any]:
       obs_frame: Dict[str, Any] = {}
       
       # 拼接多个 observation.state 流
       if len(self._state_specs) > 1:
           parts = []
           for sv in self._state_specs:
               key = f"{sv.key}_{sv.topic.replace('/', '_')}"
               v = self._subs[key].buf.sample(sample_t_ns)
               parts.append(v if v is not None else self._obs_zero.get(key))
           obs_frame["observation.state"] = np.concatenate(parts)

**源码：**
`src/inference_service/inference_service/lerobot_policy_node.py:242-283 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/lerobot_policy_node.py#L242-L283>`__,
`src/inference_service/inference_service/lerobot_policy_node.py:381-420 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/lerobot_policy_node.py#L381-L420>`__

DispatchInfer Action Server
~~~~~~~~~~~~~~~~~~~~~~~~~~~

节点暴露一个 ``DispatchInfer`` action，``action_dispatcher_node`` 调用它来请求推理。这是策略节点的 **唯一** 外部接口。

**Action 定义（来自 ibrobot_msgs/action/DispatchInfer.action）：**

::

   # Goal
   builtin_interfaces/Time obs_timestamp
   string inference_id
   ---
   # Result
   ibrobot_msgs/VariantsList action_chunk
   int32 chunk_size
   bool success
   string message
   float64 inference_latency_ms
   ---
   # Feedback
   (none)

**执行流程：**

.. mermaid::

   sequenceDiagram
       participant AD as action_dispatcher_node
       participant LPN as lerobot_policy_node
       participant IC as InferenceCoordinator/Cloud
       
       AD->>LPN: send_goal_async(obs_timestamp)
       activate LPN
       
       LPN->>LPN: _sample_obs_frame(obs_timestamp)
       
       alt 单体模式
           LPN->>IC: coordinator(obs_frame)
           IC-->>LPN: CoordinatorResult
       else 分布式模式
           LPN->>LPN: preprocessor(obs_frame)
           LPN->>IC: publish /preprocessed/batch
           IC-->>LPN: /inference/action (async)
           LPN->>LPN: postprocessor(action)
       end
       
       LPN->>LPN: _create_action_msg(action)
       LPN->>AD: goal_handle.succeed()
       deactivate LPN
       AD->>AD: _result_cb(action_chunk)

**源码：**
`src/inference_service/inference_service/lerobot_policy_node.py:367-379 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/lerobot_policy_node.py#L367-L379>`__,
`src/inference_service/inference_service/lerobot_policy_node.py:422-489 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/lerobot_policy_node.py#L422-L489>`__

单体执行模式
~~~~~~~~~~~~

在单体模式下，节点拥有一个 ``InferenceCoordinator``，在单个进程中执行所有三个阶段（预处理、推理、后处理），通过零拷贝张量传递。

.. code:: python

   # 来自 lerobot_policy_node.py:285-304
   def _setup_monolithic_mode(self):
       self._coordinator = InferenceCoordinator(
           policy_path=policy_path,
           device=str(self._device),
       )
       
       self._policy_type = self._coordinator.policy_type
       self._chunk_size = self._coordinator.chunk_size

**执行：**

.. code:: python

   # 来自 lerobot_policy_node.py:491-493
   def _execute_monolithic(self, obs_frame: Dict[str, Any]) -> CoordinatorResult:
       """在单体模式下执行推理（零拷贝）。"""
       return self._coordinator(obs_frame)

**零拷贝设计：** 张量通过协调器管道以引用方式传递。推理过程中不发生序列化或 ROS 消息转换。

**源码：**
`src/inference_service/inference_service/lerobot_policy_node.py:285-304 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/lerobot_policy_node.py#L285-L304>`__,
`src/inference_service/inference_service/lerobot_policy_node.py:491-493 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/lerobot_policy_node.py#L491-L493>`__

分布式执行模式
~~~~~~~~~~~~~~

在分布式模式下，节点作为 **异步代理**：1. 在本地预处理观测（边缘 CPU）2. 通过 ``/preprocessed/batch`` 将预处理批次发布到云端 3. **阻塞 action 回调** 等待云端响应 4. 在本地后处理动作 5. 返回给 ``action_dispatcher_node``

.. mermaid::

   graph TB
       subgraph "边缘节点 (lerobot_policy_node)"
           direction TB
           
           ACTION_REQ["DispatchInfer Goal<br/>obs_timestamp"]
           PREPROCESS["TensorPreprocessor<br/>仅 CPU"]
           UUID["生成 request_id<br/>uuid.uuid4()"]
           EVENT["threading.Event()<br/>等待云端"]
           POSTPROCESS["TensorPostprocessor<br/>仅 CPU"]
           ACTION_RESP["DispatchInfer Result<br/>action_chunk"]
           
           ACTION_REQ --> PREPROCESS
           PREPROCESS --> UUID
           UUID --> EVENT
           EVENT --> POSTPROCESS
           POSTPROCESS --> ACTION_RESP
       end
       
       subgraph "云端节点 (pure_inference_node)"
           direction TB
           CLOUD_SUB["订阅<br/>/preprocessed/batch"]
           CLOUD_INF["PureInferenceEngine<br/>GPU 推理"]
           CLOUD_PUB["发布<br/>/inference/action"]
           
           CLOUD_SUB --> CLOUD_INF
           CLOUD_INF --> CLOUD_PUB
       end
       
       UUID -->|"带 request_id 发布"| CLOUD_SUB
       CLOUD_PUB -->|"匹配 request_id"| EVENT
       
       style EVENT fill:#fff3e0

**请求-响应匹配：** 每个推理请求被分配一个唯一的 ``request_id``，该 ID 通过云端传回，使边缘节点能够将响应与待处理请求匹配。

.. code:: python

   # 来自 lerobot_policy_node.py:495-554
   def _execute_distributed(self, obs_frame: Dict[str, Any], inference_id: str) -> CoordinatorResult:
       # 1. 本地预处理
       batch = self._preprocessor(obs_frame)
       
       # 2. 生成请求 ID 并创建事件
       request_id = str(uuid.uuid4())
       batch["task.request_id"] = [request_id]
       event = threading.Event()
       self._pending_requests[request_id] = [event, None]
       
       # 3. 发布到云端
       msg = TensorMsgConverter.to_variant(batch)
       self._pub_batch.publish(msg)
       
       # 4. 阻塞直到云端响应（带超时）
       success = event.wait(timeout=self._config.request_timeout)
       if not success:
           raise TimeoutError(f"Inference timeout for request {request_id}")
       
       # 5. 获取云端结果
       cloud_result = self._pending_requests.pop(request_id)[1]
       
       # 6. 本地后处理
       action = self._postprocessor(cloud_result["action"])
       
       return CoordinatorResult(action=action, ...)

**云端结果回调：**

.. code:: python

   # 来自 lerobot_policy_node.py:556-584
   def _cloud_result_callback(self, msg: VariantsList):
       batch = TensorMsgConverter.from_variant(msg, self._device)
       request_id = batch.pop("action.request_id", None)[0]
       
       if request_id in self._pending_requests:
           req = self._pending_requests[request_id]
           req[1] = batch  # 存储云端结果
           req[0].set()    # 唤醒等待线程

**透明性：** 分布式架构对 ``action_dispatcher_node`` 完全不可见。从它的角度看，它只是发送一个目标并接收结果——该结果是本地计算还是通过云端计算已被抽象化。

**源码：**
`src/inference_service/inference_service/lerobot_policy_node.py:306-351 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/lerobot_policy_node.py#L306-L351>`__,
`src/inference_service/inference_service/lerobot_policy_node.py:495-584 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/lerobot_policy_node.py#L495-L584>`__

--------------

pure_inference_node
-------------------

``pure_inference_node`` 是专为分布式模式设计的轻量级 GPU 工作器。它订阅预处理批次，使用 ``PureInferenceEngine`` 运行推理，并发布原始动作张量。

.. _node-architecture-1:

节点架构
~~~~~~~~

.. mermaid::

   graph TB
       subgraph "PureInferenceNode 类"
           direction TB
           
           INIT["__init__<br/>节点初始化"]
           ENGINE["PureInferenceEngine<br/>加载策略到 GPU"]
           
           SUB["create_subscription<br/>/preprocessed/batch"]
           PUB["create_publisher<br/>/inference/action"]
           
           CB["_inference_cb(msg)<br/>主回调"]
           DECODE["TensorMsgConverter.from_variant()"]
           EXTRACT_ID["提取 request_id"]
           INFER["engine(batch)"]
           ENCODE["TensorMsgConverter.to_variant()"]
           
           INIT --> ENGINE
           INIT --> SUB
           INIT --> PUB
           
           SUB --> CB
           CB --> DECODE
           DECODE --> EXTRACT_ID
           EXTRACT_ID --> INFER
           INFER --> ENCODE
           ENCODE --> PUB
       end
       
       POLICY[策略检查点<br/>*.safetensors]
       
       POLICY -->|"load"| ENGINE

**关键特性：** - **无 Action Server：** 与 ``lerobot_policy_node`` 不同，此节点仅处理发布/订阅 - **无状态：** 每次推理独立；无观测订阅 - **透传请求 ID：** 保留 ``request_id`` 用于响应匹配 - **延迟报告：** 在响应中包含 ``_latency_ms`` 用于可观测性

**源码：**
`src/inference_service/inference_service/pure_inference_node.py:33-79 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/pure_inference_node.py#L33-L79>`__

初始化与参数
~~~~~~~~~~~~


.. list-table::
   :header-rows: 1

   * - 参数
     - 类型
     - 默认值
     - 描述
   * - ``policy_path``
     - str
     - None（必需）
     - 策略检查点目录 的路径
   * - ``input_topic``
     - str
     - ``"/prep rocessed/batch"``
     - 订阅预处理批次
   * - ``output_topic``
     - str
     - ``"/in ference/action"``
     - 发布推理结果
   * - ``device``
     - str
     - ``"auto"``
     - GPU 设备选择

.. code:: python

   # 来自 pure_inference_node.py:43-79
   def __init__(self, node_name: str = "pure_inference", ...):
       super().__init__(node_name)
       
       self._engine = PureInferenceEngine(policy_path=policy_path, device=device)
       
       self._sub = self.create_subscription(
           VariantsList, input_topic, self._inference_cb, 10
       )
       
       self._pub = self.create_publisher(VariantsList, output_topic, 10)

**源码：**
`src/inference_service/inference_service/pure_inference_node.py:33-79 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/pure_inference_node.py#L33-L79>`__

推理回调
~~~~~~~~

回调处理完整的推理周期：

.. code:: python

   # 来自 pure_inference_node.py:81-119
   def _inference_cb(self, msg: VariantsList):
       # 1. 将 ROS 消息解码为张量
       batch = TensorMsgConverter.from_variant(msg, self._engine._device)
       
       # 2. 提取 request_id（用于响应匹配）
       req_list = batch.pop("task.request_id", None)
       request_id = req_list[0] if req_list and isinstance(req_list, list) else None
       
       # 3. 运行推理
       start_time = time.perf_counter()
       result = self._engine(batch)
       inference_latency_ms = (time.perf_counter() - start_time) * 1000.0
       
       # 4. 构建响应批次
       out_batch: Dict[str, Any] = {"action": result.action}
       if request_id is not None:
           out_batch["action.request_id"] = [request_id]
       out_batch["_latency_ms"] = inference_latency_ms
       
       # 5. 编码并发布
       out_msg = TensorMsgConverter.to_variant(out_batch)
       self._pub.publish(out_msg)

**消息格式：**

输入（``/preprocessed/batch``）：

::

   VariantsList {
     "observation.images.top": Tensor[1, 10, 480, 640, 3]
     "observation.state": Tensor[1, 10, 14]
     "task.request_id": ["uuid-string"]
   }

输出（``/inference/action``）：

::

   VariantsList {
     "action": Tensor[100, 7]
     "action.request_id": ["uuid-string"]
     "_latency_ms": 42.3
   }

**源码：**
`src/inference_service/inference_service/pure_inference_node.py:81-119 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/pure_inference_node.py#L81-L119>`__

--------------

通信模式
--------

单体模式
~~~~~~~~

.. mermaid::

   sequenceDiagram
       participant AD as action_dispatcher_node
       participant LP as lerobot_policy_node
       participant Cam as Camera Topics
       participant JS as /joint_states
       
       Note over Cam,JS: 持续流
       Cam->>LP: /camera/top/image_raw
       JS->>LP: /joint_states
       
       loop 100Hz 控制循环
           AD->>LP: DispatchInfer Goal
           activate LP
           LP->>LP: _sample_obs_frame()
           LP->>LP: coordinator(obs_frame)
           LP-->>AD: Result(action_chunk)
           deactivate LP
       end

**延迟分解：** - 观测采样：~0.1ms（引用查找） - 预处理：~5-10ms（图像调整大小、归一化） - 推理：~20-80ms（取决于模型） - 后处理：~1-2ms（时序集成、裁剪） - **总计：** ~30-100ms

**源码：**
`src/inference_service/inference_service/lerobot_policy_node.py:422-493 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/lerobot_policy_node.py#L422-L493>`__

分布式模式
~~~~~~~~~~

.. mermaid::

   sequenceDiagram
       participant AD as action_dispatcher_node
       participant Edge as lerobot_policy_node<br/>(边缘 CPU)
       participant Cloud as pure_inference_node<br/>(云端 GPU)
       participant Cam as Camera Topics
       
       Note over Cam,Cloud: 持续流
       Cam->>Edge: /camera/top/image_raw
       
       loop 100Hz 控制循环
           AD->>Edge: DispatchInfer Goal
           activate Edge
           Edge->>Edge: _sample_obs_frame()
           Edge->>Edge: preprocessor(obs_frame)
           Edge->>Cloud: /preprocessed/batch<br/>(带 request_id)
           Note over Edge: threading.Event.wait()<br/>Action 回调在此阻塞
           
           activate Cloud
           Cloud->>Cloud: engine(batch)
           Cloud->>Edge: /inference/action<br/>(带 request_id)
           deactivate Cloud
           
           Edge->>Edge: 匹配 request_id<br/>Event.set()
           Edge->>Edge: postprocessor(action)
           Edge-->>AD: Result(action_chunk)
           deactivate Edge
       end

**延迟分解：** - 边缘预处理：~5-10ms - 网络传输：~5-20ms（LAN） - 云端推理：~20-80ms - 网络返回：~5-20ms（LAN） - 边缘后处理：~1-2ms - **总计：** ~40-140ms

**故障处理：** - 如果云端在 ``request_timeout``（默认 5s）内未响应，action 回调抛出 ``TimeoutError`` - action 目标以 ``success=False`` 中止 - ``action_dispatcher_node`` 将此作为推理失败处理

**源码：**
`src/inference_service/inference_service/lerobot_policy_node.py:495-584 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/lerobot_policy_node.py#L495-L584>`__,
`src/inference_service/inference_service/pure_inference_node.py:81-119 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/pure_inference_node.py#L81-L119>`__

--------------

启动集成
--------

两个节点都通过 ``robot_config`` 的执行构建器启动，这些构建器自动从 YAML 配置检测执行模式。

**单体启动：**

.. code:: python

   # 来自 launch_builders/execution.py:61-126
   def generate_monolithic_inference_node(robot_config, control_mode, use_sim=False):
       inference_node = Node(
           package="inference_service",
           executable="lerobot_policy_node",
           name="act_inference_node",
           parameters=[{
               "checkpoint": model_config["path"],
               "robot_config_path": str(robot_config_path),
               "device": "auto",
               "execution_mode": "monolithic",
           }],
       )
       return inference_node

**分布式启动：**

.. code:: python

   # 来自 launch_builders/execution.py:129-228
   def generate_distributed_inference_nodes(robot_config, control_mode, use_sim=False):
       nodes = []
       
       # 边缘节点（与单体相同，但 execution_mode=distributed）
       edge_node = Node(
           package="inference_service",
           executable="lerobot_policy_node",
           name="act_inference_node",
           parameters=[{
               "checkpoint": policy_path,
               "robot_config_path": str(robot_config_path),
               "execution_mode": "distributed",
               "cloud_inference_topic": "/preprocessed/batch",
               "cloud_result_topic": "/inference/action",
           }],
       )
       nodes.append(edge_node)
       
       # 云端节点（仅纯推理）
       cloud_node = Node(
           package="inference_service",
           executable="pure_inference_node",
           name="pure_inference",
           parameters=[{
               "policy_path": policy_path,
               "input_topic": "/preprocessed/batch",
               "output_topic": "/inference/action",
           }],
       )
       nodes.append(cloud_node)
       
       return nodes

**配置示例（robot_config YAML）：**

.. code:: yaml

   control_modes:
     model_inference:
       inference:
         enabled: true
         model: act_policy_v1
         execution_mode: distributed  # 或 "monolithic"
         request_timeout: 5.0
         cloud_inference_topic: /preprocessed/batch
         cloud_result_topic: /inference/action

**源码：**
`src/robot_config/robot_config/launch_builders/execution.py:61-228 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/launch_builders/execution.py#L61-L228>`__,
`src/robot_config/launch/robot.launch.py:264-275 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/launch/robot.launch.py#L264-L275>`__

--------------

代码实体参考
------------

lerobot_policy_node 类与函数
~~~~~~~~~~~~~~~~~~~~~~~~~~~~


.. list-table::
   :header-rows: 1

   * - 实体
     - 位置
     - 用途
   * - ``LeRobotPolicyNode``
     - `src/inference_service/inference_service/lerobot_policy_node.py:105-641 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/lerobot_policy_node.py#L105-L641>`__
     - 主节点类
   * - ``_NodeConfig``
     - `src/inference_service/inference_service/lerobot_policy_node.py:88-103 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/lerobot_policy_node.py#L88-L103>`__
     - 配置 dataclass
   * - ``_SubState``
     - `src/inference_service/inference_service/lerobot_policy_node.py:80-84 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/lerobot_policy_node.py#L80-L84>`__
     - 每订阅状态（规格 + 缓冲区）
   * - ``_load_policy_config()``
     - `src/inference_service/inference_service/lerobot_policy_node.py:180-203 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/lerobot_policy_node.py#L180-L203>`__
     - 加载模型的 config.json
   * - ``_load_contract()``
     - `src/inference_service/inference_service/lerobot_policy_node.py:205-240 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/lerobot_policy_node.py#L205-L240>`__
     - 加载并过滤契约观测
   * - ``_setup_observation_subscriptions()``
     - `src/inference_service/inference_service/lerobot_policy_node.py:242-283 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/lerobot_policy_node.py#L242-L283>`__
     - 创建带 StreamBuffer 的 ROS 订阅
   * - ``_setup_monolithic_mode()``
     - `src/inference_service/inference_service/lerobot_policy_node.py:285-304 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/lerobot_policy_node.py#L285-L304>`__
     - 初始化 InferenceCoordinator
   * - ``_setup_distributed_mode()``
     - `src/inference_service/inference_service/lerobot_policy_node.py:306-351 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/lerobot_policy_node.py#L306-L351>`__
     - 初始化预/后处理器 + 发布/订阅
   * - ``_obs_cb()``
     - `src/inference_service/inference_service/lerobot_policy_node.py:381-397 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/lerobot_policy_node.py#L381-L397>`__
     - 观测回调（解码 + 推送到缓冲区）
   * - ``_sample_obs_frame()``
     - `src/inference_service/inference_service/lerobot_policy_node.py:399-420 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/lerobot_policy_node.py#L399-L420>`__
     - 在时间戳处采样所有缓冲区
   * - ``_dispatch_infer_callback()``
     - `src/inference_service/inference_service/lerobot_policy_node.py:422-489 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/lerobot_policy_node.py#L422-L489>`__
     - Action Server 执行回调
   * - ``_execute_monolithic()``
     - `src/inference_service/inference_service/lerobot_policy_node.py:491-493 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/lerobot_policy_node.py#L491-L493>`__
     - 单体推理执行
   * - ``_execute_distributed()``
     - `src/inference_service/inference_service/lerobot_policy_node.py:495-554 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/lerobot_policy_node.py#L495-L554>`__
     - 带异步等待的分布式推理执行
   * - ``_cloud_result_callback()``
     - `src/inference_service/inference_service/lerobot_policy_node.py:556-584 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/lerobot_policy_node.py#L556-L584>`__
     - 处理云端响应并唤醒等待线程

pure_inference_node 类与函数
~~~~~~~~~~~~~~~~~~~~~~~~~~~~


.. list-table::
   :header-rows: 1

   * - 实体
     - 位置
     - 用途
   * - ``P ureInferenceNode``
     - `src/inference_service/inference_service/pure_inference_node.py:33-120 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/ce_service/pure_inference_node.py#L33-L120>`__
     - 云端推理工作器节点 ference_service/inferen
   * - ` `_inference_cb()``
     - `src/inference_service/inference_service/pure_inference_node.py:81-119 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/ce_service/pure_inference_node.py#L81-L119>`__
     - 主推理回调 ference_service/inferen
   * - ``main()``
     - `src/inference_service/inference_service/pure_inference_node.py:122-164 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/pure_inference_node.py#L122-L164>`__
     - 带参数加载的入口点 带参数加载的入口点

**源码：**
`src/inference_service/inference_service/lerobot_policy_node.py:1-721 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/lerobot_policy_node.py#L1-L721>`__,
`src/inference_service/inference_service/pure_inference_node.py:1-165 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/pure_inference_node.py#L1-L165>`__

--------------

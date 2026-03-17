动作调度器节点
==============

.. raw:: html

   <details>

相关源文件

以下文件用于生成此文档页面：

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
-  `src/inference_service/inference_service/lerobot_policy_node.py <src/inference_service/inference_service/lerobot_policy_node.py>`__
-  `src/robot_config/launch/robot.launch.py <src/robot_config/launch/robot.launch.py>`__
-  `src/robot_config/robot_config/config.py <src/robot_config/robot_config/config.py>`__
-  `src/robot_config/robot_config/contract_builder.py <src/robot_config/robot_config/contract_builder.py>`__
-  `src/robot_config/robot_config/contract_utils.py <src/robot_config/robot_config/contract_utils.py>`__
-  `src/robot_config/robot_config/launch_builders/execution.py <src/robot_config/robot_config/launch_builders/execution.py>`__
-  `src/robot_config/robot_config/launch_builders/recording.py <src/robot_config/robot_config/launch_builders/recording.py>`__

.. raw:: html

   </details>

目的与范围
----------

``ActionDispatcherNode`` 是 IB-Robot 动作调度流水线中的核心执行协调器。它实现了基于拉取的架构，维护一个动作队列，当队列不足时触发推理请求，并以固定频率（默认 100Hz）向 ros2_control 发布动作。本文档介绍该节点的控制循环、队列管理和基于水位线的推理触发机制。

| **相关页面**：- 有关时间平滑算法和跨帧混合，请参阅 `时间平滑 <#8.2>`__ - 有关通过 TopicExecutor 和 ActionExecutor 执行动作，请参阅 `话题和动作执行器 <#8.3>`__
| - 有关提供动作的推理服务，请参阅 `策略节点 <#7.4>`__

**来源**：
`src/action_dispatch/action_dispatch/action_dispatcher_node.py:1-319 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatch/action_dispatcher_node.py#L1-L319>`__,
`src/action_dispatch/README.en.md:1-447 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/README.en.md#L1-L447>`__

--------------

概述
----

``ActionDispatcherNode`` 充当机器人的"小脑"，将推理延迟与控制频率解耦。它解决了 AI 策略推理（通常 50-200ms）远慢于所需控制速率（100Hz = 10ms）的根本问题。

关键职责
~~~~~~~~


.. list-table::
   :header-rows: 1

   * - 职责
     - 实现
   * - **队列管理**
     - 维护 ``collections.deque`` 或 ``TemporalSmoother`` 用于动作 缓冲
   * - **异步推理**
     - 当队列低于水位线时，通过 ``DispatchInfer`` Action 触发推理
   * - **高频控制**
     - 通过 ``TopicExecutor`` 以 100Hz 发布动作
   * - **时间对齐**
     - 跟踪推理期间执行的动作数量， 以正确对齐分块
   * - **安全回退**
     - 当队列为空时保持最后一个动作

**来源**：
`src/action_dispatch/action_dispatch/action_dispatcher_node.py:38-48 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatch/action_dispatcher_node.py#L38-L48>`__,
`src/action_dispatch/README.en.md:133-148 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/README.en.md#L133-L148>`__

--------------

系统架构
--------

执行流水线中的位置
~~~~~~~~~~~~~~~~~~

.. mermaid::

   graph TB
       subgraph "Inference Layer"
           PolicyNode["lerobot_policy_node<br/>(DispatchInfer Action Server)"]
       end
       
       subgraph "Action Dispatcher Node"
           ControlLoop["_control_loop()<br/>100Hz Timer"]
           QueueCheck{"Queue < Watermark?"}
           ActionQueue["Action Queue<br/>_queue / _smoother"]
           RequestInf["_request_inference()<br/>Send DispatchInfer Goal"]
           ResultCb["_result_cb()<br/>Handle Inference Result"]
           
           ControlLoop --> QueueCheck
           QueueCheck -->|Yes| RequestInf
           RequestInf --> PolicyNode
           PolicyNode -->|Result| ResultCb
           ResultCb --> ActionQueue
           QueueCheck -->|No| ActionQueue
       end
       
       subgraph "Execution Layer"
           Executor["TopicExecutor<br/>execute()"]
           ROS2Control["ros2_control<br/>Controllers"]
       end
       
       ActionQueue -->|Pop Action| Executor
       Executor --> ROS2Control
       
       style ActionQueue fill:#f9f,stroke:#333,stroke-width:2px
       style ControlLoop fill:#bbf,stroke:#333,stroke-width:2px

**来源**：`src/action_dispatch/README.en.md:13-42 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/README.en.md#L13-L42>`__,
`src/action_dispatch/action_dispatch/action_dispatcher_node.py:165-201 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatch/action_dispatcher_node.py#L165-L201>`__

通信接口
~~~~~~~~

.. mermaid::

   graph LR
       subgraph "Inputs"
           JointState["/joint_states<br/>(sensor_msgs/JointState)"]
           InfResult["DispatchInfer Result<br/>(ibrobot_msgs/VariantsList)"]
       end
       
       subgraph "ActionDispatcherNode"
           InfClient["_infer_client<br/>(ActionClient)"]
           JointSub["_joint_sub<br/>(Subscription)"]
           Executor["_executor<br/>(TopicExecutor)"]
       end
       
       subgraph "Outputs"
           QueueSizePub["~/queue_size<br/>(std_msgs/Int32)"]
           SmoothingPub["~/smoothing_enabled<br/>(std_msgs/Bool)"]
           ControlTopics["Controller Topics<br/>(Float64MultiArray)"]
       end
       
       subgraph "Services"
           ResetSrv["~/reset<br/>(std_srvs/Empty)"]
           ToggleSrv["~/toggle_smoothing<br/>(std_srvs/Empty)"]
       end
       
       JointState --> JointSub
       InfClient -->|Goal| InfResult
       InfClient -->|Result| InfClient
       
       Executor --> ControlTopics
       ActionDispatcherNode --> QueueSizePub
       ActionDispatcherNode --> SmoothingPub
       
       ResetSrv -.-> ActionDispatcherNode
       ToggleSrv -.-> ActionDispatcherNode

**来源**：
`src/action_dispatch/action_dispatch/action_dispatcher_node.py:125-154 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatch/action_dispatcher_node.py#L125-L154>`__,
`src/action_dispatch/README.en.md:344-378 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/README.en.md#L344-L378>`__

--------------

控制循环实现
------------

基于定时器的执行
~~~~~~~~~~~~~~~~

``ActionDispatcherNode`` 的核心是 ``_control_loop()`` 方法，以固定频率（默认 100Hz）执行：

.. mermaid::

   graph TD
       Start["_control_loop() Triggered<br/>(100Hz Timer)"]
       GetQueueSize["q_size = _get_plan_length()"]
       PubStatus["Publish queue_size and<br/>smoothing_enabled"]
       
       CheckWatermark{"q_size < _watermark<br/>AND NOT<br/>_inference_in_progress?"}
       TriggerInf["_request_inference()"]
       
       CheckQueue{"q_size > 0?"}
       PopAction["Pop action from queue/smoother"]
       UseLastAction["Use _last_action (hold)"]
       
       Execute["_executor.execute(action)"]
       End["End Timer Cycle"]
       
       Start --> GetQueueSize
       GetQueueSize --> PubStatus
       PubStatus --> CheckWatermark
       
       CheckWatermark -->|Yes| TriggerInf
       CheckWatermark -->|No| CheckQueue
       TriggerInf --> CheckQueue
       
       CheckQueue -->|Yes| PopAction
       CheckQueue -->|No| UseLastAction
       
       PopAction --> Execute
       UseLastAction --> Execute
       Execute --> End

**关键实现细节**：


.. list-table::
   :header-rows: 1

   * - 方面
     - 实现
   * - 定时器创建
     - ``self.create_timer(1.0 / s elf._control_hz, self._control_loop, ...)``
   * - 队列长度 计算
     - ``_get_plan_length()`` - 同时适用于 deque 和 smoother 模式
   * - 动作获取
     - Smoother: ``_smoother.get_next_action()``, Simple: ``_queue.popleft()``
   * - 保持行为
     - 当队列为空时使用 ``_last_action`` 以保持稳定性

**来源**：
`src/action_dispatch/action_dispatch/action_dispatcher_node.py:142-146 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatch/action_dispatcher_node.py#L142-L146>`__,
`src/action_dispatch/action_dispatch/action_dispatcher_node.py:165-201 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatch/action_dispatcher_node.py#L165-L201>`__

--------------

队列管理
--------

双模式架构
~~~~~~~~~~

该节点支持两种队列管理模式：

**1. 简单队列模式**\ （``temporal_smoothing_enabled=false``）- 使用 ``collections.deque``，设置 ``maxlen=queue_size`` - 推理完成时直接替换动作 - 适用于单步策略或调试

**2. 时间平滑模式**\ （``temporal_smoothing_enabled=true``）- 使用 ``TemporalSmootherManager`` 包装器 - 跨帧指数加权混合 - 动作分块模型（ACT、Diffusion Policy）必需

.. mermaid::

   graph TB
       subgraph "Mode Selection (Initialization)"
           ParamCheck{"temporal_smoothing_enabled?"}
           CreateDeque["self._queue = deque(maxlen=queue_size)<br/>self._smoother = None"]
           CreateSmoother["self._smoother = TemporalSmootherManager(...)<br/>Uses _queue internally"]
       end
       
       subgraph "Queue Operations"
           GetLength["_get_plan_length()"]
           PopAction["Pop Next Action"]
           UpdateQueue["Update with New Actions"]
       end
       
       ParamCheck -->|False| CreateDeque
       ParamCheck -->|True| CreateSmoother
       
       CreateDeque --> GetLength
       CreateSmoother --> GetLength
       
       GetLength -->|Simple| SimpleLen["return len(self._queue)"]
       GetLength -->|Smoother| SmootherLen["return self._smoother.plan_length"]
       
       PopAction -->|Simple| SimplePop["self._queue.popleft()"]
       PopAction -->|Smoother| SmootherPop["self._smoother.get_next_action()"]
       
       UpdateQueue -->|Simple| SimpleClear["self._queue.clear()<br/>self._queue.extend(actions)"]
       UpdateQueue -->|Smoother| SmootherUpdate["self._smoother.update(actions,<br/>actions_executed)"]

**来源**：
`src/action_dispatch/action_dispatch/action_dispatcher_node.py:89-103 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatch/action_dispatcher_node.py#L89-L103>`__,
`src/action_dispatch/action_dispatch/action_dispatcher_node.py:165-178 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatch/action_dispatcher_node.py#L165-L178>`__

动作执行跟踪
~~~~~~~~~~~~

为了正确对齐新的推理结果与现有队列，节点跟踪推理期间执行了多少动作：

.. code:: python

   # At inference request time (line 209)
   self._plan_length_at_inference_start = self._get_plan_length()

   # At inference result time (line 259-260)
   current_plan_length = self._get_plan_length()
   actions_executed = max(0, self._plan_length_at_inference_start - current_plan_length)

这个 ``actions_executed`` 值对于时间平滑对齐至关重要。

**来源**：
`src/action_dispatch/action_dispatch/action_dispatcher_node.py:208-216 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatch/action_dispatcher_node.py#L208-L216>`__,
`src/action_dispatch/action_dispatch/action_dispatcher_node.py:232-278 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatch/action_dispatcher_node.py#L232-L278>`__

--------------

基于水位线的推理触发
--------------------

触发逻辑
~~~~~~~~

节点使用水位线阈值异步触发推理：

.. mermaid::

   graph TD
       ControlLoop["Control Loop (100Hz)"]
       CheckConditions{"queue_size < watermark<br/>AND<br/>NOT inference_in_progress?"}
       
       SendGoal["Create DispatchInfer.Goal<br/>goal.obs_timestamp = now()"]
       SendAsync["_infer_client.send_goal_async(goal)"]
       SetFlag["_inference_in_progress = True"]
       RecordQueueLen["_plan_length_at_inference_start = queue_size"]
       
       WaitCallback["Wait for Goal Response Callback"]
       
       ControlLoop --> CheckConditions
       CheckConditions -->|Yes| SendGoal
       CheckConditions -->|No| ControlLoop
       
       SendGoal --> RecordQueueLen
       RecordQueueLen --> SetFlag
       SetFlag --> SendAsync
       SendAsync --> WaitCallback
       WaitCallback -.->|Async| GoalResponseCb["_goal_response_cb()"]

**参数配置**：


.. list-table::
   :header-rows: 1

   * - 参数
     - 默认值
     - 用途
   * - ``watermark_threshold``
     - 20
     - 当队列低于此数值时 触发推理
   * - ``queue_size``
     - 100
     - 最大队列容量
   * - ``control_frequency``
     - 100.0
     - Hz - 控制循环速率

**触发策略**：- **提前触发**：当 watermark=20 时，在队列消耗 80% 时开始推理 - **重叠**：新推理在旧动作仍在执行时完成 - **连续运行**：确保动作流无间隙

**来源**：
`src/action_dispatch/action_dispatch/action_dispatcher_node.py:54-68 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatch/action_dispatcher_node.py#L54-L68>`__,
`src/action_dispatch/action_dispatch/action_dispatcher_node.py:203-220 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatch/action_dispatcher_node.py#L203-L220>`__

推理请求流程
~~~~~~~~~~~~

.. mermaid::

   sequenceDiagram
       participant CL as _control_loop
       participant RIF as _request_inference
       participant AC as _infer_client
       participant PN as PolicyNode
       participant GRC as _goal_response_cb
       participant RC as _result_cb
       participant Q as Queue/Smoother
       
       CL->>CL: Check watermark
       CL->>RIF: Trigger inference
       RIF->>RIF: Set _inference_in_progress = True
       RIF->>RIF: Record _plan_length_at_inference_start
       RIF->>AC: send_goal_async(goal)
       AC->>PN: DispatchInfer Goal
       
       Note over PN: Policy inference<br/>(50-200ms)
       
       PN->>AC: Goal Accepted
       AC->>GRC: goal_handle
       GRC->>GRC: get_result_async()
       
       PN->>AC: Result (action_chunk)
       AC->>RC: Result future
       RC->>RC: Decode VariantsList
       RC->>RC: Calculate actions_executed
       RC->>Q: Update queue/smoother
       RC->>RC: Set _inference_in_progress = False

**来源**：
`src/action_dispatch/action_dispatch/action_dispatcher_node.py:203-230 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatch/action_dispatcher_node.py#L203-L230>`__,
`src/action_dispatch/README.en.md:84-130 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/README.en.md#L84-L130>`__

--------------

结果处理与队列更新
------------------

推理结果回调
~~~~~~~~~~~~

当推理完成时，``_result_cb()`` 处理结果并更新队列：

.. mermaid::

   graph TD
       ResultCb["_result_cb(future)"]
       ClearFlag["_inference_in_progress = False"]
       CheckSuccess{"result.success?"}
       
       DecodeBatch["batch = TensorMsgConverter.from_variant(<br/>result.action_chunk)"]
       GetAction["action_chunk = batch['action']"]
       
       ConvertTensor["Convert to Tensor if needed"]
       ReshapeCheck{"action_chunk.ndim == 1?"}
       Reshape2D["Reshape to (1, action_dim)"]
       
       CalcExecuted["current_len = _get_plan_length()<br/>actions_executed = start_len - current_len"]
       
       SmootherCheck{"_smoother exists?"}
       SmootherUpdate["_smoother.update(<br/>action_chunk_tensor,<br/>actions_executed)"]
       SimpleUpdate["Skip actions_executed actions<br/>_queue.clear()<br/>_queue.extend(remaining)"]
       
       LogError["Log error message"]
       End["End"]
       
       ResultCb --> ClearFlag
       ClearFlag --> CheckSuccess
       CheckSuccess -->|No| LogError
       CheckSuccess -->|Yes| DecodeBatch
       
       DecodeBatch --> GetAction
       GetAction --> ConvertTensor
       ConvertTensor --> ReshapeCheck
       ReshapeCheck -->|Yes| Reshape2D
       ReshapeCheck -->|No| CalcExecuted
       Reshape2D --> CalcExecuted
       
       CalcExecuted --> SmootherCheck
       SmootherCheck -->|Yes| SmootherUpdate
       SmootherCheck -->|No| SimpleUpdate
       
       SmootherUpdate --> End
       SimpleUpdate --> End
       LogError --> End

**关键代码段**：

.. code:: python

   # Decode inference result (lines 241-256)
   batch = TensorMsgConverter.from_variant(result.action_chunk)
   action_chunk = batch['action']

   # Handle both Tensor and NumPy (lines 246-256)
   if hasattr(action_chunk, 'detach'):
       action_chunk_tensor = action_chunk
       action_chunk_np = action_chunk.detach().cpu().numpy()
   else:
       action_chunk_tensor = torch.from_numpy(action_chunk)
       action_chunk_np = action_chunk

   # Calculate temporal alignment (lines 259-260)
   current_plan_length = self._get_plan_length()
   actions_executed = max(0, self._plan_length_at_inference_start - current_plan_length)

**来源**：
`src/action_dispatch/action_dispatch/action_dispatcher_node.py:232-278 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatch/action_dispatcher_node.py#L232-L278>`__

简单队列模式更新
~~~~~~~~~~~~~~~~

对于简单队列模式，更新逻辑跳过已执行的动作：

.. code:: python

   # Skip actions that were executed during inference (line 272)
   relevant_actions = action_chunk_np[actions_executed:]

   # Replace entire queue with relevant actions (lines 273-274)
   self._queue.clear()
   self._queue.extend(relevant_actions)

这确保队列只包含未来的动作，而非过时的动作。

**来源**：
`src/action_dispatch/action_dispatch/action_dispatcher_node.py:270-278 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatch/action_dispatcher_node.py#L270-L278>`__

--------------

状态管理
--------

状态变量
~~~~~~~~

节点维护多个状态变量以协调推理和执行：

.. mermaid::

   graph TB
       subgraph "Queue State"
           Queue["_queue: deque<br/>or<br/>_smoother: TemporalSmootherManager"]
           LastAction["_last_action: Optional[np.ndarray]<br/>(for hold behavior)"]
       end
       
       subgraph "Inference State"
           InfInProgress["_inference_in_progress: bool<br/>(prevents concurrent requests)"]
           PlanLenStart["_plan_length_at_inference_start: int<br/>(for temporal alignment)"]
       end
       
       subgraph "Runtime State"
           IsRunning["_is_running: bool<br/>(emergency stop flag)"]
           SmoothingEnabled["_smoothing_enabled: bool<br/>(toggleable at runtime)"]
       end
       
       subgraph "Configuration State"
           ActionSpecs["_action_specs: List[SpecView]<br/>(from contract)"]
           Executor["_executor: TopicExecutor<br/>(action publisher)"]
       end

**状态转换**：


.. list-table::
   :header-rows: 1

   * - 事件
     - 状态变化
   * - 推理请求
     - ``_inference_in_progress = True``\ \ ``_ plan_length_at_inference_start = queue_size``
   * - 推理完成
     - ``_inference_in_progress = False``\ 队列 更新为新动作
   * - 动作执行
     - 队列大小减 1\ ``_last_action`` 更新
   * - 切换平滑
     - ``_smoothing_enabled`` 翻转\ Smoother 配置 更新
   * - 重置服务
     - 所有队列清除\ 标志重置为初始状态

**来源**：
`src/action_dispatch/action_dispatch/action_dispatcher_node.py:80-103 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatch/action_dispatcher_node.py#L80-L103>`__

--------------

服务接口
--------

重置服务
~~~~~~~~

``~/reset`` 服务将调度器重置为初始状态：

.. code:: python

   def _reset_cb(self, request, response):
       self.get_logger().info("Resetting dispatcher state")
       self._queue.clear()
       if self._smoother is not None:
           self._smoother.reset()
       self._inference_in_progress = False
       self._plan_length_at_inference_start = 0
       self._last_action = None
       return response

**用例**：- 紧急停止并重启 - 在控制模式之间切换 - 清除损坏的队列状态

**来源**：
`src/action_dispatch/action_dispatch/action_dispatcher_node.py:280-288 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatch/action_dispatcher_node.py#L280-L288>`__

切换平滑服务
~~~~~~~~~~~~

``~/toggle_smoothing`` 服务支持运行时在平滑模式和直接模式之间切换：

.. code:: python

   def _toggle_smoothing_cb(self, request, response):
       if self._smoother is None:
           self.get_logger().warn("Cannot toggle smoothing: smoother not initialized")
           return response
       
       self._smoothing_enabled = not self._smoothing_enabled
       self._smoother._config.enabled = self._smoothing_enabled
       self._smoother._smoother.config.enabled = self._smoothing_enabled
       
       self.get_logger().info(f"Temporal smoothing {'ENABLED' if self._smoothing_enabled else 'DISABLED'}")
       return response

**注意**：只有在初始化了 ``TemporalSmootherManager`` 的情况下（即启动时 ``temporal_smoothing_enabled=true``）才能切换平滑。

**来源**：
`src/action_dispatch/action_dispatch/action_dispatcher_node.py:290-301 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatch/action_dispatcher_node.py#L290-L301>`__

--------------

参数参考
--------

完整参数表
~~~~~~~~~~


.. list-table::
   :header-rows: 1

   * - 参数
     - 类型
     - 默认值
     - 描述
   * - ``queue_size``
     - int
     - 100
     - 最大动作队列 长度
   * - ``wate rmark_threshold``
     - int
     - 20
     - 当队列低于此数值时 触发推理
   * - ``co ntrol_frequency``
     - double
     - 100.0
     - 控制循环 频率（Hz）
   * - ``inferenc e_action_server``
     - string
     - ``/act_infe rence_node/Di spatchInfer``
     - 推理 Action Server 的全名
   * - ``ro bot_config_path``
     - string
     - ``''``
     - robot_config YAML 路径 （TopicExecutor 需要）
   * - ``jo int_state_topic``
     - string
     - ``/j oint_states``
     - 关节状态反馈 话题（可选）
   * - ``temporal_sm oothing_enabled``
     - bool
     - false
     - 启用跨帧 时间平滑
   * - ``temporal _ensemble_coeff``
     - double
     - 0.01
     - 指数平滑系数 （参见 `时间平滑 <#8.2>`__）
   * - ``chunk_size``
     - int
     - 100
     - 推理预期的 动作分块大小
   * - ``s moothing_device``
     - string
     - ``''``
     - 平滑计算设备 （空=自动检测）

**来源**：
`src/action_dispatch/action_dispatch/action_dispatcher_node.py:54-66 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatch/action_dispatcher_node.py#L54-L66>`__,
`src/action_dispatch/README.en.md:173-185 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/README.en.md#L173-L185>`__

--------------

初始化序列
----------

节点启动流程
~~~~~~~~~~~~

.. mermaid::

   graph TD
       Init["__init__()"]
       DeclareParams["Declare all parameters"]
       ReadParams["Read parameter values"]
       
       CheckSmoothing{"temporal_smoothing_enabled?"}
       InitSimpleQueue["_queue = deque(maxlen=queue_size)<br/>_smoother = None"]
       InitSmoother["_smoother = TemporalSmootherManager(...)<br/>with config"]
       
       LoadContract["Load robot_config_path<br/>Extract action_specs"]
       CreateExecutor["_executor = TopicExecutor(self, {'action_specs': _action_specs})"]
       InitExecutor["_executor.initialize()"]
       
       CreateClient["_infer_client = ActionClient(DispatchInfer, server_name)"]
       CreateSubs["Create joint_state subscription"]
       CreatePubs["Create ~/queue_size and ~/smoothing_enabled publishers"]
       CreateServices["Create ~/reset and ~/toggle_smoothing services"]
       CreateTimer["Create control_loop timer at control_frequency"]
       
       LogReady["Log 'Dispatcher ready' message"]
       
       Init --> DeclareParams
       DeclareParams --> ReadParams
       ReadParams --> CheckSmoothing
       
       CheckSmoothing -->|False| InitSimpleQueue
       CheckSmoothing -->|True| InitSmoother
       
       InitSimpleQueue --> LoadContract
       InitSmoother --> LoadContract
       
       LoadContract --> CreateExecutor
       CreateExecutor --> InitExecutor
       
       InitExecutor --> CreateClient
       CreateClient --> CreateSubs
       CreateSubs --> CreatePubs
       CreatePubs --> CreateServices
       CreateServices --> CreateTimer
       CreateTimer --> LogReady

**关键依赖**：``TopicExecutor`` 需要契约中的 ``action_specs`` 来将动作维度映射到控制器话题。如果未提供 ``robot_config_path``，执行器将使用默认值，可能无法正常工作。

**来源**：
`src/action_dispatch/action_dispatch/action_dispatcher_node.py:49-159 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatch/action_dispatcher_node.py#L49-L159>`__

--------------

与其他组件的集成
----------------

契约驱动执行
~~~~~~~~~~~~

节点依赖 robot_config 契约来正确映射动作：

.. code:: python

   # Load contract (lines 106-113)
   from robot_config.loader import load_robot_config
   self._contract = load_robot_config(robot_config_path).to_contract()
   self._action_specs = [s for s in iter_specs(self._contract) if s.is_action]

   # Pass to executor (line 120)
   self._executor = TopicExecutor(self, {'action_specs': self._action_specs})

这确保当执行器接收到多维动作数组时，它知道如何将其拆分为手臂关节和夹爪指令。

**来源**：
`src/action_dispatch/action_dispatch/action_dispatcher_node.py:106-122 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatch/action_dispatcher_node.py#L106-L122>`__

启动配置示例
~~~~~~~~~~~~

从 ``robot.launch.py`` 中，调度器使用正确的参数启动：

.. code:: python

   # Parameter binding from control mode config
   parameters = [{
       'queue_size': 100,
       'watermark_threshold': 20,
       'control_frequency': 100.0,
       'robot_config_path': robot_config_path,
       'inference_action_server': f'/lerobot_policy_node/DispatchInfer',
       'temporal_smoothing_enabled': executor_config.get('temporal_smoothing', {}).get('enabled', False),
       'temporal_ensemble_coeff': executor_config.get('temporal_smoothing', {}).get('coeff', 0.01),
       'chunk_size': model_config.get('chunk_size', 100),
   }]

**来源**：
`src/robot_config/robot_config/launch_builders/execution.py:1-436 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/launch_builders/execution.py#L1-L436>`__

--------------

主入口点
--------

节点通过标准 ROS 2 Python 可执行模式启动：

.. code:: python

   def main(args=None):
       rclpy.init(args=args)
       node = ActionDispatcherNode()
       executor = rclpy.executors.MultiThreadedExecutor()
       executor.add_node(node)
       try:
           executor.spin()
       except KeyboardInterrupt:
           pass
       finally:
           node.destroy_node()
           rclpy.shutdown()

   if __name__ == '__main__':
       main()

``MultiThreadedExecutor`` 是处理并发回调（定时器、动作回调、服务调用）而不阻塞所必需的。

**来源**：
`src/action_dispatch/action_dispatch/action_dispatcher_node.py:304-318 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatch/action_dispatcher_node.py#L304-L318>`__

--------------

动作调度概述
============

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
-  `src/action_dispatch/action_dispatch/init.py <src/action_dispatch/action_dispatch/__init__.py>`__
-  `src/action_dispatch/action_dispatch/action_dispatcher_node.py <src/action_dispatch/action_dispatch/action_dispatcher_node.py>`__
-  `src/action_dispatch/action_dispatch/temporal_smoother.py <src/action_dispatch/action_dispatch/temporal_smoother.py>`__
-  `src/action_dispatch/test/test_temporal_smoother.py <src/action_dispatch/test/test_temporal_smoother.py>`__
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

**动作调度**\ （Action Dispatch）包实现了一个基于拉取的动作分发层，位于 AI 推理服务和 ros2_control 硬件接口之间。它提供队列管理、基于水位线的推理触发，以及用于动作分块模型的跨帧时间平滑。

有关生成动作的推理服务信息，请参阅 `推理服务 <#7>`__。有关硬件控制和执行的信息，请参阅 `硬件集成 <#11>`__。

--------------

目的与范围
----------

动作调度解决了将**离散模型推理**\ （以可变延迟产生动作分块）与**连续机器人控制**\ （需要固定 100Hz 频率的指令）进行桥接的根本问题。该系统：

-  维护一个 FIFO 动作队列，当队列低于水位线阈值时触发新的推理
-  实现跨帧时间平滑，确保连续动作分块之间的平滑过渡
-  提供高频（100Hz）流式传输到 ros2_control 控制器
-  将推理延迟与控制频率解耦，即使使用较慢的模型也能实现平滑的机器人运动

该包主要用于端到端策略部署（ACT、Diffusion Policy 等）的 ``model_inference`` 控制模式，但也可以与 MoveIt 配合用于轨迹平滑。

**来源**：`src/action_dispatch/README.en.md:1-43 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/README.en.md#L1-L43>`__,
`README.md:36-37 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L36-L37>`__

--------------

IB-Robot 架构中的系统位置
--------------------------

.. mermaid::

   graph TB
       subgraph "Inference Layer"
           Policy["lerobot_policy_node<br/>(Inference Service)"]
           ActionServer["DispatchInfer<br/>Action Server"]
           Policy --> ActionServer
       end
       
       subgraph "Action Dispatch Layer"
           Dispatcher["ActionDispatcherNode<br/>(100Hz Control Loop)"]
           Queue["Action Queue<br/>(FIFO Buffer)"]
           Smoother["TemporalSmoother<br/>(Cross-frame Blending)"]
           Executor["TopicExecutor /<br/>ActionExecutor"]
           
           Dispatcher -->|"watermark < 20"| ActionClient["DispatchInfer<br/>Action Client"]
           ActionClient -->|"goal"| ActionServer
           ActionServer -->|"result: action_chunk"| Dispatcher
           Dispatcher --> Smoother
           Smoother --> Queue
           Queue -->|"pop @ 100Hz"| Executor
       end
       
       subgraph "Control Layer"
           Controllers["ros2_control<br/>Controllers"]
           Hardware["Hardware Interface<br/>(so101_hardware / Gazebo)"]
           
           Executor -->|"position commands"| Controllers
           Controllers --> Hardware
       end
       
       Hardware -.->|"joint states"| Dispatcher

**图：系统上下文中的动作调度**

动作调度充当机器人的"小脑"——它不做出高层决策（那是推理服务的职责），但确保这些决策在硬件控制频率下平滑、安全地执行。

**来源**：`src/action_dispatch/README.en.md:11-79 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/README.en.md#L11-L79>`__,
`docs/architecture.md:86-177 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/docs/architecture.md#L86-L177>`__

--------------

基于拉取的队列架构
------------------

工作原理
~~~~~~~~

动作调度采用**基于拉取**的设计而非推送式。调度器维护一个动作队列，并在需要时主动请求新的推理，而不是被动接收动作。

.. mermaid::

   graph LR
       subgraph "Control Loop @ 100Hz"
           Start["Start Cycle"] --> Check{"Queue Length<br/>< Watermark?"}
           Check -->|"Yes (< 20)"| Trigger["Trigger Inference<br/>(Async Action Goal)"]
           Check -->|"No (>= 20)"| Skip["Skip Inference"]
           Trigger --> Pop
           Skip --> Pop
           Pop["Pop Next Action<br/>from Queue"] --> Execute["Execute via<br/>TopicExecutor"]
           Execute --> Publish["Publish to<br/>ros2_control"]
           Publish --> Start
       end
       
       subgraph "Async Inference Path"
           Goal["send_goal_async()"] --> Wait["Wait for<br/>Goal Acceptance"]
           Wait --> Result["get_result_async()"]
           Result --> Decode["Decode VariantsList<br/>to Tensor"]
           Decode --> Smooth["Temporal Smoothing<br/>(if enabled)"]
           Smooth --> Enqueue["Enqueue Actions"]
       end
       
       Trigger -.->|"non-blocking"| Goal
       Enqueue -.->|"fills queue"| Check

**图：基于拉取的控制流程**

**关键设计决策**：

1. **水位线触发**：当 ``queue_length < watermark_threshold`` （默认 20）时触发推理，确保队列永不为空，同时考虑可变的推理延迟
2. **异步动作客户端**：使用 ``send_goal_async()`` 避免在推理期间阻塞控制循环
3. **动作对齐**：计算推理期间执行了多少动作，以跳过新动作分块中过时的部分

**来源**：
`src/action_dispatch/action_dispatcher_node.py:171-201 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatcher_node.py#L171-L201>`__,
`src/action_dispatch/README.en.md:84-129 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/README.en.md#L84-L129>`__

--------------

核心组件
--------

ActionDispatcherNode
~~~~~~~~~~~~~~~~~~~~

实现基于拉取的调度器的主要 ROS2 节点。

**关键属性**：- ``_queue``：``collections.deque`` 或 ``TemporalSmootherManager``（启用平滑时）- ``_watermark``：触发推理的阈值（默认 20）- ``_control_hz``：控制频率（默认 100.0 Hz）- ``_inference_in_progress``：防止并发推理请求的标志 - ``_plan_length_at_inference_start``：跟踪推理开始时的队列长度

**关键方法**：- ``_control_loop()``：100Hz 定时器回调
`src/action_dispatch/action_dispatcher_node.py:171-201 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatcher_node.py#L171-L201>`__ -
``_request_inference()``：向推理服务发送异步目标
`src/action_dispatch/action_dispatcher_node.py:203-220 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatcher_node.py#L203-L220>`__ -
``_result_cb()``：处理推理结果并将动作入队
`src/action_dispatch/action_dispatcher_node.py:232-278 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatcher_node.py#L232-L278>`__

**实现**：

.. code:: python

   # From action_dispatcher_node.py
   class ActionDispatcherNode(Node):
       def _control_loop(self):
           q_size = self._get_plan_length()
           
           # A. Trigger inference if queue low
           if q_size < self._watermark and not self._inference_in_progress:
               self._request_inference()
           
           # B. Get next action
           if q_size > 0:
               action = self._smoother.get_next_action()  # or queue.popleft()
           
           # C. Execute
           self._executor.execute(action)

该节点使用 ``MutuallyExclusiveCallbackGroup`` 作为控制定时器，以确保线程安全的执行。

**来源**：`src/action_dispatch/action_dispatcher_node.py:38-302 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatcher_node.py#L38-L302>`__

TemporalSmoother
~~~~~~~~~~~~~~~~

实现动作分块的跨帧指数加权平滑。

**关键属性**：- ``config``：``TemporalSmootherConfig``，包含 ``enabled``、``chunk_size``、``temporal_ensemble_coeff`` - ``_current_plan``：当前动作计划（Torch 张量）- ``_weights``：预计算的指数权重 ``exp(-coeff * k)`` - ``_cumsum``：用于归一化的权重累加和 - ``_count``：用于时间对齐的每个动作执行计数

**关键方法**：- ``update(actions, actions_executed)``：将新动作分块与现有计划混合 - ``get_next_action()``：弹出并返回计划中的下一个动作 - ``reset()``：清除内部状态

**来源**：
`src/action_dispatch/action_dispatch/temporal_smoother.py:19-294 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatch/temporal_smoother.py#L19-L294>`__

TopicExecutor
~~~~~~~~~~~~~

用于位置控制的高频基于话题的执行器。

**关键职责**：

- 使用契约动作规范将动作张量索引映射到关节名称
- 向位置控制器话题发布 ``Float64MultiArray``
- 支持契约中的多个动作规范（手臂 + 夹爪）

**实现**：
`src/action_dispatch/action_dispatch/topic_executor.py:1-150 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatch/topic_executor.py#L1-L150>`__

**来源**：
`src/action_dispatch/action_dispatch/topic_executor.py:1-150 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatch/topic_executor.py#L1-L150>`__

--------------

时间平滑深入解析
----------------

问题描述
~~~~~~~~

动作分块模型（ACT、Diffusion Policy）每次推理输出 ``n`` 个动作。在执行过程中：

1. 第一次推理产生动作 ``[a1, a2, ..., a10]`` （n=10）
2. 在推理延迟期间执行了 ``l=3`` 个动作后，第二次推理完成
3. 新推理产生 ``[b1, b2, ..., b10]``
4. 动作 ``[b1, b2, b3]`` 已经过时（对应过去的状态）
5. 剩余的旧动作 ``[a4, ..., a10]`` 和相关的新动作 ``[b4, ..., b10]`` 重叠

**无平滑**：突变过渡导致运动不连续。
**有平滑**：指数加权混合确保连续性。

**来源**：`src/action_dispatch/README.en.md:212-258 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/README.en.md#L212-L258>`__

跨帧平滑算法
~~~~~~~~~~~~

.. mermaid::

   graph TB
       subgraph "Timeline"
           T1["T1: First Inference<br/>[a1, a2, ..., a10]"]
           T2["T2: Execute 3 Actions<br/>(during inference)"]
           T3["T3: Second Inference<br/>[b1, b2, ..., b10]"]
           T4["T4: Align Actions<br/>Skip [b1, b2, b3]"]
           T5["T5: Blend Overlap<br/>[a4..a10] + [b4..b10]"]
           T6["T6: Final Plan<br/>[blended4..10] + [b11..]"]
           
           T1 --> T2
           T2 --> T3
           T3 --> T4
           T4 --> T5
           T5 --> T6
       end
       
       subgraph "Smoothing Logic"
           Old["Old Plan: [a4, a5, a6, a7, a8, a9, a10]<br/>count: [1, 1, 1, 1, 1, 1, 1]"]
           New["New Chunk: [b4, b5, b6, b7, b8, b9, b10]"]
           Weight["weights[k] = exp(-coeff × k)<br/>[0.99, 0.98, 0.97, ...]"]
           Blend["blended[i] = (old[i] × cumsum[count-1] + new[i] × weight[count]) / cumsum[count]"]
           
           Old --> Blend
           New --> Blend
           Weight --> Blend
       end

**图：时间平滑过程**

**数学公式**：

对于重叠区域中的每个位置 ``i``：

::

   blended[i] = (old[i] * cumsum[count[i] - 1] + new[i] * weight[count[i]]) / cumsum[count[i]]

其中：- ``count[i]``：位置 ``i`` 被混合的次数（每次更新时递增）-
``weight[k] = exp(-temporal_ensemble_coeff * k)``：指数衰减权重 - ``cumsum[k]``：到 ``k`` 的权重累加和

**效果**：随着 ``count[i]`` 增加，旧动作通过 ``cumsum[count-1]`` 积累更多权重，使计划逐渐更加倾向于已决定的动作。

**来源**：
`src/action_dispatch/action_dispatch/temporal_smoother.py:95-218 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatch/temporal_smoother.py#L95-L218>`__,
`src/action_dispatch/README.en.md:259-308 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/README.en.md#L259-L308>`__

平滑系数调优
~~~~~~~~~~~~

=========== ============================================================
系数        行为
=========== ============================================================
``0.0``     均匀加权（无偏好）
``0.01``    **默认值**\ （来自 ACT 论文）- 稳定、保守
``> 0.01``  更多权重给旧动作 - 非常稳定但响应较慢
``< 0``     更多权重给新动作 - 响应快但可能导致抖动
=========== ============================================================

**来源**：`src/action_dispatch/README.en.md:323-330 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/README.en.md#L323-L330>`__,
`src/action_dispatch/action_dispatch/temporal_smoother.py:26-31 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatch/temporal_smoother.py#L26-L31>`__

实现细节
~~~~~~~~

平滑器使用 PyTorch 进行高效的张量操作，并支持多种设备：

.. code:: python

   # From temporal_smoother.py:95-150
   def update(self, actions, actions_executed):
       """Update plan with new actions and temporal smoothing."""
       # Skip outdated actions
       new_actions_relevant = new_actions[actions_executed:]
       
       # Calculate overlap length
       overlap_len = min(len(old_plan), len(new_actions_relevant))
       
       # Blend overlapping region
       for i in range(overlap_len):
           count_i = self._count[i]
           weight_i = self._weights[count_i]
           cumsum_i = self._cumsum[count_i]
           
           blended[i] = (old_plan[i] * cumsum_prev + new_actions_relevant[i] * weight_i) / cumsum_i
           self._count[i] += 1
       
       # Append new tail
       blended = torch.cat([blended, new_actions_relevant[overlap_len:]])

**来源**：
`src/action_dispatch/action_dispatch/temporal_smoother.py:95-218 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatch/temporal_smoother.py#L95-L218>`__

--------------

执行策略
--------

TopicExecutor（高频位置控制）
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

用于以 100Hz 向 ros2_control 位置控制器流式传输位置指令。

**契约驱动映射**：1. 从契约读取 ``action_specs``
`src/robot_config/robot_config/contract_utils.py:60-68 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/contract_utils.py#L60-L68>`__ 2. 为动作规范中的每个 ``publish_topic`` 创建话题发布者 3. 使用 ``selector.names`` 将动作张量索引映射到关节名称

**消息格式**：``std_msgs/Float64MultiArray``

**示例**：

.. code:: python

   # From topic_executor.py:80-120
   def execute(self, action):
       """Publish action to position controller topics."""
       for spec in self._action_specs:
           indices = self._spec_to_indices[spec.key]
           values = action[indices]
           
           msg = Float64MultiArray()
           msg.data = values.tolist()
           self._publishers[spec.publish_topic].publish(msg)

**来源**：
`src/action_dispatch/action_dispatch/topic_executor.py:1-150 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatch/topic_executor.py#L1-L150>`__

ActionExecutor（轨迹控制）
~~~~~~~~~~~~~~~~~~~~~~~~~~

用于基于 MoveIt 或轨迹控制器的轨迹控制。

**消息格式**：``trajectory_msgs/JointTrajectory``

**用例**：

- MoveIt 运动规划执行
- 时间参数化轨迹跟踪
- 多点路径执行

**注意**：目前已实现但在标准推理模式中未主动使用。有关基于轨迹的控制，请参阅 `MoveIt 集成 <#10>`__。

**来源**：`src/action_dispatch/README.en.md:145-153 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/README.en.md#L145-L153>`__,
`README.md:36-37 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L36-L37>`__

--------------

ROS 接口
--------

动作客户端
~~~~~~~~~~


.. list-table::
   :header-rows: 1

   * - 方向
     - 接口
     - 类型
     - 描述
   * - **请求**
     - ``~ /DispatchInfer``
     - `` ibrobot _msgs/a ction/D ispatch Infer``
     - 发送推理目标 （异步）
   * - **响应**
     - ``resul t.action_chunk``
     - ``ibr obot_ms gs/msg/ Variant sList``
     - 接收动作 分块张量

**目标字段**：- ``obs_timestamp``：用于观测采样的 ROS 时间戳 - ``inference_id``：唯一请求标识符（用于分布式模式）

**结果字段**：- ``action_chunk``：作为 VariantsList 的张量（由 TensorMsgConverter 解码）- ``chunk_size``：分块中的动作数量 - ``success``：成功标志 - ``message``：失败时的错误消息 - ``inference_latency_ms``：总推理时间

**来源**：
`src/action_dispatch/action_dispatcher_node.py:203-220 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatcher_node.py#L203-L220>`__,
`src/action_dispatch/README.en.md:345-351 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/README.en.md#L345-L351>`__

发布话题
~~~~~~~~


.. list-table::
   :header-rows: 1

   * - 话题
     - 消息类型
     - 频率
     - 描述
   * - ``~/queu e_size``
     - ``std_msgs/Int32``
     - 100 Hz
     - 当前动作 队列长度
   * - ``~/smo othing_e nabled``
     - ``std_msgs/Bool``
     - 100 Hz
     - 平滑状态 标志
   * - ``/ joint_co mmands``
     - ``std_msgs/ Float64MultiArray``
     - 100 Hz
     - 到控制器的 位置指令

**来源**：
`src/action_dispatch/action_dispatcher_node.py:136-138 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatcher_node.py#L136-L138>`__

订阅话题
~~~~~~~~


.. list-table::
   :header-rows: 1

   * - 话题
     - 消息类型
     - QoS
     - 描述
   * - ``/joint _states``
     - ``se nsor_msgs/JointState``
     - Best Effort
     - 关节状态反馈 （可选）

**来源**：
`src/action_dispatch/action_dispatcher_node.py:128-134 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatcher_node.py#L128-L134>`__

服务
~~~~


.. list-table::
   :header-rows: 1

   * - 服务
     - 类型
     - 描述
   * - ``~/reset``
     - ``std_srvs/Empty``
     - 清除队列并重置 平滑器状态
   * - ` `~/toggle_smoothing``
     - ``std_srvs/Empty``
     - 运行时切换 时间平滑

**来源**：
`src/action_dispatch/action_dispatcher_node.py:149-154 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatcher_node.py#L149-L154>`__,
`src/action_dispatch/README.en.md:365-370 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/README.en.md#L365-L370>`__

--------------

配置与参数
----------

启动集成
~~~~~~~~

当使用 ``model_inference`` 控制模式时，动作调度由 ``robot_config`` 启动系统自动实例化。

**启动参数绑定**：

.. code:: python

   # From launch_builders/execution.py:140-180
   dispatcher_node = Node(
       package='action_dispatch',
       executable='action_dispatcher_node',
       parameters=[{
           'queue_size': 100,
           'watermark_threshold': 20,
           'control_frequency': 100.0,
           'robot_config_path': robot_config_path,
           'temporal_smoothing_enabled': True,
           'temporal_ensemble_coeff': 0.01,
           'chunk_size': 100,
       }]
   )

**来源**：
`src/robot_config/robot_config/launch_builders/execution.py:140-220 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/launch_builders/execution.py#L140-L220>`__

节点参数
~~~~~~~~


.. list-table::
   :header-rows: 1

   * - 参数
     - 类型
     - 默认值
     - 描述
   * - ``queue_size``
     - ``int``
     - 100
     - 最大动作队列 长度
   * - ``wate rmark_threshold``
     - ``int``
     - 20
     - 当队列 < 阈值时 触发推理
   * - ``co ntrol_frequency``
     - `` double``
     - 100.0
     - 控制循环 频率（Hz）
   * - ``inferenc e_action_server``
     - `` string``
     - ``/act_infe rence_node/Di spatchInfer``
     - 推理服务名称
   * - ``ro bot_config_path``
     - `` string``
     - ``''``
     - 机器人配置 YAML 路径（用于契约）
   * - ``jo int_state_topic``
     - `` string``
     - ``/j oint_states``
     - 关节状态 订阅话题
   * - ``temporal_sm oothing_enabled``
     - ``bool``
     - ``false``
     - 启用跨帧 平滑
   * - ``temporal _ensemble_coeff``
     - `` double``
     - 0.01
     - 指数平滑 系数
   * - ``chunk_size``
     - ``int``
     - 100
     - 预期的动作 分块大小
   * - ``s moothing_device``
     - `` string``
     - ``''``
     - 平滑计算设备 （``cpu``/``cuda``/ auto）

**来源**：`src/action_dispatch/action_dispatcher_node.py:54-77 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatcher_node.py#L54-L77>`__,
`src/action_dispatch/README.en.md:172-185 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/README.en.md#L172-L185>`__

契约驱动配置
~~~~~~~~~~~~

动作调度使用契约系统自动配置话题映射：

.. code:: yaml

   # From robot_config YAML
   contract:
     actions:
       - key: "action"
         publish_topic: "/arm_position_controller/commands"
         type: "std_msgs/Float64MultiArray"
         selector:
           names: ["joint1", "joint2", "joint3", "joint4", "joint5", "joint6"]

``TopicExecutor`` 从契约读取 ``action_specs`` 以确定：1. 发布到哪些话题（``publish_topic``）2. 包含哪些关节（``selector.names``）3. 如何切片动作张量（自动索引映射）

**来源**：
`src/action_dispatch/action_dispatcher_node.py:106-122 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatcher_node.py#L106-L122>`__,
`src/robot_config/robot_config/contract_utils.py:60-70 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/contract_utils.py#L60-L70>`__

--------------

运行时行为示例
--------------

典型执行序列
~~~~~~~~~~~~

.. mermaid::

   sequenceDiagram
       participant Timer as "Control Timer<br/>(100Hz)"
       participant Dispatcher as "ActionDispatcherNode"
       participant Client as "Action Client"
       participant Server as "lerobot_policy_node"
       participant Smoother as "TemporalSmoother"
       participant Executor as "TopicExecutor"
       participant Hardware as "ros2_control"
       
       Note over Timer,Hardware: Initialization
       Dispatcher->>Client: wait_for_server()
       Client-->>Dispatcher: Server available
       
       Note over Timer,Hardware: Control Loop Cycle
       Timer->>Dispatcher: _control_loop()
       Dispatcher->>Dispatcher: Check queue_length < 20
       Dispatcher->>Client: send_goal_async(obs_timestamp)
       Client->>Server: DispatchInfer Goal
       
       Note over Server: Inference (30-100ms)
       Server-->>Client: Result (action_chunk)
       Client->>Dispatcher: _result_cb()
       Dispatcher->>Smoother: update(actions, actions_executed=3)
       Smoother->>Smoother: Blend overlap region
       Smoother-->>Dispatcher: new_plan_length=107
       
       loop Every 10ms
           Timer->>Dispatcher: _control_loop()
           Dispatcher->>Smoother: get_next_action()
           Smoother-->>Dispatcher: action[t]
           Dispatcher->>Executor: execute(action)
           Executor->>Hardware: Float64MultiArray
       end

**图：运行时执行序列**

**延迟分解**\ （典型）：- 推理触发延迟：< 1ms（异步目标发送）- 模型推理：30-100ms（取决于模型/硬件）- 平滑更新：< 1ms（张量操作）- 动作执行：10ms 周期（100Hz）

**队列动态**：- 初始状态：队列为空，立即触发推理 - 第一次推理后：队列 = 100 个动作 - 执行速率：10 个动作/秒（100Hz）- 水位线触发：当队列 = 20 时，触发下一次推理（第一次后约 8 秒）- 推理期间：消耗约 3 个动作（30ms 延迟），接收 100 个新动作 → 净增 +97

**来源**：
`src/action_dispatch/action_dispatcher_node.py:171-278 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatcher_node.py#L171-L278>`__

--------------

高级用法
--------

手动控制
~~~~~~~~

.. code:: bash

   # Start dispatcher node standalone
   ros2 run action_dispatch action_dispatcher_node \
       --ros-args \
       -p queue_size:=100 \
       -p watermark_threshold:=20 \
       -p temporal_smoothing_enabled:=true \
       -p robot_config_path:=/path/to/robot_config.yaml

   # Monitor queue size
   ros2 topic echo /action_dispatcher/queue_size

   # Toggle smoothing at runtime
   ros2 service call /action_dispatcher/toggle_smoothing std_srvs/srv/Empty

   # Reset dispatcher state
   ros2 service call /action_dispatcher/reset std_srvs/srv/Empty

**来源**：`src/action_dispatch/README.en.md:156-341 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/README.en.md#L156-L341>`__

Python API 用法
~~~~~~~~~~~~~~~

.. code:: python

   from action_dispatch import TemporalSmoother, TemporalSmootherConfig

   # Create smoother
   config = TemporalSmootherConfig(
       enabled=True,
       chunk_size=100,
       temporal_ensemble_coeff=0.01,
   )
   smoother = TemporalSmoother(config)

   # Update with new actions
   actions = model.inference(obs)  # shape: (100, action_dim)
   smoother.update(actions, actions_executed=30)

   # Execute smoothed actions
   while smoother.plan_length > 0:
       action = smoother.get_next_action()
       robot.execute(action)

**来源**：`src/action_dispatch/README.en.md:379-413 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/README.en.md#L379-L413>`__

--------------

测试
----

该包包含时间平滑算法的全面单元测试：

-  **配置验证**：
   `src/action_dispatch/test/test_temporal_smoother.py:23-48 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/test/test_temporal_smoother.py#L23-L48>`__
-  **基本更新/获取**：
   `src/action_dispatch/test/test_temporal_smoother.py:50-95 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/test/test_temporal_smoother.py#L50-L95>`__
-  **跨帧平滑**：
   `src/action_dispatch/test/test_temporal_smoother.py:97-150 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/test/test_temporal_smoother.py#L97-L150>`__
-  **管理器运行时切换**：
   `src/action_dispatch/test/test_temporal_smoother.py:152-200 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/test/test_temporal_smoother.py#L152-L200>`__

**运行测试**：

.. code:: bash

   cd src/action_dispatch
   pytest test/test_temporal_smoother.py -v

**来源**：
`src/action_dispatch/test/test_temporal_smoother.py:1-300 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/test/test_temporal_smoother.py#L1-L300>`__

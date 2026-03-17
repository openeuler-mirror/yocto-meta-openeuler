回合录制
========

.. raw:: html

   <details>

相关源文件

以下文件用于生成此 wiki 页面的上下文：

-  `.shrc_local <.shrc_local>`__
-  `src/action_dispatch/action_dispatch/action_dispatcher_node.py <src/action_dispatch/action_dispatch/action_dispatcher_node.py>`__
-  `src/dataset_tools/README.md <src/dataset_tools/README.md>`__
-  `src/dataset_tools/dataset_tools/init.py <src/dataset_tools/dataset_tools/__init__.py>`__
-  `src/dataset_tools/dataset_tools/bag_to_lerobot.py <src/dataset_tools/dataset_tools/bag_to_lerobot.py>`__
-  `src/dataset_tools/dataset_tools/episode_recorder.py <src/dataset_tools/dataset_tools/episode_recorder.py>`__
-  `src/dataset_tools/dataset_tools/record_cli.py <src/dataset_tools/dataset_tools/record_cli.py>`__
-  `src/dataset_tools/package.xml <src/dataset_tools/package.xml>`__
-  `src/dataset_tools/resource/dataset_tools <src/dataset_tools/resource/dataset_tools>`__
-  `src/dataset_tools/setup.cfg <src/dataset_tools/setup.cfg>`__
-  `src/dataset_tools/setup.py <src/dataset_tools/setup.py>`__
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

回合录制为 IB-Robot 框架提供了一个 **触发的、分集的数据收集系统**。它使用户能够按需录制单个演示（回合），每个回合保存为单独的 ROS2 bag 文件，包含语义元数据（任务提示）。本文档介绍 ``episode_recorder`` Action Server 和 ``record_cli`` 交互式客户端。

**相关页面**：- 有关生成被录制演示的遥操作界面，请参阅 `遥操作与数据收集 <#9.1>`__ - 有关将录制的 bag 转换为 LeRobot 数据集，请参阅 `数据集转换 <#9.3>`__ - 有关连续（一体化）录制模式，请参阅 `Recording launch builder <src/robot_config/robot_config/launch_builders/recording.py:21-100>`__\ () 中的启动配置

--------------

录制模式
--------

IB-Robot 支持两种录制范式，通过 ``record_mode`` 启动参数选择：


.. list-table::
   :header-rows: 1

   * - 模式
     - 触发方式
     - 输出
     - 用例
   * - **连续**
     - 启动时
     - 包含所有数据 的单个 bag 文件
     - 长时间数据收集、 调试
   * - **分集**
     - Action Server 目标
     - 每个回合一个 bag，带提示 元数据
     - 语义任务导向的 训练数据集

本文档重点介绍 **分集录制**。

**来源**：
`src/robot_config/robot_config/launch_builders/recording.py:21-56 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/launch_builders/recording.py#L21-L56>`__

--------------

架构概述
--------

.. mermaid::

   graph TB
       subgraph "Launch System"
           LAUNCH["robot.launch.py<br/>(record:=true record_mode:=episodic)"]
           BUILDER["generate_recording_nodes()<br/>recording.py:102-168"]
       end
       
       subgraph "Episode Recorder Node"
           direction TB
           NODE["EpisodeRecorderServer<br/>episode_recorder.py:161-677"]
           
           ACTION_SRV["RecordEpisode Action Server<br/>action name: 'record_episode'"]
           CANCEL_SRV["Trigger Service<br/>'record_episode/cancel'"]
           
           SUBSCRIPTIONS["Topic Subscriptions<br/>(created from Contract)"]
           
           WRITER["rosbag2_py.SequentialWriter"]
           
           TIMERS["Episode Timers<br/>- Feedback (0.5Hz)<br/>- Timeout (max_duration_s)"]
           
           NODE --> ACTION_SRV
           NODE --> CANCEL_SRV
           NODE --> SUBSCRIPTIONS
           NODE --> WRITER
           NODE --> TIMERS
       end
       
       subgraph "Record CLI Client"
           CLI["RecordCLI Node<br/>record_cli.py:20-85"]
           INPUT["Interactive Prompt<br/>cli_loop()"]
           ACTION_CLIENT["ActionClient<br/>(RecordEpisode)"]
           
           CLI --> ACTION_CLIENT
           INPUT --> CLI
       end
       
       subgraph "Configuration"
           ROBOT_CONFIG["robot_config.yaml<br/>Contract (Single Source of Truth)"]
           CONTRACT["Contract.observations<br/>Contract.actions<br/>Contract.rate_hz<br/>Contract.max_duration_s"]
           
           ROBOT_CONFIG --> CONTRACT
       end
       
       subgraph "Output"
           BAG_DIR["~/rosbag_demos/episodes/<br/><sec>_<nsec>/"]
           MCAP["*.mcap file"]
           METADATA["metadata.yaml<br/>(with operator prompt)"]
           
           BAG_DIR --> MCAP
           BAG_DIR --> METADATA
       end
       
       LAUNCH --> BUILDER
       BUILDER -->|spawns| NODE
       
       CONTRACT -.->|topic list| SUBSCRIPTIONS
       
       INPUT -->|"prompt text"| ACTION_CLIENT
       ACTION_CLIENT -->|RecordEpisode.Goal| ACTION_SRV
       
       ACTION_SRV -->|feedback| ACTION_CLIENT
       ACTION_SRV -.->|controls| WRITER
       
       SUBSCRIPTIONS -->|messages| WRITER
       
       WRITER -->|writes| BAG_DIR
       
       TIMERS -.->|timeout/feedback| ACTION_SRV
       
       style ROBOT_CONFIG fill:#fff3e0,stroke:#ff9800,stroke-width:3px
       style CONTRACT fill:#fff3e0,stroke:#ff9800,stroke-width:2px

**分析**：录制系统遵循 ROS2 Action Server 模式。``EpisodeRecorderServer`` 节点暴露一个 ``record_episode`` Action Server，``record_cli`` 客户端可以触发。收到目标后，服务器打开 ``rosbag2_py.SequentialWriter``，从 Contract 注册所有话题，并将传入消息直接流式写入磁盘。两个定时器提供周期性反馈并强制执行最大持续时间。当回合完成（通过超时、取消或错误）时，服务器关闭写入器并将操作员的提示补丁到 ``metadata.yaml``。

**来源**：
`src/dataset_tools/dataset_tools/episode_recorder.py:1-60 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/dataset_tools/episode_recorder.py#L1-L60>`__,
`src/dataset_tools/dataset_tools/record_cli.py:1-23 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/dataset_tools/record_cli.py#L1-L23>`__,
`src/robot_config/robot_config/launch_builders/recording.py:102-168 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/launch_builders/recording.py#L102-L168>`__

--------------

回合录制服务器
--------------

契约驱动的订阅
~~~~~~~~~~~~~~

``EpisodeRecorderServer`` 从 ``robot_config.yaml`` 加载其话题配置作为 **单一事实来源**。这确保录制和推理使用相同的话题映射。

.. mermaid::

   graph LR
       subgraph "Initialization Flow"
           INIT["__init__()<br/>episode_recorder.py:169-273"]
           LOAD["Load robot_config_path parameter"]
           CONTRACT["load_robot_config().to_contract()<br/>episode_recorder.py:199-206"]
           
           UNION["Merge observations + tasks + actions<br/>episode_recorder.py:230-236"]
           
           SUBS["Create subscriptions for each topic<br/>_make_sub() episode_recorder.py:388-439"]
           
           INIT --> LOAD
           LOAD --> CONTRACT
           CONTRACT --> UNION
           UNION --> SUBS
       end
       
       subgraph "Contract Structure"
           OBS["contract.observations<br/>(topic, type, qos)"]
           TASKS["contract.tasks<br/>(topic, type, qos)"]
           ACTS["contract.actions<br/>(publish_topic, type, qos)"]
           
           UNION --> OBS
           UNION --> TASKS
           UNION --> ACTS
       end
       
       subgraph "Subscription Behavior"
           CB["Callback: _make_sub.cb()<br/>episode_recorder.py:401-436"]
           CHECK["Check: is_recording?"]
           SERIALIZE["serialize_message(msg)"]
           WRITE["writer.write(topic, data, ts_ns)<br/>episode_recorder.py:425"]
           
           SUBS --> CB
           CB --> CHECK
           CHECK -->|Yes| SERIALIZE
           SERIALIZE --> WRITE
       end

**关键实现细节**：

1. **话题列表构建** `episode_recorder.py:230-236 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/episode_recorder.py#L230-L236>`__：服务器将 Contract 中的 ``observations``、``tasks`` 和 ``actions`` 合并为统一的 ``_topics`` 列表，包含 ``(topic, type, qos)`` 元组。

2. **持久订阅** `episode_recorder.py:238-242 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/episode_recorder.py#L238-L242>`__：订阅在节点启动时创建一次，并在回合之间持久存在，以避免 DDS 重新协商开销。

3. **条件写入** `episode_recorder.py:401-436 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/episode_recorder.py#L401-L436>`__：订阅回调在写入前检查 ``_flags.is_recording`` 标志。这允许订阅在回合之间保持活动状态而不产生冗余数据。

4. **时间戳策略** `episode_recorder.py:419 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/episode_recorder.py#L419>`__：始终使用到达时间（``get_clock().now().nanoseconds``）作为写入时间戳，确保确定性排序，无论消息头时间戳如何。

**来源**：
`src/dataset_tools/dataset_tools/episode_recorder.py:169-273 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/dataset_tools/episode_recorder.py#L169-L273>`__,
`src/dataset_tools/dataset_tools/episode_recorder.py:230-242 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/dataset_tools/episode_recorder.py#L230-L242>`__,
`src/dataset_tools/dataset_tools/episode_recorder.py:388-439 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/dataset_tools/episode_recorder.py#L388-L439>`__

--------------

Action Server 生命周期
~~~~~~~~~~~~~~~~~~~~~~~

.. mermaid::

   stateDiagram-v2
       [*] --> Idle: Node starts
       
       Idle --> GoalEvaluation: RecordEpisode.Goal received
       
       GoalEvaluation --> Idle: REJECT (already recording)
       GoalEvaluation --> Executing: ACCEPT
       
       Executing --> WriterOpen: Open rosbag2 writer
       WriterOpen --> TopicRegistration: Register topics from Contract
       TopicRegistration --> TimersStart: Start feedback + timeout timers
       
       TimersStart --> Recording: Set is_recording=True
       
       Recording --> Recording: Write messages continuously
       
       Recording --> Stopping: Cancel requested OR timeout OR error
       
       Stopping --> WriterClose: Close writer, destroy timers
       WriterClose --> MetadataPatch: Write operator prompt to metadata.yaml
       MetadataPatch --> ResultEmit: Emit Result (success/canceled/abort)
       
       ResultEmit --> Idle: Ready for next episode
       
       note right of Recording
           Subscriptions push messages to writer
           _flags.is_recording controls writes
       end note
       
       note right of Stopping
           3 stop conditions:
           - is_cancel_requested
           - timeout timer fires
           - fatal_error (write exception)
       end note

**目标回调** `episode_recorder.py:277-288 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/episode_recorder.py#L277-L288>`__：如果 ``_flags.is_recording`` 为 ``True``，则拒绝新目标，防止并发回合。

**执行回调** `episode_recorder.py:551-637 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/episode_recorder.py#L551-L637>`__：主编排循环：

1. **设置阶段** `episode_recorder.py:564-604 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/episode_recorder.py#L564-L604>`__：

   -  生成唯一目录：``<bag_base_dir>/<sec>_<nsec>``
      `episode_recorder.py:501-517 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/episode_recorder.py#L501-L517>`__
   -  使用 MCAP 存储打开写入器 `episode_recorder.py:584-587 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/episode_recorder.py#L584-L587>`__
   -  从 Contract 注册所有话题
      `episode_recorder.py:586-587 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/episode_recorder.py#L586-L587>`__
   -  启动反馈定时器（0.5 Hz）和超时定时器
      `episode_recorder.py:602-603 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/episode_recorder.py#L602-L603>`__

2. **录制阶段** `episode_recorder.py:606-616 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/episode_recorder.py#L606-L616>`__：

   -  阻塞于 ``_episode_done_evt.wait(timeout=0.1)``
      `episode_recorder.py:616 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/episode_recorder.py#L616>`__
   -  检查取消请求：``goal_handle.is_cancel_requested``
      `episode_recorder.py:611 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/episode_recorder.py#L611>`__
   -  订阅回调异步写入消息

3. **完成阶段** `episode_recorder.py:619-636 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/episode_recorder.py#L619-L636>`__：

   -  关闭写入器 `episode_recorder.py:530-531 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/episode_recorder.py#L530-L531>`__
   -  用提示补丁元数据 `episode_recorder.py:534 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/episode_recorder.py#L534>`__
   -  销毁定时器 `episode_recorder.py:536-542 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/episode_recorder.py#L536-L542>`__
   -  发出终端转换（成功/取消/中止）
      `episode_recorder.py:624-636 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/episode_recorder.py#L624-L636>`__

**错误处理** `episode_recorder.py:428-435 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/episode_recorder.py#L428-L435>`__：写入失败设置 ``_flags.fatal_error`` 并发出 episode_done 事件信号。执行循环检测到此情况并转换为 ABORTED 状态。

**来源**：
`src/dataset_tools/dataset_tools/episode_recorder.py:277-288 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/dataset_tools/episode_recorder.py#L277-L288>`__,
`src/dataset_tools/dataset_tools/episode_recorder.py:551-637 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/dataset_tools/episode_recorder.py#L551-L637>`__,
`src/dataset_tools/dataset_tools/episode_recorder.py:501-517 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/dataset_tools/episode_recorder.py#L501-L517>`__

--------------

元数据嵌入
~~~~~~~~~~

服务器将操作员的提示嵌入到 bag 的 ``metadata.yaml`` 文件中，供下游数据集转换使用。

**实现** `episode_recorder.py:641-677 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/episode_recorder.py#L641-L677>`__：

.. code:: python

   def _write_episode_metadata(self, bag_dir: Path, prompt: str) -> None:
       """Patch the bag's metadata.yaml with the operator prompt (best-effort).
       
       Retries multiple times to handle storage backend flush delays.
       """
       if not prompt:
           return
       meta_path = bag_dir / "metadata.yaml"
       # Retry logic for storage backend flush
       for _ in range(METADATA_RETRIES):  # 20 retries
           try:
               with meta_path.open("r", encoding="utf-8") as f:
                   meta = yaml.safe_load(f) or {}
               info = meta.get("rosbag2_bagfile_information") or {}
               custom = info.get("custom_data") or {}
               
               # Store under lerobot.operator_prompt key
               custom["lerobot.operator_prompt"] = str(prompt)
               info["custom_data"] = custom
               meta["rosbag2_bagfile_information"] = info
               
               # Write back atomically
               with meta_path.open("w", encoding="utf-8") as f:
                   yaml.safe_dump(meta, f)
               return  # Success
           except (FileNotFoundError, yaml.YAMLError):
               time.sleep(METADATA_RETRY_PERIOD_S)  # 0.1s delay

**重试逻辑**：存储后端（MCAP）在写入器关闭时可能仍在刷新 ``metadata.yaml``。该函数以 0.1 秒延迟重试最多 20 次 `episode_recorder.py:93-94 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/episode_recorder.py#L93-L94>`__。

**元数据结构**：

.. code:: yaml

   rosbag2_bagfile_information:
     custom_data:
       lerobot.operator_prompt: "get the can from the table"

**消费**：``bag_to_lerobot`` 转换器读取此提示并将其存储为 LeRobot 数据集帧中的 ``task`` 字段 `bag_to_lerobot.py:416-420 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/bag_to_lerobot.py#L416-L420>`__。

**来源**：
`src/dataset_tools/dataset_tools/episode_recorder.py:641-677 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/dataset_tools/episode_recorder.py#L641-L677>`__,
`src/dataset_tools/dataset_tools/episode_recorder.py:93-94 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/dataset_tools/episode_recorder.py#L93-L94>`__,
`src/dataset_tools/dataset_tools/bag_to_lerobot.py:416-420 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/dataset_tools/bag_to_lerobot.py#L416-L420>`__

--------------

Record CLI 客户端
-----------------

``record_cli`` 可执行文件提供了一个交互式界面来触发录制。

.. mermaid::

   graph TB
       subgraph "Main Thread"
           MAIN["main()<br/>record_cli.py:125-141"]
           CLI_LOOP["cli_loop(node)<br/>record_cli.py:87-123"]
           INPUT["input('Prompt > ')"]
           
           MAIN --> CLI_LOOP
           CLI_LOOP --> INPUT
       end
       
       subgraph "Background Thread"
           SPIN["rclpy.spin(node)<br/>Handles callbacks"]
       end
       
       subgraph "RecordCLI Node"
           NODE["RecordCLI()<br/>record_cli.py:20-85"]
           ACTION_CLIENT["ActionClient<br/>(RecordEpisode, 'record_episode')"]
           CANCEL_CLIENT["Service Client<br/>(Trigger, 'record_episode/cancel')"]
           
           NODE --> ACTION_CLIENT
           NODE --> CANCEL_CLIENT
       end
       
       subgraph "Goal Flow"
           SEND["send_goal(prompt)<br/>record_cli.py:34-44"]
           RESP["goal_response_callback()<br/>record_cli.py:46-55"]
           RESULT["get_result_callback()<br/>record_cli.py:57-65"]
           
           SEND --> ACTION_CLIENT
           ACTION_CLIENT --> RESP
           RESP --> RESULT
       end
       
       subgraph "Feedback Flow"
           FB["feedback_callback()<br/>record_cli.py:67-72"]
           DISPLAY["Print: [Time Left: Xs] message"]
           
           FB --> DISPLAY
       end
       
       MAIN -.->|spawn| SPIN
       INPUT -->|"prompt text"| SEND
       INPUT -->|"Enter (stop)"| CANCEL_CLIENT
       
       ACTION_CLIENT -.->|feedback| FB
       ACTION_CLIENT -.->|result| RESULT

**初始化** `record_cli.py:21-32 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/record_cli.py#L21-L32>`__：- 创建用于发送 ``RecordEpisode`` 目标的 ``ActionClient`` - 创建用于通过 ``Trigger`` 服务提前取消的服务客户端 - 等待 Action Server 可用

**交互循环** `record_cli.py:87-123 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/record_cli.py#L87-L123>`__：

.. code:: python

   def cli_loop(node):
       last_prompt = "default_task"
       
       while rclpy.ok():
           prompt = input("Prompt > ")
           if prompt.strip().lower() in ['q', 'quit']:
               break
           if not prompt.strip():
               prompt = last_prompt  # Reuse last prompt
           else:
               last_prompt = prompt.strip()
           
           node.send_goal(prompt)  # Start recording
           input()  # Wait for user to press Enter
           node.cancel_recording()  # Stop recording

**线程模型**：CLI 在后台线程运行 ``rclpy.spin()`` `record_cli.py:130-131 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/record_cli.py#L130-L131>`__，这样主线程中的 ``input()`` 不会阻塞 Action 回调。

**反馈显示** `record_cli.py:67-72 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/record_cli.py#L67-L72>`__：使用 ``\r`` 在同一行打印实时进度：

::

   [Time Left: 87s] writing… total=1234

**来源**：`src/dataset_tools/dataset_tools/record_cli.py:20-85 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/dataset_tools/record_cli.py#L20-L85>`__,
`src/dataset_tools/dataset_tools/record_cli.py:87-123 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/dataset_tools/record_cli.py#L87-L123>`__,
`src/dataset_tools/dataset_tools/record_cli.py:125-141 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/dataset_tools/record_cli.py#L125-L141>`__

--------------

录制工作流程
------------

端到端流程
~~~~~~~~~~

.. mermaid::

   sequenceDiagram
       participant User
       participant CLI as record_cli
       participant Server as episode_recorder
       participant Writer as rosbag2 Writer
       participant Topics as ROS2 Topics
       
       User->>CLI: ros2 run dataset_tools record_cli
       CLI->>Server: Connect to Action Server
       
       User->>CLI: Enter prompt: "get the can"
       CLI->>Server: RecordEpisode.Goal<br/>(prompt="get the can")
       
       Server->>Server: goal_callback()<br/>Accept if not recording
       Server->>Writer: Open bag directory<br/>~/rosbag_demos/episodes/1234567890_123456789/
       Server->>Writer: Register topics from Contract
       Server->>Server: Set is_recording=True<br/>Start timers
       
       Server->>CLI: Goal ACCEPTED
       CLI->>User: "🔴 RECORDING STARTED"
       
       loop Every 0.5s
           Server->>CLI: Feedback<br/>(seconds_remaining, message_count)
           CLI->>User: Display progress
       end
       
       loop Continuous
           Topics->>Server: ROS2 messages
           Server->>Writer: writer.write(topic, data, ts_ns)
       end
       
       User->>CLI: Press Enter (stop early)
       CLI->>Server: Call cancel service
       Server->>Server: Set stop_requested=True
       
       Server->>Writer: Close writer
       Server->>Writer: Patch metadata.yaml<br/>with "get the can" prompt
       Server->>Server: Destroy timers
       
       Server->>CLI: Result<br/>(success=True, message="Wrote 1894 messages")
       CLI->>User: "✅ RECORDING SAVED"
       
       Server->>Server: Reset to Idle state

**来源**：
`src/dataset_tools/dataset_tools/episode_recorder.py:551-637 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/dataset_tools/episode_recorder.py#L551-L637>`__,
`src/dataset_tools/dataset_tools/record_cli.py:34-85 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/dataset_tools/record_cli.py#L34-L85>`__

--------------

启动集成
~~~~~~~~

录制系统通过 ``recording`` 启动构建器与机器人启动系统集成。

**启动命令**：

.. code:: bash

   ros2 launch robot_config robot.launch.py \
       robot_config:=so101_single_arm \
       control_mode:=teleop \
       record:=true \
       record_mode:=episodic \
       use_sim:=false

**构建器实现** `recording.py:102-168 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/recording.py#L102-L168>`__：

.. code:: python

   def generate_episodic_recording_node(robot_config: dict, active_control_mode: str):
       """Generate episodic recording node using episode_recorder Action Server."""
       
       # Validate Contract exists
       contract = robot_config.get('contract')
       if not contract:
           print("[ERROR] No 'contract' section found in robot configuration.")
           return []
       
       # Get bag output directory
       recording_config = robot_config.get('recording', {})
       custom_dir = recording_config.get('bag_base_dir', '~/rosbag_demos/episodes')
       bag_base_dir = os.path.expanduser(custom_dir)
       
       # Get robot_config file path (Single Source of Truth)
       robot_config_path = robot_config.get('_config_path', '')
       
       # Create episode_recorder node
       episode_recorder_node = Node(
           package='dataset_tools',
           executable='episode_recorder',
           name='episode_recorder',
           output='screen',
           parameters=[
               {'robot_config_path': robot_config_path},
               {'bag_base_dir': bag_base_dir},
           ],
       )
       
       print("[IMPORTANT] Use SEPARATE TERMINAL to trigger recordings:")
       print("    ros2 run dataset_tools record_cli")
       
       return [episode_recorder_node]

**关键模式**：启动系统将 ``robot_config_path`` 传递给录制器，使其能够在运行时加载 Contract。这消除了硬编码的话题列表。

**来源**：
`src/robot_config/robot_config/launch_builders/recording.py:102-168 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/launch_builders/recording.py#L102-L168>`__,
`src/robot_config/launch/robot.launch.py:315-334 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/launch/robot.launch.py#L315-L334>`__

--------------

输出结构
~~~~~~~~

每个回合存储在唯一目录中：

::

   ~/rosbag_demos/episodes/
   └── 1234567890_123456789/           # <sec>_<nsec> from system time
       ├── metadata.yaml                # Bag metadata with operator prompt
       └── 1234567890_123456789_0.mcap  # MCAP data file

**目录命名** `episode_recorder.py:501-517 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/episode_recorder.py#L501-L517>`__：

.. code:: python

   def _unique_bag_dir(self) -> Path:
       """Generate unique bag directory name based on system time."""
       sec = int(time.time())
       nsec = int((time.time() - sec) * 1e9)
       base = f"{sec:010d}_{nsec:09d}"
       bag_dir = self._bag_base / base
       suffix = 1
       while bag_dir.exists():  # Collision protection
           bag_dir = self._bag_base / f"{base}_{suffix}"
           suffix += 1
       return bag_dir

**元数据示例**：

.. code:: yaml

   rosbag2_bagfile_information:
     version: 8
     storage_identifier: mcap
     duration:
       nanoseconds: 89456732100
     starting_time:
       nanoseconds_since_epoch: 1234567890123456789
     message_count: 1894
     topics_with_message_count:
       - topic_metadata:
           name: /joint_states
           type: sensor_msgs/msg/JointState
         message_count: 1780
       - topic_metadata:
           name: /camera/front/image_raw
           type: sensor_msgs/msg/Image
         message_count: 57
     custom_data:
       lerobot.operator_prompt: "get the can from the table"

**来源**：
`src/dataset_tools/dataset_tools/episode_recorder.py:501-517 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/dataset_tools/episode_recorder.py#L501-L517>`__,
`src/dataset_tools/dataset_tools/episode_recorder.py:641-677 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/dataset_tools/episode_recorder.py#L641-L677>`__

--------------

配置
----

参数
~~~~

``episode_recorder`` 节点接受以下参数：


.. list-table::
   :header-rows: 1

   * - 参数
     - 类型
     - 默认值
     - 描述
   * - ``ro bot_config_path``
     - string
     - * *(required)**
     - robot_config.yaml 的路径（单一事实 来源）
   * - ``bag_base_dir``
     - string
     - ``/t mp/episodes``
     - 回合存储的基础目录
   * - ``storage _preset_profile``
     - string
     - ``""``
     - MCAP 压缩预设配置 （例如，``"zstd_fast"``）
   * - ``sto rage_config_uri``
     - string
     - ``""``
     - rosbag2 存储配置文件 的路径

**来源**：
`src/dataset_tools/dataset_tools/episode_recorder.py:179-221 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/dataset_tools/episode_recorder.py#L179-L221>`__

--------------

契约配置
~~~~~~~~

录制器从 ``robot_config.yaml`` 中的 Contract 派生其话题列表。示例配置：

.. code:: yaml

   robot:
     name: so101_single_arm
     
     contract:
       rate_hz: 20
       max_duration_s: 90.0
       
       observations:
         - key: observation.images.front
           topic: /camera/front/image_raw
           type: sensor_msgs/msg/Image
           
         - key: observation.state
           topic: /joint_states
           type: sensor_msgs/msg/JointState
           selector:
             names: [position.1, position.2, position.3, position.4, position.5, position.6]
       
       actions:
         - key: action
           selector:
             names: [action.0, action.1, action.2, action.3, action.4, action.5]
           publish:
             topic: /arm_position_controller/commands
             type: std_msgs/msg/Float64MultiArray

**录制的话题**：- 所有 ``observations[].topic`` 条目 - 所有 ``tasks[].topic`` 条目（如果存在）- 所有 ``actions[].publish_topic`` 条目

**最大持续时间**：``max_duration_s`` 参数 `episode_recorder.py:577 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/episode_recorder.py#L577>`__ 控制超时定时器。默认为 90 秒。

**来源**：
`src/dataset_tools/dataset_tools/episode_recorder.py:230-236 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/dataset_tools/episode_recorder.py#L230-L236>`__,
`src/robot_config/robot_config/config/robots/so101_single_arm.yaml:1-200 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/config/robots/so101_single_arm.yaml#L1-L200>`__

--------------

存储后端
--------

录制器使用带有 MCAP 存储格式的 ``rosbag2_py.SequentialWriter``。

**写入器初始化** `episode_recorder.py:345-378 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/episode_recorder.py#L345-L378>`__：

.. code:: python

   def _open_writer(self, bag_uri: str, storage_id: str) -> rosbag2_py.SequentialWriter:
       """Open rosbag2 writer with conservative defaults and optional presets."""
       storage_options = rosbag2_py.StorageOptions(uri=bag_uri, storage_id=storage_id)
       
       # Optional tuning (MCAP-specific)
       if self._storage_preset_profile:
           storage_options.storage_preset_profile = self._storage_preset_profile
       if self._storage_config_uri:
           storage_options.storage_config_uri = self._storage_config_uri
       
       converter_options = rosbag2_py.ConverterOptions(
           input_serialization_format="cdr",
           output_serialization_format="cdr"
       )
       
       writer = rosbag2_py.SequentialWriter()
       writer.open(storage_options, converter_options)
       return writer

**话题注册** `episode_recorder.py:380-386 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/episode_recorder.py#L380-L386>`__：

.. code:: python

   def _register_topic(self, topic: str, type_str: str) -> None:
       """Register a topic with the active writer (idempotent per writer)."""
       meta = rosbag2_py.TopicMetadata(
           name=topic, type=type_str, serialization_format="cdr"
       )
       self._ws.writer.create_topic(meta)

**消息写入** `episode_recorder.py:422-427 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/episode_recorder.py#L422-L427>`__：

.. code:: python

   ts_ns = self.get_clock().now().nanoseconds
   data = serialize_message(msg)
   with self._ws.writer_lock:
       if self._ws.writer is not None:
           self._ws.writer.write(_topic, data, ts_ns)

**线程安全**：``_ws.writer_lock`` 互斥锁 `episode_recorder.py:148 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/episode_recorder.py#L148>`__ 保护来自订阅回调和执行循环的并发访问。

**来源**：
`src/dataset_tools/dataset_tools/episode_recorder.py:345-378 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/dataset_tools/episode_recorder.py#L345-L378>`__,
`src/dataset_tools/dataset_tools/episode_recorder.py:380-386 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/dataset_tools/episode_recorder.py#L380-L386>`__,
`src/dataset_tools/dataset_tools/episode_recorder.py:422-427 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/dataset_tools/episode_recorder.py#L422-L427>`__

--------------

诊断与可观测性
--------------

每话题计数器
~~~~~~~~~~~~

服务器跟踪消息计数以进行调试：

.. code:: python

   @dataclass(slots=True)
   class _TopicCounter:
       """Per-topic counters."""
       seen: int = 0      # Messages received by subscription
       written: int = 0   # Messages successfully written to bag

**更新点**：- ``seen`` 在回调入口时递增 `episode_recorder.py:404-405 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/episode_recorder.py#L404-L405>`__ - ``written`` 在成功写入后递增 `episode_recorder.py:426-427 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/episode_recorder.py#L426-L427>`__

**用法**：总消息计数在反馈和最终结果中报告 `episode_recorder.py:444-445 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/episode_recorder.py#L444-L445>`__。

**来源**：
`src/dataset_tools/dataset_tools/episode_recorder.py:101-115 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/dataset_tools/episode_recorder.py#L101-L115>`__,
`src/dataset_tools/dataset_tools/episode_recorder.py:404-427 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/dataset_tools/episode_recorder.py#L404-L427>`__,
`src/dataset_tools/dataset_tools/episode_recorder.py:444-445 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/dataset_tools/episode_recorder.py#L444-L445>`__

--------------

反馈定时器
~~~~~~~~~~

反馈定时器在录制期间以 2 Hz `episode_recorder.py:92 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/episode_recorder.py#L92>`__ 运行：

.. code:: python

   def _start_feedback_timer(self, end_time: Time) -> None:
       """(Re)create the 2 Hz feedback timer."""
       fb = RecordEpisode.Feedback()
       
       def _tick() -> None:
           if not self._flags.is_recording or self._current_goal_handle is None:
               return
           if self._current_goal_handle.is_cancel_requested:
               return
           
           now = self.get_clock().now()
           remaining_ns = max(0, end_time.nanoseconds - now.nanoseconds)
           fb.seconds_remaining = remaining_ns // 1_000_000_000
           fb.feedback_message = f"writing… total={self._get_total_messages_written()}"
           
           self._current_goal_handle.publish_feedback(fb)
       
       self._feedback_timer = self.create_timer(FEEDBACK_PERIOD_S, _tick)

**反馈字段**：- ``seconds_remaining``（int）：距离超时的时间 - ``feedback_message``（string）：已写入的总消息数

**来源**：
`src/dataset_tools/dataset_tools/episode_recorder.py:447-479 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/dataset_tools/episode_recorder.py#L447-L479>`__,
`src/dataset_tools/dataset_tools/episode_recorder.py:92 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/dataset_tools/episode_recorder.py#L92>`__

--------------

对比：分集与连续模式
--------------------


.. list-table::
   :header-rows: 1

   * - 方面
     - 分集模式
     - 连续模式
   * - **触发**
     - Action Server 目标
     - 启动时（自动）
   * - **界面**
     - ``record_cli`` （交互式）
     - ``ros2 bag record`` （被动）
   * - **输出**
     - 每个回合一个 bag
     - 单个整体 bag
   * - **元数据**
     - 每个回合的操作员提示
     - 无
   * - **用例**
     - 用于训练的任务导向数据集
     - 调试、长时间日志记录
   * - **构建器**
     - ``generate_epi sodic_recording_node()``
     - ``generate_cont inuous_recording_action()``

**连续模式实现** `recording.py:58-100 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/recording.py#L58-L100>`__：- 使用 ``ExecuteProcess`` 生成 ``ros2 bag record`` 命令 - 从 Contract 自动发现话题 `recording.py:79 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/recording.py#L79>`__ - 文件名：``~/rosbag/<robot_name>_<timestamp>.mcap`` `recording.py:83-84 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/recording.py#L83-L84>`__

**来源**：
`src/robot_config/robot_config/launch_builders/recording.py:58-100 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/launch_builders/recording.py#L58-L100>`__,
`src/robot_config/robot_config/launch_builders/recording.py:102-168 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/launch_builders/recording.py#L102-L168>`__

--------------

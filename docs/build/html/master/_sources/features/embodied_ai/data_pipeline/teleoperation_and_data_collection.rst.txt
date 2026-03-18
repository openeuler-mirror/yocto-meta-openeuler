遥操作与数据收集
================

.. raw:: html

   <details>

相关源文件

以下文件用于生成此 wiki 页面的上下文：

-  `README.en.md <README.en.md>`__
-  `README.md <README.md>`__
-  `docs/architecture.md <docs/architecture.md>`__
-  `/image/architecture.png </image/architecture.png>`__
-  `docs/roadmap.md <docs/roadmap.md>`__
-  `scripts/build.sh <scripts/build.sh>`__
-  `src/README.md <src/README.md>`__
-  `src/action_dispatch/README.en.md <src/action_dispatch/README.en.md>`__
-  `src/action_dispatch/README.md <src/action_dispatch/README.md>`__
-  `src/dataset_tools/README.md <src/dataset_tools/README.md>`__

.. raw:: html

   </details>

目的与范围
----------

本文档介绍 IB-Robot 中的遥操作界面和数据收集流水线，涵盖从人工演示到录制 ROS2 bag 的工作流程。它解释了专家操作员如何通过各种输入设备控制机器人，以及这些演示如何被捕获为训练数据。

有关将数据集转换为 LeRobot 格式，请参阅 `数据集转换 (bag_to_lerobot) <#9.3>`__。有关与外部 lerobot 库的训练集成，请参阅 `训练集成 <#9.4>`__。

**来源**：`README.md:1-192 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L1-L192>`__, `docs/architecture.md:1-313 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/docs/architecture.md#L1-L313>`__,
`src/dataset_tools/README.md:1-208 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/README.md#L1-L208>`__

--------------

遥操作概述
----------

IB-Robot 支持多种遥操作界面来收集专家演示。所有遥操作方法都向同一个 ros2_control 界面发布命令，确保无论输入设备如何都能保持一致的行为。

支持的输入设备
~~~~~~~~~~~~~~


.. list-table::
   :header-rows: 1

   * - 设备类型
     - 用例
     - 包
     - 状态
   * - **VR 控制器**
     - 沉浸式 6DOF 操作
     - ``r obot_teleop``
     - 已实现
   * - **Xbox/PS 控制器**
     - 易用的游戏手柄 输入
     - ``r obot_teleop``
     - 已实现
   * - **移动 IMU**
     - 基于智能手机的 方向控制
     - ``r obot_teleop``
     - 已实现
   * - **主从臂**
     - 直接动力学教学
     - ``r obot_teleop``
     - 已实现

**来源**：`README.md:27-28 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L27-L28>`__, `README.en.md:27-28 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.en.md#L27-L28>`__,
`docs/architecture.md:238-239 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/docs/architecture.md#L238-L239>`__

遥操作控制流程
~~~~~~~~~~~~~~

.. mermaid::

   graph TB
       subgraph "Input Devices"
           VR["VR Controllers<br/>(Meta Quest/Vive)"]
           XBOX["Xbox/PS Gamepad"]
           IMU["Mobile IMU<br/>(Phone sensor)"]
           LEADER["Leader Arm<br/>(Kinesthetic)"]
       end
       
       subgraph "robot_teleop Package"
           TELEOP_NODE["robot_teleop Node"]
           INPUT_HANDLER["Input Handler"]
           DEADMAN["Deadman Switch<br/>Safety Logic"]
           MAPPER["Joint Mapper"]
       end
       
       subgraph "Control Layer"
           TOPIC_EXEC["TopicExecutor<br/>Direct Position Control"]
           POS_CTRL["position_controllers<br/>(ros2_control)"]
       end
       
       subgraph "Hardware"
           HW_INTERFACE["Hardware Interface"]
           MOTORS["Physical Motors"]
       end
       
       VR --> INPUT_HANDLER
       XBOX --> INPUT_HANDLER
       IMU --> INPUT_HANDLER
       LEADER --> INPUT_HANDLER
       
       INPUT_HANDLER --> TELEOP_NODE
       TELEOP_NODE --> DEADMAN
       DEADMAN --> MAPPER
       MAPPER --> TOPIC_EXEC
       
       TOPIC_EXEC --> POS_CTRL
       POS_CTRL --> HW_INTERFACE
       HW_INTERFACE --> MOTORS

**来源**：`src/action_dispatch/README.en.md:149-154 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/README.en.md#L149-L154>`__,
`README.md:27-28 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L27-L28>`__

--------------

数据收集架构
------------

数据收集系统围绕 ROS2 Actions 构建，用于同步录制控制。``episode_recorder`` 节点充当 Action Server，允许外部客户端触发分集或连续录制。

组件架构
~~~~~~~~

.. mermaid::

   graph TB
       subgraph "Teleoperation Layer"
           HUMAN["Human Operator"]
           INPUT["Input Device<br/>(VR/Xbox/IMU)"]
           TELEOP["robot_teleop Node"]
       end
       
       subgraph "Robot Execution"
           ROBOT["Physical Robot"]
           SENSORS["Sensors<br/>(Cameras + Joint States)"]
       end
       
       subgraph "Recording Layer - dataset_tools Package"
           RECORDER["episode_recorder Node<br/>(Action Server)"]
           CLI["record_cli<br/>(Action Client)"]
           WRITER["MCAP Writer"]
       end
       
       subgraph "Storage"
           BAG["ROS2 Bag Files<br/>(MCAP format)"]
       end
       
       subgraph "Configuration Source"
           CONFIG["robot_config YAML<br/>Contract Definition"]
       end
       
       HUMAN --> INPUT
       INPUT --> TELEOP
       TELEOP --> ROBOT
       ROBOT --> SENSORS
       
       SENSORS --> RECORDER
       CLI --> RECORDER
       CONFIG -.->|"defines topics<br/>to record"| RECORDER
       
       RECORDER --> WRITER
       WRITER --> BAG

**来源**：`src/dataset_tools/README.md:1-208 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/README.md#L1-L208>`__,
`README.md:56-61 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L56-L61>`__

--------------

回合录制系统
------------

episode_recorder 节点
~~~~~~~~~~~~~~~~~~~~~

``episode_recorder`` 节点在 ``/record_episode`` 提供一个 ``RecordEpisode`` Action Server。它订阅机器人契约中定义的所有话题（观测和动作），并将它们以 MCAP 格式写入 ROS2 bag 文件。

**关键特性**：- **契约驱动的订阅**：自动从 ``robot_config`` YAML 订阅话题 - **元数据嵌入**：在 bag 元数据中存储契约定义，供下游处理 - **双录制模式**：分集（手动开始/停止）或连续（始终录制）- **QoS 配置**：使用契约指定的 QoS 配置文件进行可靠的消息捕获

**启动集成**：

录制器在 ``record:=true`` 时通过 ``robot.launch.py`` 启动：

.. code:: bash

   ros2 launch robot_config robot.launch.py \
       robot_config:=so101_single_arm \
       control_mode:=teleop \
       record:=true \
       record_mode:=episodic \
       use_sim:=false

**来源**：`src/dataset_tools/README.md:115-119 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/README.md#L115-L119>`__,
`src/dataset_tools/README.md:36-45 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/README.md#L36-L45>`__

录制模式
~~~~~~~~


.. list-table::
   :header-rows: 1

   * - 模式
     - 描述
     - 用例
     - 触发方式
   * - ``ep isodic``
     - 每个回合手动开始/停止
     - 收集离散任务 演示
     - ``record_cli`` 或自定义 Action Client
   * - ``cont inuous``
     - 将整个会话录制到 单个 bag
     - 长时间数据日志
     - 启动时自动

**来源**：`src/dataset_tools/README.md:203-207 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/README.md#L203-L207>`__

--------------

使用 record_cli 进行交互式录制
------------------------------

``record_cli`` 工具提供了一个命令行界面来控制分集录制。它作为 ``/record_episode`` 服务器的 Action Client。

工作流程
~~~~~~~~

步骤 1：启用录制启动机器人
^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code:: bash

   ros2 launch robot_config robot.launch.py \
       robot_config:=so101_single_arm \
       control_mode:=teleop \
       record:=true \
       record_mode:=episodic \
       use_sim:=false

这将启动：- 遥操作控制栈 - ``episode_recorder`` Action Server - 相机驱动和 joint_state_broadcaster

**来源**：`src/dataset_tools/README.md:38-45 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/README.md#L38-L45>`__

步骤 2：启动录制客户端
^^^^^^^^^^^^^^^^^^^^^^

在单独的终端中：

.. code:: bash

   ros2 run dataset_tools record_cli

输出：

::

   ========================================================
   Dataset Collection CLI
   Enter prompt text to start recording. (Press Enter to reuse: 'get')
   Type 'q' or 'quit' to exit.
   ========================================================
   Prompt >

**来源**：`src/dataset_tools/README.md:47-51 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/README.md#L47-L51>`__

步骤 3：录制回合
^^^^^^^^^^^^^^^^

::

   Prompt > pick up the red cube
   [INFO] 🔴 RECORDING STARTED. (Press Enter to stop early)

此时：1. 使用遥操作设备操作机器人 2. 执行任务（例如，"拿起红色方块"）3. 任务完成后按 Enter

输出：

::

   [INFO] ✅ RECORDING SAVED: Wrote 1894 messages to /path/to/dataset/episode_000
   Prompt >

**来源**：`src/dataset_tools/README.md:53-62 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/README.md#L53-L62>`__

步骤 4：重复或退出
^^^^^^^^^^^^^^^^^^

::

   Prompt > place it in the box
   [INFO] 🔴 RECORDING STARTED...
   [INFO] ✅ RECORDING SAVED: Wrote 2103 messages to /path/to/dataset/episode_001
   Prompt > q

**来源**：`src/dataset_tools/README.md:53-62 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/README.md#L53-L62>`__

--------------

契约驱动的录制
--------------

单一事实来源
~~~~~~~~~~~~

录制系统使用 ``robot_config`` YAML 中的契约定义作为单一事实来源。这确保：- 训练数据和部署观测使用相同的处理 - 无需维护重复的契约文件 - 传感器配置的更改自动传播到录制

**so101_single_arm.yaml 中的契约示例**：

.. code:: yaml

   contract:
     rate_hz: 20
     max_duration_s: 90.0
     
     observations:
       - key: observation.images.front
         topic: /camera/front/image_raw
         type: sensor_msgs/msg/Image
         image:
           resize: [480, 640]
       
       - key: observation.images.top
         topic: /camera/top/image_raw
         type: sensor_msgs/msg/Image
         image:
           resize: [480, 640]
       
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

**来源**：`src/dataset_tools/README.md:148-198 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/README.md#L148-L198>`__

契约消费者
~~~~~~~~~~

.. mermaid::

   graph TB
       subgraph "robot_config YAML"
           CONTRACT["contract:<br/>- observations<br/>- actions<br/>- rate_hz"]
       end
       
       subgraph "Recording (dataset_tools)"
           RECORDER["episode_recorder"]
           REC_SUBS["Topic Subscriptions"]
           REC_META["Bag Metadata<br/>(embeds contract)"]
       end
       
       subgraph "Conversion (dataset_tools)"
           BAG2LR["bag_to_lerobot"]
           B2L_DECODE["Message Decoder"]
           B2L_RESAMPLE["Resampler @ rate_hz"]
       end
       
       subgraph "Inference (inference_service)"
           INF_NODE["lerobot_policy_node"]
           INF_SUBS["Topic Subscriptions"]
           INF_FILTER["Filter by model's<br/>input_features"]
       end
       
       CONTRACT -.->|"defines topics"| REC_SUBS
       CONTRACT -.->|"embedded in"| REC_META
       CONTRACT -.->|"loaded from"| B2L_DECODE
       CONTRACT -.->|"rate_hz drives"| B2L_RESAMPLE
       CONTRACT -.->|"observation keys"| INF_FILTER
       CONTRACT -.->|"defines topics"| INF_SUBS
       
       RECORDER --> REC_SUBS
       RECORDER --> REC_META
       BAG2LR --> B2L_DECODE
       BAG2LR --> B2L_RESAMPLE
       INF_NODE --> INF_FILTER
       INF_NODE --> INF_SUBS

**来源**：`src/dataset_tools/README.md:13-30 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/README.md#L13-L30>`__,
`src/dataset_tools/README.md:122-144 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/README.md#L122-L144>`__

--------------

完整数据收集流程
----------------

阶段分解
~~~~~~~~

.. mermaid::

   graph LR
       subgraph "Phase 1: Setup"
           CONFIG_LOAD["Load robot_config<br/>so101_single_arm.yaml"]
           LAUNCH["robot.launch.py<br/>record:=true"]
           RECORDER_START["episode_recorder<br/>Action Server Ready"]
       end
       
       subgraph "Phase 2: Recording Trigger"
           CLI_START["record_cli sends<br/>RecordEpisode Goal"]
           RECORDER_ACTIVE["Recorder subscribes<br/>to contract topics"]
       end
       
       subgraph "Phase 3: Demonstration"
           TELEOP_CONTROL["Human operates robot<br/>via input device"]
           SENSORS_PUBLISH["Cameras + joint_states<br/>publish data"]
           RECORDER_WRITE["episode_recorder<br/>writes to MCAP"]
       end
       
       subgraph "Phase 4: Save"
           CLI_STOP["CLI sends stop<br/>(Enter key)"]
           RECORDER_FINALIZE["Recorder finalizes<br/>bag file"]
           BAG_SAVED["ROS2 Bag with<br/>embedded contract"]
       end
       
       CONFIG_LOAD --> LAUNCH
       LAUNCH --> RECORDER_START
       RECORDER_START --> CLI_START
       CLI_START --> RECORDER_ACTIVE
       RECORDER_ACTIVE --> TELEOP_CONTROL
       TELEOP_CONTROL --> SENSORS_PUBLISH
       SENSORS_PUBLISH --> RECORDER_WRITE
       RECORDER_WRITE --> CLI_STOP
       CLI_STOP --> RECORDER_FINALIZE
       RECORDER_FINALIZE --> BAG_SAVED

**来源**：`src/dataset_tools/README.md:123-143 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/README.md#L123-L143>`__

详细消息流程
~~~~~~~~~~~~

.. mermaid::

   sequenceDiagram
       participant Human
       participant record_cli
       participant episode_recorder
       participant Cameras
       participant JointStates
       participant MCAP_Writer
       
       Human->>record_cli: Enter task prompt
       record_cli->>episode_recorder: SendGoal(RecordEpisode)<br/>prompt="pick cube"
       episode_recorder->>episode_recorder: Create subscriptions<br/>from contract
       episode_recorder->>record_cli: GoalAccepted
       
       loop During Recording
           Cameras->>episode_recorder: Image messages
           JointStates->>episode_recorder: Joint state messages
           episode_recorder->>MCAP_Writer: Write messages<br/>with timestamps
       end
       
       Human->>record_cli: Press Enter to stop
       record_cli->>episode_recorder: CancelGoal()
       episode_recorder->>MCAP_Writer: Finalize bag file
       episode_recorder->>record_cli: Result(success=true,<br/>message_count=1894)
       record_cli->>Human: Display save confirmation

**来源**：`src/dataset_tools/README.md:33-62 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/README.md#L33-L62>`__

--------------

输出数据格式
------------

ROS2 Bag 结构
~~~~~~~~~~~~~

每个录制的回合创建一个 MCAP 格式的 ROS2 bag 目录：

::

   episode_000/
   ├── metadata.yaml          # Bag metadata with contract
   └── episode_000.mcap       # Binary message storage

嵌入的契约元数据
~~~~~~~~~~~~~~~~

bag 的 ``metadata.yaml`` 包含完整的契约定义，确保下游工具可以正确处理数据：

.. code:: yaml

   rosbag2_bagfile_information:
     version: 5
     storage_identifier: mcap
     duration:
       nanoseconds: 45000000000  # 45 seconds
     starting_time:
       nanoseconds_since_epoch: 1234567890123456789
     message_count: 1894
     topics_with_message_count:
       - topic_metadata:
           name: /camera/front/image_raw
           type: sensor_msgs/msg/Image
           serialization_format: cdr
         message_count: 900
       - topic_metadata:
           name: /camera/top/image_raw
           type: sensor_msgs/msg/Image
           serialization_format: cdr
         message_count: 900
       - topic_metadata:
           name: /joint_states
           type: sensor_msgs/msg/JointState
           serialization_format: cdr
           offered_qos_profiles: "..."
         message_count: 900
     custom_data:
       contract: |
         {contract YAML content embedded here}

**来源**：`src/dataset_tools/README.md:98-113 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/README.md#L98-L113>`__

--------------

关键参数与配置
--------------

录制的启动参数
~~~~~~~~~~~~~~


.. list-table::
   :header-rows: 1

   * - 参数
     - 类型
     - 默认值
     - 描述
   * - ``record``
     - bool
     - ``false``
     - 启用/禁用 录制系统
   * - ``record_mode``
     - string
     - ``episodic``
     - 录制模式： ``episodic`` 或 ``continuous``
   * - ``record_path``
     - string
     - ``~/datasets``
     - 保存 bag 的 基础目录

**使用示例**：

.. code:: bash

   ros2 launch robot_config robot.launch.py \
       robot_config:=so101_single_arm \
       control_mode:=teleop \
       record:=true \
       record_mode:=episodic \
       record_path:=/data/robot_demos

**来源**：`src/dataset_tools/README.md:36-45 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/README.md#L36-L45>`__

契约配置
~~~~~~~~

影响录制的关键契约参数：


.. list-table::
   :header-rows: 1

   * - 参数
     - 位置
     - 对录制的影响
   * - ``rate_hz``
     - ``contract.rate_hz``
     - 用于验证的预期数据率
   * - ``max_duration_s``
     - ``cont ract.max_duration_s``
     - 最大回合持续时间
   * - ``observations``
     - ``cont ract.observations[]``
     - 要订阅和录制的话题
   * - ``actions``
     - ` `contract.actions[]``
     - 要录制的动作话题 （来自遥操作）

**来源**：`src/dataset_tools/README.md:148-199 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/README.md#L148-L199>`__

--------------

数据流水线的下一步
------------------

将回合录制为 ROS2 bag 后，接下来的步骤是：

1. **数据集转换**：使用 ``bag_to_lerobot`` 将 MCAP bag 转换为带有视频编码和 parquet 文件的 LeRobot v3 格式。请参阅 `数据集转换 (bag_to_lerobot) <#9.3>`__。

2. **训练**：在外部 lerobot 库中加载 LeRobot 数据集以训练 ACT、Diffusion Policy 或 VLA 模型。请参阅 `训练集成 <#9.4>`__。

3. **部署**：使用相同的契约通过 ``lerobot_policy_node`` 部署训练好的策略进行推理。请参阅 `策略节点 <#7.4>`__。

**来源**：`src/dataset_tools/README.md:67-84 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/README.md#L67-L84>`__,
`README.md:1-192 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L1-L192>`__

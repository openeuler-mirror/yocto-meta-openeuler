IB-Robot 概述
=============

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

本页面提供 IB-Robot 系统架构、设计原则和核心组件的高层次介绍。它解释了 IB-Robot 如何将 Hugging Face LeRobot 机器学习生态系统与 ROS 2 机器人中间件连接起来，以实现端到端的具身智能工作流程。

有关配置系统的详细文档，请参阅 `Configuration System (robot_config) <#5>`__。有关推理管道的详细信息，请参阅 `Inference Pipeline <#7>`__。有关数据收集工作流程，请参阅 `Data Pipeline <#9>`__。

**来源**: `README.md:1-192 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L1-L192>`__, `docs/architecture.md:1-313 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/docs/architecture.md#L1-L313>`__

--------------

什么是 IB-Robot？
-----------------

IB-Robot（Intelligence Boom Robot）是一个集成开发框架，连接了两个不同的生态系统：

-  **LeRobot**: Hugging Face 的机器人学习框架，用于训练 AI 策略（ACT、Diffusion Policy、VLA 模型）
-  **ROS 2 Humble**: 行业标准的机器人中间件，用于硬件控制、感知和运动规划

该系统提供了从专家演示收集、策略训练到实际部署的完整工具链，消除了机器学习实验与机器人生产系统之间的传统鸿沟。

**主要仓库结构**:

::

   IB_Robot/
   ├── libs/lerobot/          # [子模块] LeRobot 训练框架
   ├── src/                   # [子模块] 核心 ROS 2 包
   │   ├── robot_config/      # 配置中心（单一数据源）
   │   ├── tensormsg/         # ROS↔Tensor 协议转换器
   │   ├── inference_service/ # 策略推理节点
   │   ├── action_dispatch/   # 动作执行与平滑
   │   ├── dataset_tools/     # 数据收集与转换
   │   └── so101_hardware/    # 硬件驱动
   ├── scripts/setup.sh       # 环境初始化
   └── scripts/build.sh       # 支持 mixin 的构建系统

**来源**: `README.md:1-47 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L1-L47>`__, `src/README.md:1-103 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/README.md#L1-L103>`__

--------------

集成挑战
--------

IB-Robot 解决了机器学习与机器人控制范式之间的根本不兼容问题：

概念差异
~~~~~~~~


.. list-table::
   :header-rows: 1

   * - 维度
     - LeRobot (机器 学习世界)
     - ROS 2 (控制世 界)
     - IB-Robot 解决方案
   * - **数据单元**
     - Episode (回合)
     - Topic stream (话题流)
     - 契约驱动的转换
   * - **时间模型**
     - 离散步数
     - 连续实时
     - 带重采样的 ``StreamBuffer``
   * - **控制**
     - 端到端策略
     - 分层规划
     - 双模式架构
   * - **部署**
     - Python 脚本
     - 分布式节点
     - Action Server 集成

**来源**: `README.md:11-16 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L11-L16>`__, `docs/architecture.md:53-77 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/docs/architecture.md#L53-L77>`__

数据格式桥接
~~~~~~~~~~~~

.. mermaid::

   graph LR
       subgraph "LeRobot Training Space"
           EP["Episode<br/>(parquet + video)"]
           FEAT["Features Dict<br/>observation.state: [N,7]<br/>observation.images.top: [N,H,W,3]<br/>action: [N,6]"]
       end
       
       subgraph "IB-Robot Bridge Layer"
           CONTRACT["robot_config YAML<br/>Contract Definition"]
           BAG2LR["bag_to_lerobot.py"]
           TENSORMSG["tensormsg Converter"]
       end
       
       subgraph "ROS 2 Runtime Space"
           BAG["ROS2 Bag<br/>(MCAP format)"]
           TOPICS["Topic Streams<br/>/joint_states<br/>/camera/top/image_raw<br/>/arm_controller/commands"]
       end
       
       TOPICS -->|"record"| BAG
       BAG -->|"decode_value()"| BAG2LR
       CONTRACT -.->|"defines mappings"| BAG2LR
       BAG2LR -->|"feature_from_spec()"| FEAT
       FEAT --> EP
       
       EP -.->|"trained policy"| POLICY["Policy Checkpoint"]
       POLICY --> TENSORMSG
       TOPICS -->|"subscribe"| TENSORMSG
       CONTRACT -.->|"defines mappings"| TENSORMSG
       TENSORMSG -->|"from_variant()"| FEAT

``tensormsg`` 包通过基于注册表的解码器系统实现双向转换。``robot_config`` 契约作为所有映射规范的单一数据源。

**来源**: `README.md:29-41 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L29-L41>`__,
`src/dataset_tools/dataset_tools/bag_to_lerobot.py:1-73 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/dataset_tools/bag_to_lerobot.py#L1-L73>`__,
`src/robot_config/robot_config/contract_utils.py:1-100 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/contract_utils.py#L1-L100>`__

--------------

架构原则
--------

1. 单一数据源模式
~~~~~~~~~~~~~~~~~

所有系统配置均源自 ``robot_config`` YAML 文件。这消除了数据收集、训练和部署之间的配置漂移：

.. mermaid::

   graph TB
       YAML["robot_config YAML<br/>so101_single_arm.yaml"]
       
       subgraph "Configuration Propagation"
           YAML --> CONTRACT["Contract Section<br/>observations + actions"]
           YAML --> JOINTS["Joint Definitions<br/>limits + controllers"]
           YAML --> PERIPH["Peripheral Config<br/>cameras + transforms"]
           YAML --> MODES["Control Modes<br/>teleop | model_inference | moveit"]
       end
       
       subgraph "Runtime Consumers"
           CONTRACT --> RECORDER["episode_recorder<br/>creates subscriptions"]
           CONTRACT --> CONVERTER["bag_to_lerobot<br/>decode + resample"]
           CONTRACT --> INFERENCE["lerobot_policy_node<br/>filter observations"]
           
           JOINTS --> CONTROL["ros2_control<br/>hardware interface"]
           PERIPH --> CAMERAS["Camera Drivers<br/>usb_cam/realsense"]
           MODES --> LAUNCH["robot.launch.py<br/>node selection"]
       end
       
       RECORDER --> BAG["rosbag2 files"]
       BAG --> CONVERTER
       CONVERTER --> DS["LeRobot Dataset"]
       DS -.->|"training"| MODEL["Policy .pt"]
       MODEL --> INFERENCE

**关键实现**: ``robot_config.loader.load_robot_config()`` 加载 YAML，``RobotConfig.to_contract()`` 合成契约数据类。

**来源**:
`src/robot_config/config/robots/so101_single_arm.yaml:1-100 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L1-L100>`__,
`README.md:39-41 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L39-L41>`__,
`src/robot_config/robot_config/contract_builder.py:1-104 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/contract_builder.py#L1-L104>`__

2. 契约驱动设计
~~~~~~~~~~~~~~~

``Contract`` 数据类定义了机器人与策略之间的观测-动作接口：

.. code:: python

   @dataclass(frozen=True, slots=True)
   class Contract:
       name: str
       version: int
       rate_hz: float                          # 记录/推理频率
       max_duration_s: float                   # Episode 超时
       observations: List[ObservationSpec]     # 输入话题
       actions: List[ActionSpec]               # 输出话题
       tasks: List[TaskSpec]                   # 可选任务提示
       recording: Dict[str, Any]
       robot_type: Optional[str]

每个 ``ObservationSpec`` 和 ``ActionSpec`` 包括：- ROS 话题名称和消息类型 - 张量形状和数据类型规范 - QoS 配置设置 - 对齐策略（用于重采样）

此契约被三个关键系统使用，处理逻辑完全相同：

1. ``episode_recorder``
   (`src/dataset_tools/dataset_tools/episode_recorder.py:159-274 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/dataset_tools/episode_recorder.py#L159-L274>`__):
   订阅所有契约话题
2. ``bag_to_lerobot``
   (`src/dataset_tools/dataset_tools/bag_to_lerobot.py:213-231 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/dataset_tools/bag_to_lerobot.py#L213-L231>`__):
   使用 ``decode_value()`` 解码消息
3. ``lerobot_policy_node``
   (`src/inference_service/inference_service/lerobot_policy_node.py:205-240 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/lerobot_policy_node.py#L205-L240>`__):
   根据模型的 ``input_features`` 过滤观测

**来源**:
`src/robot_config/robot_config/contract_utils.py:83-97 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/contract_utils.py#L83-L97>`__,
`src/dataset_tools/dataset_tools/bag_to_lerobot.py:1-73 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/dataset_tools/bag_to_lerobot.py#L1-L73>`__

3. 双模式控制架构
~~~~~~~~~~~~~~~~~

IB-Robot 支持三种控制模式，它们汇聚到同一个 ``ros2_control`` 硬件接口：

.. mermaid::

   graph TB
       subgraph "Mode Selection"
           LAUNCH["robot.launch.py<br/>--control_mode parameter"]
           DEFAULT["default_control_mode<br/>from robot_config"]
           
           LAUNCH -.->|"overrides"| DEFAULT
       end
       
       subgraph "Mode 1: Teleoperation"
           TELEOP["robot_teleop node<br/>VR/Xbox/IMU input"]
           TELEOP_EXEC["TopicExecutor<br/>position_controllers"]
           
           TELEOP --> TELEOP_EXEC
       end
       
       subgraph "Mode 2: Model Inference"
           INF["lerobot_policy_node<br/>ACT/Diffusion Policy"]
           DISP["action_dispatcher_node<br/>TemporalSmoother"]
           TOPIC_EXEC["TopicExecutor<br/>100Hz streaming"]
           
           INF -->|"action chunks"| DISP
           DISP --> TOPIC_EXEC
       end
       
       subgraph "Mode 3: MoveIt Planning"
           POSE["Pose Commands<br/>/cmd_pose"]
           GATEWAY["moveit_gateway.py<br/>IK solver"]
           MOVEIT["MoveIt2 Core<br/>OMPL planner"]
           ACTION_EXEC["ActionExecutor<br/>FollowJointTrajectory"]
           
           POSE --> GATEWAY
           GATEWAY --> MOVEIT
           MOVEIT --> ACTION_EXEC
       end
       
       subgraph "Unified Hardware Layer"
           ROS2CTRL["ros2_control<br/>controller_manager"]
           
           TELEOP_EXEC --> ROS2CTRL
           TOPIC_EXEC --> ROS2CTRL
           ACTION_EXEC --> ROS2CTRL
           
           ROS2CTRL --> HW{"use_sim?"}
           HW -->|"false"| REAL["so101_hardware<br/>Feetech SDK"]
           HW -->|"true"| SIM["Gazebo<br/>gz_ros2_control"]
       end
       
       LAUNCH -->|"teleop"| TELEOP
       LAUNCH -->|"model_inference"| INF
       LAUNCH -->|"moveit_planning"| GATEWAY

``action_dispatcher_node`` 实现了基于拉取的动作执行，并为 Action Chunking 模型提供时间平滑，当队列水位达到时触发推理。

**来源**: `README.md:121-154 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L121-L154>`__,
`src/action_dispatch/action_dispatch/action_dispatcher_node.py:1-319 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatch/action_dispatcher_node.py#L1-L319>`__,
`src/robot_moveit/scripts/moveit_gateway.py:1-100 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/scripts/moveit_gateway.py#L1-L100>`__

--------------

系统组件与数据流
----------------

核心包职责
~~~~~~~~~~

.. mermaid::

   graph TB
       subgraph "Layer 1: Configuration"
           RC["robot_config<br/>- load_robot_config()<br/>- to_contract()<br/>- launch builders"]
       end
       
       subgraph "Layer 2: Protocol Conversion"
           TM["tensormsg<br/>- TensorMsgConverter<br/>- register_encoder/decoder<br/>- decode_value()"]
       end
       
       subgraph "Layer 3: Inference & Execution"
           INF["inference_service<br/>- lerobot_policy_node<br/>- InferenceCoordinator<br/>- TensorPreprocessor"]
           DISP["action_dispatch<br/>- action_dispatcher_node<br/>- TemporalSmoother<br/>- TopicExecutor"]
           
           INF -->|"DispatchInfer Action"| DISP
       end
       
       subgraph "Layer 4: Data Pipeline"
           RECORDER["dataset_tools<br/>- episode_recorder<br/>- bag_to_lerobot<br/>- record_cli"]
           TELEOP["robot_teleop<br/>- VR/Xbox/IMU drivers<br/>- Leader-Follower"]
       end
       
       subgraph "Layer 5: Hardware Abstraction"
           CTRL["ros2_control<br/>- controller_manager<br/>- hardware_interface"]
           HW["so101_hardware<br/>- SO101Hardware class<br/>- Feetech SDK"]
           
           CTRL --> HW
       end
       
       subgraph "Layer 6: Motion Planning"
           MOVEIT["robot_moveit<br/>- MoveItGateway<br/>- kinematics.yaml"]
       end
       
       RC -.->|"provides Contract"| TM
       RC -.->|"provides Contract"| RECORDER
       RC -.->|"provides Contract"| INF
       
       TM --> INF
       TM --> DISP
       
       TELEOP --> RECORDER
       
       DISP --> CTRL
       MOVEIT --> CTRL

**来源**: `src/README.md:20-98 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/README.md#L20-L98>`__, `README.md:44-71 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L44-L71>`__

组件交互：推理循环
~~~~~~~~~~~~~~~~~~

.. mermaid::

   sequenceDiagram
       participant Sensors as "/joint_states<br/>/camera/top/image_raw"
       participant PolicyNode as "lerobot_policy_node"
       participant Dispatcher as "action_dispatcher_node"
       participant Controller as "ros2_control"
       participant Hardware as "so101_hardware"
       
       Note over Sensors,Hardware: Steady-state operation at 100Hz
       
       loop Every 10ms (100Hz control loop)
           Dispatcher->>Dispatcher: Check queue watermark
           
           alt Queue below watermark (< 20 actions)
               Dispatcher->>PolicyNode: DispatchInfer.Goal(obs_timestamp)
               PolicyNode->>Sensors: Sample latest observations
               Sensors-->>PolicyNode: /joint_states, images
               PolicyNode->>PolicyNode: TensorPreprocessor<br/>PureInferenceEngine (GPU)<br/>TensorPostprocessor
               PolicyNode-->>Dispatcher: Result(action_chunk[100,6])
               Dispatcher->>Dispatcher: TemporalSmoother.update()<br/>blend overlapping actions
           end
           
           Dispatcher->>Dispatcher: pop next action from queue
           Dispatcher->>Controller: /arm_position_controller/commands
           Controller->>Hardware: write() joint positions
           Hardware-->>Sensors: read() joint states
       end

``action_dispatcher_node`` 维护一个动作队列，并通过 ``DispatchInfer`` Action 接口触发异步推理。``TemporalSmoother`` 使用指数加权混合重叠的动作块，以确保平滑过渡。

**来源**: `src/action_dispatch/README.en.md:1-447 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/README.en.md#L1-L447>`__,
`src/action_dispatch/action_dispatch/action_dispatcher_node.py:38-302 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatch/action_dispatcher_node.py#L38-L302>`__,
`src/inference_service/inference_service/lerobot_policy_node.py:422-489 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/lerobot_policy_node.py#L422-L489>`__

--------------

数据生命周期：从收集到部署
--------------------------

端到端工作流程
~~~~~~~~~~~~~~

.. mermaid::

   graph LR
       subgraph "Phase 1: Data Collection"
           HUMAN["Human Expert<br/>VR/Xbox controller"]
           TELEOP_NODE["robot_teleop node"]
           ROBOT1["Physical Robot"]
           
           HUMAN --> TELEOP_NODE
           TELEOP_NODE --> ROBOT1
       end
       
       subgraph "Phase 2: Recording"
           RECORDER_NODE["episode_recorder<br/>Action Server"]
           CLI["record_cli<br/>trigger interface"]
           MCAP["ROS2 Bag<br/>MCAP format"]
           
           CLI -->|"RecordEpisode.Goal"| RECORDER_NODE
           ROBOT1 -.->|"sensors"| RECORDER_NODE
           RECORDER_NODE --> MCAP
       end
       
       subgraph "Phase 3: Conversion"
           BAG2LR["bag_to_lerobot.py<br/>--robot-config"]
           LRDS["LeRobot v3 Dataset<br/>parquet + mp4"]
           
           MCAP --> BAG2LR
           BAG2LR --> LRDS
       end
       
       subgraph "Phase 4: Training"
           TRAIN["lerobot library<br/>ACT/Diffusion training"]
           MODEL["Policy Checkpoint<br/>config.json + model.safetensors"]
           
           LRDS --> TRAIN
           TRAIN --> MODEL
       end
       
       subgraph "Phase 5: Deployment"
           POLICY_NODE["lerobot_policy_node"]
           ROBOT2["Physical Robot<br/>Autonomous execution"]
           
           MODEL --> POLICY_NODE
           POLICY_NODE --> ROBOT2
       end
       
       ROBOT2 -.->|"online evaluation"| RECORDER_NODE

**关键脚本和命令**:

1. **启动记录服务器**:
   ``ros2 launch robot_config robot.launch.py control_mode:=teleop record:=true record_mode:=episodic``
2. **触发 episode**: ``ros2 run dataset_tools record_cli``
   (交互式提示)
3. **转换为 LeRobot**:
   ``python bag_to_lerobot.py --robot-config so101_single_arm.yaml --bag /path/to/episode --out /path/to/dataset``
4. **训练策略**:
   ``python -m lerobot.train policy=act dataset_repo_id=local/dataset``
5. **部署**:
   ``ros2 launch robot_config robot.launch.py control_mode:=model_inference``

**来源**:
`src/dataset_tools/dataset_tools/episode_recorder.py:1-60 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/dataset_tools/episode_recorder.py#L1-L60>`__,
`src/dataset_tools/dataset_tools/bag_to_lerobot.py:27-73 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/dataset_tools/bag_to_lerobot.py#L27-L73>`__,
`src/robot_config/robot_config/launch_builders/recording.py:102-168 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/launch_builders/recording.py#L102-L168>`__

--------------

环境设置与构建系统
------------------

初始化工作流程
~~~~~~~~~~~~~~

IB-Robot 使用 Python 虚拟环境（``venv``）将 ML 依赖与系统 ROS 2 包隔离：

.. mermaid::

   graph TB
       SETUP["./scripts/setup.sh"]
       
       SETUP --> SUB["git submodule update<br/>--init --recursive"]
       SETUP --> SYSDEPS["Install system packages<br/>nlohmann-json, build tools"]
       SETUP --> VENV["Create venv/<br/>Python 3.11 isolated environment"]
       
       VENV --> PIP["pip install<br/>torch, numpy<2.0, lerobot"]
       PIP --> SHRC["Generate .shrc_local<br/>source venv + ROS 2"]
       
       SHRC --> BUILD["./scripts/build.sh<br/>colcon build with mixins"]
       
       BUILD --> LEROBOT_EDITABLE["pip install -e libs/lerobot"]
       BUILD --> COLCON["colcon build<br/>--mixin dev"]

``build.sh`` 脚本支持基于 mixin 的配置，用于不同的构建配置文件：

=========== ==================================================
Mixin       配置
=========== ==================================================
``dev``     调试符号，符号链接安装，无测试（默认）
``release`` 优化构建，``-O3``
``test``    启用测试
``asan``    AddressSanitizer 用于内存调试
=========== ==================================================

**用法**: ``./scripts/build.sh --mixin release test``

**来源**: `scripts/build.sh:1-229 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/scripts/build.sh#L1-L229>`__, `README.md:75-118 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L75-L118>`__

启动系统架构
~~~~~~~~~~~~

``robot.launch.py`` 入口点使用构建器模式根据 ``robot_config`` 动态生成节点：

.. code:: python

   # Simplified launch flow
   def launch_setup(context):
       robot_config = load_robot_config(robot_config_name)
       control_mode = robot_config['default_control_mode']
       
       actions = []
       
       # Generate nodes from launch_builders modules
       actions += generate_ros2_control_nodes(robot_config, use_sim)
       actions += generate_camera_nodes(robot_config)
       actions += generate_tf_nodes(robot_config)
       
       if use_sim:
           actions += generate_gazebo_nodes(robot_config)
       
       if control_mode == 'model_inference':
           actions += generate_inference_node(robot_config, control_mode)
           actions += generate_dispatcher_node(robot_config)
       elif control_mode == 'moveit_planning':
           actions += generate_moveit_nodes(robot_config)
       
       return actions

**关键启动参数**:

================== ====================================== =============
参数               用途                                   默认值
================== ====================================== =============
``robot_config``   配置名称（映射到 YAML 文件）           ``test_cam``
``use_sim``        启用 Gazebo 仿真                       ``false``
``control_mode``   覆盖控制模式                           （来自 YAML）
``with_inference`` 强制启用/禁用推理                       （自动检测）
``moveit_display`` 为 MoveIt 启动 RViz                    ``true``
================== ====================================== =============

**来源**: `src/robot_config/launch/robot.launch.py:1-300 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/launch/robot.launch.py#L1-L300>`__,
`src/robot_config/robot_config/launch_builders/execution.py:1-200 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/launch_builders/execution.py#L1-L200>`__

--------------

分布式推理支持
--------------

IB-Robot 支持两种策略推理执行模式：

单体模式（默认）
~~~~~~~~~~~~~~~~

所有推理组件在单个 ``lerobot_policy_node`` 进程中运行，采用零拷贝张量传递：

::

   lerobot_policy_node process:
     ├─ TensorPreprocessor (CPU)
     ├─ PureInferenceEngine (GPU)
     └─ TensorPostprocessor (CPU)

分布式模式（云-边）
~~~~~~~~~~~~~~~~~~

边缘节点执行预处理，云端节点执行 GPU 推理，边缘节点执行后处理：

.. mermaid::

   graph LR
       subgraph "Edge Node (Robot)"
           SENSORS["Sensors"]
           EDGE["lerobot_policy_node<br/>(edge proxy)"]
           PRE["TensorPreprocessor"]
           POST["TensorPostprocessor"]
           DISPATCH["action_dispatcher_node"]
           
           SENSORS --> EDGE
           EDGE --> PRE
           POST --> DISPATCH
       end
       
       subgraph "Cloud Node (GPU Server)"
           CLOUD["pure_inference_node"]
           ENGINE["PureInferenceEngine<br/>(GPU)"]
           
           CLOUD --> ENGINE
       end
       
       PRE -->|"/preprocessed/batch<br/>VariantsList"| CLOUD
       ENGINE -->|"/inference/action<br/>VariantsList"| POST

边缘节点在等待云端响应时挂起 ``DispatchInfer`` Action 回调，使用 ``threading.Event`` 进行同步。

**配置**:

.. code:: yaml

   inference:
     enabled: true
     execution_mode: distributed  # or 'monolithic'
     cloud_inference_topic: /preprocessed/batch
     cloud_result_topic: /inference/action
     request_timeout: 5.0

**来源**:
`src/inference_service/inference_service/lerobot_policy_node.py:1-34 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/lerobot_policy_node.py#L1-L34>`__,
`src/inference_service/inference_service/lerobot_policy_node.py:306-351 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/lerobot_policy_node.py#L306-L351>`__,
`src/inference_service/inference_service/lerobot_policy_node.py:495-554 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/lerobot_policy_node.py#L495-L554>`__

--------------

横切关注点
----------

错误处理与诊断
~~~~~~~~~~~~~~

系统通过 ``DiagnosticStatus`` 消息发布健康诊断：

-  ``lerobot_policy_node`` 监控推理延迟并发布到 ``~/health``
-  ``action_dispatcher_node`` 监控队列大小并发布到 ``~/queue_size``
-  硬件驱动将通信错误报告到 ``/diagnostics``

线程安全
~~~~~~~~

-  ``StreamBuffer``: 用于观测采样的无锁环形缓冲区
-  ``episode_recorder``: ``threading.Lock`` 保护 ``SequentialWriter`` 访问
-  ``action_dispatcher_node``: 使用 ROS 2 ``MutuallyExclusiveCallbackGroup`` 进行控制循环隔离

性能优化
~~~~~~~~

1. **零拷贝推理**\ （单体模式）：张量在预处理器、引擎和后处理器之间通过引用传递
2. **符号链接安装**\ （开发）：``colcon build --symlink-install`` 用于仅 Python 更改无需重新构建
3. **动作分块**：通过以 10Hz 预测 100 步（10 秒范围）降低推理频率
4. **时间平滑**：``TemporalSmoother`` 使用指数加权 ``exp(-coeff * k)`` 混合重叠的动作规划（默认 coeff=0.01）

**来源**: `src/action_dispatch/README.en.md:212-331 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/README.en.md#L212-L331>`__,
`scripts/build.sh:117-229 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/scripts/build.sh#L117-L229>`__,
`src/inference_service/inference_service/lerobot_policy_node.py:286-304 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/lerobot_policy_node.py#L286-L304>`__

--------------

下一步
------

本概述介绍了 IB-Robot 系统架构、设计原则和核心工作流程。有关特定子系统的详细信息：

-  **配置与契约**: 参阅 `Single Source of Truth Pattern <#3.1>`__ 和 `Contract System <#3.2>`__
-  **推理管道详情**: 参阅 `Inference Architecture <#7.1>`__ 和执行模式 (#7.2, #7.3)
-  **动作分发与平滑**: 参阅 `Action Dispatch <#8>`__ 和 `Temporal Smoothing <#8.2>`__
-  **数据收集工作流程**: 参阅 `Episode Recording <#9.2>`__ 和 `Dataset Conversion <#9.3>`__
-  **硬件集成**: 参阅 `ros2_control Configuration <#11.1>`__ 和 `Hardware Plugins <#11.2>`__

**来源**: `README.md:1-192 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L1-L192>`__, `docs/architecture.md:1-313 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/docs/architecture.md#L1-L313>`__

--------------

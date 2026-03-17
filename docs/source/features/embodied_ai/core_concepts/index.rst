核心概念
=========

.. toctree::
   :titlesonly:
   :hidden:

   single_source_of_truth_pattern
   contract_system
   control_mode_architecture

.. raw:: html

   <details>

相关源文件

以下文件用作生成此文档页面的上下文：

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
-  `src/robot_config/README.en.md <src/robot_config/README.en.md>`__
-  `src/robot_config/README.md <src/robot_config/README.md>`__
-  `src/robot_config/config/robots/so101_dual_arm.yaml <src/robot_config/config/robots/so101_dual_arm.yaml>`__
-  `src/robot_config/config/robots/so101_single_arm.yaml <src/robot_config/config/robots/so101_single_arm.yaml>`__
-  `src/robot_config/launch/robot.launch.py <src/robot_config/launch/robot.launch.py>`__
-  `src/robot_config/robot_config/config.py <src/robot_config/robot_config/config.py>`__
-  `src/robot_config/robot_config/contract_builder.py <src/robot_config/robot_config/contract_builder.py>`__
-  `src/robot_config/robot_config/contract_utils.py <src/robot_config/robot_config/contract_utils.py>`__
-  `src/robot_config/robot_config/launch_builders/execution.py <src/robot_config/robot_config/launch_builders/execution.py>`__
-  `src/robot_config/robot_config/launch_builders/recording.py <src/robot_config/robot_config/launch_builders/recording.py>`__
-  `src/robot_config/robot_config/loader.py <src/robot_config/robot_config/loader.py>`__
-  `src/tensormsg/tensormsg/converter.py <src/tensormsg/tensormsg/converter.py>`__

.. raw:: html

   </details>

目的与范围
----------

本文档阐述了支撑 IB-Robot 系统的三个基本架构原则：**单一数据源**、**契约驱动设计**和**控制模式架构**。这些原则消除了配置冗余，确保训练与部署的一致性，并实现了不同机器人控制范式之间的无缝切换。

| 各原则的详细实现： - `单一数据源模式 <#3.1>`__ - 深入了解 ``robot_config`` YAML 结构 - `契约系统 <#3.2>`__ - 全面的契约抽象文档
| - `控制模式架构 <#3.3>`__ - 详细的控制模式切换机制

有关系统整体架构概述，请参阅 `系统架构 <#4>`__。

--------------

三大架构支柱
------------

IB-Robot 通过三个核心设计原则解决了机器学习生态系统（LeRobot）与机器人中间件（ROS 2）之间的基本集成挑战：


.. list-table::
   :header-rows: 1

   * - 原则
     - 解决的问题
     - 核心优势
   * - **单一数据源**
     - 数据采集、训练和推理之间 的配置重复
     - 消除不一致性； 一处修改，处处生效
   * - **契约驱动设计**
     - 训练-部署偏差（模型在 训练和推理时看到不同的 数据格式）
     - 保证数据生命周期中 处理流水线一致
   * - **控制模式架构**
     - 硬编码的控制逻辑；无法 在遥操作、AI和规划之间 切换
     - 统一的硬件接口； 通过单一参数切换模式

这些原则协同工作，创建了一个这样的系统： 1. 硬件配置在 ``robot_config`` YAML 中**定义一次** 2. 数据处理契约从此配置中自动**合成** 3. 多种控制模式**汇聚**于同一硬件抽象层

**来源**：`README.md:1-192 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L1-L192>`__，`docs/architecture.md:47-79 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/docs/architecture.md#L47-L79>`__

--------------

原则一：单一数据源（robot_config YAML）
--------------------------------------

概述
~~~~

``robot_config`` YAML 文件作为所有机器人规格的**唯一权威来源**。IB-Robot 不再为 ros2_control、摄像头、ML 契约和关节定义维护单独的配置，而是在一处定义所有内容并自动传播到所有子系统。

配置结构
~~~~~~~~

机器人配置整合了四个传统上分离的系统：

.. code:: yaml

   robot:
     name: so101_single_arm
     type: so101
     
     # 1. 关节定义（用于 ros2_control、MoveIt 和契约）
     joints:
       arm: ["1", "2", "3", "4", "5"]
       gripper: ["6"]
       all: ["1", "2", "3", "4", "5", "6"]
     
     # 2. 硬件接口（ros2_control 配置）
     ros2_control:
       hardware_plugin: so101_hardware/SO101SystemHardware
       port: /dev/ttyACM0
       controllers_config: $(find so101_hardware)/config/so101_controllers.yaml
     
     # 3. 外设（摄像头和传感器及其变换）
     peripherals:
       - type: camera
         name: top
         driver: opencv
         width: 640
         height: 480
         fps: 30
         transform:
           parent_frame: base
           x: 0.0
           y: 0.0
           z: 0.5
     
     # 4. ML 契约（AI 模型的观测和动作）
     contract:
       rate_hz: 20
       max_duration_s: 90.0
       observations:
         - key: observation.images.top
           topic: /camera/top/image_raw
           peripheral: top  # 引用上面定义的摄像头

**来源**：
`src/robot_config/config/robots/so101_single_arm.yaml:1-329 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L1-L329>`__

图表：配置传播流程
~~~~~~~~~~~~~~~~~~

.. mermaid::

   graph TB
       subgraph "Single Source of Truth"
           YAML["robot_config YAML<br/>(so101_single_arm.yaml)"]
           
           YAML --> JOINTS["joints:<br/>arm: [1,2,3,4,5]<br/>gripper: [6]"]
           YAML --> PERIPH["peripherals:<br/>- camera top (640x480@30fps)<br/>- camera wrist"]
           YAML --> CONTRACT["contract:<br/>observations + actions<br/>rate_hz: 20"]
           YAML --> ROS2C["ros2_control:<br/>hardware_plugin<br/>controllers"]
       end
       
       subgraph "Consumers: Runtime Systems"
           JOINTS --> URDF["robot_description<br/>URDF generation"]
           JOINTS --> MOVEIT["robot_moveit<br/>MoveItGateway.arm_group_name"]
           
           PERIPH --> CAM_LAUNCH["Camera Launch Nodes<br/>usb_cam / realsense2_camera"]
           PERIPH --> TF_PUB["TF Static Publishers<br/>camera transforms"]
           
           CONTRACT --> RECORDER["episode_recorder<br/>topic subscriptions"]
           CONTRACT --> BAG2LR["bag_to_lerobot<br/>tensor shapes + resampling"]
           CONTRACT --> INFERENCE["lerobot_policy_node<br/>observation filtering"]
           
           ROS2C --> CTRL_MGR["controller_manager<br/>spawner scripts"]
       end
       
       subgraph "Consistency Guarantee"
           RECORDER --> TRAIN_DATA["Training Dataset<br/>(LeRobot format)"]
           INFERENCE --> DEPLOY_OBS["Deployment Observations<br/>(runtime tensors)"]
           
           TRAIN_DATA --> ALIGN["Same Contract =<br/>Same Processing"]
           DEPLOY_OBS --> ALIGN
       end
       
       YAML -.->|"loaded by"| LOADER["RobotConfig.load()<br/>robot_config/loader.py"]
       LOADER -.->|"synthesizes"| CONTRACT_OBJ["Contract object<br/>contract_utils.py"]

**来源**：`src/robot_config/robot_config/loader.py:1-359 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/loader.py#L1-L359>`__，
`src/robot_config/robot_config/contract_utils.py:1-500 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/contract_utils.py#L1-L500>`__，
`README.md:39-41 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L39-L41>`__

关键代码实体
~~~~~~~~~~~~


.. list-table::
   :header-rows: 1

   * - 实体
     - 文件
     - 用途
   * - ` `load_robot_config()``
     - `robot_config/loader.py:86-359 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/py#L86-L359>`__
     - 加载并验证 YAML 配置 _config/loader.
   * - ``RobotConfig`` 类
     - `robot_config/ config.py <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/robot_config/ config.py>`__
     - 表示整个配置的 Python 数据类
   * - ``to_contract()``
     - `robot_config/ config.py <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/robot_config/ config.py>`__
     - 从机器人配置合成契约
   * - ``robot.launch.py``
     - `robot_config/launch/robot.launch.py:1-432 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/robot_config/launch/robot.launch.py#L1-L432>`__
     - 主入口点，将配置传播到 所有节点 主入口点，将配置传播到 所有节点

传播示例：摄像头配置
~~~~~~~~~~~~~~~~~~~~

当您在 ``robot_config`` YAML 中定义摄像头外设时：

.. code:: yaml

   peripherals:
     - type: camera
       name: top
       width: 640
       height: 480
       fps: 30

这个单一定义会自动传播到：

1. **摄像头驱动启动**：`launch_builders/perception.py <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/launch_builders/perception.py>`__ 生成带有正确参数的 ``usb_cam`` 节点
2. **TF 变换**：`launch_builders/perception.py <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/launch_builders/perception.py>`__ 创建静态变换发布器
3. **契约观测**：外设元数据（宽度、高度、帧率）被注入到观测规格中
4. **数据集转换**：`bag_to_lerobot.py:369-370 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/bag_to_lerobot.py#L369-L370>`__ 使用此元数据验证图像形状

**来源**：
`src/robot_config/robot_config/launch_builders/perception.py <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/launch_builders/perception.py>`__，
`src/dataset_tools/dataset_tools/bag_to_lerobot.py:216-230 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/dataset_tools/bag_to_lerobot.py#L216-L230>`__

--------------

原则二：契约驱动设计
--------------------

.. _overview-1:

概述
~~~~

**契约**是一个机器可读的规范，定义了： - 机器人提供什么观测（摄像头、关节状态、任务描述） - 机器人期望什么动作（关节命令、夹爪命令） - ROS 消息如何映射到 ML 张量（反之亦然） - 时序参数（rate_hz、对齐策略、重采样策略）

契约确保在数据采集、训练和部署期间使用**相同的处理流水线**，消除了常见的"训练时有效，部署时失败"问题。

契约数据模型
~~~~~~~~~~~~

契约抽象定义在 `contract_utils.py:26-117 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/contract_utils.py#L26-L117>`__：

.. code:: python

   @dataclass
   class Contract:
       """Contract defining observations, actions, and processing parameters."""
       robot_type: str              # e.g., "so_101"
       rate_hz: float               # Recording/inference frequency
       max_duration_s: float        # Episode duration limit
       observations: List[ObservationSpec]  # Input specs
       actions: List[ActionSpec]            # Output specs

每个 ``ObservationSpec`` 包含：


.. list-table::
   :header-rows: 1

   * - 字段
     - 用途
     - 示例
   * - ``key``
     - 数据集中的张量名称
     - ``"obser vation.images.top"``
   * - ``topic``
     - 要订阅的 ROS 2 话题
     - ``"/cam era/top/image_raw"``
   * - ``ros_type``
     - 消息类型
     - ``"sens or_msgs/msg/Image"``
   * - ``peripheral``
     - 外设配置引用
     - ``"top"``（链接到 摄像头元数据）
   * - ``resample_policy``
     - 对齐策略
     - ``"hold"``（保持 最后一值）
   * - ``asof_tol_ms``
     - 时间戳容差
     - ``1500``（1.5 秒）

**来源**：
`src/robot_config/robot_config/contract_utils.py:26-117 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/contract_utils.py#L26-L117>`__

图表：契约生命周期与传播
~~~~~~~~~~~~~~~~~~~~~~~~

.. mermaid::

   graph TB
       subgraph "Phase 1: Contract Definition"
           RC["robot_config YAML<br/>contract section"]
           RC --> SYNTH["RobotConfig.to_contract()"]
           SYNTH --> CONTRACT["Contract object<br/>(observations + actions)"]
       end
       
       subgraph "Phase 2: Data Collection"
           CONTRACT --> RECORDER["episode_recorder node"]
           RECORDER --> SUBS["Subscribe to topics:<br/>/camera/top/image_raw<br/>/joint_states"]
           SUBS --> BAGMETA["Write to ROS2 bag<br/>+ embed contract in metadata"]
       end
       
       subgraph "Phase 3: Dataset Conversion"
           BAGMETA --> BAG2LR["bag_to_lerobot script"]
           CONTRACT --> BAG2LR
           BAG2LR --> DECODE["decode_value()<br/>(shared with live inference)"]
           BAG2LR --> RESAMPLE["resample() at rate_hz<br/>(shared with live inference)"]
           BAG2LR --> LRDS["LeRobot Dataset<br/>(parquet + videos)"]
       end
       
       subgraph "Phase 4: Training"
           LRDS --> TRAIN["lerobot.train()<br/>(external library)"]
           TRAIN --> MODEL["Policy Checkpoint<br/>(.pt file)"]
       end
       
       subgraph "Phase 5: Deployment"
           CONTRACT --> INFNODE["lerobot_policy_node"]
           MODEL --> INFNODE
           INFNODE --> FILTER["Filter observations by<br/>model's input_features"]
           INFNODE --> STREAMBUF["StreamBuffer.sample()<br/>(same resampling logic)"]
           STREAMBUF --> TENSORPREP["TensorPreprocessor<br/>(same decode_value)"]
       end
       
       DECODE -.->|"shared code"| TENSORPREP
       RESAMPLE -.->|"shared code"| STREAMBUF

**来源**：
`src/dataset_tools/dataset_tools/bag_to_lerobot.py:1-718 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/dataset_tools/bag_to_lerobot.py#L1-L718>`__，
`src/inference_service/inference_service/lerobot_policy_node.py:1-700 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/lerobot_policy_node.py#L1-L700>`__，
`src/robot_config/robot_config/contract_utils.py:267-450 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/contract_utils.py#L267-L450>`__

共享处理函数
~~~~~~~~~~~~

以下函数在数据采集、数据集转换和实时推理中**完全相同**地使用：


.. list-table::
   :header-rows: 1

   * - 函数
     - 文件
     - 用途
   * - ``decode_value()``
     - `contract_utils.py:267-332 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/contract_utils.py#L267-L332>`__
     - ROS 消息 → numpy 数组转换 ROS 消息 → numpy 数组转换
   * - ``resample()``
     - `contract_utils.py:372-450 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/contract_utils.py#L372-L450>`__
     - 以固定 rate_hz 进行 时序对齐 以固定 rate_hz 进行 时序对齐
   * - `` qos_profile_from_dict()``
     - `contract_utils.py:229-265 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/#L229-L265>`__
     - QoS 设置合成 tract_utils.py
   * - ``StreamBuffer.sample()``
     - `contract_utils.py:335-370 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/contract_utils.py#L335-L370>`__
     - 基于时间戳的数据检索 基于时间戳的数据检索

示例：图像观测处理
~~~~~~~~~~~~~~~~~~

给定此契约观测：

.. code:: yaml

   - key: observation.images.top
     topic: /camera/top/image_raw
     type: sensor_msgs/msg/Image
     peripheral: top
     image:
       resize: [480, 640]
     align:
       strategy: hold
       stamp: header
       tol_ms: 1500

**录制期间**\ （`episode_recorder.py:161-600 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/episode_recorder.py#L161-L600>`__）：

.. code:: python

   # Subscribe to topic with QoS from contract
   sub = node.create_subscription(
       sensor_msgs.msg.Image,
       "/camera/top/image_raw",
       callback,
       qos_profile_from_dict(spec.qos)
   )
   # Write raw message to bag (no processing)
   writer.write(topic, serialize_message(msg), timestamp_ns)

**数据集转换期间**\ （`bag_to_lerobot.py:454-485 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/bag_to_lerobot.py#L454-L485>`__）：

.. code:: python

   # Decode using contract metadata
   val = decode_value(spec.ros_type, msg, spec)  # Returns HWC numpy array
   # Resample at contract rate_hz
   resampled = resample(spec.resample_policy, timestamps, values, 
                        ticks_ns, step_ns, spec.asof_tol_ms)
   # Apply resize from contract
   resized = nearest_resize_rgb(resampled, spec.image_resize)

**实时推理期间**\ （`lerobot_policy_node.py:381-420 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/lerobot_policy_node.py#L381-L420>`__）：

.. code:: python

   # Same decode function
   val = decode_value(spec.ros_type, msg, spec)
   # Same buffer sampling
   obs_frame[spec.key] = stream_buffer.sample(timestamp_ns)
   # Same preprocessing (inside TensorPreprocessor)
   preprocessor.process(obs_frame)  # Uses same resize logic

**来源**：
`src/dataset_tools/dataset_tools/episode_recorder.py:161-600 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/dataset_tools/episode_recorder.py#L161-L600>`__，
`src/dataset_tools/dataset_tools/bag_to_lerobot.py:454-632 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/dataset_tools/bag_to_lerobot.py#L454-L632>`__，
`src/inference_service/inference_service/lerobot_policy_node.py:381-420 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/lerobot_policy_node.py#L381-L420>`__

契约指纹
~~~~~~~~

为了检测训练和部署之间的契约不匹配，IB-Robot 计算**契约指纹**：

.. code:: python

   def contract_fingerprint(contract: Contract) -> str:
       """Generate deterministic hash of contract structure."""
       # Include: observation keys, action keys, tensor shapes, rate_hz
       # Exclude: topics, QoS (deployment-specific)
       data = {
           "observations": {obs.key: obs.shape for obs in contract.observations},
           "actions": {act.key: act.shape for act in contract.actions},
           "rate_hz": contract.rate_hz
       }
       return hashlib.sha256(json.dumps(data, sort_keys=True).encode()).hexdigest()

此指纹： - 在数据集转换期间存储在 ``info.json`` 中（`bag_to_lerobot.py:385-389 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/bag_to_lerobot.py#L385-L389>`__） - 在推理启动时验证（可选检查）

**来源**：
`src/robot_config/robot_config/contract_utils.py:120-150 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/contract_utils.py#L120-L150>`__，
`src/dataset_tools/dataset_tools/bag_to_lerobot.py:385-389 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/dataset_tools/bag_to_lerobot.py#L385-L389>`__

--------------

原则三：控制模式架构
--------------------

.. _overview-2:

概述
~~~~

IB-Robot 支持**三种控制模式**，代表根本不同的机器人控制范式：

1. ``teleop``：人类遥操作（VR、Xbox、主臂）
2. ``model_inference``：高频 AI 控制（ACT、Diffusion Policy）
3. ``moveit_planning``：带轨迹执行的运动规划（VoxPoser、VLM）

所有三种模式**汇聚于同一硬件抽象层**\ （ros2_control），通过单一启动参数实现无缝模式切换。

模式配置结构
~~~~~~~~~~~~

每种模式在 ``robot_config`` YAML 的 ``control_modes`` 部分定义：

.. code:: yaml

   control_modes:
     teleop:
       description: "Human teleoperation mode (direct control)"
       controllers:
         - joint_state_broadcaster
         - arm_position_controller
         - gripper_position_controller
       inference:
         enabled: false
         force_disable: true
       executor:
         type: topic
         mode: teleop
         control_frequency: 50.0
     
     model_inference:
       description: "High-frequency end-to-end control mode (ACT/pi0)"
       controllers:
         - joint_state_broadcaster
         - arm_position_controller
         - gripper_position_controller
       inference:
         enabled: true
         execution_mode: "distributed"  # or "monolithic"
         model: so101_act
       executor:
         type: topic
         mode: model_inference
         control_frequency: 50.0
         queue_size: 100
     
     moveit_planning:
       description: "MoveIt trajectory planning mode (VoxPoser/VLM)"
       controllers:
         - joint_state_broadcaster
         - arm_trajectory_controller
         - gripper_trajectory_controller
       inference:
         enabled: false
       executor:
         type: action
         mode: moveit_planning

**来源**：
`src/robot_config/config/robots/so101_single_arm.yaml:45-103 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L45-L103>`__，
`src/robot_config/README.en.md:88-213 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/README.en.md#L88-L213>`__

图表：控制模式汇聚架构
~~~~~~~~~~~~~~~~~~~~~~

.. mermaid::

   graph TB
       subgraph "Control Mode Selection"
           LAUNCH["robot.launch.py<br/>--control_mode parameter"]
           DEFAULT["default_control_mode<br/>from robot_config YAML"]
           
           LAUNCH -.->|"overrides if specified"| ROUTER["Control Mode Router<br/>validate_control_mode_config()"]
           DEFAULT --> ROUTER
       end
       
       subgraph "Mode 1: Teleoperation"
           TELEOP_DEV["Teleoperation Device<br/>(VR/Xbox/LeaderArm)"]
           TELEOP_NODE["robot_teleop node<br/>leader_follower.py"]
           TELEOP_EXEC["TopicExecutor<br/>(direct passthrough)"]
           
           TELEOP_DEV --> TELEOP_NODE
           TELEOP_NODE --> TELEOP_EXEC
       end
       
       subgraph "Mode 2: Model Inference"
           INF_SVC["lerobot_policy_node<br/>(ACT/Diffusion Policy)"]
           DISP_NODE["action_dispatcher_node<br/>(queue + smoother)"]
           TOPIC_EXEC["TopicExecutor<br/>(100Hz streaming)"]
           
           INF_SVC -->|"action chunks"| DISP_NODE
           DISP_NODE --> TOPIC_EXEC
       end
       
       subgraph "Mode 3: MoveIt Planning"
           POSE_CMD["Pose Commands<br/>/cmd_pose topic"]
           MOVEIT_GW["MoveItGateway<br/>moveit_gateway.py"]
           MOVEIT_CORE["MoveIt2 Core<br/>(OMPL/Pilz planners)"]
           ACTION_EXEC["ActionExecutor<br/>(FollowJointTrajectory)"]
           
           POSE_CMD --> MOVEIT_GW
           MOVEIT_GW --> MOVEIT_CORE
           MOVEIT_CORE --> ACTION_EXEC
       end
       
       subgraph "Unified Hardware Layer"
           ROS2_CTRL["ros2_control<br/>controller_manager"]
           
           TELEOP_EXEC -->|"/arm_position_controller/commands"| ROS2_CTRL
           TOPIC_EXEC -->|"/arm_position_controller/commands"| ROS2_CTRL
           ACTION_EXEC -->|"/arm_trajectory_controller/follow_joint_trajectory"| ROS2_CTRL
           
           HW_CHOICE{"use_sim parameter"}
           
           ROS2_CTRL --> HW_CHOICE
           
           HW_CHOICE -->|"false"| REAL["SO101SystemHardware<br/>Feetech SDK"]
           HW_CHOICE -->|"true"| SIM["gz_ros2_control<br/>Gazebo simulation"]
       end
       
       ROUTER -->|"mode=teleop"| TELEOP_NODE
       ROUTER -->|"mode=model_inference"| INF_SVC
       ROUTER -->|"mode=moveit_planning"| MOVEIT_GW

**来源**：`src/robot_config/launch/robot.launch.py:87-432 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/launch/robot.launch.py#L87-L432>`__，
`src/robot_config/robot_config/contract_builder.py:9-104 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/contract_builder.py#L9-L104>`__，
`src/robot_moveit/scripts/moveit_gateway.py <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/scripts/moveit_gateway.py>`__

各模式的控制器类型
~~~~~~~~~~~~~~~~~~

不同的控制模式需要不同的 ros2_control 控制器：


.. list-table::
   :header-rows: 1

   * - 模式
     - 控制器类型
     - 接口
     - 频率
     - 用途
   * - ``tel eop``
     - ``JointGroupPo sitionController``
     - Topic ( ``Float64Mu ltiArray``)
     - 50 Hz
     - 来自人类 输入的直接 位置命令
   * - ``mo del_i nfere nce``
     - ``JointGroupPo sitionController``
     - Topic ( ``Float64Mu ltiArray``)
     - 100 Hz
     - 来自 AI 模型的高频 流式命令
   * - ``mo veit_ plann ing``
     - ``JointTraj ectoryController``
     - Action (``Fo llowJointTr ajectory``)
     - 可变
     - 来自规划器 的时间参数 化轨迹

**来源**：`src/robot_config/README.en.md:164-206 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/README.en.md#L164-L206>`__

模式切换的关键代码实体
~~~~~~~~~~~~~~~~~~~~~~


.. list-table::
   :header-rows: 1

   * - 实体
     - 文件
     - 用途
   * - ``validate_c ontrol_mode_config()``
     - `contract_builder.py:9-104 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.py#L9-L104>`__
     - 在启动前验证模式配置 ontract_builder
   * - ``genera te_execution_nodes()``
     - `launch_builders/execution.py:113-350 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/y#L113-L350>`__
     - 根据模式生成推理/调度器 节点 ers/execution.p
     - 节点
   * - ``generate_ ros2_control_nodes()``
     - `la unch_builders/c ontrol.py <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/la unch_builders/c ontrol.py>`__
     - 为模式生成正确的控制器
   * - ``TopicExecutor``
     - `action_di spatch/topic_ex ecutor.py <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/action_di spatch/topic_ex ecutor.py>`__
     - 向话题发布位置命令
   * - ``ActionExecutor``
     - `action_dis patch/action_ex ecutor.py <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/action_dis patch/action_ex ecutor.py>`__
     - 通过动作发送轨迹

模式切换示例
~~~~~~~~~~~~

从 ``model_inference`` 切换到 ``moveit_planning``：

.. code:: bash

   # Original launch (model_inference mode)
   ros2 launch robot_config robot.launch.py \
     robot_config:=so101_single_arm \
     control_mode:=model_inference

   # Switch to moveit_planning mode
   ros2 launch robot_config robot.launch.py \
     robot_config:=so101_single_arm \
     control_mode:=moveit_planning

内部变化： 1. **控制器生成**：``arm_trajectory_controller`` 替换 ``arm_position_controller`` 2.
**节点生成**：``MoveItGateway`` 节点替代 ``lerobot_policy_node`` 启动 3. **执行器类型**：使用 ``ActionExecutor`` 而非 ``TopicExecutor`` 4. **硬件接口**：**无变化** - 同一 ``SO101SystemHardware`` 插件

**来源**：`src/robot_config/launch/robot.launch.py:154-179 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/launch/robot.launch.py#L154-L179>`__，
`src/robot_config/README.md:88-356 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/README.md#L88-L356>`__

自动模式检测
~~~~~~~~~~~~

启动系统可以根据模式配置自动检测要启动的适当节点：

.. code:: python

   # From robot.launch.py
   def should_launch_inference(control_mode_config, with_inference_override):
       """Auto-detect if inference service should launch."""
       if with_inference_override is not None:
           return with_inference_override  # Explicit override
       
       # Auto-detect from mode config
       inference_config = control_mode_config.get('inference', {})
       return inference_config.get('enabled', False)

   def should_launch_moveit(control_mode_name, with_moveit_override):
       """Auto-detect if MoveIt should launch."""
       if with_moveit_override is not None:
           return with_moveit_override  # Explicit override
       
       # Auto-detect: launch MoveIt if mode name contains "moveit"
       return 'moveit' in control_mode_name.lower()

**来源**：`src/robot_config/launch/robot.launch.py:112-179 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/launch/robot.launch.py#L112-L179>`__

--------------

总结：三大原则如何协同工作
--------------------------

三个核心概念形成一个集成架构：

1. **单一数据源**提供基础：

   -  所有机器人规格集中在一个 YAML 文件中
   -  消除子系统间的配置漂移

2. **契约驱动设计**确保一致性：

   -  契约从 robot_config **合成**
   -  从数据采集 → 训练 → 部署使用相同的处理流水线

3. **控制模式架构**实现灵活性：

   -  多种控制范式（人类、AI、规划）
   -  所有模式使用**相同的契约**和**相同的硬件接口**
   -  通过单一参数切换模式

这些原则共同实现： - **开发效率**：一处修改配置，处处生效 - **部署可靠性**：训练和推理看到相同的数据格式 - **系统灵活性**：无需修改代码即可切换控制模式

**来源**：`README.md:9-17 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L9-L17>`__，`docs/architecture.md:179-185 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/docs/architecture.md#L179-L185>`__，
`README.en.md:9-17 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.en.md#L9-L17>`__

--------------



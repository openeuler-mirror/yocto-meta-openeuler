单一数据源模式
==============

.. raw:: html

   <details>

相关源文件

以下文件用于生成此文档页面：

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

**目的**：本文档解释 IB-Robot 如何使用 ``robot_config`` YAML 文件作为所有硬件配置、观测/动作映射和系统行为的单一数据源。此模式消除了配置重复，并确保数据收集、训练和部署之间的一致性。

**范围**：涵盖 ``robot_config`` 包作为中央配置权威的角色、契约抽象，以及不同子系统如何消费相同配置。有关契约的技术模式详情，请参阅 `契约系统 <#3.2>`__。有关控制模式切换机制，请参阅 `控制模式架构 <#3.3>`__。

--------------

核心原则
--------

**单一数据源** 模式意味着所有系统配置都源自单个 ``robot_config`` YAML 文件。没有其他配置文件重复此信息。所有子系统——录制、数据集转换、推理、动作分发——都从同一源读取，确保它们以相同的方式处理数据。

**关键不变量**：如果两个节点处理相同的观测（例如相机图像），它们必须使用相同的参数（分辨率、编码、QoS 设置）。robot_config YAML 通过作为唯一定义这些参数的位置来强制执行此不变量。

.. mermaid::

   graph TB
       subgraph "单一数据源"
           YAML["robot_config YAML<br/>so101_single_arm.yaml"]
       end
       
       subgraph "直接消费者"
           LOADER["RobotConfig 加载器<br/>load_robot_config()"]
           CONTRACT["契约生成<br/>to_contract()"]
       end
       
       subgraph "子系统消费者"
           RECORDER["episode_recorder<br/>主题订阅"]
           BAG2LR["bag_to_lerobot<br/>解码 + 重采样"]
           INFERENCE["lerobot_policy_node<br/>观测过滤"]
           DISPATCH["action_dispatcher_node<br/>动作映射"]
           LAUNCH["robot.launch.py<br/>节点生成"]
       end
       
       YAML --> LOADER
       LOADER --> CONTRACT
       
       CONTRACT --> RECORDER
       CONTRACT --> BAG2LR
       CONTRACT --> INFERENCE
       CONTRACT --> DISPATCH
       
       YAML --> LAUNCH
       
       style YAML fill:#f9f9f9,stroke:#333,stroke-width:3px

**来源**：
`src/robot_config/config/robots/so101_single_arm.yaml:1-329 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L1-L329>`__，
`src/robot_config/robot_config/loader.py:147-214 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/loader.py#L147-L214>`__，
`src/robot_config/robot_config/config.py:133-216 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/config.py#L133-L216>`__

--------------

robot_config YAML 结构
----------------------

``robot_config`` YAML 文件包含多个顶层部分，每个部分服务于特定目的：


.. list-table::
   :header-rows: 1

   * - 部分
     - 用途
     - 消费者
   * - ``robot.name``
     - 机器人标识符
     - 所有节点（日志、命名空间）
   * - ``robot.robot_type``
     - LeRobot 数据集元数据
     - ``bag_to_lerobot``、数据集信息
   * - ``robot.joints``
     - 统一关节定义
     - 控制器、MoveIt、验证
   * - ``robot.models``
     - 策略检查点库
     - ``lerobot_policy_node``、启动
   * - ``robot.peripherals``
     - 硬件设备（相机）
     - 相机驱动、TF 发布器
   * - ``robot.control_modes``
     - 模式特定控制器集
     - ``robot.launch.py``、控制器生成器
   * - ``robot.contract````
     - **观测 + 动作**
     - **所有数据流水线节点**
   * - ``robot.ros2_control``
     - 硬件抽象配置
     - ``ros2_control_node``、URDF
   * - ``robot.teleoperation``
     - 遥操作设备配置
     - ``robot_teleop`` 节点

关键部分：contract
~~~~~~~~~~~~~~~~~~~~~~~~~~~

``contract`` 部分对单一数据源模式最为重要。它定义：

.. code:: yaml

   contract:
     rate_hz: 20                    # 所有数据的重为样率
     max_duration_s: 90.0           # 回合超时
     
     observations:
       - key: observation.images.top
         topic: /camera/top/image_raw
         type: sensor_msgs/msg/Image
         peripheral: top              # 引用 peripherals 部分
         image:
           resize: [480, 640]         # H, W，用于 LeRobot
         align:
           strategy: hold             # 重采样策略
           stamp: header
           tol_ms: 1500
         qos:
           reliability: best_effort
           depth: 10
       
       - key: observation.state
         topic: /joint_states
         type: sensor_msgs/msg/JointState
         selector:
           names:                     # 消息中的点分路径
             - "position.1"
             - "position.2"
             # ...
     
     actions:
       - key: action
         selector:
           names:
             - "action.0"
             - "action.1"
             # ...
         publish:
           topic: /arm_position_controller/commands
           type: std_msgs/msg/Float64MultiArray
           qos:
             reliability: best_effort

**来源**：
`src/robot_config/config/robots/so101_single_arm.yaml:198-302 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L198-L302>`__

--------------

契约作为数据类
--------------

YAML 契约通过 ``RobotConfig.to_contract()`` 加载到结构化的 ``Contract`` 数据类中：

.. mermaid::

   graph LR
       YAML["robot_config YAML"]
       LOADER["load_robot_config()"]
       ROBOT_CFG["RobotConfig dataclass"]
       CONTRACT["Contract dataclass"]
       
       YAML -->|"yaml.safe_load()"| LOADER
       LOADER -->|"验证 + 解析"| ROBOT_CFG
       ROBOT_CFG -->|"to_contract()"| CONTRACT
       
       subgraph "契约模式"
           OBS["ObservationSpec[]<br/>- key, topic, type<br/>- selector, image<br/>- align, qos"]
           ACT["ActionSpec[]<br/>- key, publish_topic<br/>- selector, qos<br/>- safety_behavior"]
           META["元数据<br/>- rate_hz<br/>- max_duration_s<br/>- robot_type"]
       end
       
       CONTRACT --> OBS
       CONTRACT --> ACT
       CONTRACT --> META

``Contract`` 数据类提供对配置的类型化访问：

.. code:: python

   # 来自 robot_config/contract_utils.py
   @dataclass(frozen=True)
   class Contract:
       name: str
       version: int
       rate_hz: float
       max_duration_s: float
       observations: List[ObservationSpec]
       actions: List[ActionSpec]
       tasks: List[TaskSpec]
       robot_type: Optional[str]

**关键方法**：``RobotConfig.to_contract()`` 从 YAML 合成 ``Contract``，解析外设引用并应用默认值。

**来源**：`src/robot_config/robot_config/config.py:133-216 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/config.py#L133-L216>`__，
`src/robot_config/robot_config/contract_utils.py:83-97 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/contract_utils.py#L83-L97>`__

--------------

契约传播到子系统
------------------

契约从 ``robot_config.yaml`` 流向所有数据流水线子系统：

.. mermaid::

   graph TB
       subgraph "robot_config YAML"
           YAML["so101_single_arm.yaml<br/>契约定义"]
       end
       
       subgraph "阶段 1: 录制"
           RECORDER["episode_recorder 节点"]
           REC_LOAD["load_robot_config()<br/>to_contract()"]
           REC_SUBS["为所有观测<br/>创建订阅"]
           REC_WRITE["写入 bag 并附带<br/>契约元数据"]
       end
       
       subgraph "阶段 2: 数据集转换"
           BAG2LR["bag_to_lerobot 脚本"]
           B2L_LOAD["load_robot_config()<br/>to_contract()"]
           B2L_DECODE["对每个 obs<br/>decode_value()"]
           B2L_RESAMPLE["以 rate_hz<br/>resample()"]
           B2L_FEATURES["feature_from_spec()<br/>张量形状"]
       end
       
       subgraph "阶段 3: 推理"
           INFERENCE["lerobot_policy_node"]
           INF_LOAD["load_robot_config()<br/>to_contract()"]
           INF_FILTER["按 model 的<br/>input_features 过滤"]
           INF_SUBS["为每个 obs<br/>创建 StreamBuffer"]
           INF_DECODE["运行时<br/>decode_value()"]
       end
       
       YAML --> REC_LOAD
       REC_LOAD --> REC_SUBS
       REC_SUBS --> REC_WRITE
       
       YAML --> B2L_LOAD
       B2L_LOAD --> B2L_DECODE
       B2L_DECODE --> B2L_RESAMPLE
       B2L_RESAMPLE --> B2L_FEATURES
       
       YAML --> INF_LOAD
       INF_LOAD --> INF_FILTER
       INF_FILTER --> INF_SUBS
       INF_SUBS --> INF_DECODE
       
       style YAML fill:#f9f9f9,stroke:#333,stroke-width:3px

**来源**：
`src/dataset_tools/dataset_tools/episode_recorder.py:194-206 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/dataset_tools/episode_recorder.py#L194-L206>`__，
`src/dataset_tools/dataset_tools/bag_to_lerobot.py:216-230 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/dataset_tools/bag_to_lerobot.py#L216-L230>`__，
`src/inference_service/inference_service/lerobot_policy_node.py:205-240 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/lerobot_policy_node.py#L205-L240>`__

--------------

共享处理函数
------------

所有子系统使用来自 ``robot_config.contract_utils`` 的相同函数以确保相同的数据处理：


.. list-table::
   :header-rows: 1

   * - 函数
     - 用途
     - 使用者
   * - ``iter_specs(contract)``
     - 生成统一的 ``SpecView`` 用于 obs/actions
     - 所有子系统
   * - ``decode_value( ros_type, msg, spec)``
     - 将 ROS 消息解码为 numpy
     - ``bag_to_lerobot``、 ``lerobot_policy_node``
   * - ``feature_from_spec( spec, use_videos)``
     - 生成 LeRobot 特征字典
     - ``bag_to_lerobot``
   * - ``zero_pad(feature_dict)``
     - 创建零值占位符
     - ``lerobot_policy_node``、 ``bag_to_lerobot``
   * - ``resample(policy, ts, vals, ticks, ...)``
     - 将流重为样为固定频率
     - ``bag_to_lerobot``
   * - ``qos_profile_from_dict(qos_dict)``
     - 将 QoS 字典转换为 ``QoSProfile``
     - ``episode_recorder``、 ``lerobot_policy_node``

**示例**：图像解码在录制和推理中使用相同的逻辑：

.. mermaid::

   graph LR
       subgraph "录制路径"
           REC_MSG["sensor_msgs/Image"]
           REC_DECODE["decode_value()<br/>contract_utils"]
           REC_BAG["写入 bag"]
       end
       
       subgraph "推理路径"
           INF_MSG["sensor_msgs/Image"]
           INF_DECODE["decode_value()<br/>contract_utils"]
           INF_TENSOR["转换为张量"]
       end
       
       REC_MSG --> REC_DECODE
       REC_DECODE --> REC_BAG
       
       INF_MSG --> INF_DECODE
       INF_DECODE --> INF_TENSOR
       
       SHARED["共享实现<br/>tensormsg.converter<br/>TensorMsgConverter.decode()"]
       
       REC_DECODE -.->|"调用"| SHARED
       INF_DECODE -.->|"调用"| SHARED
       
       style SHARED fill:#f9f9f9,stroke:#333,stroke-width:2px

**来源**：
`src/robot_config/robot_config/contract_utils.py:264-267 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/contract_utils.py#L264-L267>`__，
`src/tensormsg/tensormsg/converter.py:24-39 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/tensormsg/tensormsg/converter.py#L24-L39>`__，
`src/tensormsg/tensormsg/converter.py:172-232 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/tensormsg/tensormsg/converter.py#L172-L232>`__

--------------

外设引用解析
--------------

契约的 ``peripheral```` 字段在观测和硬件配置之间创建链接：

.. code:: yaml

   peripherals:
     - type: camera
       name: top
       driver: opencv
       index: 0
       width: 640
       height: 480
       fps: 30
       pixel_format: bgr8

   contract:
         observations:
       - key: observation.images.top
         topic: /camera/top/image_raw
         peripheral: top    # 引用上面的相机 'top'

**解析流程**：

1. ``load_robot_config()`` 将外设解析为 ``CameraConfig`` 对象
2. ``RobotConfig.to_contract()`` 解析 ``peripheral: top`` 以获取相机元数据
3. 如果缺少 ``image`` 字典，则从相机配置填充默认值：

   -  ``resize: [height, width]``
   -  ``encoding: pixel_format``

这确保观测规范自动继承硬件参数。

**来源**：`src/robot_config/robot_config/config.py:155-180 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/config.py#L155-L180>`__，
`src/robot_config/config/robots/so101_single_arm.yaml:131-196 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L131-L196>`__

--------------

一致性保证
----------

单一数据源模式提供三个关键保证：

1. 训练-部署对齐
~~~~~~~~~~~~~~~~

**问题**：ML 模型在部署中经常失败，因为训练数据预处理与运行时预处理不同（例如不同的图像调整大小算法、归一化范围）。

**解决方案**：``bag_to_lerobot`` 和 ``lerobot_policy_node`` 都使用相同的 ``decode_value()`` 函数，并使用从相同契约派生的相同 ``SpecView``。

.. mermaid::

   graph TB
       subgraph "训练数据集"
           BAG["ROS2 Bag"]
           B2L_DECODE["decode_value(spec)"]
           TRAIN_TENSOR["训练张量<br/>shape: [480, 640, 3]"]
       end
       
       subgraph "部署"
           LIVE["实时 ROS 主题"]
           INF_DECODE["decode_value(spec)"]
           DEPLOY_TENSOR["推理张量<br/>shape: [480, 640, 3]"]
       end
       
       SHARED_SPEC["SpecView 来自契约<br/>- image_resize: [480, 640]<br/>- image_encoding: bgr8"]
       
       BAG --> B2L_DECODE
       B2L_DECODE --> TRAIN_TENSOR
       
       LIVE --> INF_DECODE
       INF_DECODE --> DEPLOY_TENSOR
       
       SHARED_SPEC -.->|"相同规范"| B2L_DECODE
       SHARED_SPEC -.->|"相同规范"| INF_DECODE
       
       GUARANTEE["✓ 相同处理<br/>✓ 无训练-服务偏差"]
       TRAIN_TENSOR -.-> GUARANTEE
       DEPLOY_TENSOR -.-> GUARANTEE

**来源**：
`src/dataset_tools/dataset_tools/bag_to_lerobot.py:476-481 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/dataset_tools/bag_to_lerobot.py#L476-L481>`__，
`src/inference_service/inference_service/lerobot_policy_node.py:391-397 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/lerobot_policy_node.py#L391-L397>`__

2. 按模型需求过滤观测
~~~~~~~~~~~~~~~~~~~~~~

**问题**：单个机器人配置可能支持多个具有不同观测需求的模型（例如一个模型使用 3 个相机，另一个使用 2 个）。

**解决方案**：``lerobot_policy_node`` 加载模型的 ``config.json`` 以获取 ``input_features``，然后过滤契约的观测以仅订阅所需的主题。

.. mermaid::

   graph LR
       subgraph "robot_config YAML"
           ALL_OBS["所有观测<br/>- images.top<br/>- images.wrist<br/>- images.front<br/>- state"]
       end
       
       subgraph "模型 A (ACT)"
           MODEL_A_CFG["config.json<br/>input_features:<br/>- images.top<br/>- images.wrist<br/>- state"]
           MODEL_A_SUBS["订阅<br/>- /camera/top<br/>- /camera/wrist<br/>- /joint_states"]
       end
       
       subgraph "模型 B (Diffusion)"
           MODEL_B_CFG["config.json<br/>input_features:<br/>- images.front<br/>- state"]
           MODEL_B_SUBS["订阅<br/>- /camera/front<br/>- /joint_states"]
       end
       
       ALL_OBS --> MODEL_A_CFG
       MODEL_A_CFG -->|"过滤契约"| MODEL_A_SUBS
       
       ALL_OBS --> MODEL_B_CFG
       MODEL_B_CFG -->|"过滤契约"| MODEL_B_SUBS

**代码**：
`src/inference_service/inference_service/lerobot_policy_node.py:180-240 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/lerobot_policy_node.py#L180-L240>`__

.. code:: python

   def _load_policy_config(self):
       # 加载模型的 config.json
       config_path = Path(policy_path) / "config.json"
       self._policy_config = json.load(f)
       
       # 提取所需输入
       input_features = self._policy_config.get("input_features", {})
       self._required_inputs = set(input_features.keys())

   def _load_contract(self, robot_config_path: str):
       # 从 robot_config 加载契约（所有观测）
       all_obs_specs = [s for s in iter_specs(contract) if not s.is_action]
       
       # 按模型需求过滤
       self._obs_specs = [
           s for s in all_obs_specs 
           if s.key in self._required_inputs
       ]

**来源**：
`src/inference_service/inference_service/lerobot_policy_node.py:180-240 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/lerobot_policy_node.py#L180-L240>`__

3. 动作映射一致性
~~~~~~~~~~~~~~~~~~

**问题**：模型生成的动作必须路由到正确的控制器主题，并使用正确的消息结构。

**解决方案**：契约的 ``actions`` 部分定义了张量侧选择器（哪些索引去哪里）和 ROS 侧发布器（主题、类型、QoS）。

**契约示例**：

.. code:: yaml

   actions:
     # 手臂关节 (0-4) 去手臂控制器
     - key: action
       selector:
         names: ["action.0", "action.1", "action.2", "action.3", "action.4"]
       publish:
         topic: /arm_position_controller/commands
         type: std_msgs/msg/Float64MultiArray
     
     # 夹爪关节 (5) 去夹爪控制器
     - key: action
       selector:
         names: ["action.5"]
       publish:
         topic: /gripper_position_controller/commands
         type: std_msgs/msg/Float64MultiArray

``TopicExecutor`` 读取此契约以正确拆分动作张量：

.. code:: python

   # 来自 action_dispatch/topic_executor.py (概念性)
   for action_spec in contract.actions:
       # action_spec.selector.names = ["action.0", "action.1", ...]
       # action_spec.publish_topic = "/arm_position_controller/commands"
       
       indices = [int(name.split('.')[-1]) for name in action_spec.names]
       msg = encode_value(action_spec.type, action_spec.names, 
                          action_tensor[indices], action_spec.clamp)
       publisher.publish(msg)

**来源**：
`src/robot_config/config/robots/so101_single_arm.yaml:262-301 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L262-L301>`__，
`src/action_dispatch/action_dispatch/topic_executor.py:1-319 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatch/topic_executor.py#L1-L319>`__

--------------

配置加载流水线
----------------

从 YAML 到运行时使用的完整加载流水线：

.. mermaid::

   graph TB
       YAML["robot_config YAML"]
       
       subgraph "加载层"
           LOAD["load_robot_config()<br/>loader.py"]
           ROBOT_CFG["RobotConfig dataclass<br/>config.py"]
           TO_CONTRACT["to_contract() 方法"]
           CONTRACT["Contract dataclass<br/>contract_utils.py"]
       end
       
       subgraph "消费层"
           ITER_SPECS["iter_specs(contract)<br/>→ SpecView[]"]
           
           RECORDER_USE["episode_recorder<br/>- 创建订阅<br/>- 写入 bag"]
           BAG2LR_USE["bag_to_lerobot<br/>- 解码消息<br/>- 重为样流<br/>- 生成特征"]
           INFERENCE_USE["lerobot_policy_node<br/>- 按" input_features 过滤<br/>- 创建 StreamBuffer<br/>- 解码观测"]
           DISPATCH_USE["action_dispatcher_node<br/>- 创建 TopicExecutor<br/>- 路由动作块"]
       end
       
       YAML --> LOAD
       LOAD --> ROBOT_CFG
       ROBOT_CFG --> TO_CONTRACT
       TO_CONTRACT --> CONTRACT
       
       CONTRACT --> ITER_SPECS
       
       ITER_SPECS --> RECORDER_USE
       ITER_SPECS --> BAG2LR_USE
       ITER_SPECS --> INFERENCE_USE
       ITER_SPECS --> DISPATCH_USE
       
       style YAML fill:#f9f9f9,stroke:#333,stroke-width:3px
       style CONTRACT fill:#e8f5e9,stroke:#388e3c,stroke-width:2px

**来源**：`src/robot_config/robot_config/loader.py:147-214 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/loader.py#L147-L214>`__，
`src/robot_config/robot_config/config.py:133-216 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/config.py#L133-L216>`__，
`src/robot_config/robot_config/contract_utils.py:156-211 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/contract_utils.py#L156-L211>`__

--------------

代码实体映射
------------

实现单一数据源模式的关键类和函数：


.. list-table::
   :header-rows: 1

   * - 实体
     - 文件
     - 用途
   * - ``RobotConfig``
     - `config.py:105-217 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/config.py#L105-L217>`__
     - 主配置数据类
   * - ``RobotConfig.to_contract()``
     - `config.py:133-216 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/config.py#L133-L216>`__
     - 从配置合成契约
   * - ``Contract``
     - `contract_utils.py:83-97 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/contract_utils.py#L83-L97>`__
     - 运行时 I/O 规范
   * - ``ObservationSpec``
     - `contract_utils.py:42-56 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/contract_utils.py#L42-L56>`__
     - 单个观测流规范
   * - ``ActionSpec``
     - `contract_utils.py:59-70 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/contract_utils.py#L59-L70>`__
     - 单个动作流规范
   * - ``SpecView``
     - `contract_utils.py:112-129 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/contract_utils.py#L112-L129>`__
     - 标准化运行时视图
   * - ``load_robot_config()``
     - `loader.py:147-214 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/loader.py#L147-L214>`__
     - YAML → RobotConfig 解析器
   * - ``iter_specs()``
     - `contract_utils.py:156-211 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/contract_utils.py#L156-L211>`__
     - 契约 → SpecView[] 迭代器
   * - ``decode_value()``
     - `contract_utils.py:264-267 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/contract_utils.py#L264-L267>`__
     - ROS 消息 → numpy 解码器
   * - ``feature_from_spec()``
     - `contract_utils.py:214-235 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/contract_utils.py#L214-L235>`__
     - SpecView → LeRobot 特征字典
   * - ``qos_profile_from_dict()``
     - `contract_utils.py:370-392 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/contract_utils.py#L370-L392>`__
     - QoS 字典 → QoSProfile 转换器

--------------

实践示例：添加新相机
--------------------

为了演示单一数据源模式的实际应用，考虑添加一个新相机：

**步骤 1**：在 ``peripherals`` 部分添加相机：

.. code:: yaml

   peripherals:
     - type: camera
       name: side
       driver: opencv
       index: 4
       width: 640
       height: 480
       fps: 30
       pixel_format: bgr8
       frame_id: camera_side_frame

**步骤 2**：在 ``contract`` 部分添加观测：

.. code:: yaml

   contract:
     observations:
       - key: observation.images.side
         topic: /camera/side/image_raw
         peripheral: side    # 自动元数据解析
         image:
           resize: [480, 640]
         align:
           strategy: hold

**结果**：无需代码更改。系统自动：

1. **启动**：``robot.launch.py`` 生成相机驱动节点
2. **录制**：``episode_recorder`` 订阅 ``/camera/side/image_raw``
3. **转换**：``bag_to_lerobot`` 解码并重为样新相机
4. **训练**：LeRobot 数据集包含 ``observation.images.side`` 特征
5. **推理**：``lerobot_policy_node`` 如果模型需要则订阅

所有子系统使用相同的分辨率（480×640）、编码（bgr8）和 QoS 设置，因为它们都从相同的 YAML 读取。

**来源**：`src/robot_config/launch/robot.launch.py:220-240 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/launch/robot.launch.py#L220-L240>`__，
`src/dataset_tools/dataset_tools/episode_recorder.py:229-243 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/dataset_tools/episode_recorder.py#L229-L243>`__，
`src/dataset_tools/dataset_tools/bag_to_lerobot.py:287-327 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/dataset_tools/bag_to_lerobot.py#L287-L327>`__

--------------

配置验证
----------

``validate_config()`` 函数在运行时之前确保架构一致性：

.. code:: python

   # 来自 robot_config/contract_builder.py
   def validate_control_mode_config(robot_config: Dict, control_mode: str):
       """在合成之前验证控制模式配置。"""
       
       # 检查 1：控制模式存在
       if control_mode not in robot_config.get('control_modes', {}):
           raise ContractSynthesisError(f"Mode '{control_mode}' 未定义")
       
       # 检查 2：模型引用存在
       model_name = inference_config.get('model')
       if model_name not in robot_config.get('models', {}):
           raise ContractSynthesisError(f"Model '{model_name}' 未找到")
       
       # 检查 3：外设引用有效
       for obs_spec in observations:
           peripheral_name = obs_spec.get('peripheral')
           if peripheral_name:
               if not find_peripheral(robot_config, peripheral_name):
                   raise ContractSynthesisError(
                       f"Peripheral '{peripheral_name}' 未定义"
                   )

这在启动时（快速失败）而不是在推理期间捕获错误。

**来源**：
`src/robot_config/robot_config/contract_builder.py:9-104 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/contract_builder.py#L9-L104>`__

--------------

反模式：配置重复
----------------

**❌ 错误**：在多个位置定义相机分辨率：

.. code:: yaml

   # 错误：重复定义
   peripherals:
     - name: top
       width: 640
       height: 480

   contract:
     observations:
       - key: observation.images.top
         peripheral: top
         image:
           resize: [480, 640]  # 重复！可能不同步

   # 然后在推理代码中也重复：
   # policy_node.py
   # self.image_resize = (480, 640)  # 三重定义！

**✓ 正确**：定义一次，到处引用：

.. code:: yaml

   peripherals:
     - name: top
       width: 640    # 单一数据源
       height: 480

   contract:
     observations:
       - key: observation.images.top
         peripheral: top  # 从外设定义自动填充
         # image.resize 从相机配置自动填充

**来源**：`src/robot_config/robot_config/config.py:155-180 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/config.py#L155-L180>`__

--------------

总结
----

IB-Robot 中的单一数据源模式确保：

1. **无重复**：所有硬件和 I/O 配置位于一个 YAML 文件中
2. **一致性**：相同的契约 → 在录制、训练和推理中相同的处理
3. **可维护性**：更改相机分辨率会自动更新所有子系统
4. **类型安全**：配置被解析为带验证的类型化数据类
5. **可扩展性**：添加新观测/动作仅需 YAML 更改，无需代码

**关键文件**：

- 配置：`src/robot_config/config/robots/so101_single_arm.yaml:1-329 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L1-L329>`__
- 加载：`src/robot_config/robot_config/loader.py:147-214 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/loader.py#L147-L214>`__
- 契约生成：`src/robot_config/robot_config/config.py:133-216 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/config.py#L133-L216>`__
- 契约模式：`src/robot_config/robot_config/contract_utils.py:83-97 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/contract_utils.py#L83-L97>`__
- 录制使用：`src/dataset_tools/dataset_tools/episode_recorder.py:194-206 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/dataset_tools/episode_recorder.py#L194-L206>`__
- 转换使用：`src/dataset_tools/dataset_tools/bag_to_lerobot.py:216-230 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/dataset_tools/bag_to_lerobot.py#L216-L230>`__
- 推理使用：`src/inference_service/inference_service/lerobot_policy_node.py:205-240 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/lerobot_policy_node.py#L205-L240>`__

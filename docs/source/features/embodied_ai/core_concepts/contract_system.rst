契约系统
========

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
-  `src/robot_config/README.en.md <src/robot_config/README.en.md>`__
-  `src/robot_config/README.md <src/robot_config/README.md>`__
-  `src/robot_config/config/contracts/pi05_multi_tasks.yaml <src/robot_config/config/contracts/pi05_multi_tasks.yaml>`__
-  `src/robot_config/config/robots/so101_dual_arm.yaml <src/robot_config/config/robots/so101_dual_arm.yaml>`__
-  `src/robot_config/config/robots/so101_single_arm.yaml <src/robot_config/config/robots/so101_single_arm.yaml>`__
-  `src/robot_config/robot_config/loader.py <src/robot_config/robot_config/loader.py>`__
-  `src/tensormsg/tensormsg/converter.py <src/tensormsg/tensormsg/converter.py>`__

.. raw:: html

   </details>

目的与范围
----------

契约系统是定义 IB-Robot 系统的 **观测**\ （传感器输入）和 **动作**\ （机器人输出）及其 ROS 到张量映射的架构抽象。它作为单一数据源，确保整个流水线从数据收集到训练再到部署的数据格式一致性。

本文档涵盖：

- 契约定义结构和 YAML 语法
- 观测和动作规范
- 外设集成和元数据传播
- 对齐策略和 QoS 设置

有关机器人配置如何使用契约的信息，请参阅 `机器人配置文件 <#5.1>`__。有关实际的 ROS 到张量转换实现详情，请参阅 `协议转换 (tensormsg) <#6>`__。

**来源**：`README.md:1-192 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L1-L192>`__，
`src/robot_config/config/robots/so101_single_arm.yaml:1-329 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L1-L329>`__，
`docs/architecture.md:1-313 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/docs/architecture.md#L1-L313>`__

--------------

契约架构概述
------------

契约抽象位于 IB-Robot 数据一致性保证的核心。通过在 YAML 中一次性定义观测-动作接口，所有下游消费者（录制器、数据集转换器、推理节点）自动使用相同的处理逻辑。

.. mermaid::

   graph TB
       subgraph "契约定义层"
           YAML["robot_config YAML<br/>(单一数据源)"]
           CONTRACT["contract 部分"]
           OBS["observations[]"]
           ACT["actions[]"]
           PERIPH["peripherals[]"]
           
           YAML --> CONTRACT
           CONTRACT --> OBS
           CONTRACT --> ACT
           YAML --> PERIPH
       end
       
       subgraph "契约加载层"
           LOADER["robot_config.loader<br/>load_contract_config()"]
           CONFIG["ContractExtensionConfig"]
           OBS_OBJ["ContractObservation[]"]
           ACT_OBJ["ContractAction[]"]
           
           CONTRACT --> LOADER
           LOADER --> CONFIG
           CONFIG --> OBS_OBJ
           CONFIG --> ACT_OBJ
       end
       
       subgraph "契约消费层"
           RECORDER["episode_recorder<br/>订阅主题"]
           BAG2LR["bag_to_lerobot<br/>解码 + 重采样"]
           POLICY["lerobot_policy_node<br/>StreamBuffer 创建"]
           
           OBS_OBJ --> RECORDER
           OBS_OBJ --> BAG2LR
           OBS_OBJ --> POLICY
           
           ACT_OBJ --> RECORDER
           ACT_OBJ --> BAG2LR
           ACT_OBJ --> POLICY
       end
       
       PERIPH -.->|"元数据注入"| OBS_OBJ

**图表**：契约系统架构，显示定义、加载和消费层。

**来源**：`src/robot_config/robot_config/loader.py:94-144 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/loader.py#L94-L144>`__，
`src/robot_config/config/robots/so101_single_arm.yaml:198-301 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L198-L301>`__

--------------

契约结构
--------

契约定义在机器人配置 YAML 的 ``robot.contract`` 部分中。完整结构包括：


.. list-table::
   :header-rows: 1

   * - 字段
     - 类型
     - 必需
     - 描述
   * - ``base_contract``
     - string
     - 否
     - 要继承的基础契约 YAML 的路径
   * - ``rate_hz``
     - float
     - 是
     - 录制/推理频率（Hz）
   * - ``max_duration_s``
     - float
     - 是
     - 最大回合时长（秒）
   * - ``observations``
     - list
     - 是
     - 观测规范 (传感器、图像、状态)
   * - ``actions``
     - list
     - 是
     - 动作规范 (关节命令、夹爪)

**契约结构示例**：

.. code:: yaml

   contract:
     base_contract: $(find robot_config)/config/contracts/act_grab_pan.yaml
     rate_hz: 20
     max_duration_s: 90.0
     
     observations:
       - key: observation.images.top
         # ... 观测规范
       - key: observation.state
         # ... 状态规范
     
     actions:
       - key: action
         # ... 动作规范

**来源**：
`src/robot_config/config/robots/so101_single_arm.yaml:198-202 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L198-L202>`__，
`src/robot_config/robot_config/loader.py:94-144 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/loader.py#L94-L144>`__

--------------

观测规范
--------

每个观测定义如何将 ROS 主题转换为 ML 模型使用的张量。观测规范包括主题信息、数据提取规则、时间对齐策略和 QoS 设置。

观测模式
~~~~~~~~

.. mermaid::

   graph LR
       OBS["ContractObservation"]
       
       OBS --> KEY["key: str<br/>(例如 'observation.images.top')"]
       OBS --> TOPIC["topic: str<br/>(ROS 主题路径)"]
       OBS --> TYPE["type: str<br/>(ROS 消息类型)"]
       OBS --> PERIPH["peripheral: str<br/>(引用 peripherals[])"]
       OBS --> SELECTOR["selector: dict<br/>(names: [])"]
       OBS --> IMAGE["image: dict<br/>(resize: [H, W])"]
       OBS --> ALIGN["align: dict<br/>(strategy, stamp, tol_ms)"]
       OBS --> QOS["qos: dict<br/>(reliability, history, depth)"]

**图表**：观测规范模式，显示所有可配置字段。

**来源**：`src/robot_config/robot_config/loader.py:113-124 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/loader.py#L113-L124>`__，
`src/robot_config/robot_config/config.py:1-200 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/config.py#L1-L200>`__

图像观测
~~~~~~~~

图像观测引用相机外设并指定调整大小参数：

.. code:: yaml

   observations:
     - key: observation.images.top
       topic: /camera/top/image_raw
       type: sensor_msgs/msg/Image
       peripheral: top  # 引用 peripherals[name='top']
       image:
         resize: [480, 640]  # [高度, 宽度]，用于 LeRobot
       align:
         strategy: hold
         stamp: header
         tol_ms: 1500
       qos:
         reliability: best_effort
         history: keep_last
         depth: 10

``peripheral`` 字段启用自动元数据注入：当 ``bag_to_lerobot`` 或 ``lerobot_policy_node`` 加载此观测时，它们自动从外设定义中获知相机的原始分辨率、FPS 和帧 ID。

**来源**：
`src/robot_config/config/robots/so101_single_arm.yaml:219-232 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L219-L232>`__，
`src/robot_config/config/robots/so101_single_arm.yaml:130-152 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L130-L152>`__

状态观测
~~~~~~~~

状态观测使用 ``selector`` 机制从 ROS 消息中提取特定字段：

.. code:: yaml

   observations:
     - key: observation.state
       topic: /joint_states
       type: sensor_msgs/msg/JointState
       selector:
         names:
           - "position.1"
           - "position.2"
           - "position.3"
           - "position.4"
           - "position.5"
           - "position.6"
       align:
         strategy: hold
         stamp: header
         tol_ms: 1500
       qos:
         reliability: best_effort
         history: keep_last
         depth: 50

``selector.names`` 列表使用 **点分路径表示法** 从 ROS 消息中提取嵌套字段。格式为 ``field.subfield[.index]``。对于 ``sensor_msgs/msg/JointState``，``position.1`` 表示"名为 '1' 的关节的位置值"。

**来源**：
`src/robot_config/config/robots/so101_single_arm.yaml:249-260 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L249-L260>`__，
`src/tensormsg/tensormsg/converter.py:86-93 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/tensormsg/tensormsg/converter.py#L86-L93>`__

--------------

动作规范
--------

动作定义如何将 ML 模型的张量输出转换回 ROS 消息并发布以控制机器人。

动作模式
~~~~~~~~

.. mermaid::

   graph LR
       ACT["ContractAction"]
       
       ACT --> KEY["key: str<br/>(例如 'action')"]
       ACT --> SELECTOR["selector: dict<br/>(names: [])"]
       ACT --> PUBLISH["publish: dict"]
       ACT --> SAFETY["safety_behavior: str<br/>('hold' | 'zeros')"]
       
       PUBLISH --> TOPIC["topic: str"]
       PUBLISH --> TYPE["type: str"]
       PUBLISH --> LAYOUT["layout: str<br/>('flat')"]
       PUBLISH --> QOS_PUB["qos: dict"]
       PUBLISH --> STRATEGY["strategy: dict<br/>(mode, tolerance_ms)"]

**图表**：动作规范模式，显示发布配置。

**来源**：`src/robot_config/robot_config/loader.py:127-136 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/loader.py#L127-L136>`__，
`src/robot_config/robot_config/config.py:1-200 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/config.py#L1-L200>`__

动作示例
~~~~~~~~

动作可以在使用相同张量键的同时拆分到多个 ROS 主题。这允许单个 ``action`` 张量路由到不同的控制器：

.. code:: yaml

   actions:
     # 手臂关节 (1-5) - 使用键 "action"
     - key: action
       selector:
         names:
           - "action.0"
           - "action.1"
           - "action.2"
           - "action.3"
           - "action.4"
       publish:
         topic: /arm_position_controller/commands
         type: std_msgs/msg/Float64MultiArray
         layout: flat
         qos:
           reliability: best_effort
           history: keep_last
           depth: 10
         strategy:
           mode: nearest
           tolerance_ms: 500
       safety_behavior: hold

     # 夹爪关节 (6) - 也使用键 "action"
     - key: action
       selector:
         names:
           - "action.5"
       publish:
         topic: /gripper_position_controller/commands
         type: std_msgs/msg/Float64MultiArray
         # ... 其余配置

此处的 ``selector.names`` 使用 **张量索引表示法**：``action.0`` 指动作张量的索引 0。在推理期间，``tensormsg`` 根据这些选择器拆分张量，并将每个切片路由到适当的主题。

**来源**：
`src/robot_config/config/robots/so101_single_arm.yaml:262-301 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L262-L301>`__

--------------

对齐策略
--------

观测中的 ``align`` 部分定义如何将不同时间戳的消息同步到契约的目标 ``rate_hz``。

可用策略
~~~~~~~~


.. list-table::
   :header-rows: 1

   * - 策略
     - 行为
     - 用例
   * - ``hold``
     - 如果没有新消息则保持 最后一个值
     - 大多数传感器的 默认策略
   * - ``drop``
     - 如果在容忍度内没有 消息则跳过
     - 严格的同步要求
   * - ``interpolate``
     - 在消息之间线性插值
     - 平滑状态估计

对齐配置
~~~~~~~~

.. code:: yaml

   align:
     strategy: hold
     stamp: header  # 从哪里读取时间戳 (header.stamp)
     tol_ms: 1500   # 容忍度（毫秒）

``stamp`` 字段使用点分路径表示法定位消息中的时间戳。对于大多数传感器消息，这是 ``header.stamp``。``tol_ms`` 定义消息在对齐策略生效前可以有多旧。

**来源**：
`src/robot_config/config/robots/so101_single_arm.yaml:225-228 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L225-L228>`__

--------------

外设集成
--------

外设（相机、传感器）在 ``robot.peripherals`` 部分单独定义，观测通过名称引用它们。这实现了 **元数据传播**，观测规范自动继承相机参数。

外设到观测的链接
~~~~~~~~~~~~~~~~

.. mermaid::

   graph TB
       subgraph "外设定义"
           CAM_DEF["peripherals:<br/>- name: top<br/>  driver: opencv<br/>  width: 640<br/>  height: 480<br/>  fps: 30"]
       end
       
       subgraph "观测定义"
           OBS_DEF["observations:<br/>- key: observation.images.top<br/>  topic: /camera/top/image_raw<br/>  peripheral: top"]
       end
       
       subgraph "运行时解析"
           LOADER["load_contract_config()"]
           INJECT["元数据注入:<br/>- native_width: 640<br/>- native_height: 480<br/>- native_fps: 30<br/>- frame_id: camera_top_frame"]
       end
       
       CAM_DEF --> LOADER
       OBS_DEF --> LOADER
       LOADER --> INJECT
       
       INJECT -.->|"被使用"| BAG2LR["bag_to_lerobot<br/>(解码 + 调整大小)"]
       INJECT -.->|"被使用"| POLICY["lerobot_policy_node<br/>(缓冲区大小调整)"]

**图表**：契约加载时的外设元数据传播到观测。

这种设计消除了冗余：您在外设中定义一次相机分辨率，它会自动传播到所有引用它的观测。

**来源**：
`src/robot_config/config/robots/so101_single_arm.yaml:130-152 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L130-L152>`__，
`src/robot_config/config/robots/so101_single_arm.yaml:219-232 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L219-L232>`__

--------------

契约在数据流水线中的传播
------------------------

相同的契约定义驱动数据流水线的所有三个阶段，确保相同的处理逻辑。

.. mermaid::

   graph TB
       subgraph "阶段 1: 数据录制"
           YAML1["robot_config YAML<br/>契约定义"]
           REC["episode_recorder"]
           
           YAML1 -->|"加载契约"| REC
           REC -->|"订阅<br/>观测主题"| BAG["MCAP bag 文件<br/>+ 嵌入元数据"]
       end
       
       subgraph "阶段 2: 数据集转换"
           YAML2["robot_config YAML<br/>相同契约"]
           B2L["bag_to_lerobot"]
           
           YAML2 -->|"加载契约"| B2L
           BAG -->|"读取消息"| B2L
           
           B2L -->|"通过 selector.names 解码<br/>通过 image.resize 调整大小<br/>以 rate_hz 重采样"| LRDS["LeRobot v3 数据集<br/>(parquet + videos)"]
       end
       
       subgraph "阶段 3: 实时推理"
           YAML3["robot_config YAML<br/>相同契约"]
           POL["lerobot_policy_node"]
           
           YAML3 -->|"加载契约"| POL
           POL -->|"按 model.input_features 过滤<br/>创建 StreamBuffer<br/>相同解码逻辑"| TENSOR["观测批次<br/>(对齐的张量)"]
       end
       
       LRDS -.->|"训练数据"| MODEL["策略模型"]
       MODEL -.->|"部署到"| POL
       
       style YAML1 fill:#fff3e0,stroke:#ff9800,stroke-width:2px
       style YAML2 fill:#fff3e0,stroke:#ff9800,stroke-width:2px
       style YAML3 fill:#fff3e0,stroke:#ff9800,stroke-width:2px

**图表**：契约驱动的录制、训练和部署阶段一致性保证。

契约消费的代码实体
~~~~~~~~~~~~~~~~~~


.. list-table::
   :header-rows: 1

   * - 消费者
     - 入口点
     - 关键操作
   * - ``episode_recorder``
     - 为每个 ``observation.topic`` 创建 ROS 订阅
     - 消息缓冲、回合录制
   * - ``bag_to_lerobot``
     - `src/dataset_tools/dataset_tools/bag_to_lerobot.py:1-500 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/dataset_tools/bag_to_lerobot.py#L1-L500>`__
     - ``TensorMsgConverter.decode()``， 以 ``rate_hz`` 重采样
   * - ``lerobot_policy_node``
     - 创建 ``StreamBuffer`` 实例
     - 相同解码、按需对齐

**来源**：
`src/robot_config/config/robots/so101_single_arm.yaml:198-301 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L198-L301>`__，
`src/tensormsg/tensormsg/converter.py:1-262 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/tensormsg/tensormsg/converter.py#L1-L262>`__

--------------

QoS 配置
--------

服务质量（QoS）设置控制每个观测和动作的 ROS 2 通信可靠性和缓冲行为。

QoS 模式
~~~~~~~~

.. code:: yaml

   qos:
     reliability: best_effort  # 或 'reliable'
     history: keep_last        # 或 'keep_all'
     depth: 10                 # 缓冲区大小

常见 QoS 模式
~~~~~~~~~~~~


.. list-table::
   :header-rows: 1

   * - 用例
     - 可靠性
     - 历史
     - 深度
     - 理由
   * - 相机图像
     - ``best_effort``
     - ``keep_last``
     - 10
     - 优先获取新鲜 图像而非保证 传递
   * - 关节状态
     - ``best_effort``
     - ``keep_last``
     - 50
     - 高频状态更新
   * - 动作命令
     - ``best_effort``
     - ``keep_last``
     - 10
     - 控制循环优先 最近命令
   * - 目标姿态
     - ``reliable``
     - ``keep_all``
     - 5
     - 关键命令 不能丢失

**来源**：
`src/robot_config/config/robots/so101_single_arm.yaml:214-217 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L214-L217>`__，
`src/robot_config/config/robots/so101_single_arm.yaml:256-260 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L256-L260>`__

--------------

选择器语法参考
--------------

``selector.names`` 字段使用 **点分路径表示法** 从 ROS 消息和张量中提取数据。

用于 ROS 消息（观测）
~~~~~~~~~~~~~~~~~~~~

格式：``field.subfield[.arrayKey]``

**示例**：

.. code:: yaml

   # 从 JointState 提取名为 "1" 的关节位置
   names: ["position.1"]  # 等价于 msg.position[msg.name.index("1")]

   # 从 Twist 提取 linear.x
   names: ["linear.x"]    # 等价于 msg.linear.x

   # 提取嵌套字段
   names: ["pose.position.x", "pose.position.y"]

**实现**：`src/tensormsg/tensormsg/utils.py:1-100 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/tensormsg/tensormsg/utils.py#L1-L100>`__
(``dot_get()`` 函数)

用于张量（动作）
~~~~~~~~~~~~~~~~

格式：``key.index``

**示例**：

.. code:: yaml

   # 从动作张量提取索引 0-4
   names: ["action.0", "action.1", "action.2", "action.3", "action.4"]

   # 等价 Python: action_tensor[0:5]

**实现**：`src/tensormsg/tensormsg/converter.py:75-84 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/tensormsg/tensormsg/converter.py#L75-L84>`__
(``_encode_via_dotted_paths()``)

**来源**：`src/tensormsg/tensormsg/converter.py:86-93 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/tensormsg/tensormsg/converter.py#L86-L93>`__，
`src/robot_config/config/robots/so101_single_arm.yaml:252-253 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L252-L253>`__

--------------

示例：完整契约定义
------------------

以下是来自 ``so101_single_arm.yaml`` 的完整契约定义，展示观测、动作和外设集成：

.. code:: yaml

   contract:
     base_contract: $(find robot_config)/config/contracts/act_grab_pan.yaml
     rate_hz: 20
     max_duration_s: 90.0

     observations:
       # 带外设引用的相机观测
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
         qos:
           reliability: best_effort
           history: keep_last
           depth: 10

       # 带选择器的关节状态观测
       - key: observation.state
         topic: /joint_states
         type: sensor_msgs/msg/JointState
         selector:
           names: ["position.1", "position.2", "position.3", 
                   "position.4", "position.5", "position.6"]
         align:
           strategy: hold
           stamp: header
           tol_ms: 1500
         qos:
           reliability: best_effort
           history: keep_last
           depth: 50

     actions:
       # 手臂关节动作
       - key: action
         selector:
           names: ["action.0", "action.1", "action.2", 
                   "action.3", "action.4"]
         publish:
           topic: /arm_position_controller/commands
           type: std_msgs/msg/Float64MultiArray
           layout: flat
           qos:
             reliability: best_effort
             history: keep_last
             depth: 10
           strategy:
             mode: nearest
             tolerance_ms: 500
         safety_behavior: hold

**来源**：
`src/robot_config/config/robots/so101_single_arm.yaml:198-301 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L198-L301>`__

--------------

总结
----

契约系统提供：

1. **单一数据源**：一个 YAML 定义用于录制、训练和推理
2. **类型安全**：显式的 ROS 消息类型和张量形状防止运行时错误
3. **元数据传播**：外设定义自动注入相机/传感器参数
4. **时间对齐**：可配置的多模态数据同步策略
5. **灵活路由**：选择器语法实现精确的数据提取和动作分发

这种设计通过确保相同的契约管理离线数据集创建和在线策略执行，消除了常见的 ML 部署问题——训练-服务偏差。

**来源**：`README.md:1-192 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L1-L192>`__，
`docs/architecture.md:187-215 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/docs/architecture.md#L187-L215>`__，
`src/robot_config/config/robots/so101_single_arm.yaml:198-301 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L198-L301>`__

--------------

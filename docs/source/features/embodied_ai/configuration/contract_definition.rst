契约定义
========

.. raw:: html

   <details>

相关源文件

以下文件用于生成此文档页面：

-  `src/robot_config/README.en.md <src/robot_config/README.en.md>`__
-  `src/robot_config/README.md <src/robot_config/README.md>`__
-  `src/robot_config/config/contracts/pi05_multi_tasks.yaml <src/robot_config/config/contracts/pi05_multi_tasks.yaml>`__
-  `src/robot_config/config/robots/so101_dual_arm.yaml <src/robot_config/config/robots/so101_dual_arm.yaml>`__
-  `src/robot_config/config/robots/so101_single_arm.yaml <src/robot_config/config/robots/so101_single_arm.yaml>`__
-  `src/robot_config/robot_config/loader.py <src/robot_config/robot_config/loader.py>`__
-  `src/tensormsg/tensormsg/converter.py <src/tensormsg/tensormsg/converter.py>`__

.. raw:: html

   </details>

本文档介绍 robot_config YAML 文件中的 **契约（Contract）** 部分，该部分作为单一数据源，定义 ROS 主题如何映射到 ML 模型输入（观测）和输出（动作）。契约确保数据收集、数据集转换和推理部署之间的一致性。

有关更广泛的 robot_config YAML 结构信息，请参阅 `机器人配置文件 <#5.1>`__。有关契约引用的相机和传感器外设定义，请参阅 `外设配置 <#5.3>`__。

--------------

概述
----

契约是一个声明式规范，定义：

1. **观测**：哪些 ROS 主题为 ML 模型提供输入（例如相机图像、关节状态）
2. **动作**：哪些 ROS 主题接收 ML 模型的输出（例如关节位置命令）
3. **录制参数**：数据收集的采样率和回合时长
4. **对齐策略**：如何时间同步多模态传感器数据
5. **QoS 策略**：用于可靠数据传输的 ROS2 服务质量设置

契约被三个关键系统组件使用：

- **episode_recorder**：在数据收集期间为所有观测主题创建订阅
- **bag_to_lerobot**：使用契约规范将 ROS2 bag 消息解码为 LeRobot 数据集格式
- **lerobot_policy_node**：为实时推理创建订阅和消息解码器

来源：
`src/robot_config/config/robots/so101_single_arm.yaml:198-302 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L198-L302>`__，
`src/robot_config/robot_config/loader.py:94-144 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/loader.py#L94-L144>`__

--------------

契约结构
--------

契约部分出现在 robot_config YAML 文件中：

.. code:: yaml

   robot:
     contract:
       base_contract: $(find robot_config)/config/contracts/act_grab_pan.yaml  # 可选
       rate_hz: 20                    # 录制/推理频率（整数）
       max_duration_s: 90.0           # 最大回合时长
       
       observations:
         - key: observation.images.top
           topic: /camera/top/image_raw
           type: sensor_msgs/msg/Image
           # ... (观测特定字段)
         
         - key: observation.state
           topic: /joint_states
           type: sensor_msgs/msg/JointState
           # ... (观测特定字段)
       
       actions:
         - key: action
           selector:
             names: ["action.0", "action.1", ...]
           publish:
             topic: /arm_position_controller/commands
             type: std_msgs/msg/Float64MultiArray
           # ... (动作特定字段)

基础契约继承
~~~~~~~~~~~~

``base_contract`` 字段允许机器人特定配置扩展共享契约模板：


.. list-table::
   :header-rows: 1

   * - 字段
     - 类型
     - 描述
   * - ``base_contract``
     - string
     - 基础契约 YAML 的路径 (可选，使用 ``$(find ...)`` 语法)
   * - ``rate_hz``
     - integer
     - 录制/推理频率（Hz）
   * - ``max_duration_s``
     - float
     - 最大回合时长（秒）

机器人特定的观测和动作与基础契约合并，实现跨多个机器人的配置复用。

来源：
`src/robot_config/config/robots/so101_single_arm.yaml:199-201 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L199-L201>`__，
`src/robot_config/config/contracts/pi05_multi_tasks.yaml:1-10 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/contracts/pi05_multi_tasks.yaml#L1-L10>`__

--------------

观测规范
--------

每个观测定义如何将 ROS 主题解码为 ML 模型输入的张量。

.. mermaid::

   graph TB
       subgraph "观测定义"
           KEY["key: observation.images.top"]
           TOPIC["topic: /camera/top/image_raw"]
           TYPE["type: sensor_msgs/msg/Image"]
           PERIPH["peripheral: top"]
           IMG["image:<br/>resize: [480, 640]"]
           ALIGN["align:<br/>strategy: hold<br/>stamp: header<br/>tol_ms: 1500"]
           QOS["qos:<br/>reliability: best_effort<br/>history: keep_last<br/>depth: 10"]
       end
       
       subgraph "处理流水线"
           SUB[创建 ROS 订阅]
           BUFFER[StreamBuffer]
           DECODE[TensorMsgConverter.decode]
           RESIZE[图像调整大小]
           SYNC[时间对齐]
           TENSOR[输出张量]
       end
       
       TOPIC --> SUB
       QOS --> SUB
       SUB --> BUFFER
       ALIGN --> SYNC
       BUFFER --> SYNC
       SYNC --> DECODE
       TYPE --> DECODE
       IMG --> RESIZE
       DECODE --> RESIZE
       RESIZE --> TENSOR
       PERIPH -.->|元数据| DECODE
       
       style KEY fill:#f9f9f9
       style TENSOR fill:#f9f9f9

**观测处理流程**：观测定义控制 ROS 订阅创建、时间对齐、消息解码和图像预处理。

来源：
`src/robot_config/config/robots/so101_single_arm.yaml:203-260 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L203-L260>`__

--------------

观测字段参考
~~~~~~~~~~~~


.. list-table::
   :header-rows: 1

   * - 字段
     - 类型
     - 必需
     - 描述
   * - ``key``
     - string
     - 是
     - 使用点表示法的层次标识符 (例如 ``observation.images.top``)
   * - ``topic``
     - string
     - 是
     - 要订阅的 ROS2 主题
   * - ``type``
     - string
     - 是
     - 完整 ROS 消息类型 (例如 ``sensor_msgs/msg/Image``)
   * - ``peripheral``
     - string
     - 否
     - 引用外设定义 (自动填充分辨率、FPS 等 元数据)
   * - ``selector``
     - dict
     - 否
     - 从消息中提取特定字段 (见下方选择器语法)
   * - ``image``
     - dict
     - 否
     - 图像特定处理 (见下方图像处理)
   * - ``align``
     - dict
     - 否
     - 时间对齐策略 (见下方对齐策略)
   * - ``qos``
     - dict
     - 否
     - ROS2 服务质量设置 (见下方 QoS 配置)

来源：`src/robot_config/robot_config/loader.py:112-124 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/loader.py#L112-L124>`__

--------------

键命名约定
~~~~~~~~~~

观测键使用层次化点表示法，直接映射到 LeRobot 数据集结构：


.. list-table::
   :header-rows: 1

   * - 键模式
     - 描述
     - 数据集列
   * - ``observation.images.{name}``
     - 相机图像观测
     - ``observation.images.{name}``
   * - ``observation.state``
     - 机器人关节状态
     - ``observation.state``
   * - ``observation.environment.{sensor}``
     - 环境传感器
     - ``observation.environment.{sensor}``
   * - ``task.{field}``
     - 任务特定元数据
     - ``task.{field}``

键决定 LeRobot 数据集中的特征名称，在推理时必须与模型期望的输入特征匹配。

来源：
`src/robot_config/config/robots/so101_single_arm.yaml:204-250 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L204-L250>`__

--------------

外设引用
~~~~~~~~

``peripheral`` 字段将观测链接到外设定义（通常是相机），自动继承元数据：

.. code:: yaml

   # 在 peripherals 部分：
   peripherals:
     - type: camera
       name: top
       driver: opencv
       width: 640
       height: 480
       fps: 30

   # 在契约观测中：
   observations:
     - key: observation.images.top
       topic: /camera/top/image_raw
       peripheral: top  # 自动填充 width, height, fps 元数据

这确保契约可以访问相机分辨率和帧率，而无需重复配置。

来源：
`src/robot_config/config/robots/so101_single_arm.yaml:132-152 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L132-L152>`__，
`src/robot_config/config/robots/so101_single_arm.yaml:219-232 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L219-L232>`__

--------------

选择器语法
~~~~~~~~~~

``selector`` 字段使用点表示法从 ROS 消息中提取特定值：

.. code:: yaml

   - key: observation.state
     topic: /joint_states
     type: sensor_msgs/msg/JointState
     selector:
       names:
         - "position.1"      # 提取 position[0] 并重命名为 "1"
         - "position.2"      # 提取 position[1] 并重命名为 "2"
         - "position.3"      # 提取 position[2] 并重命名为 "3"
         - "position.4"
         - "position.5"
         - "position.6"

**选择器处理**：

1. ``names`` 列表指定 ROS 消息结构中的点分路径
2. 每个路径使用 ``dot_get(msg, path)`` 解析（例如 ``msg.position[1]``）
3. 值按指定顺序连接成 1D numpy 数组
4. 解码器 ``_decode_via_names(msg, names)`` 处理提取

来源：
`src/robot_config/config/robots/so101_single_arm.yaml:249-260 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L249-L260>`__，
`src/tensormsg/tensormsg/converter.py:86-93 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/tensormsg/tensormsg/converter.py#L86-L93>`__

--------------

图像处理
~~~~~~~~

``image`` 字段控制相机观测的图像预处理：

.. code:: yaml

   - key: observation.images.wrist
     topic: /camera/wrist/image_raw
     type: sensor_msgs/msg/Image
     image:
       resize: [480, 640]  # [高度, 宽度]，LeRobot 约定

**图像解码流水线**
(`src/tensormsg/tensormsg/converter.py:172-232 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/tensormsg/tensormsg/converter.py#L172-L232>`__)：

.. mermaid::

   graph LR
       RAW["ROS 图像消息<br/>(sensor_msgs/msg/Image)"]
       DECODE["解码编码<br/>(bgr8, rgb8, mono8, 32fc1 等)"]
       BGR2RGB["BGR → RGB 转换<br/>(如需要)"]
       RESIZE["最近邻调整大小<br/>(如指定 resize)"]
       NORM["归一化到 [0, 1]<br/>(uint8 → float32)"]
       OUTPUT["输出: np.ndarray<br/>shape: [H, W, 3]<br/>dtype: float32"]
       
       RAW --> DECODE
       DECODE --> BGR2RGB
       BGR2RGB --> RESIZE
       RESIZE --> NORM
       NORM --> OUTPUT

**图像解码处理流水线**：图像从 ROS 编码解码，转换为 RGB，可选调整大小，并归一化。

**支持的编码**：

| 编码 | 描述 | 处理 |
|———-|————-|————|
| ``rgb8``, ``bgr8`` | 8 位彩色 | 转换为 RGB，归一化到 [0, 1] |
| ``rgba8``, ``bgra8`` | 8 位彩色 + 透明通道 | 丢弃透明通道，转换为 RGB |
| ``mono8``, ``8uc1`` | 8 位灰度 | 重复到 3 通道 |
| ``32fc1``, ``32fc`` | 32 位浮点深度 | 裁剪到 [0, 50m]，归一化到 [0, 1]，重复到 3 通道 |
| ``16uc1``, ``mono16`` | 16 位深度 | 转换为米，裁剪到 [0, 10m]，归一化 |

来源：
`src/robot_config/config/robots/so101_single_arm.yaml:208-210 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L208-L210>`__，
`src/tensormsg/tensormsg/converter.py:172-232 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/tensormsg/tensormsg/converter.py#L172-L232>`__

--------------

对齐策略
~~~~~~~~

``align`` 字段控制多模态传感器数据的时间同步：

.. code:: yaml

   - key: observation.images.top
     topic: /camera/top/image_raw
     align:
       strategy: hold       # 'hold' | 'interpolate' | 'nearest'
       stamp: header        # 'header' | 'arrival' - 使用消息 header.stamp 或到达时间
       tol_ms: 1500         # 认为数据有效的容忍度（毫秒）

**对齐策略**：


.. list-table::
   :header-rows: 1

   * - 策略
     - 行为
     - 用例
   * - ``hold``
     - 保持最后接收的值 直到新消息到达
     - 图像和离散传感器的 默认策略
   * - ``interpolate``
     - 在消息之间线性插值
     - 连续传感器值 (IMU、力传感器)
   * - ``nearest``
     - 选择时间戳最接近目标 的消息
     - 低延迟要求

**时间戳来源**：

- ``stamp: header``：使用 ROS 消息中的 ``msg.header.stamp``
- ``stamp: arrival``：使用消息被接收时 ROS 节点的墙上时钟

**容忍度**：``tol_ms`` 字段定义消息被认为有效的最大年龄（毫秒）。如果在此窗口内没有收到消息，系统可能会触发警告或使用回退行为。

来源：
`src/robot_config/config/robots/so101_single_arm.yaml:210-213 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L210-L213>`__

--------------

QoS 配置
~~~~~~~~

``qos`` 字段指定订阅的 ROS2 服务质量策略：

.. code:: yaml

   observations:
     - key: observation.images.top
       topic: /camera/top/image_raw
       qos:
         reliability: best_effort  # 'best_effort' | 'reliable'
         history: keep_last        # 'keep_last' | 'keep_all'
         depth: 10                 # 队列深度

**QoS 字段参考**：


.. list-table::
   :header-rows: 1

   * - 字段
     - 值
     - 描述
   * - ``reliability``
     - ``best_effort``, ``reliable``
     - ``best_effort`` 用于高频传感器 (相机)，``reliable`` 用于关键 命令
   * - ``history``
     - ``keep_last``, ``keep_all``
     - ``keep_last`` 维护固定大小队列， ``keep_all`` 保留完整历史
   * - ``depth``
     - integer
     - ``keep_last`` 策略的队列大小

**常见 QoS 配置**：

- **相机图像**：``{reliability: best_effort, history: keep_last, depth: 10}`` - 如果处理落后则丢弃旧帧
- **关节状态**：``{reliability: best_effort, history: keep_last, depth: 50}`` - 高频状态更新使用更大队列
- **命令**：``{reliability: reliable, history: keep_last, depth: 10}`` - 关键动作保证传递

来源：
`src/robot_config/config/robots/so101_single_arm.yaml:214-217 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L214-L217>`__

--------------

动作规范
--------

每个动作定义如何将 ML 模型输出编码为 ROS 消息并发布：

.. mermaid::

   graph TB
       subgraph "动作定义"
           KEY["key: action"]
           SEL["selector:<br/>names: [action.0, action.1, ...]"]
           PUB["publish:<br/>topic: /arm_position_controller/commands<br/>type: std_msgs/msg/Float64MultiArray<br/>layout: flat"]
           QOS_A["qos:<br/>reliability: best_effort<br/>depth: 10"]
           STRAT["strategy:<br/>mode: nearest<br/>tolerance_ms: 500"]
           SAFE["safety_behavior: hold"]
       end
       
       subgraph "编码流水线"
           TENSOR_IN["输入张量<br/>[100, 6] 动作块"]
           SLICE["按索引切片<br/>[action.0 到 action.4]"]
           ENCODE["TensorMsgConverter.encode"]
           MSG_OUT["ROS 消息<br/>Float64MultiArray"]
           PUB_OUT["发布到主题"]
       end
       
       TENSOR_IN --> SLICE
       SEL --> SLICE
       SLICE --> ENCODE
       KEY --> ENCODE
       PUB --> ENCODE
       ENCODE --> MSG_OUT
       MSG_OUT --> PUB_OUT
       QOS_A --> PUB_OUT
       STRAT -.->|"action_dispatcher_node"| PUB_OUT
       SAFE -.->|"回退行为"| PUB_OUT
       
       style TENSOR_IN fill:#f9f9f9
       style PUB_OUT fill:#f9f9f9

**动作编码流程**：模型输出张量由选择器切片，编码为 ROS 消息，并使用 QoS/策略设置发布。

来源：
`src/robot_config/config/robots/so101_single_arm.yaml:262-301 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L262-L301>`__

--------------

动作字段参考
~~~~~~~~~~~~


.. list-table::
   :header-rows: 1

   * - 字段
     - 类型
     - 必需
     - 描述
   * - ``key``
     - string
     - 是
     - 层次标识符 (通常为 ``action`` 用于合并动作)
   * - ``selector``
     - dict
     - 是
     - 将张量索引映射到消息字段 (见下方动作选择器)
   * - ``publish``
     - dict
     - 是
     - 发布配置 (主题、类型、布局)
   * - ``safety_behavior``
     - string
     - 否
     - 推理停止时的回退行为： ``hold`` (保持最后命令) 或 ``zeros`` (零命令)

来源：`src/robot_config/robot_config/loader.py:126-136 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/loader.py#L126-L136>`__

--------------

动作选择器
~~~~~~~~~~

``selector.names`` 字段将模型输出张量索引映射到 ROS 消息字段名称：

.. code:: yaml

   actions:
     # 手臂关节（动作张量中的索引 0-4）
     - key: action
       selector:
         names:
           - "action.0"  # 将 tensor[..., 0] 映射到关节 "1"
           - "action.1"  # 将 tensor[..., 1] 映射到关节 "2"
           - "action.2"  # 将 tensor[..., 2] 映射到关节 "3"
           - "action.3"
           - "action.4"
       publish:
         topic: /arm_position_controller/commands
         type: std_msgs/msg/Float64MultiArray

**选择器处理**：

1. ``names`` 列表指定要提取的张量索引
2. 对于 ``action.0``、``action.1`` 等，整数后缀是张量索引
3. 编码器在这些索引处切片张量并编码为 ROS 消息
4. 对于 ``sensor_msgs/msg/JointState``，名称成为 ``joint_name`` 字段

**动作合并**：具有相同 ``key`` 的多个动作定义会自动合并，允许分离控制（例如，共享一个动作张量的独立手臂和夹爪主题）。

来源：
`src/robot_config/config/robots/so101_single_arm.yaml:264-279 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L264-L279>`__，
`src/robot_config/config/robots/so101_single_arm.yaml:285-301 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L285-L301>`__

--------------

发布配置
~~~~~~~~

``publish`` 字段控制动作如何发布到 ROS 主题：

.. code:: yaml

   actions:
     - key: action
       selector:
         names: ["action.0", "action.1", "action.2", "action.3", "action.4"]
       publish:
         topic: /arm_position_controller/commands
         type: std_msgs/msg/Float64MultiArray
         layout: flat
         qos:
           reliability: best_effort
           history: keep_last
           depth: 10
         strategy:
           mode: nearest           # 'fifo' | 'nearest'
           tolerance_ms: 500       # 时间戳容忍度

**发布字段参考**：


.. list-table::
   :header-rows: 1

   * - 字段
     - 类型
     - 描述
   * - ``topic``
     - string
     - 发布动作的 ROS2 主题
   * - ``type``
     - string
     - 完整 ROS 消息类型 (例如 ``std_msgs/msg/Float64MultiArray``)
   * - ``layout``
     - string
     - ``flat`` (1D 数组) 或 ``nested`` (结构化消息)
   * - ``qos``
     - dict
     - ROS2 QoS 策略（与观测相同）
   * - ``strategy.mode``
     - string
     - ``fifo`` (先进先出) 或 ``nearest`` (基于时间戳选择)
   * - ``strategy.tolerance_ms``
     - integer
     - ``nearest`` 模式的最大时间戳差异

**策略模式**：

- ``fifo``：动作按到达顺序发布（基于队列）
- ``nearest``：选择时间戳最接近当前时间的动作（由 ``action_dispatcher_node`` 使用）

来源：
`src/robot_config/config/robots/so101_single_arm.yaml:272-283 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L272-L283>`__

--------------

安全行为
~~~~~~~~

``safety_behavior`` 字段定义推理停止或遇到错误时的回退行为：


.. list-table::
   :header-rows: 1

   * - 值
     - 行为
     - 用例
   * - ``hold``
     - 继续发布最后一个有效动作
     - 位置控制安全 (保持最后姿态)
   * - ``zeros``
     - 发布全零
     - 速度控制安全 (使机器人停止)

**安全行为实践**：

.. code:: yaml

   actions:
     - key: action
       selector:
         names: ["action.0", "action.1", "action.2", "action.3", "action.4"]
       publish:
         topic: /arm_position_controller/commands
         type: std_msgs/msg/Float64MultiArray
       safety_behavior: hold  # 如果推理失败则保持最后位置

此字段由 ``action_dispatcher_node`` 使用以确定紧急回退行为。

来源：`src/robot_config/config/robots/so101_single_arm.yaml:283 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L283>`__

--------------

契约在系统中的传播
------------------

下图说明单个契约定义如何在数据生命周期中传播：

.. mermaid::

   graph TB
       subgraph "契约定义 (robot_config YAML)"
           CONTRACT["contract:<br/>  rate_hz: 20<br/>  observations: [...]<br/>  actions: [...]"]
       end
       
       subgraph "消费者 1: episode_recorder"
           REC_LOAD["通过 robot_config<br/>加载契约"]
           REC_SUB["为每个 observation.topic<br/>创建订阅"]
           REC_META["将契约嵌入<br/>bag 元数据"]
           
           REC_LOAD --> REC_SUB
           REC_SUB --> REC_META
       end
       
       subgraph "消费者 2: bag_to_lerobot"
           B2L_LOAD["从 bag 元数据<br/>加载契约"]
           B2L_DECODE["使用 observation.type<br/>解码消息"]
           B2L_RESIZE["应用 image.resize<br/>图像调整大小"]
           B2L_RESAMPLE["以 rate_hz 重采样"]
           
           B2L_LOAD --> B2L_DECODE
           B2L_DECODE --> B2L_RESIZE
           B2L_RESIZE --> B2L_RESAMPLE
       end
       
       subgraph "消费者 3: lerobot_policy_node"
           INF_LOAD["通过 robot_config<br/>加载契约"]
           INF_FILTER["按 model 的<br/>input_features 过滤"]
           INF_SUB["为过滤后的观测<br/>创建订阅"]
           INF_CONV["使用观测规范<br/>TensorMsgConverter.decode"]
           
           INF_LOAD --> INF_FILTER
           INF_FILTER --> INF_SUB
           INF_SUB --> INF_CONV
       end
       
       CONTRACT --> REC_LOAD
       CONTRACT --> INF_LOAD
       REC_META -.->|"嵌入 bag"| B2L_LOAD
       
       B2L_RESAMPLE -->|"LeRobot 数据集"| TRAIN["lerobot 训练"]
       TRAIN -->|"策略模型"| INF_LOAD
       
       INF_CONV -->|"观测张量"| POLICY["策略推理"]
       POLICY -->|"动作张量"| ENC["使用 action.publish<br/>TensorMsgConverter.encode"]
       
       style CONTRACT fill:#f9f9f9
       style TRAIN fill:#f9f9f9
       style POLICY fill:#f9f9f9

**契约传播生命周期**：契约确保训练数据和部署观测经过相同的处理。

**一致性保证**：

1. **录制**：``episode_recorder`` 订阅所有 ``observation.topic`` 字段并将契约嵌入 bag 元数据
2. **转换**：``bag_to_lerobot`` 加载嵌入的契约，使用相同的 ``observation.type``、``image.resize`` 和对齐设置解码消息
3. **推理**：``lerobot_policy_node`` 加载相同的契约，按模型的 ``input_features`` 过滤，使用相同的解码逻辑
4. **结果**：训练数据和推理观测具有相同的张量形状和预处理

来源：
`src/robot_config/config/robots/so101_single_arm.yaml:198-302 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L198-L302>`__

--------------

完整契约示例
------------

以下是单臂三相机机器人的完整带注释契约定义：

.. code:: yaml

   robot:
     contract:
       # 基础契约继承（可选）
       base_contract: $(find robot_config)/config/contracts/act_grab_pan.yaml
       
       # 录制/推理参数
       rate_hz: 20              # 20 Hz 采样率
       max_duration_s: 90.0     # 90 秒最大回合长度
       
       # 观测：定义所有模型输入
       observations:
         # 前置相机观测
         - key: observation.images.front
           topic: /camera/front/image_raw
           type: sensor_msgs/msg/Image
           peripheral: front              # 引用外设定义
           image:
             resize: [480, 640]           # 调整大小到 480x640 (H x W)
           align:
             strategy: hold               # 保持最后一帧直到新帧到达
             stamp: header                # 使用消息头时间戳
             tol_ms: 1500                 # 1.5 秒容忍度
           qos:
             reliability: best_effort     # 如果落后则丢弃旧帧
             history: keep_last
             depth: 10
         
         # 顶部相机观测
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
         
         # 腕部相机观测
         - key: observation.images.wrist
           topic: /camera/wrist/image_raw
           type: sensor_msgs/msg/Image
           peripheral: wrist
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
         
         # 关节状态观测
         - key: observation.state
           topic: /joint_states
           type: sensor_msgs/msg/JointState
           selector:
             names:
               - "position.1"     # 肩部旋转
               - "position.2"     # 肩部升降
               - "position.3"     # 肘部弯曲
               - "position.4"     # 腕部弯曲
               - "position.5"     # 腕部旋转
               - "position.6"     # 夹爪
           align:
             strategy: hold
             stamp: header
             tol_ms: 1500
           qos:
             reliability: best_effort
             history: keep_last
             depth: 50            # 高频状态使用更大队列
       
       # 动作：定义所有模型输出
       actions:
         # 手臂关节 (5 DOF) - 第一个动作定义
         - key: action
           selector:
             names:
               - "action.0"       # 映射到关节 "1"
               - "action.1"       # 映射到关节 "2"
               - "action.2"       # 映射到关节 "3"
               - "action.3"       # 映射到关节 "4"
               - "action.4"       # 映射到关节 "5"
           publish:
             topic: /arm_position_controller/commands
             type: std_msgs/msg/Float64MultiArray
             layout: flat
             qos:
               reliability: best_effort
               history: keep_last
               depth: 10
             strategy:
               mode: nearest              # 选择最接近当前时间的动作
               tolerance_ms: 500
           safety_behavior: hold          # 失败时保持最后位置
         
         # 夹爪关节 (1 DOF) - 使用相同 key 的第二个动作定义
         - key: action
           selector:
             names:
               - "action.5"       # 映射到关节 "6" (夹爪)
           publish:
             topic: /gripper_position_controller/commands
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

**关键设计模式**：

1. **外设引用**：观测引用 ``peripheral: top/wrist/front`` 继承相机元数据
2. **统一键**：手臂和夹爪动作都使用 ``key: action``，将 6 DOF 合并到一个张量
3. **选择器索引**：``action.0`` 到 ``action.5`` 将张量索引映射到物理关节
4. **QoS 调优**：图像使用 ``depth: 10``，关节状态使用 ``depth: 50`` 以适应更高频率
5. **安全**：``safety_behavior: hold`` 在推理失败时保持最后位置

来源：
`src/robot_config/config/robots/so101_single_arm.yaml:198-302 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L198-L302>`__

--------------

契约加载与验证
--------------

契约通过 ``load_contract_config()`` 加载，并在机器人初始化期间验证：

**契约加载**
(`src/robot_config/robot_config/loader.py:94-144 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/loader.py#L94-L144>`__)：

.. code:: python

   def load_contract_config(data: Dict[str, Any]) -> ContractExtensionConfig:
       """从字典加载契约扩展配置。"""
       observations = []
       for obs_data in data.get("observations", []):
           observations.append(
               ContractObservation(
                   key=obs_data["key"],
                   topic=obs_data.get("topic"),
                   peripheral=obs_data.get("peripheral"),
                   selector=obs_data.get("selector"),
                   image=obs_data.get("image"),
                   align=obs_data.get("align"),
                   qos=obs_data.get("qos"),
               )
           )
       
       actions = []
       for action_data in data.get("actions", []):
           actions.append(
               ContractAction(
                   key=action_data["key"],
                   publish=action_data.get("publish", {}),
                   selector=action_data.get("selector"),
                   from_tensor=action_data.get("from_tensor"),
                   safety_behavior=action_data.get("safety_behavior", "zeros"),
               )
           )
       
       return ContractExtensionConfig(
           base_contract=data.get("base_contract"),
           observations=observations,
           actions=actions,
           rate_hz=data.get("rate_hz", 20.0),
           max_duration_s=data.get("max_duration_s", 30.0),
       )

**契约验证**
(`src/robot_config/robot_config/loader.py:254-261 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/loader.py#L254-L261>`__)：

.. code:: python

   # 验证契约-外设引用
   for obs in config.contract.observations:
       if obs.peripheral:
           if obs.peripheral not in camera_names:
               errors.append(
                   f"Observation '{obs.key}' references undefined peripheral: {obs.peripheral}"
               )

**验证检查**：

1. 所有 ``peripheral`` 引用解析到已定义的外设
2. 必需字段（``key``、``topic``、``type``）存在
3. QoS 和对齐设置有效
4. 图像调整大小尺寸为正整数

来源：`src/robot_config/robot_config/loader.py:94-144 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/loader.py#L94-L144>`__，
`src/robot_config/robot_config/loader.py:254-261 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/loader.py#L254-L261>`__

--------------

代码中的契约使用
----------------

契约被多个系统组件使用。以下是各组件的使用方式：

episode_recorder 使用
~~~~~~~~~~~~~~~~~~~~~

.. code:: python

   # 从 robot_config 加载契约
   contract = robot_config.contract

   # 为所有观测创建订阅
   for obs in contract.observations:
       subscription = node.create_subscription(
           msg_type=get_message(obs.type),
           topic=obs.topic,
           callback=lambda msg: record_callback(msg, obs.key),
           qos_profile=create_qos_profile(obs.qos)
       )
       
   # 将契约嵌入 bag 元数据供下游处理
   bag_metadata = {
       "contract": contract.to_dict(),
       "rate_hz": contract.rate_hz,
       "max_duration_s": contract.max_duration_s
   }

bag_to_lerobot 使用
~~~~~~~~~~~~~~~~~~~

.. code:: python

   # 从 bag 元数据加载契约
   contract = load_contract_from_bag_metadata(bag)

   # 处理每个观测
   for obs in contract.observations:
       # 使用契约规范解码消息
       decoded = TensorMsgConverter.decode(msg, spec=obs)
       
       # 如果指定则应用图像调整大小
       if obs.image and obs.image.get("resize"):
           decoded = resize_image(decoded, obs.image["resize"])
       
       # 以 contract.rate_hz 重采样
       resampled = resample(decoded, contract.rate_hz)

lerobot_policy_node 使用
~~~~~~~~~~~~~~~~~~~~~~~~

.. code:: python

   # 从 robot_config 加载契约
   contract = robot_config.contract

   # 按模型的 input_features 过滤观测
   model_inputs = policy.config.input_features
   filtered_obs = [obs for obs in contract.observations if obs.key in model_inputs]

   # 创建订阅
   for obs in filtered_obs:
       subscription = node.create_subscription(
           msg_type=get_message(obs.type),
           topic=obs.topic,
           callback=lambda msg: observation_callback(msg, obs),
           qos_profile=create_qos_profile(obs.qos)
       )
       
   # 将观测解码为张量
   def observation_callback(msg, obs):
       tensor = TensorMsgConverter.decode(msg, spec=obs)
       obs_buffer[obs.key] = tensor

来源：`src/tensormsg/tensormsg/converter.py:24-39 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/tensormsg/tensormsg/converter.py#L24-L39>`__

--------------

总结
----

契约定义是 IB-Robot 系统"单一数据源"架构的基石。通过在一个位置声明式地指定观测、动作及其处理参数，契约确保：

1. **训练-部署一致性**：录制数据和实时推理使用相同的预处理
2. **配置集中化**：录制、转换和推理代码之间无重复
3. **模块化**：通过编辑 YAML 轻松更换传感器、控制模式和 ML 模型
4. **类型安全**：ROS 消息类型和张量形状的强类型
5. **外设集成**：无缝引用相机和传感器元数据

契约从 ``robot_config`` YAML 传播到 ``episode_recorder``（嵌入 bag）、``bag_to_lerobot``（数据集转换）和 ``lerobot_policy_node``（实时推理），保证 ML 流水线的端到端一致性。

有关如何验证契约配置，请参阅 `配置验证 <#5.5>`__。有关使用特定契约启动系统的详情，请参阅 `启动系统 <#5.4>`__。

来源：
`src/robot_config/config/robots/so101_single_arm.yaml:198-302 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L198-L302>`__，
`src/robot_config/robot_config/loader.py:94-144 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/loader.py#L94-L144>`__

--------------

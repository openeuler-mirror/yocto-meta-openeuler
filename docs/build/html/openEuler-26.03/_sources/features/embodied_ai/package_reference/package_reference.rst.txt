包参考
========

.. raw:: html

   <details>

相关源文件

以下文件被用作生成此 wiki 页面的上下文：

-  `README.en.md <README.en.md>`__
-  `README.md <README.md>`__
-  `docs/architecture.md <docs/architecture.md>`__
-  `/image/architecture.png </image/architecture.png>`__
-  `docs/roadmap.md <docs/roadmap.md>`__
-  `scripts/build.sh <scripts/build.sh>`__
-  `src/README.md <src/README.md>`__
-  `src/action_dispatch/README.en.md <src/action_dispatch/README.en.md>`__
-  `src/action_dispatch/README.md <src/action_dispatch/README.md>`__
-  `src/action_dispatch/package.xml <src/action_dispatch/package.xml>`__
-  `src/inference_service/package.xml <src/inference_service/package.xml>`__

.. raw:: html

   </details>

本文档提供了 IB-Robot 工作空间中所有 ROS2 包的全面参考。它详细说明了每个包的用途、关键组件、依赖关系以及在整体系统架构中的关系。

有关包构建和配置的详细信息，请参阅 `构建项目 <#2.2>`__。有关启动系统的详细信息，请参阅 `启动系统 <#5.4>`__。如需深入了解特定包，请参阅相应的架构章节（例如，``inference_service`` 参阅 `推理服务 <#7>`__，``action_dispatch`` 参阅 `动作分发 <#8>`__）。

--------------

包组织概览
----------

IB-Robot 工作空间将包按照系统架构组织为功能层。下图展示了架构层与相应包的映射关系：

**架构层中的包分布**

.. mermaid::

   graph TB
       subgraph "Configuration Layer"
           robot_config["robot_config"]
           ibrobot_msgs["ibrobot_msgs"]
       end
       
       subgraph "Protocol Conversion Layer"
           tensormsg["tensormsg"]
       end
       
       subgraph "Inference & Intelligence Layer"
           inference_service["inference_service"]
       end
       
       subgraph "Action Execution Layer"
           action_dispatch["action_dispatch"]
       end
       
       subgraph "Data Collection Layer"
           dataset_tools["dataset_tools"]
           robot_teleop["robot_teleop"]
       end
       
       subgraph "Motion Planning Layer"
           robot_moveit["robot_moveit"]
       end
       
       subgraph "Hardware & Description Layer"
           robot_description["robot_description"]
           so101_hardware["so101_hardware"]
       end
       
       robot_config --> tensormsg
       robot_config --> inference_service
       robot_config --> action_dispatch
       robot_config --> dataset_tools
       robot_config --> robot_moveit
       robot_config --> so101_hardware
       
       ibrobot_msgs --> inference_service
       ibrobot_msgs --> action_dispatch
       ibrobot_msgs --> dataset_tools
       
       tensormsg --> inference_service
       tensormsg --> action_dispatch
       tensormsg --> dataset_tools
       
       inference_service --> action_dispatch
       
       robot_description --> robot_moveit
       robot_description --> so101_hardware

**来源**: `README.md:44-71 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L44-L71>`__, `src/README.md:50-87 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/README.md#L50-L87>`__,
`docs/architecture.md:86-177 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/docs/architecture.md#L86-L177>`__

--------------

包依赖关系图
------------

下图展示了包之间的具体依赖关系，使用 ``package.xml`` 文件中的实际包名：

**ROS2 包依赖关系**

.. mermaid::

   graph TD
       ibrobot_msgs["ibrobot_msgs<br/>(interface definitions)"]
       
       robot_config["robot_config<br/>(YAML + launch builders)"]
       
       tensormsg["tensormsg<br/>(ROS↔Tensor conversion)"]
       tensormsg --> ibrobot_msgs
       tensormsg --> robot_config
       
       inference_service["inference_service<br/>(policy nodes)"]
       inference_service --> ibrobot_msgs
       inference_service --> tensormsg
       inference_service --> robot_config
       
       action_dispatch["action_dispatch<br/>(action dispatcher node)"]
       action_dispatch --> ibrobot_msgs
       action_dispatch --> tensormsg
       action_dispatch --> robot_config
       
       dataset_tools["dataset_tools<br/>(episode recorder)"]
       dataset_tools --> ibrobot_msgs
       dataset_tools --> tensormsg
       dataset_tools --> robot_config
       
       robot_teleop["robot_teleop<br/>(VR/Xbox/IMU control)"]
       robot_teleop --> ibrobot_msgs
       robot_teleop --> robot_config
       
       robot_moveit["robot_moveit<br/>(MoveIt2 config)"]
       robot_moveit --> robot_description
       
       robot_description["robot_description<br/>(URDF/SRDF/meshes)"]
       
       so101_hardware["so101_hardware<br/>(Feetech SDK driver)"]
       so101_hardware --> robot_description
       
       style ibrobot_msgs fill:#fff3e0,stroke:#ff9800,stroke-width:3px
       style robot_config fill:#fff3e0,stroke:#ff9800,stroke-width:3px

**来源**: `src/action_dispatch/package.xml:1-32 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/package.xml#L1-L32>`__,
`src/inference_service/package.xml:1-40 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/package.xml#L1-L40>`__

--------------

核心包
------

ibrobot_msgs
~~~~~~~~~~~~

| **类型**: 接口包
| **语言**: ROS2 IDL (``.msg``, ``.srv``, ``.action``)
| **位置**: ``src/ibrobot_msgs/``

**用途**: 定义 IB-Robot 系统中使用的所有自定义 ROS2 消息、服务和动作接口。提供节点之间的通信契约。

**关键接口**:


.. list-table::
   :header-rows: 1

   * - 接口类型
     - 名称
     - 用途
   * - Action
     - ``DispatchInfer``
     - 用于动作分发的推理请求/响应
   * - Message
     - ``VariantsList``
     - 张量数据序列化的通用容器
   * - Message
     - ``Variant``
     - 单个张量/值包装器

**依赖**: - ``std_msgs`` - ``sensor_msgs`` - ``geometry_msgs`` -
``trajectory_msgs`` - ``builtin_interfaces``

**来源**: `README.md:59 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L59>`__

--------------

robot_config
~~~~~~~~~~~~

| **类型**: 配置与启动包
| **语言**: Python
| **位置**: ``src/robot_config/``
| **可执行文件**: 无（仅启动包）

**用途**: 作为机器人规格、契约和系统配置的**唯一事实来源**。提供统一的启动入口点和配置构建器。

**关键组件**:


.. list-table::
   :header-rows: 1

   * - 组件
     - 文件路径
     - 用途
   * - 主启动文件
     - ``launch/robot.launch.py``
     - 统一系统入口点
   * - 机器人配置
     - ``config/robots/*.yaml``
     - 每个机器人的 规格说明
   * - 契约构建器
     - ``robot_config/contract_builder.py``
     - 自动生成 观测/动作契约
   * - 启动构建器
     - ``robot_config/launch_builders/``
     - 模块化启动 组合
   * - 配置加载器
     - ``robot_config/config_loader.py``
     - YAML 解析和 验证

**配置文件**: - ``config/robots/so101_single_arm.yaml`` - SO-101 机器人规格 - ``config/calibration/*.yaml`` - 传感器校准数据 - ``config/contracts/*.yaml`` - 预生成的契约

**启动参数**:


.. list-table::
   :header-rows: 1

   * - 参数
     - 类型
     - 默认值
     - 描述
   * - ``robot_config``
     - string
     - ``so 101_single_arm``
     - 机器人配置名称
   * - ``config_path``
     - string
     - ``''``
     - 配置文件的 绝对路径 （覆盖 robot_config）
   * - ``use_sim``
     - bool
     - ``false``
     - 启用 Gazebo 仿真
   * - ``control_mode``
     - string
     - 来自 YAML
     - 覆盖控制模式
   * - `` with_inference``
     - bool
     - auto
     - 强制启用/禁用 推理服务
   * - ``with_moveit``
     - bool
     - auto
     - 强制启用/禁用 MoveIt
   * - `` moveit_display``
     - bool
     - ``true``
     - 为 MoveIt 启动 RViz
   * - ``auto_sta rt_controllers``
     - bool
     - ``true``
     - 自动激活 控制器

**依赖**: - ``rclpy`` - ``launch`` - ``launch_ros`` - Python
3.10+

**来源**: `README.md:56 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L56>`__, `README.md:159-169 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L159-L169>`__,
`src/README.md:50-55 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/README.md#L50-L55>`__

--------------

协议转换层
----------

tensormsg
~~~~~~~~~

| **类型**: 协议转换库
| **语言**: Python
| **位置**: ``src/tensormsg/``
| **可执行文件**: 无（库包）

**用途**: 提供 ROS2 消息与张量数据结构（NumPy/PyTorch）之间的双向转换。实现契约驱动的观测/动作编码和解码。

**关键模块**:

=========================== =======================================
模块                        用途
=========================== =======================================
``tensor_msg_converter.py`` 核心 ROS↔张量转换逻辑
``stream_buffer.py``        时间同步的多话题缓冲
``contract.py``             契约模式验证
=========================== =======================================

**核心类**:

::

   TensorMsgConverter
   ├── encode_value()      # 张量 → ROS 消息
   ├── decode_value()      # ROS 消息 → 张量
   └── batch_encode()      # 批量处理

   StreamBuffer
   ├── add_message()       # 缓冲传入消息
   ├── get_latest()        # 获取最新同步批次
   └── asof_sample()       # 时间对齐采样

**依赖**: - ``rclpy`` - ``std_msgs``, ``sensor_msgs``,
``geometry_msgs`` - ``ibrobot_msgs`` - ``robot_config`` - PyTorch
（可选，用于直接张量输出）- NumPy

**来源**: `README.md:58 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L58>`__, `src/README.md:68-72 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/README.md#L68-L72>`__

--------------

推理与智能层
------------

inference_service
~~~~~~~~~~~~~~~~~

| **类型**: 推理服务包
| **语言**: Python
| **位置**: ``src/inference_service/``
| **可执行文件**: - ``lerobot_policy_node`` - 单机/分布式边缘策略推理 - ``pure_inference_node`` - 仅云端 GPU 推理服务器

**用途**: 为各种具身智能策略（ACT、Diffusion Policy、VLA 模型）提供模型推理服务。支持单机（单机）和分布式（设备-边缘-云端）执行模式。

**关键组件**:


.. list-table::
   :header-rows: 1

   * - 组件
     - 文件
     - 用途
   * - 策略节点
     - ``le robot_policy_node.py``
     - 主推理协调器
   * - 纯推理节点
     - ``pu re_inference_node.py``
     - 云端 GPU 推理服务器
   * - 预处理器
     - ``compon ents/preprocessor.py``
     - 张量预处理（CPU）
   * - 推理引擎
     - ``components /inference_engine.py``
     - 模型前向传播（GPU）
   * - 后处理器
     - ``compone nts/postprocessor.py``
     - 动作张量后处理
   * - 协调器
     - ``compo nents/coordinator.py``
     - 执行模式编排

**执行模式**:


.. list-table::
   :header-rows: 1

   * - 模式
     - 节点配置
     - 通信方式
   * - 单机
     - 单个 ``lerobot_policy_node``
     - 进程内零拷贝
   * - 分布式
     - ``lerobot_policy_node`` (边缘) + ``pure_inference_node`` (云端)
     - ROS2 话题 ``/preprocessed/batch``, ``/inference/action``

**动作接口**: - **动作服务器**: ``DispatchInfer``（来自 ``ibrobot_msgs``）- **输入**: 空目标（由水位触发）- **结果**: 包含动作块张量的 ``VariantsList``

**依赖**: - ``rclpy``, ``rclpy_action`` - ``ibrobot_msgs`` -
``tensormsg`` - ``robot_config`` - PyTorch - LeRobot 库
（来自 ``libs/lerobot/`` 的 ``lerobot`` 包）

**来源**: `src/inference_service/package.xml:1-40 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/package.xml#L1-L40>`__,
`README.md:64 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L64>`__, `src/README.md:56-61 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/README.md#L56-L61>`__

--------------

动作执行层
----------

action_dispatch
~~~~~~~~~~~~~~~

| **类型**: 动作执行服务
| **语言**: Python
| **位置**: ``src/action_dispatch/``
| **可执行文件**: - ``action_dispatcher_node`` - 基于拉取的动作分发器，带时序平滑

**用途**: 管理动作执行队列，根据水位阈值触发推理请求，并为动作块模型应用时序平滑。作为推理与硬件控制之间的"小脑"。

**关键组件**:


.. list-table::
   :header-rows: 1

   * - 组件
     - 文件
     - 用途
   * - 分发器节点
     - ``action_dispatcher_node.py``
     - 主执行循环和队列管理
   * - 时序平滑器
     - ``temporal_smoother.py``
     - 跨帧动作混合
   * - 平滑器管理器
     - ``temporal_smoother_manager.py``
     - 平滑器生命周期管理
   * - 话题执行器
     - ``executors/topic_executor.py``
     - 高频位置控制
   * - 动作执行器
     - ``executors/action_executor.py``
     - 基于轨迹的控制

**节点参数**:


.. list-table::
   :header-rows: 1

   * - 参数
     - 类型
     - 默认值
     - 描述
   * - ``queue_size``
     - int
     - 100
     - 最大动作队列长度
   * - ``watermark_threshold``
     - int
     - 20
     - 当队列 < 阈值时触发推理
   * - ``control_frequency``
     - double
     - 100.0
     - 控制循环频率（Hz）
   * - ``inference_action_server``
     - string
     - ``/act_inference_node/DispatchInfer``
     - 推理动作服务器名称
   * - ``contract_path``
     - string
     - ``''``
     - 契约 YAML 路径
   * - ``temporal_smoothing_enabled``
     - bool
     - false
     - 启用跨帧平滑
   * - ``temporal_ensemble_coeff``
     - double
     - 0.01
     - 指数平滑系数
   * - ``chunk_size``
     - int
     - 100
     - 动作块大小

**通信**:


.. list-table::
   :header-rows: 1

   * - 方向
     - 接口
     - 类型
     - 用途
   * - 客户端
     - `` DispatchInfer``
     - Action
     - 从策略节点 请求推理
   * - 发布
     - ``/j oint_commands``
     - ``Floa t64MultiArray``
     - 位置命令到 ros2_control
   * - 发布
     - ` `~/queue_size``
     - ``Int32``
     - 当前队列状态
   * - 发布
     - ``~/smoo thing_enabled``
     - ``Bool``
     - 平滑状态
   * - 订阅
     - `` /joint_states``
     - ``JointState``
     - 关节状态反馈 （可选）
   * - 服务
     - ``~/reset``
     - ``Empty``
     - 重置队列和状态
   * - 服务
     - ``~/tog gle_smoothing``
     - ``Empty``
     - 开关平滑

**依赖**: - ``rclpy``, ``rclpy_action`` - ``std_msgs``,
``sensor_msgs``, ``trajectory_msgs`` - ``ibrobot_msgs`` - ``tensormsg``
- ``robot_config`` - PyTorch（用于张量操作）

**来源**: `src/action_dispatch/package.xml:1-32 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/package.xml#L1-L32>`__,
`src/action_dispatch/README.en.md:1-447 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/README.en.md#L1-L447>`__, `README.md:61 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L61>`__,
`src/README.md:62-66 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/README.md#L62-L66>`__

--------------

数据采集与工具
--------------

dataset_tools
~~~~~~~~~~~~~

| **类型**: 数据采集与转换包
| **语言**: Python
| **位置**: ``src/dataset_tools/``
| **可执行文件**: - ``episode_recorder`` - 用于片段数据录制的动作服务器 - ``record_cli`` - 录制会话的交互式 CLI - ``bag_to_lerobot`` - ROS2 bag 到 LeRobot 数据集转换器

**用途**: 提供用于采集专家演示数据并将 ROS2 bag 数据转换为 LeRobot v3 数据集格式的工具。实现契约驱动的数据对齐和重采样。

**关键组件**:


.. list-table::
   :header-rows: 1

   * - 组件
     - 文件
     - 用途
   * - 片段录制器
     - `` episode_recor der_node.py``
     - 将多话题数据录制 到 ROS2 bag
   * - 录制 CLI
     - ``re cord_cli.py``
     - 录制控制的用户界面
   * - Bag 转换器
     - ``bag_to _lerobot.py``
     - 将 bag 转换为 LeRobot parquet/视频 格式
   * - 契约处理器
     - 使用 ``tensormsg``
     - 确保录制与训练 对齐

**录制模式**: - **片段式**: 每个片段开始/停止录制，带交互式提示 - **连续式**: 后台录制，自动片段分割

**输出格式**: - ROS2 MCAP bag（录制）- LeRobot v3 数据集（转换）: - ``data/`` - 包含观测/动作张量的 Parquet 文件 - ``videos/`` - MP4 编码的相机流

**依赖**: ``rclpy``、``rosbag2_py``、``ibrobot_msgs``、``tensormsg``、``robot_config``、``lerobot`` （用于数据集格式）

**来源**: `README.md:60 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L60>`__

--------------

robot_teleop
~~~~~~~~~~~~

| **类型**: 遥操作包
| **语言**: Python
| **位置**: ``src/robot_teleop/``
| **可执行文件**: - ``vr_teleop_node`` - VR 控制器遥操作 - ``xbox_teleop_node`` - Xbox 游戏手柄遥操作 - ``imu_teleop_node`` - 手机 IMU 遥操作 - ``leader_follower_node`` - 主从臂控制

**用途**: 提供多种遥操作接口用于采集专家演示数据。支持各种输入设备和控制方案。

**支持的设备**:

=============== ======================== =======================
设备            节点                     控制方案
=============== ======================== =======================
VR 头显         ``vr_teleop_node``       6-DOF 手部追踪
Xbox 控制器     ``xbox_teleop_node``     摇杆 + 按钮
手机 IMU        ``imu_teleop_node``      方向追踪
主臂            ``leader_follower_node`` 直接位置映射
=============== ======================== =======================

**依赖**: - ``rclpy`` - ``sensor_msgs``, ``geometry_msgs`` -
``ibrobot_msgs`` - ``robot_config`` - 设备特定库（游戏手柄用 SDL2 等）

**来源**: `README.md:62 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L62>`__

--------------

运动规划层
----------

robot_moveit
~~~~~~~~~~~~

| **类型**: MoveIt2 配置包
| **语言**: Python/YAML
| **位置**: ``src/robot_moveit/``
| **可执行文件**: - ``moveit_gateway.py`` - 高层位姿命令接口

**用途**: 为 SO-101 机器人提供 MoveIt2 运动规划集成。包括 OMPL 规划器、Pilz 工业运动规划器和 IK 求解器的配置。

**关键组件**:


.. list-table::
   :header-rows: 1

   * - 组件
     - 文件
     - 用途
   * - MoveIt 网关
     - ``scri pts/moveit_gateway.py``
     - 位姿 → IK → 轨迹流水线
   * - 启动文件
     - ``launch/s o101_moveit.launch.py``
     - MoveIt 核心 + RViz
   * - SRDF
     - ``config/so101.srdf``
     - 语义机器人描述
   * - 运动学
     - ``c onfig/kinematics.yaml``
     - IK 求解器配置
   * - 控制器
     - ``co nfig/controllers.yaml``
     - MoveIt 控制器配置

**MoveIt 网关**: - **输入**: ``/cmd_pose``（位姿命令）- **处理**: 带方向约束的多策略 IK 求解 - **输出**: 关节轨迹到 ``action_dispatcher_node``

**5自由度约束处理**: - 欠驱动臂的 ``position_only_ik`` 模式 - 自动方向约束松弛

**依赖**: - ``moveit_ros_planning_interface`` -
``moveit_ros_move_group`` - ``moveit_simple_controller_manager`` -
``robot_description`` - ``robot_config``

**来源**: `README.md:63 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L63>`__, `src/README.md:73-75 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/README.md#L73-L75>`__

--------------

硬件与描述层
------------

robot_description
~~~~~~~~~~~~~~~~~

| **类型**: URDF/网格资源包
| **语言**: XML (URDF/SRDF)
| **位置**: ``src/robot_description/``
| **可执行文件**: 无（资源包）

**用途**: 机器人模型描述的集中仓库，包括 URDF 文件、SRDF 语义描述、STL 网格和视觉资源。

**资源结构**:

::

   robot_description/
   ├── urdf/
   │   ├── so101.urdf.xacro          # 主机器人描述
   │   ├── so101.ros2_control.xacro  # ros2_control 配置
   │   └── so101.gazebo.xacro        # Gazebo 插件
   ├── srdf/
   │   └── so101.srdf                # MoveIt 语义描述
   ├── meshes/
   │   ├── visual/                   # 高质量视觉网格
   │   └── collision/                # 简化的碰撞网格
   └── config/
       └── joint_limits.yaml         # 关节限制定义

**URDF 组件**: - 基础 URDF: 运动学和连杆几何 - ros2_control: 硬件接口声明 - Gazebo: 传感器插件和物理属性

**依赖**: ``robot_state_publisher``, ``joint_state_publisher`` (可选, 用于独立测试)

**来源**: `README.md:62 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L62>`__, `src/README.md:76-78 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/README.md#L76-L78>`__

--------------

so101_hardware
~~~~~~~~~~~~~~

| **类型**: 硬件驱动插件
| **语言**: C++
| **位置**: ``src/so101_hardware/``
| **插件**: ``so101_hardware/SO101Hardware`` （ros2_control 硬件接口）

**用途**: 使用飞特舵机 SDK 实现 SO-101 机器人的 ros2_control 硬件接口。通过串口通信提供物理舵机的位置/速度读写。

**关键组件**:

======================= ===============================================
组件                    用途
======================= ===============================================
``SO101Hardware`` 类    ros2_control ``SystemInterface`` 实现
飞特 SDK 集成           底层舵机通信
串口管理器              UART 通信处理
======================= ===============================================

**硬件接口**: - **命令接口**: 位置、速度（每个关节）- **状态接口**: 位置、速度、力矩（每个关节）- **通信**: 串口（通常为 ``/dev/ttyUSB0`` 或类似）

**配置**\ （在机器人 URDF 中）:

.. code:: xml

   <ros2_control name="SO101Hardware" type="system">
     <hardware>
       <plugin>so101_hardware/SO101Hardware</plugin>
       <param name="serial_port">/dev/ttyUSB0</param>
       <param name="baud_rate">1000000</param>
     </hardware>
     ...
   </ros2_control>

**依赖**: - ``rclcpp`` - ``hardware_interface`` - ``pluginlib``
- ``robot_description`` - 飞特舵机 SDK（外部库）

**来源**: `README.md:65 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L65>`__, `src/README.md:80-82 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/README.md#L80-L82>`__

--------------

外部依赖
--------

lerobot（外部子模块）
~~~~~~~~~~~~~~~~~~~~~~

| **类型**: Python ML 库
| **语言**: Python
| **位置**: ``libs/lerobot/``
| **子模块**: Hugging Face LeRobot 仓库

**用途**: 为具身智能策略提供训练基础设施、数据集格式和预训练模型。被 ``inference_service`` 用于模型加载，被 ``dataset_tools`` 用于数据集格式合规。

**关键特性**: - ACT、Diffusion Policy、VLA 模型实现 - LeRobot v3 数据集格式（Parquet + MP4）- 训练脚本和工具

**安装**: 由 `scripts/build.sh:162-178 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/scripts/build.sh#L162-L178>`__ 以可编辑模式安装到工作空间虚拟环境。

**来源**: `README.md:53 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L53>`__, `scripts/build.sh:162-178 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/scripts/build.sh#L162-L178>`__

--------------

包文件系统映射
--------------

下图展示了包与其文件系统位置和关键文件类型的映射关系：

**工作空间文件系统结构**

.. mermaid::

   graph TB
       subgraph "Workspace Root"
           src["src/<br/>(submodule)"]
           libs["libs/"]
           scripts["scripts/"]
           install["install/<br/>(build output)"]
       end
       
       subgraph "src/ Packages"
           src --> rc["robot_config/<br/>Python, YAML, Launch"]
           src --> tm["tensormsg/<br/>Python Library"]
           src --> inf["inference_service/<br/>Python Executables"]
           src --> ad["action_dispatch/<br/>Python Executables"]
           src --> dt["dataset_tools/<br/>Python Executables"]
           src --> rt["robot_teleop/<br/>Python Executables"]
           src --> rm["robot_moveit/<br/>YAML Config, Launch"]
           src --> rd["robot_description/<br/>URDF, SRDF, STL"]
           src --> so["so101_hardware/<br/>C++ Plugin"]
           src --> im["ibrobot_msgs/<br/>IDL Definitions"]
       end
       
       subgraph "libs/ External"
           libs --> lerobot["lerobot/<br/>(Git submodule)<br/>Python ML Library"]
       end
       
       subgraph "scripts/ Tooling"
           scripts --> setup["setup.sh"]
           scripts --> build["build.sh"]
           scripts --> cleanup["cleanup_ros.sh"]
       end
       
       rc -.->|"config/*.yaml"| rc_cfg["Robot Specifications"]
       rc -.->|"launch/*.py"| rc_launch["Launch Files"]
       
       inf -.->|"depends on"| lerobot
       dt -.->|"depends on"| lerobot

**来源**: `README.md:46-71 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L46-L71>`__, `src/README.md:1-103 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/README.md#L1-L103>`__

--------------

构建系统集成
------------

所有包使用支持 mixin 的 colcon 构建系统构建。构建过程由 `scripts/build.sh <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/scripts/build.sh>`__ 管理。

**构建目标**:


.. list-table::
   :header-rows: 1

   * - 目标类型
     - 包
     - 构建工具
   * - ament_python
     - ``robot_config``, ``tensormsg``, ``inference_service``, ``action_dispatch``, ``dataset_tools``, ``robot_teleop``, ``robot_moveit``
     - setuptools
   * - ament_cmake
     - ``so101_hardware``
     - CMake
   * - Interface
     - ``ibrobot_msgs``
     - rosidl 生成器
   * - External
     - ``lerobot``
     - pip（可编辑安装）

**构建命令**:

.. code:: bash

   ./scripts/build.sh                  # 默认开发构建
   ./scripts/build.sh --mixin release  # 优化的发布构建
   ./scripts/build.sh --mixin debug test  # 带测试的调试构建

**Mixin 配置**\ （``.colcon/mixin/build.mixin.yaml``）: - ``dev``
- 开发模式（符号链接安装，无测试）- ``release`` - 优化构建（``-O3``，NDEBUG）- ``debug`` - 调试符号（``-g``，无优化）- ``test`` - 启用测试 - ``asan`` - AddressSanitizer - ``tsan`` - ThreadSanitizer

**来源**: `scripts/build.sh:1-229 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/scripts/build.sh#L1-L229>`__, `README.md:114-118 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L114-L118>`__

--------------

包启动集成
----------

``robot_config`` 包作为统一的启动入口点。它根据配置和启动参数协调所有必要包的启动：

**启动构建器系统**

.. mermaid::

   graph LR
       robot_launch["robot.launch.py"]
       
       robot_launch --> control_builder["ControlLaunchBuilder"]
       robot_launch --> sim_builder["SimulationLaunchBuilder"]
       robot_launch --> perception_builder["PerceptionLaunchBuilder"]
       robot_launch --> execution_builder["ExecutionLaunchBuilder"]
       
       control_builder --> controllers["ros2_control<br/>controllers"]
       
       sim_builder --> gazebo["Gazebo<br/>(if use_sim=true)"]
       sim_builder --> robot_state_pub["robot_state_publisher<br/>(robot_description)"]
       
       perception_builder --> cameras["Camera drivers<br/>(from peripherals)"]
       
       execution_builder --> inference["inference_service<br/>(if with_inference)"]
       execution_builder --> dispatcher["action_dispatch<br/>(if model_inference)"]
       execution_builder --> moveit_gateway["robot_moveit<br/>(if moveit_planning)"]
       execution_builder --> teleop["robot_teleop<br/>(if teleop mode)"]

**启动参数逻辑**: - ``control_mode`` 决定启动哪些执行包 - ``with_inference`` / ``with_moveit`` 可覆盖自动检测 - ``use_sim`` 在 ``so101_hardware`` 和 ``gz_ros2_control`` 之间切换

**来源**: `README.md:121-154 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L121-L154>`__

--------------

汇总表
------

**完整包参考**


.. list-table::
   :header-rows: 1

   * - 包
     - 类型
     - 语言
     - 关键可执行文件
     - 主要用途
   * - ``ibrobot_msgs``
     - Interface
     - IDL
     - -
     - 消息/动作定义
   * - ``robot_config``
     - Config/Launch
     - Python
     - -
     - 唯一事实来源，启动编排
   * - ``tensormsg``
     - Library
     - Python
     - -
     - ROS↔张量协议转换
   * - ``inference_service``
     - Service
     - Python
     - ``lerobot_policy_node``, ``pure_inference_node``
     - 模型推理（ACT、Diffusion、VLA）
   * - ``action_dispatch``
     - Service
     - Python
     - ``action_dispatcher_node``
     - 动作队列 + 时序平滑
   * - ``dataset_tools``
     - Tools
     - Python
     - ``episode_recorder``, ``bag_to_lerobot``, ``record_cli``
     - 数据采集与转换
   * - ``robot_teleop``
     - Control
     - Python
     - ``vr_teleop_node``, ``xbox_teleop_node``, etc.
     - 遥操作接口
   * - ``robot_moveit``
     - Planning
     - Python/YAML
     - ``moveit_gateway.py``
     - MoveIt2 配置与网关
   * - ``robot_description``
     - Assets
     - URDF/SRDF
     - -
     - 机器人模型和网格
   * - ``so101_hardware``
     - Driver
     - C++
     - - (plugin)
     - ros2_control 硬件接口
   * - ``lerobot``
     - External
     - Python
     - -
     - ML 训练库（子模块）

**来源**: `README.md:44-71 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L44-L71>`__, `src/README.md:20-87 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/README.md#L20-L87>`__,
`docs/architecture.md:217-265 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/docs/architecture.md#L217-L265>`__

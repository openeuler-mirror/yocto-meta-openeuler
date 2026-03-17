控制模式架构
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
-  `src/robot_config/README.en.md <src/robot_config/README.en.md>`__
-  `src/robot_config/README.md <src/robot_config/README.md>`__
-  `src/robot_config/config/robots/so101_dual_arm.yaml <src/robot_config/config/robots/so101_dual_arm.yaml>`__
-  `src/robot_config/config/robots/so101_single_arm.yaml <src/robot_config/config/robots/so101_single_arm.yaml>`__
-  `src/robot_config/robot_config/loader.py <src/robot_config/robot_config/loader.py>`__
-  `src/tensormsg/tensormsg/converter.py <src/tensormsg/tensormsg/converter.py>`__

.. raw:: html

   </details>

目的与范围
----------

本文档介绍 IB-Robot 的控制模式架构，该架构使单个机器人配置能够支持三种不同的操作范式：遥操作、AI 模型推理和运动规划。每种模式使用不同的控制器和执行策略，同时汇聚到 ``ros2_control`` 提供的相同硬件抽象层。

有关定义观测和动作的底层契约系统详情，请参阅 `契约系统 <#3.2>`__。有关动作分发机制的信息，请参阅 `动作分发 <#8>`__。有关硬件集成详情，请参阅 `硬件集成 <#11>`__。

**来源**：`README.md:15-17 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L15-L17>`__，
`src/robot_config/config/robots/so101_single_arm.yaml:45-103 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L45-L103>`__，
`docs/architecture.md:209-214 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/docs/architecture.md#L209-L214>`__

--------------

概述
----

IB-Robot 实现三种控制模式以适应不同的用例和 AI 模型架构：


.. list-table::
   :header-rows: 1

   * - 模式
     - 主要用例
     - 控制频率
     - 控制器类型
     - 执行接口
   * - ``teleop``
     - 人工演示数据收集
     - 50-100 Hz
     - 位置控制器
     - 直接主题流
   * - ``model_inference``
     - 端到端模仿学习 (ACT, Diffusion Policy)
     - 50-100 Hz
     - 位置控制器
     - 带时间平滑的动作分发
   * - ``moveit_planning``
     - 目标条件策略 (VoxPoser, VLM)
     - 可变
     - 轨迹控制器
     - 动作服务器 (FollowJointTrajectory)

控制模式在启动时确定，驱动整个系统栈——从生成哪些控制器到实例化哪些动作执行器。

**来源**：
`src/robot_config/config/robots/so101_single_arm.yaml:48-103 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L48-L103>`__，
`src/robot_config/README.en.md:88-256 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/README.en.md#L88-L256>`__，`README.md:160-168 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L160-L168>`__

--------------

控制模式选择架构
----------------

.. mermaid::

   graph TB
       subgraph "配置层"
           YAML["robot_config YAML<br/>(so101_single_arm.yaml)"]
           DEFAULT["default_control_mode<br/>(第 46 行)"]
           MODES["control_modes 部分<br/>(第 48-103 行)"]
           
           YAML --> DEFAULT
           YAML --> MODES
       end
       
       subgraph "启动层"
           LAUNCH["robot.launch.py"]
           PARAM["--control_mode 参数<br/>(命令行)"]
           ROUTER["模式路由器<br/>(LaunchBuilder 逻辑)"]
           
           LAUNCH --> PARAM
           DEFAULT -.->|"默认值"| ROUTER
           PARAM -.->|"覆盖"| ROUTER
       end
       
       subgraph "验证"
           ROUTER --> VALIDATE{"模式存在于<br/>control_modes?"}
           VALIDATE -->|"是"| SPAWN["为选定模式<br/>生成控制器"]
           VALIDATE -->|"否"| ERROR["启动错误"]
       end
       
       subgraph "控制器生成"
           SPAWN --> TELEOP_CTRL["teleop:<br/>position_controllers"]
           SPAWN --> MODEL_CTRL["model_inference:<br/>position_controllers"]
           SPAWN --> MOVEIT_CTRL["moveit_planning:<br/>trajectory_controllers"]
       end
       
       MODES -.->|"定义有效模式"| VALIDATE

控制模式选择遵循以下优先级：

1. **默认模式** 在 ``default_control_mode`` 字段中指定
   `so101_single_arm.yaml:46 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/so101_single_arm.yaml#L46>`__
2. **命令行覆盖** 通过 ``--control_mode:=<mode>`` 启动参数
3. **验证** 对照 YAML 中的 ``control_modes`` 字典
   `so101_single_arm.yaml:48-103 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/so101_single_arm.yaml#L48-L103>`__

**来源**：
`src/robot_config/config/robots/so101_single_arm.yaml:46-103 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L46-L103>`__，
`src/robot_config/README.en.md:345-363 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/README.en.md#L345-L363>`__，`README.md:164-168 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L164-L168>`__

--------------

遥操作模式
----------

目的
~~~~

遥操作模式支持用于数据收集和系统验证的直接人工控制。它提供从输入设备（主臂、游戏手柄、VR 控制器）到机器人硬件的零延迟直通。

配置
~~~~

.. code:: yaml

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
       queue_size: 100
       control_frequency: 50.0

**关键特性**：

- 使用 ``JointGroupPositionController`` 进行直接位置命令
- 发布到 ``/arm_position_controller/commands`` 和 ``/gripper_position_controller/commands`` 主题
- 无动作分发层——命令直接从遥操作节点流向控制器
- 通过 ``force_disable: true`` 显式禁用推理服务

**来源**：
`src/robot_config/config/robots/so101_single_arm.yaml:49-64 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L49-L64>`__，
`src/robot_config/README.en.md:94-134 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/README.en.md#L94-L134>`__

数据流
~~~~~~

.. mermaid::

   graph LR
       subgraph "遥操作设备"
           LEADER["主臂 / 游戏手柄<br/>(robot_teleop 节点)"]
       end
       
       subgraph "直接控制路径"
           TOPIC_PUB["主题发布器<br/>/arm_position_controller/commands<br/>/gripper_position_controller/commands"]
       end
       
       subgraph "ros2_control"
           CTRL_ARM["arm_position_controller<br/>(JointGroupPositionController)"]
           CTRL_GRIP["gripper_position_controller<br/>(ForwardCommandController)"]
           HW_IF["硬件接口"]
       end
       
       subgraph "硬件"
           MOTORS["舵机电机<br/>(SO101SystemHardware)"]
       end
       
       LEADER --> TOPIC_PUB
       TOPIC_PUB --> CTRL_ARM
       TOPIC_PUB --> CTRL_GRIP
       CTRL_ARM --> HW_IF
       CTRL_GRIP --> HW_IF
       HW_IF --> MOTORS

**来源**：`src/robot_config/README.en.md:94-134 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/README.en.md#L94-L134>`__，
`src/robot_config/config/robots/so101_single_arm.yaml:49-64 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L49-L64>`__

--------------

模型推理模式
------------

目的
~~~~

模型推理模式支持输出高频位置流的端到端学习策略。此模式针对预测未来动作序列的动作分块模型（ACT、Diffusion Policy）进行优化。

配置
~~~~

.. code:: yaml

   model_inference:
     description: "High-frequency end-to-end control mode (ACT/pi0)"
     controllers:
       - joint_state_broadcaster
       - arm_position_controller
       - gripper_position_controller
     inference:
       enabled: true
       model: so101_act
       action_server: /inference/dispatch
     executor:
       type: topic
       mode: model_inference
       queue_size: 100
       control_frequency: 50.0

**关键特性**：

- 使用与遥操作模式相同的位置控制器
- 集成 ``action_dispatcher_node`` 用于时间平滑和队列管理
- 通过 ``DispatchInfer`` 动作服务器异步触发推理
- 支持单体和分布式推理执行模式

**来源**：
`src/robot_config/config/robots/so101_single_arm.yaml:66-89 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L66-L89>`__，
`src/robot_config/README.en.md:136-176 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/README.en.md#L136-L176>`__

带动作分发的数据流
~~~~~~~~~~~~~~~~~~

.. mermaid::

   graph TB
       subgraph "推理服务"
           POLICY["lerobot_policy_node<br/>(策略网络)"]
           ACTION_SRV["DispatchInfer 动作服务器<br/>/inference/dispatch"]
           
           POLICY --> ACTION_SRV
       end
       
       subgraph "动作分发器节点"
           QUEUE["动作队列<br/>(FIFO 缓冲区)"]
           SMOOTHER["TemporalSmoother<br/>(跨帧混合)"]
           TIMER["控制循环定时器<br/>(100 Hz)"]
           WATERMARK{"队列长度 <br/>水位线?"}
           
           TIMER --> WATERMARK
           WATERMARK -->|"是"| ACTION_SRV
           ACTION_SRV -->|"动作块"| SMOOTHER
           SMOOTHER --> QUEUE
           TIMER -->|"弹出动作"| QUEUE
       end
       
       subgraph "主题执行器"
           EXEC["TopicExecutor"]
           PUB_ARM["发布到<br/>/arm_position_controller/commands"]
           PUB_GRIP["发布到<br/>/gripper_position_controller/commands"]
           
           QUEUE --> EXEC
           EXEC --> PUB_ARM
           EXEC --> PUB_GRIP
       end
       
       subgraph "ros2_control"
           CTRL["位置控制器"]
           HW["硬件接口"]
           
           PUB_ARM --> CTRL
           PUB_GRIP --> CTRL
           CTRL --> HW
       end

**关键组件**：

- **动作分发器节点**：维护动作队列、通过水位线触发推理、应用时间平滑
- **TopicExecutor**：根据契约规范将平滑后的动作路由到适当的控制器主题
- **TemporalSmoother**：对重叠的动作块执行指数加权混合（见 `动作分发 <#8.2>`__）

**来源**：`src/action_dispatch/README.en.md:9-130 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/README.en.md#L9-L130>`__，
`src/robot_config/config/robots/so101_single_arm.yaml:66-89 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L66-L89>`__

--------------

MoveIt 规划模式
---------------

目的
~~~~

MoveIt 规划模式支持带碰撞避免和逆运动学的高级运动规划。此模式针对输出稀疏航点或目标姿态而非密集动作序列的目标条件策略（VoxPoser、VLM）设计。

配置
~~~~

.. code:: yaml

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

**与其他模式的关键区别**：

- 使用 ``JointTrajectoryController`` 而非位置控制器
- 通过 ``FollowJointTrajectory`` 动作接口发送命令
- 轨迹执行包括时间参数化和速度限制
- 支持 MoveIt 的规划流水线（OMPL、Pilz 规划器）

**来源**：
`src/robot_config/config/robots/so101_single_arm.yaml:91-103 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L91-L103>`__，
`src/robot_config/README.en.md:177-213 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/README.en.md#L177-L213>`__

带 MoveIt 集成的数据流
~~~~~~~~~~~~~~~~~~~~~~

.. mermaid::

   graph TB
       subgraph "高级规划"
           POSE_CMD["姿态命令<br/>/cmd_pose<br/>(geometry_msgs/PoseStamped)"]
           MOVEIT_GW["MoveItGateway 节点<br/>(moveit_gateway.py)"]
           
           POSE_CMD --> MOVEIT_GW
       end
       
       subgraph "MoveIt 核心"
           IK["IK 求解器<br/>(KDL/TracIK)"]
           PLANNER["运动规划器<br/>(OMPL/Pilz)"]
           TRAJ_GEN["轨迹生成器<br/>(时间参数化)"]
           
           MOVEIT_GW --> IK
           IK --> PLANNER
           PLANNER --> TRAJ_GEN
       end
       
       subgraph "动作执行"
           ACTION_EXEC["ActionExecutor<br/>(action_dispatch)"]
           ACTION_CLIENT["FollowJointTrajectory<br/>动作客户端"]
           
           TRAJ_GEN --> ACTION_EXEC
           ACTION_EXEC --> ACTION_CLIENT
       end
       
       subgraph "ros2_control"
           TRAJ_CTRL["arm_trajectory_controller<br/>(JointTrajectoryController)"]
           HW["硬件接口"]
           
           ACTION_CLIENT --> TRAJ_CTRL
           TRAJ_CTRL --> HW
       end

**MoveItGateway 职责**：

- 订阅 ``/cmd_pose`` 获取目标姿态命令
- 调用 IK 求解器计算关节配置
- 调用 MoveIt 的规划流水线生成无碰撞轨迹
- 通过动作接口将轨迹发送到 ``JointTrajectoryController``

**来源**：`src/robot_moveit/scripts/moveit_gateway.py:1-300 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/scripts/moveit_gateway.py#L1-L300>`__，
`src/robot_config/README.en.md:177-213 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/README.en.md#L177-L213>`__

--------------

统一硬件接口
------------

所有三种控制模式汇聚到 ``ros2_control`` 框架，该框架提供硬件抽象层。这种设计实现了模式之间的无缝切换，无需修改硬件驱动。

.. mermaid::

   graph TB
       subgraph "控制模式"
           TELEOP["teleop 模式<br/>position_controllers"]
           MODEL["model_inference 模式<br/>position_controllers"]
           MOVEIT["moveit_planning 模式<br/>trajectory_controllers"]
       end
       
       subgraph "ros2_control 层"
           JSB["joint_state_broadcaster"]
           HW_IF["硬件接口<br/>(read/write 方法)"]
           
           TELEOP --> HW_IF
           MODEL --> HW_IF
           MOVEIT --> HW_IF
           HW_IF --> JSB
       end
       
       subgraph "硬件选择"
           USE_SIM{"use_sim<br/>参数"}
           
           HW_IF --> USE_SIM
       end
       
       subgraph "真实硬件"
           SO101["so101_hardware 插件<br/>(SO101SystemHardware)"]
           SDK["Feetech 舵机 SDK"]
           SERIAL["串口<br/>(/dev/ttyACM0)"]
           
           USE_SIM -->|"false"| SO101
           SO101 --> SDK
           SDK --> SERIAL
       end
       
       subgraph "仿真"
           GZ["gz_ros2_control 插件"]
           GAZEBO["Gazebo 物理引擎"]
           
           USE_SIM -->|"true"| GZ
           GZ --> GAZEBO
       end
       
       JSB -->|"/joint_states"| FEEDBACK["状态反馈<br/>(到推理/规划)"]

**硬件抽象优势**：

1. **统一接口**：所有模式使用 ``ros2_control`` 定义的相同 ``read()`` 和 ``write()`` 方法
2. **仿真到真实迁移**：相同的控制代码在仿真和真实硬件上运行
3. **热插拔后端**：通过单个启动参数在真实硬件和仿真之间切换
4. **控制器复用**：标准 ROS2 控制器跨不同机器人类型工作

**来源**：
`src/robot_config/config/robots/so101_single_arm.yaml:104-122 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L104-L122>`__，
`README.md:15-17 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L15-L17>`__，`docs/architecture.md:209-214 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/docs/architecture.md#L209-L214>`__

--------------

模式切换机制
------------

启动参数解析
~~~~~~~~~~~~

``robot.launch.py`` 文件使用启动构建器实现模式选择逻辑：

.. code:: python

   # 伪代码表示
   def generate_launch_description():
       # 1. 加载 robot_config YAML
       config = load_robot_config(robot_config_path)
       
       # 2. 解析控制模式
       control_mode = launch_param('control_mode') or config['default_control_mode']
       
       # 3. 验证模式存在
       if control_mode not in config['control_modes']:
           raise ValueError(f"Invalid control mode: {control_mode}")
       
       # 4. 获取模式配置
       mode_config = config['control_modes'][control_mode]
       
       # 5. 构建启动实体
       controllers = spawn_controllers(mode_config['controllers'])
       executor = create_executor(mode_config['executor'])
       
       if mode_config['inference']['enabled']:
           inference = launch_inference_service(...)
       
       return LaunchDescription([controllers, executor, inference, ...])

**来源**：`src/robot_config/README.en.md:345-363 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/README.en.md#L345-L363>`__，
`README.md:122-154 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L122-L154>`__

控制器生成策略
~~~~~~~~~~~~~~

每个控制模式指定所需控制器列表。启动系统仅生成活动模式所需的控制器：


.. list-table::
   :header-rows: 1

   * - 模式
     - 生成的控制器
   * - ``teleop``
     - ``joint_state_broadcaster``, ``arm_position_controller``, ``gripper_position_controller``
   * - ``model_inference``
     - ``joint_state_broadcaster``, ``arm_position_controller``, ``gripper_position_controller``
   * - ``moveit_planning``
     - ``joint_state_broadcaster``, ``arm_trajectory_controller``, ``gripper_trajectory_controller``

**控制器冲突预防**：相同关节的位置控制器和轨迹控制器是 **互斥的**。启动系统确保每个关节组只有一个控制器类型处于活动状态，防止资源冲突。

**来源**：
`src/robot_config/config/robots/so101_single_arm.yaml:48-103 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L48-L103>`__，
`src/robot_config/README.en.md:349-363 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/README.en.md#L349-L363>`__

执行器选择
~~~~~~~~~~

``action_dispatch`` 包根据模式配置实例化不同的执行器类型：

.. code:: yaml

   # model_inference 模式
   executor:
     type: topic        # 创建 TopicExecutor
     mode: model_inference
     
   # moveit_planning 模式  
   executor:
     type: action       # 创建 ActionExecutor
     mode: moveit_planning

**TopicExecutor** (``type: topic``)：

- 向控制器命令主题发布 ``Float64MultiArray`` 消息
- 高频操作（50-100 Hz）
- 直接位置控制
- 由 ``teleop`` 和 ``model_inference`` 模式使用

**ActionExecutor** (``type: action``)：

- 发送 ``FollowJointTrajectory`` 动作目标
- 基于轨迹持续时间的可变频率
- 时间参数化的轨迹执行
- 由 ``moveit_planning`` 模式使用

**来源**：`src/action_dispatch/README.en.md:149-154 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/README.en.md#L149-L154>`__，
`src/robot_config/config/robots/so101_single_arm.yaml:60-103 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L60-L103>`__

--------------

配置示例
--------

基本模式覆盖
~~~~~~~~~~~~

.. code:: bash

   # 使用 YAML 中的默认模式 (model_inference)
   ros2 launch robot_config robot.launch.py robot_config:=so101_single_arm

   # 覆盖为遥操作
   ros2 launch robot_config robot.launch.py robot_config:=so101_single_arm control_mode:=teleop

   # 覆盖为 MoveIt 规划并启用仿真
   ros2 launch robot_config robot.launch.py robot_config:=so101_single_arm \
       control_mode:=moveit_planning use_sim:=true

**来源**：`README.md:126-154 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L126-L154>`__，
`src/robot_config/README.en.md:414-420 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/README.en.md#L414-L420>`__

完整多模式配置
~~~~~~~~~~~~~~

.. code:: yaml

   robot:
     name: so101_single_arm
     default_control_mode: "model_inference"
     
     control_modes:
       teleop:
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
           
       model_inference:
         controllers:
           - joint_state_broadcaster
           - arm_position_controller
           - gripper_position_controller
         inference:
           enabled: true
           model: so101_act
         executor:
           type: topic
           mode: model_inference
           control_frequency: 50.0
           
       moveit_planning:
         controllers:
           - joint_state_broadcaster
           - arm_trajectory_controller
           - gripper_trajectory_controller
         executor:
           type: action
           mode: moveit_planning

**来源**：
`src/robot_config/config/robots/so101_single_arm.yaml:45-103 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L45-L103>`__，
`src/robot_config/README.en.md:259-345 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/README.en.md#L259-L345>`__

--------------

故障排除
--------

模式无法切换
~~~~~~~~~~~~

**症状**：命令行 ``--control_mode`` 参数无效。

**解决方案**：验证参数语法（注意 ``:=`` 赋值运算符）：

.. code:: bash

   # 正确
   ros2 launch robot_config robot.launch.py control_mode:=moveit_planning

   # 错误（将被忽略）
   ros2 launch robot_config robot.launch.py control_mode=moveit_planning

**来源**：`src/robot_config/README.en.md:366-377 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/README.en.md#L366-L377>`__

控制器冲突
~~~~~~~~~~

**症状**：控制器无法激活，出现"资源冲突"错误。

**原因**：两个控制器尝试声明相同的关节。

**解决方案**：确保模式配置使用互斥的控制器类型：

- 位置控制器（``arm_position_controller``）和轨迹控制器（``arm_trajectory_controller``）不能在同一关节组上共存。
- 使用 ``ros2 control list_controllers`` 验证活动控制器。
- 运行 ``./scripts/cleanup_ros.sh`` 清除过期的控制器状态。

**来源**：`src/robot_config/README.en.md:313-328 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/README.en.md#L313-L328>`__，
`README.md:173-178 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L173-L178>`__

执行器类型不匹配
~~~~~~~~~~~~~~~~

**症状**：推理服务发布动作但机器人不移动。

**原因**：配置了 TopicExecutor 但轨迹控制器处于活动状态（或反之）。

**解决方案**：匹配执行器类型与控制器类型：

- ``executor.type: topic`` 需要位置控制器
- ``executor.type: action`` 需要轨迹控制器
- 验证 YAML 中的配置与预期的控制模式匹配

**来源**：`src/robot_config/README.en.md:331-338 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/README.en.md#L331-L338>`__，
`src/action_dispatch/README.en.md:149-154 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/README.en.md#L149-L154>`__

--------------

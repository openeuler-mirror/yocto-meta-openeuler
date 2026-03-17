硬件集成
========

.. toctree::
   :titlesonly:
   :hidden:

   ros2_control_configuration
   hardware_plugins

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

本文档介绍 IB-Robot 的硬件抽象层，该抽象层使相同的高级控制逻辑能够与物理机器人和仿真环境无缝协作。系统使用 ``ros2_control`` 作为抽象边界，下方是特定硬件的插件，上方是与控制模式无关的控制器。

关于控制模式和控制器的配置，请参阅 `控制模式架构 <#3.3>`__。关于定义运动学结构的 URDF/SRDF 机器人模型，请参阅第 12 页（包参考）。

--------------

ros2_control 架构
-----------------

IB-Robot 使用标准的 ROS 2 Control 框架，在控制逻辑和硬件驱动之间创建清晰的分离。这种三层架构确保在仿真和真实硬件之间切换只需要配置更改，无需修改代码。

三层堆栈
~~~~~~~~

.. mermaid::

   graph TB
       subgraph "Application Layer"
           TeleopNode["robot_teleop<br/>(Human Control)"]
           InferenceNode["lerobot_policy_node<br/>(AI Control)"]
           MoveItNode["MoveItGateway<br/>(Planning Control)"]
       end
       
       subgraph "Control Layer"
           ActionDispatch["action_dispatcher_node<br/>(Action Chunking)"]
           TopicExec["TopicExecutor<br/>(Position Commands)"]
           ActionExec["ActionExecutor<br/>(Trajectory Commands)"]
       end
       
       subgraph "ros2_control Framework"
           ControllerMgr["controller_manager"]
           
           subgraph "Controllers"
               JSB["joint_state_broadcaster<br/>(State Publisher)"]
               ArmPos["arm_position_controller<br/>(JointGroupPositionController)"]
               GripPos["gripper_position_controller<br/>(ForwardCommandController)"]
               ArmTraj["arm_trajectory_controller<br/>(JointTrajectoryController)"]
               GripTraj["gripper_trajectory_controller<br/>(JointTrajectoryController)"]
           end
           
           HWInterface["Hardware Interface<br/>(read/write abstraction)"]
       end
       
       subgraph "Hardware Plugin Layer"
           HWChoice{"use_sim<br/>parameter?"}
       end
       
       subgraph "Physical Layer"
           RealHW["so101_hardware/SO101SystemHardware<br/>(Feetech SDK)"]
           SimHW["gz_ros2_control<br/>(Gazebo Physics)"]
       end
       
       TeleopNode --> TopicExec
       InferenceNode --> ActionDispatch
       MoveItNode --> ActionExec
       
       ActionDispatch --> TopicExec
       ActionDispatch --> ActionExec
       
       TopicExec --> ArmPos
       TopicExec --> GripPos
       ActionExec --> ArmTraj
       ActionExec --> GripTraj
       
       ArmPos --> ControllerMgr
       GripPos --> ControllerMgr
       ArmTraj --> ControllerMgr
       GripTraj --> ControllerMgr
       JSB --> ControllerMgr
       
       ControllerMgr --> HWInterface
       HWInterface --> HWChoice
       
       HWChoice -->|"false"| RealHW
       HWChoice -->|"true"| SimHW
       
       RealHW --> Motors["/dev/ttyACM0<br/>Physical Motors"]
       SimHW --> Physics["Gazebo Physics Engine"]
       
       Motors -.->|"State Feedback"| RealHW
       Physics -.->|"Simulated State"| SimHW
       
       RealHW -.-> JSB
       SimHW -.-> JSB

**来源：** `README.md:23-41 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L23-L41>`__, `docs/architecture.md:86-177 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/docs/architecture.md#L86-L177>`__,
`src/robot_config/config/robots/so101_single_arm.yaml:104-129 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L104-L129>`__

--------------

硬件插件系统
------------

``ros2_control`` 硬件接口由与真实硬件或仿真环境通信的插件实现。IB-Robot 支持两种主要的硬件后端。

插件选择机制
~~~~~~~~~~~~

.. mermaid::

   graph TB
       LaunchFile["robot.launch.py<br/>--use_sim parameter"]
       
       ConfigYAML["robot_config YAML<br/>ros2_control section"]
       
       LaunchFile -->|"reads"| ConfigYAML
       
       URDFGen["URDF Generation<br/>(xacro processing)"]
       
       ConfigYAML --> URDFGen
       
       URDFChoice{"use_sim<br/>== true?"}
       
       URDFGen --> URDFChoice
       
       URDFChoice -->|"Yes"| SimPlugin["<ros2_control><br/>  <hardware><br/>    <plugin>gz_ros2_control/GazeboSimSystem</plugin>"]
       
       URDFChoice -->|"No"| RealPlugin["<ros2_control><br/>  <hardware><br/>    <plugin>so101_hardware/SO101SystemHardware</plugin><br/>    <param name='port'>/dev/ttyACM0</param><br/>    <param name='calib_file'>~/.calibrate/...</param>"]
       
       SimPlugin --> ControllerMgr["controller_manager<br/>(loads plugin at runtime)"]
       RealPlugin --> ControllerMgr
       
       ControllerMgr --> HWInterface["Hardware Interface API<br/>(read_state / write_command)"]

选择过程通过由 ``use_sim`` 参数驱动的 xacro 条件语句在 URDF 生成期间发生。然后 ``controller_manager`` 节点在运行时加载相应的插件。

**来源：** `README.md:121-149 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L121-L149>`__,
`src/robot_config/config/robots/so101_single_arm.yaml:104-121 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L104-L121>`__

--------------

SO101SystemHardware 插件
------------------------

真实硬件插件使用 Feetech 舵机 SDK 提供与物理 SO-101 机械臂的接口。

插件配置
~~~~~~~~

插件在 ``robot_config`` YAML 文件的 ``ros2_control`` 部分中配置：

.. code:: yaml

   ros2_control:
     hardware_plugin: so101_hardware/SO101SystemHardware
     port: /dev/ttyACM0
     calib_file: $(env HOME)/.calibrate/so101_follower_calibrate.json
     joint_names: ["1", "2", "3", "4", "5", "6"]
     reset_positions:
       "1": 0.0
       "2": 0.0
       "3": 0.0
       "4": 0.0
       "5": 0.0
     urdf_path: $(find robot_description)/urdf/lerobot/so101/so101.urdf.xacro

**配置参数：**


.. list-table::
   :header-rows: 1

   * - 参数
     - 类型
     - 描述
   * - ``hardware_plugin``
     - string
     - 完全限定的插件类名
   * - ``port``
     - string
     - 串口设备（例如 ``/dev/ttyACM0``）
   * - ``calib_file``
     - path
     - 包含舵机校准偏移的 JSON 文件
   * - ``joint_names``
     - list
     - 与 URDF 关节名称匹配的关节标识符
   * - ``reset_positions``
     - dict
     - 用于初始化的默认关节位置（弧度）
   * - ``urdf_path``
     - path
     - 包含 ``<ros2_control>`` 标签的 机器人描述文件

**来源：**
`src/robot_config/config/robots/so101_single_arm.yaml:104-118 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L104-L118>`__

硬件接口实现
~~~~~~~~~~~~

``SO101SystemHardware`` 插件必须实现标准的 ``ros2_control`` 硬件接口生命周期：

.. mermaid::

   stateDiagram-v2
       [*] --> Unconfigured
       
       Unconfigured --> Inactive: on_configure()<br/>(open serial port,<br/>load calibration)
       
       Inactive --> Active: on_activate()<br/>(enable servo torque,<br/>move to reset positions)
       
       Active --> Inactive: on_deactivate()<br/>(disable torque)
       
       Inactive --> Unconfigured: on_cleanup()<br/>(close serial port)
       
       Active --> Active: read()<br/>(query servo positions)<br/><br/>write()<br/>(send position commands)
       
       Unconfigured --> [*]
       Inactive --> [*]
       Active --> [*]: on_shutdown()

**关键方法：**

-  ``on_configure()``：打开串口，加载校准文件，初始化 Feetech SDK
-  ``on_activate()``：启用电机扭矩，将关节移动到重置位置
-  ``read()``：从舵机查询当前关节位置和速度（以控制频率调用）
-  ``write()``：向舵机发送命令位置（以控制频率调用）
-  ``on_deactivate()``：出于安全考虑禁用电机扭矩
-  ``on_cleanup()``：关闭串口并释放资源

**来源：** `README.md:23-41 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L23-L41>`__, `docs/architecture.md:254-265 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/docs/architecture.md#L254-L265>`__

--------------

Gazebo 仿真插件
--------------

对于仿真环境，IB-Robot 使用标准的 ``gz_ros2_control`` 插件，该插件与 Gazebo 的物理引擎交互。

仿真硬件配置
~~~~~~~~~~~~

当 ``use_sim:=true`` 时，URDF 生成过程会自动替换为仿真插件：

.. code:: xml

   <ros2_control name="GazeboSimSystem" type="system">
     <hardware>
       <plugin>gz_ros2_control/GazeboSimSystem</plugin>
     </hardware>
     <!-- Joint definitions identical to real hardware -->
   </ros2_control>

该插件提供：

-  **基于物理的状态反馈**：由 Gazebo 计算的关节位置、速度和力
-  **命令执行**：将命令位置应用于仿真关节
-  **相同的 API**：暴露与真实硬件相同的 ``read()``/``write()`` 接口

**仿真模式的优势：**


.. list-table::
   :header-rows: 1

   * - 方面
     - 优势
   * - **开发速度**
     - 算法开发期间无需访问物理硬件
   * - **安全性**
     - 测试危险轨迹而无硬件损坏风险
   * - **调试**
     - 在 RViz/Gazebo GUI 中通过视觉反馈 单步调试物理
   * - **可重复性**
     - 确定性物理用于回归测试

**来源：** `README.md:121-149 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L121-L149>`__, `README.en.md:76-93 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.en.md#L76-L93>`__

--------------

控制器配置
----------

控制器是高级命令和硬件接口之间的桥梁。IB-Robot 根据控制模式使用不同类型的控制器。

控制器类型
~~~~~~~~~~

.. mermaid::

   graph LR
       subgraph "State Broadcasting"
           JSB["joint_state_broadcaster<br/>(Always Active)"]
       end
       
       subgraph "Position Control (model_inference/teleop modes)"
           ArmPos["arm_position_controller<br/>Type: JointGroupPositionController"]
           GripPos["gripper_position_controller<br/>Type: ForwardCommandController"]
       end
       
       subgraph "Trajectory Control (moveit_planning mode)"
           ArmTraj["arm_trajectory_controller<br/>Type: JointTrajectoryController"]
           GripTraj["gripper_trajectory_controller<br/>Type: JointTrajectoryController"]
       end
       
       JSB -->|"/joint_states"| App["Application Nodes"]
       
       ArmPos -->|"read/write"| HW["Hardware Interface"]
       GripPos -->|"read/write"| HW
       ArmTraj -->|"read/write"| HW
       GripTraj -->|"read/write"| HW
       
       Teleop["robot_teleop"] -->|"Float64MultiArray"| ArmPos
       Inference["action_dispatcher"] -->|"Float64MultiArray"| ArmPos
       
       MoveIt["MoveItGateway"] -->|"FollowJointTrajectory<br/>(Action)"| ArmTraj

**控制器职责：**


.. list-table::
   :header-rows: 1

   * - 控制器
     - 类型
     - 输入
     - 输出
     - 用途
   * - ``joint_st ate_broadcaster``
     - 状态 发布器
     - 硬件 状态
     - ``/join t_states`` 话题
     - 为所有消费者 发布当前机器 人状态
   * - ``arm_posi tion_controller``
     - 位置 命令
     - ``/co mmands`` 话题
     - 硬件 写入
     - 高频位置流 （ACT、 遥操作）
   * - ``gripper_posi tion_controller``
     - 位置 命令
     - ``/co mmands`` 话题
     - 硬件 写入
     - 夹爪开合命令
   * - ``arm_trajec tory_controller``
     - 轨迹 执行
     - Action 目标
     - 硬件 写入
     - MoveIt 规划的 带时间参数化 的轨迹
   * - ``gripper_trajec tory_controller``
     - 轨迹 执行
     - Action 目标
     - 硬件 写入
     - 协调的夹爪 轨迹

**来源：**
`src/robot_config/config/robots/so101_single_arm.yaml:46-103 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L46-L103>`__,
`src/robot_config/README.md:88-243 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/README.md#L88-L243>`__

控制器配置文件
~~~~~~~~~~~~~~

控制器在由 ``robot_config`` 引用的单独 YAML 文件中定义：

.. code:: yaml

   # so101_controllers.yaml (referenced by robot_config)
   controller_manager:
     ros__parameters:
       update_rate: 100  # Hz
       
       joint_state_broadcaster:
         type: joint_state_broadcaster/JointStateBroadcaster
       
       arm_position_controller:
         type: position_controllers/JointGroupPositionController
       
       gripper_position_controller:
         type: forward_command_controller/ForwardCommandController
       
       arm_trajectory_controller:
         type: joint_trajectory_controller/JointTrajectoryController
       
       gripper_trajectory_controller:
         type: joint_trajectory_controller/JointTrajectoryController

   arm_position_controller:
     ros__parameters:
       joints:
         - "1"
         - "2"
         - "3"
         - "4"
         - "5"

   gripper_position_controller:
     ros__parameters:
       joints:
         - "6"

**来源：**
`src/robot_config/config/robots/so101_single_arm.yaml:119-122 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L119-L122>`__

--------------

robot_config 中的硬件配置
-------------------------

``robot_config`` YAML 作为所有硬件相关配置的唯一真实来源，消除了 URDF、启动文件和控制器配置之间的重复。

配置结构
~~~~~~~~

.. mermaid::

   graph TB
       RobotYAML["robot_config YAML<br/>(so101_single_arm.yaml)"]
       
       subgraph "Hardware Definition"
           ROS2Ctrl["ros2_control:<br/>- hardware_plugin<br/>- port<br/>- calib_file<br/>- joint_names<br/>- reset_positions"]
           
           ControllersRef["controllers_config:<br/>path to controllers.yaml"]
           
           URDFPath["urdf_path:<br/>path to URDF/xacro"]
       end
       
       subgraph "Joint Definition (DRY)"
           Joints["joints:<br/>  arm: [1, 2, 3, 4, 5]<br/>  gripper: [6]<br/>  all: [1, 2, 3, 4, 5, 6]"]
       end
       
       subgraph "Control Mode Mapping"
           Modes["control_modes:<br/>  teleop: [position_controllers]<br/>  model_inference: [position_controllers]<br/>  moveit_planning: [trajectory_controllers]"]
       end
       
       RobotYAML --> ROS2Ctrl
       RobotYAML --> ControllersRef
       RobotYAML --> URDFPath
       RobotYAML --> Joints
       RobotYAML --> Modes
       
       ROS2Ctrl --> URDFGen["URDF Generation<br/>(xacro with use_sim conditional)"]
       ControllersRef --> CtrlSpawn["Controller Spawning<br/>(based on control_mode)"]
       URDFPath --> URDFGen
       Joints --> URDFGen
       Joints --> CtrlSpawn
       Modes --> CtrlSpawn

**配置层次：**

1. **硬件插件选择**：``ros2_control.hardware_plugin`` + ``use_sim`` 参数
2. **关节定义**：单个 ``joints`` 部分传播到 URDF、控制器和合约
3. **控制器映射**：每个 ``control_mode`` 指定要激活的控制器
4. **外设集成**：摄像头和传感器在 ``peripherals`` 部分定义

**来源：**
`src/robot_config/config/robots/so101_single_arm.yaml:1-329 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L1-L329>`__,
`src/robot_config/README.md:40-86 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/README.md#L40-L86>`__

参数解析
~~~~~~~~

配置系统支持环境变量替换和 ROS 包路径解析：


.. list-table::
   :header-rows: 1

   * - 语法
     - 示例
     - 解析
   * - ``$(env VAR)``
     - ``$(env HOME)/.ca librate/file.json``
     - 展开为环境变量值
   * - ``$(find pkg)``
     - ``$(find robot_desc ription)/urdf/...``
     - 解析为 ROS 包安装路径

**实现：** `src/robot_config/robot_config/utils.py <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/utils.py>`__（未在文件中显示，但在加载器中引用）

**来源：**
`src/robot_config/config/robots/so101_single_arm.yaml:108-117 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L108-L117>`__,
`src/robot_config/robot_config/loader.py:20-21 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/loader.py#L20-L21>`__

--------------

在仿真和真实硬件之间切换
------------------------

``use_sim`` 参数提供了在仿真和物理硬件之间切换的一行命令，无需任何代码更改。

切换机制
~~~~~~~~

.. mermaid::

   graph TB
       LaunchCmd["ros2 launch robot_config robot.launch.py<br/>--use_sim true/false"]
       
       LaunchCmd --> ParamCheck{"use_sim<br/>parameter"}
       
       ParamCheck -->|"true"| SimPath["Simulation Path"]
       ParamCheck -->|"false"| RealPath["Real Hardware Path"]
       
       subgraph SimPath["Simulation Path"]
           SimGazebo["Launch Gazebo<br/>(gz_sim)"]
           SimURDF["Load URDF with<br/>gz_ros2_control plugin"]
           SimCtrl["Spawn Controllers<br/>(same as real hardware)"]
           
           SimGazebo --> SimURDF
           SimURDF --> SimCtrl
       end
       
       subgraph RealPath["Real Hardware Path"]
           RealURDF["Load URDF with<br/>SO101SystemHardware plugin"]
           RealInit["Initialize Serial Port<br/>(port: /dev/ttyACM0)"]
           RealCtrl["Spawn Controllers<br/>(same as simulation)"]
           
           RealURDF --> RealInit
           RealInit --> RealCtrl
       end
       
       SimCtrl --> Unified["Unified Interface<br/>(/joint_states, controller topics)"]
       RealCtrl --> Unified
       
       Unified --> App["Application Layer<br/>(inference_service, action_dispatch, etc.)"]

**启动命令示例：**

.. code:: bash

   # Simulation with AI inference
   ros2 launch robot_config robot.launch.py \
     robot_config:=so101_single_arm \
     use_sim:=true \
     control_mode:=model_inference

   # Real hardware with teleoperation
   ros2 launch robot_config robot.launch.py \
     robot_config:=so101_single_arm \
     use_sim:=false \
     control_mode:=teleop

   # Simulation with MoveIt planning
   ros2 launch robot_config robot.launch.py \
     robot_config:=so101_single_arm \
     use_sim:=true \
     control_mode:=moveit_planning

**切换时的变化：**


.. list-table::
   :header-rows: 1

   * - 方面
     - 仿真 (``use_sim:=true``)
     - 真实硬件 (``use_sim:=false``)
   * - **硬 件插 件**
     - ``gz_ros 2_control/GazeboSimSystem``
     - ``so101 _hardware/SO101SystemHardware``
   * - **状 态来 源**
     - Gazebo 物理引擎
     - 与 Feetech 舵机的串口通信
   * - **命 令执 行**
     - 仿真关节执行器
     - 物理电机控制器
   * - **延 迟**
     - ~1-2ms（进程内）
     - ~5-10ms（串口 + 舵机响应）
   * - **安 全性 **
     - 无物理风险
     - 需要关节限位、碰撞监控
   * - **额 外进 程**
     - Gazebo 仿真器 (``gz_sim``)
     - 无（直接硬件访问）

**保持不变的内容：**

-  控制器类型和参数
-  控制器话题名称（``/arm_position_controller/commands`` 等）
-  状态话题（``/joint_states``）
-  应用层代码（推理、动作分发、遥操作）
-  合约定义

**来源：** `README.md:121-168 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L121-L168>`__, `README.en.md:76-93 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.en.md#L76-L93>`__,
`README.en.md:126-154 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.en.md#L126-L154>`__

--------------

控制器生命周期管理
------------------

控制器由 ``controller_manager`` 节点管理，该节点处理生成、激活和切换。

控制器生成过程
~~~~~~~~~~~~~~

.. mermaid::

   sequenceDiagram
       participant Launch as robot.launch.py
       participant Manager as controller_manager
       participant Loader as spawner.py
       participant HW as Hardware Plugin
       
       Launch->>Manager: Start controller_manager node
       Manager->>HW: Load hardware plugin (on_configure)
       HW-->>Manager: Plugin loaded
       Manager->>HW: Activate hardware (on_activate)
       HW-->>Manager: Hardware active
       
       Launch->>Loader: Spawn controllers (per control_mode)
       
       loop For each controller
           Loader->>Manager: load_controller(name)
           Manager-->>Loader: Controller loaded
           Loader->>Manager: configure_controller(name)
           Manager-->>Loader: Controller configured
           Loader->>Manager: activate_controller(name)
           Manager-->>Loader: Controller active
       end
       
       Note over Manager,HW: Main control loop (100 Hz)
       loop Every 10ms
           Manager->>HW: read() - get joint states
           HW-->>Manager: Current positions/velocities
           Manager->>Manager: Controller update()
           Manager->>HW: write() - send commands
       end

**控制器激活规则：**

1. **始终激活**：``joint_state_broadcaster``（为所有模式发布状态）
2. **模式特定**：仅激活当前 ``control_mode`` 中列出的控制器
3. **互斥**：同一关节的位置控制器和轨迹控制器不能同时激活

**来源：**
`src/robot_config/config/robots/so101_single_arm.yaml:46-103 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L46-L103>`__,
`docs/architecture.md:209-228 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/docs/architecture.md#L209-L228>`__

运行时控制器切换
~~~~~~~~~~~~~~~~

虽然 IB-Robot 通常在启动时通过 ``control_mode`` 选择控制器，但 ``ros2_control`` 支持运行时切换：

.. code:: bash

   # List active controllers
   ros2 control list_controllers

   # Deactivate position controllers
   ros2 control set_controller_state arm_position_controller inactive
   ros2 control set_controller_state gripper_position_controller inactive

   # Activate trajectory controllers
   ros2 control set_controller_state arm_trajectory_controller active
   ros2 control set_controller_state gripper_trajectory_controller active

**运行时切换的用例：**

-  从遥操作过渡到 AI 控制而无需重启
-  通过停用所有控制器实现紧急停止
-  单独调试控制器行为

**来源：** `src/robot_config/README.md:305-338 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/README.md#L305-L338>`__,
`src/robot_config/README.en.md:366-404 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/README.en.md#L366-L404>`__

--------------

硬件集成故障排除
----------------

常见问题与解决方案
~~~~~~~~~~~~~~~~~~


.. list-table::
   :header-rows: 1

   * - 问题
     - 症状
     - 解决方案
   * - **串口权限**
     - ``Failed t o open /dev/ttyACM0``
     - ``sudo usermod -a -G dialout $USER`` （需要注销）
   * - **控制器无法 启动**
     - ``Failed to activate controller``
     - 检查 YAML 中的控制器 配置；验证关节名称 与 URDF 匹配
   * - **控制器冲突**
     - ``Resource conflict`` 错误
     - 确保每个关节只有一个 控制器处于活动状态； 检查 ``control_mode`` 配置
   * - **校准文件未 找到**
     - ``Calibra tion file not found`` 错误
     - 验证 ``calib_file`` 路径；确保文件存在 且可读
   * - **高延迟**
     - 真实硬件上运动 不流畅
     - 检查串口波特率；降低 控制频率；验证无 USB 集线器干扰
   * - **仿真无法启动**
     - Gazebo 无法启动
     - 确保 ``gz_sim`` 已 安装；检查 URDF 语法 错误

**调试命令：**

.. code:: bash

   # Check controller manager status
   ros2 control list_controllers

   # View controller manager logs
   ros2 run controller_manager spawner --help

   # Monitor joint states
   ros2 topic echo /joint_states

   # Test hardware interface directly
   ros2 control list_hardware_interfaces

   # Check URDF validity
   check_urdf $(ros2 pkg prefix robot_description)/share/robot_description/urdf/...

**来源：** `README.md:171-186 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L171-L186>`__,
`src/robot_config/README.md:471-516 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/README.md#L471-L516>`__

--------------

总结
----

IB-Robot 的硬件集成层提供：

1. **抽象**：``ros2_control`` 将控制逻辑与硬件细节解耦
2. **灵活性**：单个 ``use_sim`` 参数在仿真和真实硬件之间切换
3. **一致性**：相同的控制器、话题和应用代码在两种环境中工作
4. **安全性**：具有显式激活/停用阶段的生命周期管理
5. **可扩展性**：插件架构支持添加新的硬件后端

配置驱动的方法消除了 URDF、控制器配置和启动文件之间的手动同步，减少了错误并提高了可维护性。

**来源：** `README.md:1-192 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L1-L192>`__, `docs/architecture.md:1-313 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/docs/architecture.md#L1-L313>`__,
`src/robot_config/config/robots/so101_single_arm.yaml:1-329 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L1-L329>`__

--------------



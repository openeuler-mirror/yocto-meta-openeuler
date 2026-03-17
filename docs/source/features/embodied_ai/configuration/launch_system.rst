启动系统
========

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

启动系统是根据配置动态生成并启动机器人操作所需所有 ROS2 节点的编排层。它加载 robot_config YAML 文件并调用专门的构建器模块来创建感知、控制、执行和其他子系统的节点。系统支持多种控制模式，并根据运行时参数有条件地生成节点。

有关 robot_config YAML 结构本身的信息，请参阅 `机器人配置文件 <#5.1>`__。有关契约定义详情，请参阅 `契约定义 <#5.2>`__。有关外设配置，请参阅 `外设配置 <#5.3>`__。

--------------

架构概述
--------

启动系统遵循 **构建器模式**，其中中央编排器（`robot.launch.py:123-360 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/robot.launch.py#L123-L360>`__）加载配置并将节点生成委托给专门的构建器模块。每个构建器负责特定子系统（如相机、控制器、推理）并返回启动动作列表。

启动系统组件
~~~~~~~~~~~~

.. mermaid::

   graph TB
       subgraph "入口点"
           MAIN["robot.launch.py<br/>generate_launch_description()"]
           SETUP["launch_setup()<br/>OpaqueFunction"]
       end
       
       subgraph "配置加载"
           LOAD["load_robot_config()<br/>lines 87-120"]
           YAML["robot_config YAML<br/>so101_single_arm.yaml"]
           CONFIG["RobotConfig 对象<br/>来自 loader.py"]
       end
       
       subgraph "启动构建器"
           CONTROL["control.py<br/>generate_ros2_control_nodes()"]
           PERCEPTION["perception.py<br/>generate_camera_nodes()<br/>generate_tf_nodes()"]
           SIMULATION["simulation.py<br/>generate_gazebo_nodes()"]
           EXECUTION["execution.py<br/>generate_inference_node()<br/>generate_action_dispatcher_node()"]
           TELEOP["teleop.py<br/>generate_teleop_nodes()"]
           RECORDING["recording.py<br/>generate_recording_nodes()"]
       end
       
       subgraph "生成的节点"
           CTRL_NODES["ros2_control_node<br/>controller_spawner"]
           CAM_NODES["usb_cam/realsense_node<br/>static_transform_publisher"]
           SIM_NODES["gzserver<br/>gzclient<br/>spawn_entity"]
           EXEC_NODES["lerobot_policy_node<br/>action_dispatcher_node"]
           TELE_NODES["robot_teleop_node"]
           REC_NODES["episode_recorder<br/>或 ros2 bag record"]
       end
       
       MAIN --> SETUP
       SETUP --> LOAD
       LOAD --> YAML
       YAML --> CONFIG
       
       SETUP --> CONTROL
       SETUP --> PERCEPTION
       SETUP --> SIMULATION
       SETUP --> EXECUTION
       SETUP --> TELEOP
       SETUP --> RECORDING
       
       CONTROL --> CTRL_NODES
       PERCEPTION --> CAM_NODES
       SIMULATION --> SIM_NODES
       EXECUTION --> EXEC_NODES
       TELEOP --> TELE_NODES
       RECORDING --> REC_NODES

**源码：** `src/robot_config/launch/robot.launch.py:1-360 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/launch/robot.launch.py#L1-L360>`__,
`src/robot_config/robot_config/launch_builders/control.py <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/launch_builders/control.py>`__,
`src/robot_config/robot_config/launch_builders/perception.py <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/launch_builders/perception.py>`__,
`src/robot_config/robot_config/launch_builders/execution.py <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/launch_builders/execution.py>`__

--------------

主启动文件：robot.launch.py
---------------------------

主启动文件 `robot.launch.py <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/robot.launch.py>`__ 位于 ``src/robot_config/launch/robot.launch.py``，作为启动整个机器人系统的单一入口点。

启动参数
~~~~~~~~


.. list-table::
   :header-rows: 1

   * - 参数
     - 默认值
     - 描述
   * - ``robot_config``
     - ``test_cam``
     - 机器人配置名称 (从 ``co nfig/robots/<name>.yaml`` 加载)
   * - ``config_path``
     - ``''``
     - 配置文件的可选完整路径 (覆盖 ``robot_config``)
   * - ``use_sim``
     - ``false``
     - 启用仿真模式 (Gazebo)
   * - ``auto_ start_controllers``
     - ``true``
     - 自动启动控制器 (设为 false 用于调试)
   * - ``control_mode``
     - ``''``
     - 从 YAML 覆盖控制模式 (``teleop``、 ``model_inference``、 ``moveit_planning``)
   * - ``with_inference``
     - ``''``
     - 启用推理管道 (为空时自动检测)
   * - ``with_moveit``
     - ``''``
     - 启用 MoveIt 规划 (为空时自动检测)
   * - ``moveit_display``
     - ``true``
     - 为 MoveIt 启动 RViz (仅当 MoveIt 启用时)
   * - ``record``
     - ``false``
     - 启用 rosbag 录制
   * - ``record_mode``
     - ``continuous``
     - 录制模式： ``continuous`` 或 ``episodic``

**源码：** `src/robot_config/launch/robot.launch.py:51-62 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/launch/robot.launch.py#L51-L62>`__

启动流程
~~~~~~~~

.. mermaid::

   graph TB
       START["generate_launch_description()"]
       ARGS["声明启动参数<br/>robot_config, use_sim, control_mode 等"]
       OPAQUE["OpaqueFunction(launch_setup)"]
       
       SETUP_START["launch_setup(context)"]
       
       PARSE["解析启动参数<br/>lines 140-155"]
       NORMALIZE["规范化布尔值<br/>use_sim, auto_start_controllers"]
       
       LOAD["load_robot_config()<br/>lines 157-164"]
       PATH_INJECT["将 '_config_path' 注入 robot_config<br/>lines 167-174"]
       
       MODE_OVERRIDE["应用 control_mode 覆盖<br/>lines 177-181"]
       MODE_SELECT["选择活动控制模式<br/>line 180"]
       
       INFER_DETECT["确定 with_inference 标志<br/>lines 183-196"]
       
       BUILD_CONTROL["生成控制节点<br/>lines 199-206"]
       BUILD_SIM{"use_sim?<br/>lines 209-217"}
       BUILD_PERCEPTION["生成感知节点<br/>lines 220-240"]
       BUILD_TELEOP{"control_mode == 'teleop'?<br/>lines 243-262"}
       BUILD_EXECUTION{"with_inference?<br/>lines 265-275"}
       BUILD_MOVEIT{"with_moveit?<br/>lines 278-308"}
       BUILD_RECORDING{"record?<br/>lines 311-323"}
       
       RETURN["返回动作列表"]
       
       START --> ARGS
       ARGS --> OPAQUE
       OPAQUE --> SETUP_START
       
       SETUP_START --> PARSE
       PARSE --> NORMALIZE
       NORMALIZE --> LOAD
       LOAD --> PATH_INJECT
       
       PATH_INJECT --> MODE_OVERRIDE
       MODE_OVERRIDE --> MODE_SELECT
       MODE_SELECT --> INFER_DETECT
       
       INFER_DETECT --> BUILD_CONTROL
       BUILD_CONTROL --> BUILD_SIM
       
       BUILD_SIM -->|是| SIM_NODES["Gazebo 节点"]
       BUILD_SIM -->|否| BUILD_PERCEPTION
       SIM_NODES --> BUILD_PERCEPTION
       
       BUILD_PERCEPTION --> BUILD_TELEOP
       
       BUILD_TELEOP -->|是| TELEOP_NODES["遥控节点"]
       BUILD_TELEOP -->|否| BUILD_EXECUTION
       TELEOP_NODES --> BUILD_EXECUTION
       
       BUILD_EXECUTION -->|是| EXEC_NODES["推理 + 分发器"]
       BUILD_EXECUTION -->|否| BUILD_MOVEIT
       EXEC_NODES --> BUILD_MOVEIT
       
       BUILD_MOVEIT -->|是| MOVEIT_NODES["MoveIt 节点"]
       BUILD_MOVEIT -->|否| BUILD_RECORDING
       MOVEIT_NODES --> BUILD_RECORDING
       
       BUILD_RECORDING -->|是| RECORD_NODES["录制节点"]
       BUILD_RECORDING -->|否| RETURN
       RECORD_NODES --> RETURN

**源码：** `src/robot_config/launch/robot.launch.py:123-360 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/launch/robot.launch.py#L123-L360>`__

配置路径注入
~~~~~~~~~~~~

启动系统将 ``_config_path`` 键注入 robot_config 字典，使下游节点能够访问原始 YAML 文件：

.. code:: python

   # lines 167-174
   robot_config['_config_path'] = str(Path(robot_config_share) / "config" / "robots" / f"{robot_config_name}.yaml")

这对于以下组件至关重要：- **episode_recorder**：需要路径来加载契约（`episode_recorder.py:195-206 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/episode_recorder.py#L195-L206>`__）- **inference_service**：需要路径来加载观测规格（`lerobot_policy_node.py:158-159 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/lerobot_policy_node.py#L158-L159>`__）- **action_dispatcher**：需要路径来加载动作规格（`action_dispatcher_node.py:106-117 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/action_dispatcher_node.py#L106-L117>`__）

**源码：** `src/robot_config/launch/robot.launch.py:167-174 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/launch/robot.launch.py#L167-L174>`__

--------------

启动构建器
----------

启动构建器是为特定子系统生成节点的模块化函数。每个构建器位于 ``src/robot_config/robot_config/launch_builders/``。

构建器模块架构
~~~~~~~~~~~~~~

.. mermaid::

   graph LR
       subgraph "launch_builders/"
           CONTROL["control.py<br/>ros2_control + 控制器"]
           PERCEPTION["perception.py<br/>相机 + TF"]
           SIMULATION["simulation.py<br/>Gazebo"]
           EXECUTION["execution.py<br/>推理 + 分发"]
           TELEOP["teleop.py<br/>遥控操作"]
           RECORDING["recording.py<br/>数据录制"]
       end
       
       subgraph "输入"
           CONFIG["robot_config dict"]
           MODE["control_mode str"]
           SIM["use_sim bool"]
       end
       
       subgraph "输出"
           NODES["List[Node | ExecuteProcess]"]
       end
       
       CONFIG --> CONTROL
       CONFIG --> PERCEPTION
       CONFIG --> SIMULATION
       CONFIG --> EXECUTION
       CONFIG --> TELEOP
       CONFIG --> RECORDING
       
       MODE --> CONTROL
       MODE --> EXECUTION
       MODE --> TELEOP
       MODE --> RECORDING
       
       SIM --> CONTROL
       SIM --> PERCEPTION
       SIM --> SIMULATION
       SIM --> EXECUTION
       
       CONTROL --> NODES
       PERCEPTION --> NODES
       SIMULATION --> NODES
       EXECUTION --> NODES
       TELEOP --> NODES
       RECORDING --> NODES

**源码：** `src/robot_config/robot_config/launch_builders/ <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/launch_builders/>`__

控制构建器 (control.py)
~~~~~~~~~~~~~~~~~~~~~~~

生成 ros2_control 节点和控制器启动器。

**关键函数：** -
``generate_ros2_control_nodes(robot_config, use_sim, auto_start_controllers)``
- 主入口点 - 返回：``(nodes_list, spawners_dict)``，其中 spawners_dict 将控制器名称映射到启动器节点

**逻辑：** 1. 从 robot_config 确定活动控制模式 2. 从 ``control_modes[mode].controllers`` 提取控制器列表 3. 仿真模式：启动器等待 Gazebo 的 controller_manager 4. 硬件模式：先启动 ``ros2_control_node``，然后启动器 5. 使用 ``RegisterEventHandler(OnProcessExit)`` 进行顺序启动

**示例：**

.. code:: yaml

   control_modes:
     model_inference:
       controllers:
         - joint_state_broadcaster
         - arm_position_controller
         - gripper_position_controller

生成 3 个启动器节点来激活这些控制器。

**源码：**
`src/robot_config/robot_config/launch_builders/control.py <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/launch_builders/control.py>`__

感知构建器 (perception.py)
~~~~~~~~~~~~~~~~~~~~~~~~~~

生成相机驱动节点和静态 TF 发布器。

**关键函数：** - ``generate_camera_nodes(robot_config, use_sim)`` - 创建相机驱动节点 - ``generate_tf_nodes(robot_config)`` - 创建静态变换发布器 - ``generate_virtual_camera_relays(robot_config)`` - 为虚拟相机创建主题中继节点

**相机驱动：**


.. list-table::
   :header-rows: 1

   * - 驱动
     - ROS2 包
     - 配置字段
   * - ``opencv``
     - ``usb_cam``
     - ``index``、``width``、``height``、``fps``、 ``pixel_format``
   * - ``realsense``
     - ``realsense2_camera``
     - ``serial_number``、``width``、``height``、 ``fps``、``enable_depth``

**TF 发布：** 对于每个带有 ``transform`` 字段的相机，生成一个 ``static_transform_publisher`` 节点，发布相机坐标系相对于其父坐标系的变换。

**源码：**
`src/robot_config/robot_config/launch_builders/perception.py <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/launch_builders/perception.py>`__

执行构建器 (execution.py)
~~~~~~~~~~~~~~~~~~~~~~~~~

生成推理服务和动作分发器节点。

**关键函数：** -
``generate_inference_node(robot_config, control_mode, use_sim)`` - 路由到单体或分布式 -
``generate_monolithic_inference_node()`` - 单进程推理 -
``generate_distributed_inference_nodes()`` - 边缘 + 云端推理 -
``generate_action_dispatcher_node(robot_config, control_mode, use_sim)``
- 动作分发器

**执行模式：**

.. mermaid::

   graph TB
       INFER_CHECK{"inference.enabled?"}
       
       EXEC_MODE{"execution_mode"}
       
       MONO["generate_monolithic_inference_node()<br/>单个 lerobot_policy_node"]
       
       DIST["generate_distributed_inference_nodes()<br/>边缘: lerobot_policy_node<br/>云端: pure_inference_node"]
       
       DISPATCH["generate_action_dispatcher_node()<br/>action_dispatcher_node"]
       
       INFER_CHECK -->|否| NONE["None"]
       INFER_CHECK -->|是| EXEC_MODE
       
       EXEC_MODE -->|monolithic| MONO
       EXEC_MODE -->|distributed| DIST
       
       MONO --> DISPATCH
       DIST --> DISPATCH

**单体节点参数：**

.. code:: python

   {
       "checkpoint": model_config["path"],
       "robot_config_path": str(robot_config_path),
       "device": "auto",
       "execution_mode": "monolithic",
       "node_name": "act_inference_node"
   }

**分布式节点参数：** - **边缘节点：** 与单体相同但 ``execution_mode: "distributed"`` - **云端节点：**

.. code:: python

   {
       "policy_path": policy_path,
       "input_topic": "/preprocessed/batch",
       "output_topic": "/inference/action",
       "device": "auto"
   }

**源码：**
`src/robot_config/robot_config/launch_builders/execution.py:1-360 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/launch_builders/execution.py#L1-L360>`__

遥控构建器 (teleop.py)
~~~~~~~~~~~~~~~~~~~~~~

生成人工控制设备的遥控操作节点。

**条件激活：** 仅当 ``control_mode == 'teleop'`` 且 ``teleoperation.enabled == true`` 时生成节点。

**设备类型：** - ``leader_arm``：用于双边遥控操作的 SO-101 主臂 - ``gamepad``：Xbox/PlayStation 控制器 - ``vr``：VR 控制器输入 - ``imu``：基于 IMU 的控制

**源码：**
`src/robot_config/robot_config/launch_builders/teleop.py <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/launch_builders/teleop.py>`__

录制构建器 (recording.py)
~~~~~~~~~~~~~~~~~~~~~~~~~

生成数据录制节点。

**录制模式：**


.. list-table::
   :header-rows: 1

   * - 模式
     - 描述
     - 生成的节点
   * - ``con tinuous``
     - 传统 ros2 bag record (一体化文件)
     - ``ExecuteProcess (['ros2', 'bag', 'record'])``
   * - ``e pisodic``
     - 通过 Action Server 逐 episode 触发
     - ``Node('dataset_ tools', 'episode_recorder')``

**连续模式：**

.. code:: python

   # lines 58-99
   recording_action = ExecuteProcess(
       cmd=['ros2', 'bag', 'record', '-o', output_file] + topics,
       output='screen'
   )

从 robot_config 自动发现主题（关节、相机、控制器）。

**Episodic 模式：**

.. code:: python

   # lines 102-168
   episode_recorder_node = Node(
       package='dataset_tools',
       executable='episode_recorder',
       parameters=[
           {'robot_config_path': robot_config_path},
           {'bag_base_dir': bag_base_dir}
       ]
   )

需要在单独的终端中手动运行 ``ros2 run dataset_tools record_cli`` 来触发录制。

**源码：**
`src/robot_config/robot_config/launch_builders/recording.py:1-226 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/launch_builders/recording.py#L1-L226>`__

--------------

控制模式系统
------------

启动系统根据活动控制模式调整节点生成，控制模式决定机器人的操作行为。

控制模式确定
~~~~~~~~~~~~

.. mermaid::

   graph TD
       START["启动参数: control_mode"]
       
       CHECK_OVERRIDE{"control_mode != ''?"}
       
       USE_OVERRIDE["robot_config['default_control_mode'] = control_mode<br/>line 178"]
       
       USE_DEFAULT["active_control_mode = robot_config.get('default_control_mode', 'model_inference')<br/>line 180"]
       
       VALIDATE{"模式存在于<br/>control_modes?"}
       
       ERROR["抛出错误:<br/>无效控制模式"]
       
       PROCEED["继续使用 active_control_mode"]
       
       START --> CHECK_OVERRIDE
       
       CHECK_OVERRIDE -->|是| USE_OVERRIDE
       CHECK_OVERRIDE -->|否| USE_DEFAULT
       
       USE_OVERRIDE --> USE_DEFAULT
       
       USE_DEFAULT --> VALIDATE
       
       VALIDATE -->|否| ERROR
       VALIDATE -->|是| PROCEED

**源码：** `src/robot_config/launch/robot.launch.py:177-181 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/launch/robot.launch.py#L177-L181>`__

控制模式对节点生成的影响
~~~~~~~~~~~~~~~~~~~~~~~~

每个控制模式定义：1. **要启动的控制器** - 在 ``control_modes[mode].controllers`` 中列出 2. **推理启用** - ``control_modes[mode].inference.enabled`` 3. **执行器配置** - ``control_modes[mode].executor``

**示例模式：**

.. code:: yaml

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
     
     moveit_planning:
       controllers:
         - joint_state_broadcaster
         - arm_trajectory_controller
         - gripper_trajectory_controller
       inference:
         enabled: false
       executor:
         type: action
         mode: moveit_planning

**源码：**
`src/robot_config/config/robots/so101_single_arm.yaml:46-103 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L46-L103>`__

--------------

条件节点生成
------------

启动系统使用条件逻辑根据运行时标志生成适当的节点。

推理管道启用
~~~~~~~~~~~~

.. mermaid::

   graph TD
       WITH_INFERENCE_ARG["启动参数: with_inference"]
       
       CHECK_ARG{"with_inference != ''?"}
       
       USE_ARG["with_inference = parse_bool(with_inference_str)<br/>line 186"]
       
       AUTO_DETECT["with_inference = control_modes[mode].inference.enabled<br/>line 189"]
       
       TELEOP_CHECK{"control_mode == 'teleop'<br/>&& with_inference_str == ''?"}
       
       FORCE_FALSE["with_inference = False<br/>line 193"]
       
       GENERATE{"with_inference?"}
       
       GEN_INFERENCE["generate_inference_node()<br/>generate_action_dispatcher_node()"]
       
       SKIP["跳过推理节点"]
       
       WITH_INFERENCE_ARG --> CHECK_ARG
       
       CHECK_ARG -->|是| USE_ARG
       CHECK_ARG -->|否| AUTO_DETECT
       
       USE_ARG --> TELEOP_CHECK
       AUTO_DETECT --> TELEOP_CHECK
       
       TELEOP_CHECK -->|是| FORCE_FALSE
       TELEOP_CHECK -->|否| GENERATE
       
       FORCE_FALSE --> GENERATE
       
       GENERATE -->|True| GEN_INFERENCE
       GENERATE -->|False| SKIP

**逻辑：** 1. 如果显式设置 ``--with_inference``，使用该值 2. 否则，从 ``control_modes[mode].inference.enabled`` 自动检测 3. 在 teleop 模式下强制禁用（除非显式覆盖）

**源码：** `src/robot_config/launch/robot.launch.py:183-196 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/launch/robot.launch.py#L183-L196>`__

仿真与硬件模式
~~~~~~~~~~~~~~

.. mermaid::

   graph TD
       USE_SIM["启动参数: use_sim"]
       
       PARSE["parse_bool(use_sim_str, default=False)"]
       
       SIM_CHECK{"use_sim == True?"}
       
       SIM_PATH["仿真路径"]
       HW_PATH["硬件路径"]
       
       SIM_GAZEBO["生成 Gazebo 节点<br/>gzserver, gzclient, spawn_entity"]
       SIM_CTRL["控制器等待 Gazebo 的<br/>controller_manager"]
       SIM_CAM["跳过物理相机驱动<br/>使用 Gazebo 相机插件"]
       
       HW_CTRL["启动 ros2_control_node<br/>然后启动控制器"]
       HW_CAM["生成相机驱动节点<br/>usb_cam, realsense2_camera"]
       HW_HARDWARE["加载 so101_hardware 插件"]
       
       USE_SIM --> PARSE
       PARSE --> SIM_CHECK
       
       SIM_CHECK -->|是| SIM_PATH
       SIM_CHECK -->|否| HW_PATH
       
       SIM_PATH --> SIM_GAZEBO
       SIM_GAZEBO --> SIM_CTRL
       SIM_CTRL --> SIM_CAM
       
       HW_PATH --> HW_CTRL
       HW_CTRL --> HW_CAM
       HW_CAM --> HW_HARDWARE

**源码：** `src/robot_config/launch/robot.launch.py:142-217 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/launch/robot.launch.py#L142-L217>`__

--------------

启动示例
--------

示例 1：带模型推理的仿真
~~~~~~~~~~~~~~~~~~~~~~~~

.. code:: bash

   ros2 launch robot_config robot.launch.py \
     robot_config:=so101_single_arm \
     use_sim:=true \
     control_mode:=model_inference

**生成的节点：** 1. Gazebo 服务器/客户端 2. spawn_entity（URDF 机器人） 3. joint_state_broadcaster 4. arm_position_controller 5. gripper_position_controller 6. Gazebo 相机插件 7. static_transform_publisher（用于相机） 8. lerobot_policy_node 9. action_dispatcher_node

**源码：** `src/robot_config/launch/robot.launch.py:22-26 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/launch/robot.launch.py#L22-L26>`__

示例 2：带遥控和录制的真实硬件
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code:: bash

   ros2 launch robot_config robot.launch.py \
     robot_config:=so101_single_arm \
     control_mode:=teleop \
     record:=true \
     record_mode:=episodic

**生成的节点：** 1. ros2_control_node (so101_hardware) 2. joint_state_broadcaster 3. arm_position_controller 4. gripper_position_controller 5. usb_cam 节点（顶部、腕部相机） 6. realsense_node（前置相机） 7. static_transform_publisher（相机坐标系） 8. robot_teleop_node 9. episode_recorder（后台服务）

**需要手动步骤：**

.. code:: bash

   # 在单独终端中
   ros2 run dataset_tools record_cli

**源码：** `src/robot_config/launch/robot.launch.py:28-32 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/launch/robot.launch.py#L28-L32>`__,
`src/robot_config/robot_config/launch_builders/recording.py:102-168 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/launch_builders/recording.py#L102-L168>`__

示例 3：MoveIt 规划模式
~~~~~~~~~~~~~~~~~~~~~~~

.. code:: bash

   ros2 launch robot_config robot.launch.py \
     robot_config:=so101_single_arm \
     control_mode:=moveit_planning \
     use_sim:=true \
     moveit_display:=true

**生成的节点：** 1. Gazebo 服务器/客户端 2. spawn_entity 3. joint_state_broadcaster 4. arm_trajectory_controller 5. gripper_trajectory_controller 6. move_group (MoveIt) 7. moveit_gateway_node 8. rviz2（带 MoveIt 配置）

**源码：** `src/robot_config/launch/robot.launch.py:34-38 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/launch/robot.launch.py#L34-L38>`__

--------------

参数传播
--------

启动系统通过多种机制将配置参数传播到下游节点：

1. ROS 参数（节点特定）
~~~~~~~~~~~~~~~~~~~~~~~

.. code:: python

   # 示例: action_dispatcher_node
   parameters=[{
       "robot_config_path": str(robot_config_path),
       "control_frequency": 100.0,
       "queue_size": 100,
       "watermark_threshold": 20
   }]

**源码：**
`src/robot_config/robot_config/launch_builders/execution.py:270-305 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/launch_builders/execution.py#L270-L305>`__

2. 环境变量
~~~~~~~~~~~

.. code:: python

   # 为 LeRobot 环境注入 PYTHONPATH
   env = prepare_lerobot_env()
   # env['PYTHONPATH'] = '/path/to/lerobot:...'

   Node(
       package='inference_service',
       executable='lerobot_policy_node',
       env=env,  # LeRobot 环境
       parameters=[...]
   )

**源码：**
`src/robot_config/robot_config/launch_builders/execution.py:99-123 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/launch_builders/execution.py#L99-L123>`__

3. 直接文件路径
~~~~~~~~~~~~~~~

.. code:: python

   # 传递 robot_config_path 用于契约加载
   robot_config_path = robot_config.get('_config_path', '')
   parameters=[{'robot_config_path': robot_config_path}]

节点直接从 YAML 加载契约：

.. code:: python

   # 在 episode_recorder.py 中
   from robot_config.loader import load_robot_config
   robot_config = load_robot_config(robot_config_path)
   contract = robot_config.to_contract()

**源码：**
`src/dataset_tools/dataset_tools/episode_recorder.py:194-206 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/dataset_tools/episode_recorder.py#L194-L206>`__,
`src/inference_service/inference_service/lerobot_policy_node.py:158-159 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/lerobot_policy_node.py#L158-L159>`__

--------------

调试启动问题
------------

启用调试输出
~~~~~~~~~~~~

.. code:: bash

   ros2 launch robot_config robot.launch.py \
     robot_config:=so101_single_arm \
     use_sim:=true \
     --log-level debug

禁用自动启动以便手动检查
~~~~~~~~~~~~~~~~~~~~~~~~

.. code:: bash

   ros2 launch robot_config robot.launch.py \
     robot_config:=so101_single_arm \
     auto_start_controllers:=false

这会启动 ros2_control_node 但不启动控制器。手动启动它们进行调试：

.. code:: bash

   ros2 control load_controller joint_state_broadcaster
   ros2 control set_controller_state joint_state_broadcaster active

常见问题
~~~~~~~~


.. list-table::
   :header-rows: 1

   * - 问题
     - 原因
     - 解决方案
   * - "Controller already loaded"
     - 之前的 ros2_control_node 仍在运行
     - 运行 ``p kill -9 ros2_control_node`` 或 ``./scripts/cleanup_ros.sh``
   * - "Config file not found"
     - 无效的 ``robot_config`` 名称
     - 检查 ``config/robots/`` 目录中的可用配置
   * - "Invalid control mode"
     - ``control_mode`` 不在 YAML 中
     - 验证 robot_config YAML 中的 ``control_modes`` 部分
   * - 推理节点失败
     - 缺少模型 检查点
     - 验证 robot_config 中 ``models[name].path`` 存在
   * - 相机无法打开
     - 权限被拒绝
     - 运行 ``sudo chmod 666 /dev/video*`` 或将用户添加到 ``video`` 组

**源码：** `src/robot_config/launch/robot.launch.py:46-49 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/launch/robot.launch.py#L46-L49>`__,
`src/robot_config/README.en.md:510-516 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/README.en.md#L510-L516>`__

--------------

总结
----

启动系统提供 **配置驱动、模块化的编排层** 用于机器人启动：

1. **单一入口点：** ``robot.launch.py`` 加载配置并编排所有构建器
2. **构建器模式：** 每个子系统有专门的构建器模块
3. **条件生成：** 节点根据控制模式、use_sim 和功能标志生成
4. **参数传播：** 配置通过 ROS 参数、环境变量和文件路径流向节点
5. **模式灵活性：** 支持具有不同控制器/执行器配置的 teleop、model_inference 和 moveit_planning

**关键文件：** - `src/robot_config/launch/robot.launch.py <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/launch/robot.launch.py>`__ - 主编排器 - `src/robot_config/robot_config/launch_builders/ <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/launch_builders/>`__ - 构建器模块 - `src/robot_config/config/robots/so101_single_arm.yaml <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml>`__ - 配置源

**源码：** `src/robot_config/launch/robot.launch.py:1-360 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/launch/robot.launch.py#L1-L360>`__,
`src/robot_config/robot_config/launch_builders/ <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/launch_builders/>`__

--------------

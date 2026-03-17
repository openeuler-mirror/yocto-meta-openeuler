话题与动作执行器
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

**目的**：本文档介绍 ``action_dispatch`` 包中的执行器层，它将抽象的动作张量转换为具体的 ROS 2 控制命令。两种执行器类型——``TopicExecutor`` 和 ``ActionExecutor``——提供不同的机器人硬件控制机制，各自针对特定的控制范式进行了优化。

**范围**：本文档涵盖执行器架构、实现细节、消息路由以及与动作分发器控制循环的集成。有关整体分发架构，请参阅 `动作分发器节点 <#8.1>`__。有关动作队列管理和平滑，请参阅 `时间平滑 <#8.2>`__。

--------------

执行器架构概述
--------------

执行器层位于动作分发器的控制循环和 ROS 2 控制系统之间，提供了一个将动作生成与硬件通信协议隔离的抽象。

执行器职责图
~~~~~~~~~~~~

.. mermaid::

   graph TB
       subgraph "Action Dispatcher Control Loop"
           Queue["Action Queue / TemporalSmoother"]
           ControlLoop["100 Hz Control Timer"]
           
           Queue -->|"pop action (Nx7 array)"| ControlLoop
       end
       
       subgraph "Executor Layer"
           Executor["TopicExecutor / ActionExecutor"]
           Router["Contract-Driven Router"]
           
           ControlLoop -->|"execute(action)"| Executor
           Executor --> Router
       end
       
       subgraph "ROS 2 Control Interface"
           TopicPub["Topic Publishers"]
           ActionClient["Action Clients"]
           
           Router -->|"TopicExecutor"| TopicPub
           Router -->|"ActionExecutor"| ActionClient
           
           TopicPub -->|"Float64MultiArray"| JointCmd["/joint_commands"]
           TopicPub -->|"Float64MultiArray"| ArmCmd["/arm_position_controller/commands"]
           ActionClient -->|"FollowJointTrajectory"| TrajAction["/arm_controller/follow_joint_trajectory"]
       end
       
       subgraph "ros2_control Layer"
           Controllers["Position Controllers / Trajectory Controllers"]
           
           JointCmd --> Controllers
           ArmCmd --> Controllers
           TrajAction --> Controllers
       end
       
       Controllers --> Hardware["Hardware Interface"]

**来源**：`src/action_dispatch/README.en.md:1-447 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/README.en.md#L1-L447>`__,
`src/action_dispatch/action_dispatch/action_dispatcher_node.py:1-319 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatch/action_dispatcher_node.py#L1-L319>`__

--------------

TopicExecutor：高频位置控制
---------------------------

``TopicExecutor`` 通过以高频率（通常为 100 Hz）向 ROS 2 话题发布单个动作向量来实现流式位置控制。这是输出动作块的端到端策略模型（ACT、Diffusion Policy）的默认执行器。

设计原则
~~~~~~~~

===================== ==========================================
方面                  实现
===================== ==========================================
**控制频率**          100 Hz（通过分发器可配置）
**消息类型**          ``std_msgs/Float64MultiArray``
**延迟**              最小（单话题发布）
**用例**              端到端策略推理、遥操作
**安全性**            队列为空时保持最后动作
===================== ==========================================

消息路由策略
~~~~~~~~~~~~

执行器使用 ``Contract`` 系统将动作张量维度映射到特定的控制器话题：

.. mermaid::

   graph LR
       ActionTensor["Action Tensor<br/>(N, 7)"]
       Specs["ActionSpec List<br/>from Contract"]
       
       ActionTensor --> Router["Topic Router"]
       Specs --> Router
       
       Router -->|"indices [0:6]"| ArmPub["Publisher: /arm_position_controller/commands"]
       Router -->|"index [6]"| GripperPub["Publisher: /gripper_position_controller/commands"]
       
       ArmPub --> ArmCtrl["arm_position_controller"]
       GripperPub --> GripperCtrl["gripper_position_controller"]

**来源**：
`src/action_dispatch/action_dispatch/action_dispatcher_node.py:118-122 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatch/action_dispatcher_node.py#L118-L122>`__,
`src/robot_config/robot_config/contract_utils.py:60-70 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/contract_utils.py#L60-L70>`__

初始化与设置
~~~~~~~~~~~~

``TopicExecutor`` 在动作分发器节点中创建和初始化：

`src/action_dispatch/action_dispatch/action_dispatcher_node.py:118-122 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatch/action_dispatcher_node.py#L118-L122>`__

.. code:: python

   # 5. Executor (Topic-based)
   self._executor = TopicExecutor(self, {'action_specs': self._action_specs})
   if not self._executor.initialize():
       raise RuntimeError("Failed to initialize TopicExecutor")

执行器从契约接收 ``action_specs``，定义：
- 每个动作维度组的话题名称 - 消息类型（通常为 ``Float64MultiArray``）- 可靠传递的 QoS 配置文件 - 关节名称映射

**来源**：
`src/action_dispatch/action_dispatch/action_dispatcher_node.py:106-122 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatch/action_dispatcher_node.py#L106-L122>`__

执行流程
~~~~~~~~

在每次控制循环迭代（100 Hz）时，分发器调用 ``executor.execute(action)``：

`src/action_dispatch/action_dispatch/action_dispatcher_node.py:195-201 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatch/action_dispatcher_node.py#L195-L201>`__

.. code:: python

   # B. Get Action
   action = None
   if q_size > 0:
       if self._smoother is not None:
           action_tensor = self._smoother.get_next_action()
           if isinstance(action_tensor, torch.Tensor):
               action = action_tensor.detach().cpu().numpy()
           else:
               action = action_tensor
       else:
           action = self._queue.popleft()
       self._last_action = action
   elif self._last_action is not None:
       # Hold last action if queue empty
       action = self._last_action

   # C. Execute
   if action is not None:
       self._executor.execute(action)

执行器根据契约规范拆分动作数组并发布到相应的话题。

**来源**：
`src/action_dispatch/action_dispatch/action_dispatcher_node.py:172-201 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatch/action_dispatcher_node.py#L172-L201>`__

契约驱动的话题映射
~~~~~~~~~~~~~~~~~~

契约中的动作规范定义动作张量维度如何映射到控制器话题：

.. code:: yaml

   # Example contract action specifications
   actions:
     - key: "action"
       publish_topic: "/arm_position_controller/commands"
       type: "std_msgs/Float64MultiArray"
       selector:
         names: ["joint1", "joint2", "joint3", "joint4", "joint5", "joint6"]
       publish_qos:
         reliability: "reliable"
         depth: 10
     
     - key: "action"
       publish_topic: "/gripper_position_controller/commands"
       type: "std_msgs/Float64MultiArray"
       selector:
         names: ["gripper_joint"]
       publish_qos:
         reliability: "reliable"
         depth: 10

``selector.names`` 字段定义动作张量的哪些索引路由到每个话题。

**来源**：
`src/robot_config/robot_config/contract_utils.py:60-70 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/contract_utils.py#L60-L70>`__,
`src/robot_config/config/robots/so101_single_arm.yaml:1-300 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L1-L300>`__

--------------

ActionExecutor：轨迹控制
------------------------

``ActionExecutor`` 通过向 ROS 2 动作服务器发送完整的运动计划来实现基于轨迹的控制。当与 MoveIt 集成或需要轨迹控制器时使用此执行器。

.. _design-principles-1:

设计原则
~~~~~~~~

===================== ======================================
方面                  实现
===================== ======================================
**控制频率**          可变（取决于轨迹）
**消息类型**          ``control_msgs/FollowJointTrajectory``
**延迟**              较高（动作服务器往返）
**用例**              MoveIt 规划、轨迹跟踪
**安全性**            内置轨迹验证
===================== ======================================

轨迹构建
~~~~~~~~

与发送单个位置的 ``TopicExecutor`` 不同，``ActionExecutor`` 构建完整的轨迹消息：

.. mermaid::

   graph TB
       ActionQueue["Action Queue<br/>(N x 7 positions)"]
       TrajBuilder["Trajectory Builder"]
       
       ActionQueue --> TrajBuilder
       
       TrajBuilder --> Points["Trajectory Points"]
       TrajBuilder --> TimeStamps["Time from Start"]
       TrajBuilder --> JointNames["Joint Names"]
       
       Points --> TrajMsg["FollowJointTrajectory.action<br/>Goal Message"]
       TimeStamps --> TrajMsg
       JointNames --> TrajMsg
       
       TrajMsg --> ActionClient["Action Client"]
       ActionClient -->|"send_goal_async"| Server["/arm_controller/follow_joint_trajectory"]

**来源**：`src/action_dispatch/README.en.md:1-447 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/README.en.md#L1-L447>`__,
`src/robot_moveit/scripts/moveit_gateway.py:1-300 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/scripts/moveit_gateway.py#L1-L300>`__

与 MoveIt 集成
~~~~~~~~~~~~~~

当控制模式为 ``moveit_planning`` 时，系统使用 ``ActionExecutor`` 执行规划的轨迹：

.. mermaid::

   graph LR
       PoseCmd["Pose Command<br/>/cmd_pose"]
       Gateway["MoveItGateway"]
       Planner["MoveIt2 Core<br/>OMPL/Pilz"]
       
       PoseCmd --> Gateway
       Gateway -->|"IK solve"| Planner
       Planner -->|"JointTrajectory"| Executor["ActionExecutor"]
       
       Executor -->|"FollowJointTrajectory<br/>action"| TrajController["trajectory_controller"]
       TrajController --> Hardware["ros2_control"]

**来源**：`src/robot_moveit/scripts/moveit_gateway.py:1-300 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/scripts/moveit_gateway.py#L1-L300>`__,
`README.md:134-143 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L134-L143>`__

动作服务器通信
~~~~~~~~~~~~~~

执行器使用 ROS 2 动作协议进行异步轨迹执行：

.. code:: python

   # Pseudo-code for ActionExecutor operation
   class ActionExecutor:
       def execute(self, action_chunk):
           # Build trajectory from action chunk
           trajectory = self._build_trajectory(action_chunk)
           
           # Send goal to action server
           goal = FollowJointTrajectory.Goal()
           goal.trajectory = trajectory
           
           # Async send (non-blocking)
           future = self._action_client.send_goal_async(goal)
           future.add_done_callback(self._goal_response_callback)

这允许分发器在轨迹执行期间继续运行，而不像 ``TopicExecutor`` 需要持续供给。

**来源**：`src/action_dispatch/README.en.md:66-78 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/README.en.md#L66-L78>`__,
`src/robot_moveit/scripts/moveit_gateway.py:1-300 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/scripts/moveit_gateway.py#L1-L300>`__

--------------

执行器选择与控制模式
--------------------

``TopicExecutor`` 和 ``ActionExecutor`` 之间的选择由控制模式配置决定：

控制模式到执行器的映射
~~~~~~~~~~~~~~~~~~~~~~


.. list-table::
   :header-rows: 1

   * - 控制模式
     - 执行器类型
     - 原因
   * - ``model_inference``
     - ``TopicExecutor``
     - 端到端策略输出 高频位置命令
   * - ``teleop``
     - ``TopicExecutor``
     - 实时人工控制需要 最小延迟
   * - ``moveit_planning``
     - ``ActionExecutor``
     - MoveIt 生成完整 轨迹

配置示例
~~~~~~~~

来自 ``robot_config`` YAML：

.. code:: yaml

   control_modes:
     model_inference:
       inference:
         enabled: true
         model: "act_policy"
       executor:
         type: "topic"  # Uses TopicExecutor
         frequency: 100.0
       controllers:
         - "arm_position_controller"
         - "gripper_position_controller"
     
     moveit_planning:
       executor:
         type: "action"  # Uses ActionExecutor
       controllers:
         - "arm_trajectory_controller"

**来源**：
`src/robot_config/config/robots/so101_single_arm.yaml:1-300 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L1-L300>`__,
`src/robot_config/launch/robot.launch.py:1-300 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/launch/robot.launch.py#L1-L300>`__

运行时选择逻辑
~~~~~~~~~~~~~~

执行器根据活动控制模式实例化：

.. mermaid::

   graph TB
       LaunchFile["robot.launch.py"]
       ControlMode["control_mode parameter"]
       
       LaunchFile --> ControlMode
       
       ControlMode -->|"model_inference"| TopicPath["TopicExecutor Path"]
       ControlMode -->|"teleop"| TopicPath
       ControlMode -->|"moveit_planning"| ActionPath["ActionExecutor Path"]
       
       TopicPath --> CreateTopic["Create TopicExecutor<br/>with action_specs"]
       ActionPath --> CreateAction["Create ActionExecutor<br/>with trajectory config"]
       
       CreateTopic --> Dispatcher["ActionDispatcherNode"]
       CreateAction --> Dispatcher

**来源**：`src/robot_config/launch/robot.launch.py:176-196 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/launch/robot.launch.py#L176-L196>`__,
`src/action_dispatch/action_dispatch/action_dispatcher_node.py:118-122 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatch/action_dispatcher_node.py#L118-L122>`__

--------------

消息类型详情
------------

Float64MultiArray 结构
~~~~~~~~~~~~~~~~~~~~~~

由 ``TopicExecutor`` 用于位置命令：

.. code:: python

   # std_msgs/Float64MultiArray message structure
   {
       "layout": {
           "dim": [
               {"label": "joints", "size": 6, "stride": 6}
           ],
           "data_offset": 0
       },
       "data": [0.0, -1.57, 1.57, 0.0, 1.57, 0.0]  # Joint positions
   }

执行器从原始动作数组构建这些消息，按动作规范定义进行拆分。

**来源**：`src/action_dispatch/README.en.md:370-378 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/README.en.md#L370-L378>`__

FollowJointTrajectory 结构
~~~~~~~~~~~~~~~~~~~~~~~~~~

由 ``ActionExecutor`` 用于轨迹命令：

.. code:: python

   # control_msgs/action/FollowJointTrajectory.action
   Goal:
     trajectory:
       joint_names: ["joint1", "joint2", ..., "joint6"]
       points:
         - positions: [0.0, -1.57, 1.57, 0.0, 1.57, 0.0]
           velocities: [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
           time_from_start: {sec: 0, nanosec: 100000000}
         - positions: [0.1, -1.5, 1.6, 0.0, 1.5, 0.0]
           time_from_start: {sec: 0, nanosec: 200000000}
         # ... additional points
     path_tolerance: [...]
     goal_tolerance: [...]
     goal_time_tolerance: {sec: 1, nanosec: 0}

**来源**：`src/action_dispatch/README.en.md:370-378 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/README.en.md#L370-L378>`__

--------------

契约驱动的动作路由
------------------

契约系统确保从训练到部署的动作路由一致：

契约加载与动作规范提取
~~~~~~~~~~~~~~~~~~~~~~

`src/action_dispatch/action_dispatch/action_dispatcher_node.py:106-117 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatch/action_dispatcher_node.py#L106-L117>`__

.. code:: python

   # 4. Load Contract (Essential for TopicExecutor mapping)
   robot_config_path = self.get_parameter('robot_config_path').value
   self._action_specs = []
   if robot_config_path:
       try:
           from robot_config.loader import load_robot_config
           self._contract = load_robot_config(robot_config_path).to_contract()
           self._action_specs = [s for s in iter_specs(self._contract) if s.is_action]
           self.get_logger().info(f"Loaded {len(self._action_specs)} action specs from robot_config")
       except Exception as e:
           self.get_logger().error(f"Failed to load contract from {robot_config_path}: {e}")

动作规范处理
~~~~~~~~~~~~

执行器遍历动作规范以创建发布者：

.. code:: python

   # Pseudo-code for TopicExecutor initialization
   class TopicExecutor:
       def initialize(self):
           for spec in self.action_specs:
               # Create publisher for each action spec
               pub = self.node.create_publisher(
                   msg_type=get_message(spec.type),
                   topic=spec.publish_topic,
                   qos=qos_profile_from_dict(spec.publish_qos)
               )
               
               # Store mapping: action indices -> publisher
               self.publishers[spec.key] = {
                   'publisher': pub,
                   'indices': self._extract_indices(spec.selector),
                   'joint_names': spec.selector.get('names', [])
               }

**来源**：
`src/robot_config/robot_config/contract_utils.py:60-70 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/contract_utils.py#L60-L70>`__,
`src/action_dispatch/action_dispatch/action_dispatcher_node.py:106-117 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatch/action_dispatcher_node.py#L106-L117>`__

--------------

性能特征
--------

TopicExecutor 性能概况
~~~~~~~~~~~~~~~~~~~~~~


.. list-table::
   :header-rows: 1

   * - 指标
     - 值
     - 备注
   * - 发布延迟
     - < 1 ms
     - 单话题发布操作
   * - 控制频率
     - 100 Hz
     - 可配置，通常匹配 策略输出频率
   * - CPU 开销
     - 低
     - 简单的数组切片和 消息构建
   * - 网络带宽
     - ~5 KB/s
     - 7-DOF 机械臂在 100 Hz

ActionExecutor 性能概况
~~~~~~~~~~~~~~~~~~~~~~~


.. list-table::
   :header-rows: 1

   * - 指标
     - 值
     - 备注
   * - 轨迹发送延迟
     - 5-10 ms
     - 动作服务器往返
   * - 执行延迟
     - 可变
     - 取决于轨迹长度和控制器
   * - CPU 开销
     - 中等
     - 轨迹构建和验证
   * - 网络带宽
     - 可变
     - 取决于轨迹点数

**来源**：`src/action_dispatch/README.en.md:174-185 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/README.en.md#L174-L185>`__,
`README.md:1-192 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L1-L192>`__

--------------

安全与错误处理
--------------

TopicExecutor 安全机制
~~~~~~~~~~~~~~~~~~~~~~

1. **最后动作保持**：当动作队列为空时，执行器保持最后一个有效动作以防止突然停止：

`src/action_dispatch/action_dispatch/action_dispatcher_node.py:195-201 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatch/action_dispatcher_node.py#L195-L201>`__

2. **零动作回退**：如果从未收到动作，执行器发布零值（可通过动作规范中的 ``safety_behavior`` 配置）。

3. **QoS 可靠性**：可靠的 QoS 确保即使网络压力下也能传递命令。

ActionExecutor 安全机制
~~~~~~~~~~~~~~~~~~~~~~~

1. **轨迹验证**：动作服务器在执行前验证轨迹（关节限制、速度限制）。

2. **抢占支持**：新轨迹可以抢占正在执行的轨迹以实现响应式控制。

3. **目标容差**：可配置的容差防止在不可达目标上无限等待。

**来源**：
`src/robot_config/robot_config/contract_utils.py:60-70 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/contract_utils.py#L60-L70>`__,
`src/action_dispatch/action_dispatch/action_dispatcher_node.py:195-201 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatch/action_dispatcher_node.py#L195-L201>`__

--------------

与动作分发器的集成
------------------

控制循环上下文中的执行器
~~~~~~~~~~~~~~~~~~~~~~~~

.. mermaid::

   graph TB
       subgraph "ActionDispatcherNode Control Loop (100 Hz)"
           Timer["ROS Timer Callback"]
           QueueCheck["Check Queue Length"]
           TriggerInference["Trigger Inference<br/>(if < watermark)"]
           PopAction["Pop Next Action"]
           Execute["executor.execute(action)"]
           
           Timer --> QueueCheck
           QueueCheck -->|"< watermark"| TriggerInference
           QueueCheck --> PopAction
           PopAction --> Execute
       end
       
       subgraph "Executor Layer"
           TopicExec["TopicExecutor"]
           ActionExec["ActionExecutor"]
           
           Execute --> TopicExec
           Execute --> ActionExec
       end
       
       subgraph "Async Inference"
           InferenceService["lerobot_policy_node"]
           ActionServer["DispatchInfer Action"]
           
           TriggerInference -->|"send_goal_async"| ActionServer
           ActionServer --> InferenceService
           InferenceService -->|"Result: action chunk"| Callback["_result_cb"]
       end
       
       Callback -->|"Update queue/smoother"| QueueCheck
       
       TopicExec --> ROS2Control["ros2_control"]
       ActionExec --> ROS2Control

**来源**：
`src/action_dispatch/action_dispatch/action_dispatcher_node.py:171-201 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatch/action_dispatcher_node.py#L171-L201>`__,
`src/action_dispatch/README.en.md:81-129 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/README.en.md#L81-L129>`__

--------------

总结
----

执行器层为机器人控制提供了契约驱动的抽象，支持两种互补的范式：

-  **TopicExecutor**：针对端到端策略的高频位置控制进行了优化，具有最小延迟和简单的基于话题的通信。
-  **ActionExecutor**：为运动规划器的基于轨迹的控制而设计，具有内置验证和异步执行。

两种执行器都与动作分发器的控制循环无缝集成，使用驱动数据收集和训练的相同契约规范，确保 IB-Robot 流水线中的端到端一致性。

**来源**：`src/action_dispatch/README.en.md:1-447 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/README.en.md#L1-L447>`__,
`src/action_dispatch/action_dispatch/action_dispatcher_node.py:1-319 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatch/action_dispatcher_node.py#L1-L319>`__,
`README.md:1-192 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L1-L192>`__

--------------

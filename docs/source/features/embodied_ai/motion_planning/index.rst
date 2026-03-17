运动规划 (MoveIt)
================

.. toctree::
   :titlesonly:
   :hidden:

   moveitgateway_node
   dof_kinematic_constraints
   moveit_launch_configuration

.. raw:: html

   <details>

相关源文件

以下文件用作生成此 wiki 页面的上下文：

-  `README.en.md <README.en.md>`__
-  `README.md <README.md>`__
-  `docs/architecture.md <docs/architecture.md>`__
-  `/image/architecture.png </image/architecture.png>`__
-  `docs/roadmap.md <docs/roadmap.md>`__
-  `scripts/build.sh <scripts/build.sh>`__
-  `src/README.md <src/README.md>`__
-  `src/action_dispatch/README.en.md <src/action_dispatch/README.en.md>`__
-  `src/action_dispatch/README.md <src/action_dispatch/README.md>`__
-  `src/robot_config/config/robots/test_single_arm_single_cam.yaml <src/robot_config/config/robots/test_single_arm_single_cam.yaml>`__
-  `src/robot_config/robot_config/launch_builders/moveit.py <src/robot_config/robot_config/launch_builders/moveit.py>`__
-  `src/robot_moveit/CMakeLists.txt <src/robot_moveit/CMakeLists.txt>`__
-  `src/robot_moveit/config/lerobot/so101/kinematics.yaml <src/robot_moveit/config/lerobot/so101/kinematics.yaml>`__
-  `src/robot_moveit/docs/moveit_gateway.md <src/robot_moveit/docs/moveit_gateway.md>`__
-  `src/robot_moveit/launch/so101_moveit.launch.py <src/robot_moveit/launch/so101_moveit.launch.py>`__
-  `src/robot_moveit/package.xml <src/robot_moveit/package.xml>`__
-  `src/robot_moveit/scripts/moveit_gateway.py <src/robot_moveit/scripts/moveit_gateway.py>`__

.. raw:: html

   </details>

MoveIt2 集成为 IB-Robot 中的机械臂提供基于轨迹的运动规划和逆运动学 (IK) 求解。该系统支持高级基于位姿的控制、碰撞避免和约束运动规划。该集成专门设计用于通过特殊的 IK 求解策略处理 SO101 机械臂的 5 自由度 (5DOF) 运动学约束。

关于使用模型推理的端到端 AI 策略控制，请参阅 `动作分发 <#8>`__。关于控制模式切换，请参阅 `控制模式架构 <#3.3>`__。

--------------

系统架构
--------

MoveIt2 作为 IB-Robot 中三种控制模式之一运行，通过运动规划和 IK 求解将高级笛卡尔位姿命令转换为关节轨迹。

IB-Robot 中的 MoveIt 集成
~~~~~~~~~~~~~~~~~~~~~~~~

.. mermaid::

   graph TB
       subgraph "Application Layer"
           USER["User/Application"]
           CMD_POSE["/cmd_pose topic<br/>(geometry_msgs/Pose)"]
       end
       
       subgraph "MoveIt Gateway Node"
           GATEWAY["MoveItGateway"]
           IK_SOLVER["Multi-Strategy IK Solver"]
           CONSTRAINT_GEN["Constraint Generator"]
           COORD_TRANSFORM["Coordinate Transform"]
       end
       
       subgraph "MoveIt2 Core"
           MOVE_GROUP["move_group node"]
           PLANNING_SCENE["Planning Scene"]
           KINEMATICS["KDL Kinematics Plugin"]
           PLANNER["OMPL/Pilz Planner"]
       end
       
       subgraph "Execution Layer"
           ACTION_DISPATCH["action_dispatcher_node"]
           ROS2_CONTROL["ros2_control"]
       end
       
       subgraph "Hardware/Simulation"
           HARDWARE["so101_hardware / Gazebo"]
       end
       
       USER --> CMD_POSE
       CMD_POSE --> GATEWAY
       GATEWAY --> COORD_TRANSFORM
       COORD_TRANSFORM --> CONSTRAINT_GEN
       CONSTRAINT_GEN --> IK_SOLVER
       IK_SOLVER --> MOVE_GROUP
       MOVE_GROUP --> PLANNING_SCENE
       MOVE_GROUP --> KINEMATICS
       MOVE_GROUP --> PLANNER
       PLANNER --> ACTION_DISPATCH
       ACTION_DISPATCH --> ROS2_CONTROL
       ROS2_CONTROL --> HARDWARE

**来源**: `src/robot_moveit/scripts/moveit_gateway.py:1-310 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/scripts/moveit_gateway.py#L1-L310>`__,
`src/robot_moveit/docs/moveit_gateway.md:1-50 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/docs/moveit_gateway.md#L1-L50>`__,
`README.md:15-16 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L15-L16>`__

控制模式架构
~~~~~~~~~~~~

MoveIt 规划模式通过 ``control_mode`` 参数激活，并与统一的硬件抽象层集成：

.. mermaid::

   graph LR
       subgraph "Control Mode Selection"
           LAUNCH["robot.launch.py"]
           CONFIG["robot_config YAML"]
       end
       
       subgraph "Mode: moveit_planning"
           MOVEIT_LAUNCH["so101_moveit.launch.py"]
           GATEWAY["moveit_gateway.py"]
           MOVE_GROUP["move_group"]
       end
       
       subgraph "Unified Execution"
           ACTION_EXEC["ActionExecutor"]
           TRAJECTORY_CTRL["trajectory_controllers"]
       end
       
       subgraph "Hardware Layer"
           ROS2_CTRL["ros2_control"]
       end
       
       LAUNCH --> CONFIG
       CONFIG -->|"control_mode:<br/>moveit_planning"| MOVEIT_LAUNCH
       MOVEIT_LAUNCH --> GATEWAY
       MOVEIT_LAUNCH --> MOVE_GROUP
       MOVE_GROUP --> ACTION_EXEC
       ACTION_EXEC --> TRAJECTORY_CTRL
       TRAJECTORY_CTRL --> ROS2_CTRL

**来源**:
`src/robot_config/robot_config/launch_builders/moveit.py:1-79 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/launch_builders/moveit.py#L1-L79>`__,
`README.md:136-143 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L136-L143>`__

--------------

MoveItGateway 节点
------------------

``moveit_gateway.py`` 节点作为 MoveIt2 的高级接口，提供位姿命令订阅、多策略 IK 求解和末端执行器状态发布功能。

节点接口
~~~~~~~~


.. list-table::
   :header-rows: 1

   * - **接口类型**
     - **话题/参数**
     - **消息类型**
     - **描述**
   * - **订阅**
     - ``/cmd_pose``
     - ``geomet ry_msgs/Pose``
     - 目标末端执 行器位姿命令
   * - **订阅**
     - ``/joint_states``
     - ``sensor_msg s/JointState``
     - 当前关节状 态 (IK 初 始猜测)
   * - **发布**
     - ``/robot _status/ee_pose``
     - ` `geometry_msgs /PoseStamped``
     - 当前末端执 行器位姿 (10Hz)
   * - **参数**
     - ` `arm_group_name``
     - ``string``
     - MoveIt 规 划组名称
   * - **参数**
     - ``base_link``
     - ``string``
     - 基座坐标系
   * - **参数**
     - ``ee_link``
     - ``string``
     - 末端执行器 连杆名称
   * - **参数**
     - ``shoulder_link``
     - ``string``
     - 肩部连杆 (用于 5DOF 投影)
   * - **参数**
     - ``joint_names``
     - `` list[string]``
     - 机械臂关节 名称列表

**来源**: `src/robot_moveit/scripts/moveit_gateway.py:24-80 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/scripts/moveit_gateway.py#L24-L80>`__,
`src/robot_moveit/docs/moveit_gateway.md:9-22 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/docs/moveit_gateway.md#L9-L22>`__

关键组件
~~~~~~~~

`src/robot_moveit/scripts/moveit_gateway.py:24-310 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/scripts/moveit_gateway.py#L24-L310>`__ 中的 ``MoveItGateway`` 类初始化以下内容：

1. **TF2 缓冲区和监听器** (`line 48-49 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/line 48-49>`__): 用于坐标系变换
2. **MoveIt2 接口** (`line 53-66 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/line 53-66>`__): 带有可重入回调组的 ``pymoveit2.MoveIt2`` 包装器
3. **关节状态订阅者** (`line 68-69 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/line 68-69>`__): 跟踪当前机械臂配置
4. **位姿命令订阅者** (`line 73-74 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/line 73-74>`__): 接收目标位姿
5. **末端执行器位姿发布者** (`line 71 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/line 71>`__): 发布当前末端执行器状态
6. **状态定时器** (`line 77 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/line 77>`__): 10Hz 末端执行器位姿发布

**来源**: `src/robot_moveit/scripts/moveit_gateway.py:24-80 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/scripts/moveit_gateway.py#L24-L80>`__

--------------

5DOF 运动学约束
--------------

SO101 机械臂有 5 个关节，提供 5 个自由度 (DOF)。标准的 6DOF 位姿目标 (3 位置 + 3 姿态) 对该机械臂来说在数学上是过约束的，会导致频繁的 IK 失败。MoveIt 集成实现了专门的约束处理来解决这个问题。

仅位置 IK 配置
~~~~~~~~~~~~~~

运动学求解器在 `src/robot_moveit/config/lerobot/so101/kinematics.yaml:6 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/config/lerobot/so101/kinematics.yaml#L6>`__ 中配置了 ``position_only_ik: True``：

.. code:: yaml

   arm:
     kinematics_solver: kdl_kinematics_plugin/KDLKinematicsPlugin
     kinematics_solver_search_resolution: 0.01
     kinematics_solver_timeout: 2.0
     kinematics_solver_attempts: 50
     position_only_ik: True

**``position_only_ik: True`` 的效果**： - KDL 求解器仅优化**位置** (3 DOF)，而非姿态 (3 DOF) - 目标姿态仍会传递给求解器，但在优化过程中不强制执行 - 最终解可以根据提供的姿态约束进行验证 - 将 5DOF 机械臂的 IK 成功率从约 10% 提高到 80% 以上

**来源**:
`src/robot_moveit/config/lerobot/so101/kinematics.yaml:1-7 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/config/lerobot/so101/kinematics.yaml#L1-L7>`__,
`src/robot_moveit/docs/moveit_gateway.md:34-67 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/docs/moveit_gateway.md#L34-L67>`__

姿态约束策略
~~~~~~~~~~~~

网关实现了两种几何约束投影方法，用于引导 IK 求解器找到可行的姿态：

策略 1：仅 Z 轴约束
^^^^^^^^^^^^^^^^^^

``constrain_to_z_axis_only()`` 方法
(`src/robot_moveit/scripts/moveit_gateway.py:118-175 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/scripts/moveit_gateway.py#L118-L175>`__) 保持末端执行器 Z 轴方向，同时放宽绕 Z 轴的旋转 (滚转)：

.. mermaid::

   graph TD
       INPUT["Input Quaternion<br/>(x, y, z, w)"]
       TO_MATRIX["Convert to<br/>Rotation Matrix R"]
       EXTRACT_Z["Extract Z-axis<br/>(R column 3)"]
       PROJECT_X["Project original X-axis<br/>onto plane ⊥ Z"]
       NORMALIZE_X["Normalize projected<br/>X-axis"]
       CROSS_Y["Y = Z × X<br/>(cross product)"]
       REBUILD["Rebuild R' from<br/>(X', Y', Z)"]
       TO_QUAT["Convert back to<br/>quaternion"]
       OUTPUT["Constrained Quaternion<br/>(x', y', z', w')"]
       
       INPUT --> TO_MATRIX
       TO_MATRIX --> EXTRACT_Z
       TO_MATRIX --> PROJECT_X
       EXTRACT_Z --> CROSS_Y
       PROJECT_X --> NORMALIZE_X
       NORMALIZE_X --> CROSS_Y
       CROSS_Y --> REBUILD
       REBUILD --> TO_QUAT
       TO_QUAT --> OUTPUT

**算法**
(`src/robot_moveit/scripts/moveit_gateway.py:133-174 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/scripts/moveit_gateway.py#L133-L174>`__)： 1. 将四元数转换为旋转矩阵 2. 保留 Z 轴 (第 3 列) 3. 将原始 X 轴投影到垂直于 Z 轴的平面上 4. 通过叉积计算 Y 轴：``Y = Z × X`` 5. 重构旋转矩阵并转换回四元数

**来源**: `src/robot_moveit/scripts/moveit_gateway.py:118-175 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/scripts/moveit_gateway.py#L118-L175>`__,
`src/robot_moveit/docs/moveit_gateway.md:62-67 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/docs/moveit_gateway.md#L62-L67>`__

策略 2：肩部 XZ 平面投影
^^^^^^^^^^^^^^^^^^^^^^^^

``project_orientation_to_shoulder_xz_plane()`` 方法
(`src/robot_moveit/scripts/moveit_gateway.py:177-264 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/scripts/moveit_gateway.py#L177-L264>`__) 将姿态变换到肩部坐标系，并将其约束在 XZ 平面上：

.. mermaid::

   graph TD
       INPUT["Target Quaternion<br/>in base frame"]
       TF_LOOKUP["Lookup TF:<br/>base → shoulder"]
       TRANSFORM["Transform quaternion<br/>to shoulder frame"]
       TO_MATRIX["Convert to<br/>Rotation Matrix"]
       PROJECT["Constrain X, Z axes<br/>to XZ plane (Y=0)"]
       NORMALIZE["Normalize X and Z"]
       CROSS["Y = Z × X"]
       REBUILD["Rebuild rotation<br/>matrix R'"]
       TO_QUAT["Convert to<br/>quaternion"]
       TRANSFORM_BACK["Transform back<br/>to base frame"]
       OUTPUT["Constrained Quaternion<br/>in base frame"]
       
       INPUT --> TF_LOOKUP
       TF_LOOKUP --> TRANSFORM
       TRANSFORM --> TO_MATRIX
       TO_MATRIX --> PROJECT
       PROJECT --> NORMALIZE
       NORMALIZE --> CROSS
       CROSS --> REBUILD
       REBUILD --> TO_QUAT
       TO_QUAT --> TRANSFORM_BACK
       TRANSFORM_BACK --> OUTPUT

**算法**
(`src/robot_moveit/scripts/moveit_gateway.py:193-264 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/scripts/moveit_gateway.py#L193-L264>`__)： 1. 通过 TF2 获取 ``base → shoulder`` 变换 2. 将目标姿态变换到肩部坐标系 3. 将 X 轴和 Z 轴的 Y 分量设为零 4. 归一化约束后的轴 5. 重构旋转矩阵并变换回基座坐标系

**来源**: `src/robot_moveit/scripts/moveit_gateway.py:177-264 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/scripts/moveit_gateway.py#L177-L264>`__,
`src/robot_moveit/docs/moveit_gateway.md:68-72 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/docs/moveit_gateway.md#L68-L72>`__

多策略回退系统
~~~~~~~~~~~~~~

``cmd_pose_callback()`` 方法
(`src/robot_moveit/scripts/moveit_gateway.py:266-310 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/scripts/moveit_gateway.py#L266-L310>`__) 实现了一个分层回退系统，包含 4 种姿态策略 × 5 个容差级别 = 共 20 次尝试：


.. list-table::
   :header-rows: 1

   * - **策略**
     - **方法**
     - **描述**
   * - 1. 夹爪 Z 轴
     - ``constrain_t o_z_axis_only()``
     - 保持夹爪 Z 方向，释放滚转
   * - 2. 肩部 XZ 投影
     - ``project_or ientation_to_shou lder_xz_plane()``
     - 几何精确的 5DOF 约束
   * - 3. 当前姿态
     - 使用 ``lat est_joint_state``
     - 保持现有机械臂姿态
   * - 4. 默认姿态
     - 单位四元数 ``(0,0,0,1)``
     - 无旋转约束

**容差级别** (应用于每种策略)：


.. list-table::
   :header-rows: 1

   * - **级别**
     - **X, Y 容差 (rad)**
     - **Z 容差 (rad)**
     - **角度 (约)**
   * - 严格
     - 0.1
     - 0.05
     - X/Y: ±5.7°, Z: ±2.8°
   * - 中等
     - 0.3
     - 0.1
     - X/Y: ±17°, Z: ±5.7°
   * - 宽松
     - 0.5
     - 0.15
     - X/Y: ±28°, Z: ±8.6°
   * - 仅 Z
     - 1.0
     - 0.2
     - X/Y: ±57°, Z: ±11°
   * - 无
     - —
     - —
     - 无姿态约束

**来源**: `src/robot_moveit/scripts/moveit_gateway.py:266-310 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/scripts/moveit_gateway.py#L266-L310>`__,
`src/robot_moveit/docs/moveit_gateway.md:73-95 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/docs/moveit_gateway.md#L73-L95>`__

--------------

配置系统
--------

MoveIt 配置在 ``robot_config`` YAML 中定义，并通过启动系统传递。

机器人配置 YAML 结构
~~~~~~~~~~~~~~~~~~~~

示例来自
`src/robot_config/config/robots/test_single_arm_single_cam.yaml:30-35 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/test_single_arm_single_cam.yaml#L30-L35>`__：

.. code:: yaml

   moveit:
     arm_group_name: arm
     base_link: base
     ee_link: gripper
     shoulder_link: shoulder

这些参数通过位于
`src/robot_config/robot_config/launch_builders/moveit.py:52-68 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/launch_builders/moveit.py#L52-L68>`__
的启动构建器传递给 ``moveit_gateway`` 节点：

**来源**:
`src/robot_config/config/robots/test_single_arm_single_cam.yaml:30-35 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/test_single_arm_single_cam.yaml#L30-L35>`__,
`src/robot_config/robot_config/launch_builders/moveit.py:52-68 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/launch_builders/moveit.py#L52-L68>`__

MoveIt2 配置文件
~~~~~~~~~~~~~~~~

位于 ``robot_moveit/config/lerobot/so101/``：


.. list-table::
   :header-rows: 1

   * - **文件**
     - **用途**
   * - ``kinematics.yaml``
     - IK 求解器配置 (``position_only_ik: True``)
   * - ``so101.srdf``
     - 语义机器人描述 (规划组、位姿)
   * - ``joint_limits.yaml``
     - 关节速度/加速度限制
   * - ``moveit_controllers.yaml``
     - 轨迹执行的控制器名称
   * - ``pilz_cartesian_limits.yaml``
     - 笛卡尔速度/加速度限制
   * - ``moveit.rviz``
     - RViz 可视化配置

**来源**: `src/robot_moveit/launch/so101_moveit.launch.py:60-76 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/launch/so101_moveit.launch.py#L60-L76>`__

--------------

启动系统
--------

MoveIt2 通过统一的 ``robot.launch.py`` 入口点使用 ``moveit_planning`` 控制模式启动。

启动流程
~~~~~~~~

.. mermaid::

   graph TB
       ROBOT_LAUNCH["robot.launch.py"]
       CONFIG_YAML["robot_config YAML"]
       MODE_CHECK{"control_mode<br/>contains<br/>'moveit'?"}
       MOVEIT_BUILDER["moveit.py<br/>launch_builder"]
       MOVEIT_LAUNCH["so101_moveit.launch.py"]
       
       subgraph "Launched Nodes"
           MOVE_GROUP["move_group"]
           RVIZ["rviz2 (optional)"]
           GATEWAY["moveit_gateway.py"]
       end
       
       ROBOT_LAUNCH --> CONFIG_YAML
       CONFIG_YAML --> MODE_CHECK
       MODE_CHECK -->|"Yes"| MOVEIT_BUILDER
       MODE_CHECK -->|"No"| SKIP["Skip MoveIt"]
       MOVEIT_BUILDER --> MOVEIT_LAUNCH
       MOVEIT_LAUNCH --> MOVE_GROUP
       MOVEIT_LAUNCH --> RVIZ
       MOVEIT_LAUNCH --> GATEWAY

**来源**:
`src/robot_config/robot_config/launch_builders/moveit.py:15-78 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/launch_builders/moveit.py#L15-L78>`__,
`README.md:136-143 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L136-L143>`__

启动命令
~~~~~~~~

**带 RViz 可视化**：

.. code:: bash

   ros2 launch robot_config robot.launch.py \
     robot_config:=so101_single_arm \
     control_mode:=moveit_planning \
     use_sim:=true

**无头模式 (无 RViz)**：

.. code:: bash

   ros2 launch robot_config robot.launch.py \
     robot_config:=so101_single_arm \
     control_mode:=moveit_planning \
     use_sim:=true \
     moveit_display:=false

**来源**: `README.md:136-143 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L136-L143>`__

启动构建器实现
~~~~~~~~~~~~~~

位于 `src/robot_config/robot_config/launch_builders/moveit.py:15-78 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/launch_builders/moveit.py#L15-L78>`__
的 ``generate_moveit_nodes()`` 函数执行：

1. **模式检测** (`line 31-34 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/line 31-34>`__): 检查控制模式字符串中是否包含 ``'moveit'``
2. **参数提取** (`line 47-55 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/line 47-55>`__): 从机器人配置中提取关节名称和坐标系 ID
3. **启动文件包含** (`line 58-69 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/line 58-69>`__): 包含 ``so101_moveit.launch.py`` 并映射参数

**来源**:
`src/robot_config/robot_config/launch_builders/moveit.py:15-78 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/launch_builders/moveit.py#L15-L78>`__

--------------

控制流程
--------

位姿命令处理
~~~~~~~~~~~~

从位姿命令到关节运动的完整流程：

.. mermaid::

   graph TB
       CMD["/cmd_pose<br/>(Pose message)"]
       CALLBACK["cmd_pose_callback()"]
       TF_CALC["Calculate TF:<br/>base → shoulder"]
       DIST_CHECK["Compute distances:<br/>- from base origin<br/>- from shoulder origin"]
       
       subgraph "Multi-Strategy Loop"
           STRATEGY["For each strategy:<br/>1. Z-axis<br/>2. Shoulder XZ<br/>3. Current orient<br/>4. Default orient"]
           
           subgraph "Tolerance Loop"
               TOL["For each tolerance:<br/>1. Strict<br/>2. Medium<br/>3. Relaxed<br/>4. Z-only<br/>5. None"]
               CREATE_CONSTRAINT["create_orientation_constraint()"]
               SOLVE["solve_and_move()"]
               IK_CALL["moveit2.compute_ik_async()"]
               WAIT["Wait for IK result"]
               CHECK_SUCCESS{"IK<br/>success?"}
           end
       end
       
       MOVE_JOINTS["moveit2.move_to_joint()"]
       SUCCESS["Motion Executed"]
       FAIL["All strategies failed"]
       
       CMD --> CALLBACK
       CALLBACK --> TF_CALC
       TF_CALC --> DIST_CHECK
       DIST_CHECK --> STRATEGY
       STRATEGY --> TOL
       TOL --> CREATE_CONSTRAINT
       CREATE_CONSTRAINT --> SOLVE
       SOLVE --> IK_CALL
       IK_CALL --> WAIT
       WAIT --> CHECK_SUCCESS
       CHECK_SUCCESS -->|"Yes"| MOVE_JOINTS
       CHECK_SUCCESS -->|"No"| TOL
       TOL -->|"All tolerances tried"| STRATEGY
       STRATEGY -->|"All strategies tried"| FAIL
       MOVE_JOINTS --> SUCCESS

**来源**: `src/robot_moveit/scripts/moveit_gateway.py:266-310 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/scripts/moveit_gateway.py#L266-L310>`__,
`src/robot_moveit/docs/moveit_gateway.md:122-205 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/docs/moveit_gateway.md#L122-L205>`__

约束创建
~~~~~~~~

``create_orientation_constraint()`` 方法
(`src/robot_moveit/scripts/moveit_gateway.py:312-340 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/scripts/moveit_gateway.py#L312-L340>`__) 生成
``OrientationConstraint`` 消息：

**消息结构**：

.. code:: python

   constraint = OrientationConstraint()
   constraint.header.frame_id = "base"
   constraint.link_name = "gripper"
   constraint.orientation.x = quat[0]
   constraint.orientation.y = quat[1]
   constraint.orientation.z = quat[2]
   constraint.orientation.w = quat[3]
   constraint.absolute_x_axis_tolerance = x_tol
   constraint.absolute_y_axis_tolerance = y_tol
   constraint.absolute_z_axis_tolerance = z_tol
   constraint.weight = 1.0

**来源**: `src/robot_moveit/scripts/moveit_gateway.py:312-340 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/scripts/moveit_gateway.py#L312-L340>`__,
`src/robot_moveit/docs/moveit_gateway.md:206-229 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/docs/moveit_gateway.md#L206-L229>`__

--------------

坐标系变换
----------

基座到肩部坐标系转换
~~~~~~~~~~~~~~~~~~~~

网关执行坐标变换以准确评估工作空间可达性。从基座坐标系到肩部坐标系的变换为：

::

   P_shoulder = R × (P_base - T)

其中： - ``P_base``: 基座坐标系中的目标位置 - ``T``: 基座坐标系中肩部原点的平移偏移 - ``R``: 从基座到肩部的旋转矩阵 - ``P_shoulder``: 肩部坐标系中的目标位置

**实现** 位于
`src/robot_moveit/scripts/moveit_gateway.py:266-310 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/scripts/moveit_gateway.py#L266-L310>`__：

1. **TF 查询** (`line 280-285 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/line 280-285>`__): 获取 ``base → shoulder`` 变换
2. **平移偏移** (`line 287-290 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/line 287-290>`__): 从变换中提取 ``T``
3. **旋转矩阵** (`line 292-297 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/line 292-297>`__): 将四元数转换为 3×3 矩阵
4. **向量变换** (`line 299-302 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/line 299-302>`__): 应用 ``R × (P - T)``
5. **距离计算** (`line 304-306 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/line 304-306>`__): 计算距肩部的欧几里得距离

**日志输出示例**：

::

   [INFO] Target Pose: x=-0.046, y=-0.000, z=0.423
   [INFO]   Target in shoulder frame: x=-0.034, y=0.012, z=-0.323
   [INFO]   Distance from base origin: 0.426 m
   [INFO]   Distance from shoulder origin: 0.325 m

**来源**: `src/robot_moveit/scripts/moveit_gateway.py:266-310 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/scripts/moveit_gateway.py#L266-L310>`__,
`src/robot_moveit/docs/moveit_gateway.md:97-120 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/docs/moveit_gateway.md#L97-L120>`__

四元数工具
~~~~~~~~~~

网关使用 ``scipy.spatial.transform.Rotation`` 实现四元数运算：


.. list-table::
   :header-rows: 1

   * - **函数**
     - **行号**
     - **用途**
   * - `` quaternion_multiply()``
     - `82-90 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/82-90>`__
     - 组合两个旋转： ``q = q1 * q2``
   * - ``q uaternion_conjugate()``
     - `92-98 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/92-98>`__
     - 逆旋转： ``q* = q^(-1)``
   * - ``quaternion _to_rotation_matrix()``
     - `100-107 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/100-107>`__
     - 将四元数转换为 3×3 矩阵
   * - ``rotation_m atrix_to_quaternion()``
     - `109-116 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/109-116>`__
     - 将 3×3 矩阵转换为 四元数

**来源**: `src/robot_moveit/scripts/moveit_gateway.py:82-116 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/scripts/moveit_gateway.py#L82-L116>`__

--------------

使用示例
--------

发送位姿命令
~~~~~~~~~~~~

向 ``/cmd_pose`` 发布目标位姿：

.. code:: bash

   ros2 topic pub --once /cmd_pose geometry_msgs/msg/Pose \
     "{position: {x: 0.3, y: 0.0, z: 0.2}, \
       orientation: {x: 0.0, y: 0.0, z: 0.0, w: 1.0}}"

监控末端执行器状态
~~~~~~~~~~~~~~~~~~

订阅当前末端执行器位姿：

.. code:: bash

   ros2 topic echo /robot_status/ee_pose

调试 IK 失败
~~~~~~~~~~~~

启用调试日志以查看 IK 策略尝试：

.. code:: bash

   ros2 run robot_moveit moveit_gateway.py --ros-args --log-level debug

**来源**: `src/robot_moveit/scripts/moveit_gateway.py:1-10 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/scripts/moveit_gateway.py#L1-L10>`__,
`src/robot_moveit/docs/moveit_gateway.md:1-50 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/docs/moveit_gateway.md#L1-L50>`__

--------------

与动作分发的集成
----------------

在 ``moveit_planning`` 控制模式下，MoveIt2 生成轨迹，通过 ``action_dispatch`` 的 ``ActionExecutor`` 组件执行。这与 ``model_inference`` 模式不同，后者使用 ``TopicExecutor`` 进行高频位置流传输。

**执行路径**：

::

   moveit_gateway → move_group → trajectory → ActionExecutor → trajectory_controllers → ros2_control

关于动作执行的详细信息，请参阅 `动作分发 <#8>`__。关于控制模式切换，请参阅 `控制模式架构 <#3.3>`__。

**来源**: `src/action_dispatch/README.en.md:35-38 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/README.en.md#L35-L38>`__,
`README.md:15-16 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L15-L16>`__

--------------

性能特征
--------

============================================ ========================
**指标**                                     **值**
============================================ ========================
IK 成功率 (5DOF, 仅位置)                     ~80-90%
IK 成功率 (5DOF, 完整 6DOF 约束)             ~10-20%
平均 IK 求解时间                             50-200 ms
末端执行器位姿发布频率                       10 Hz
最大 IK 求解器尝试次数                       50 (每个容差级别)
IK 求解器超时                                2.0 秒
============================================ ========================

**来源**:
`src/robot_moveit/config/lerobot/so101/kinematics.yaml:3-5 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/config/lerobot/so101/kinematics.yaml#L3-L5>`__,
`src/robot_moveit/docs/moveit_gateway.md:34-51 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/docs/moveit_gateway.md#L34-L51>`__

--------------



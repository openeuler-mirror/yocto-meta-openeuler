MoveItGateway 节点
==================

.. raw:: html

   <details>

相关源文件

以下文件用作生成此 wiki 页面的上下文：

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

目的与范围
---------

``MoveItGateway`` 节点作为高层笛卡尔位姿命令与 MoveIt2 运动规划框架之间的接口层。它专门解决 5 自由度（5DOF）机械臂的运动学约束问题，实现了带姿态松弛技术的多策略逆运动学（IK）求解。

此节点在 ``moveit_planning`` 控制模式下运行。有关其他控制模式（遥操作和模型推理）的信息，请参阅 `控制模式架构 <#3.3>`__。有关整体运动规划集成，包括 MoveIt2 配置和约束，请参阅 `运动规划 (MoveIt) <#10>`__。

--------------

系统集成
--------

``MoveItGateway`` 节点通过 MoveIt2 的 IK 求解器和轨迹规划器，将笛卡尔空间控制与关节空间执行连接起来。

**架构位置**

.. mermaid::

   graph TB
       subgraph "High-Level Commands"
           CMD["/cmd_pose<br/>(Pose)"]
       end
       
       subgraph "MoveItGateway Node"
           GW["MoveItGateway<br/>moveit_gateway.py"]
           STRATEGIES["Multi-Strategy<br/>IK Solver"]
           FALLBACK["Tolerance Fallback<br/>System"]
       end
       
       subgraph "MoveIt2 Core"
           MOVEIT2["MoveIt2 Interface<br/>(pymoveit2)"]
           IK_SOLVER["KDL IK Solver<br/>(position_only_ik)"]
           PLANNER["OMPL/Pilz<br/>Trajectory Planner"]
       end
       
       subgraph "Execution Layer"
           TRAJECTORY_CTRL["trajectory_controllers<br/>(FollowJointTrajectory)"]
           ROS2_CTRL["ros2_control"]
       end
       
       subgraph "Feedback"
           JS["/joint_states"]
           TF["TF2 Tree"]
           EE_POSE["/robot_status/ee_pose"]
       end
       
       CMD --> GW
       GW --> STRATEGIES
       STRATEGIES --> FALLBACK
       FALLBACK --> MOVEIT2
       
       MOVEIT2 --> IK_SOLVER
       IK_SOLVER --> PLANNER
       PLANNER --> TRAJECTORY_CTRL
       TRAJECTORY_CTRL --> ROS2_CTRL
       
       ROS2_CTRL --> JS
       JS --> GW
       TF --> GW
       GW --> EE_POSE

**来源**：`src/robot_moveit/scripts/moveit_gateway.py:1-596 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/scripts/moveit_gateway.py#L1-L596>`__，
`src/robot_moveit/docs/moveit_gateway.md:1-389 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/docs/moveit_gateway.md#L1-L389>`__

--------------

ROS2 接口
---------

订阅话题
~~~~~~~~


.. list-table::
   :header-rows: 1

   * - 话题
     - 类型
     - 用途
     - 回调
   * - ` `/cmd_pose``
     - `` geometry_m sgs/Pose``
     - 目标 末端执行器位姿 命令
     - `` cmd_pose_callback``
   * - ``/jo int_states``
     - ``sens or_msgs/Jo intState``
     - 当前关节位置 用于 IK 种子
     - ``joi nt_state_callback``

发布话题
~~~~~~~~


.. list-table::
   :header-rows: 1

   * - 话题
     - 类型
     - 频率
     - 用途
   * - ` `/robot_stat us/ee_pose``
     - ``geometr y_msgs/Pos eStamped``
     - 10 Hz
     - 当前 末端执行器 基座坐标系位姿

节点参数
~~~~~~~~


.. list-table::
   :header-rows: 1

   * - 参数
     - 类型
     - 必需
     - 来源
     - 用途
   * - ``a rm_group_name``
     - string
     - 是
     - ro bot_config YAML
     - MoveIt 规划组名称 （如 "arm"）
   * - ``base_link``
     - string
     - 是
     - ro bot_config YAML
     - 位姿命令 基座坐标系
   * - ``ee_link``
     - string
     - 是
     - ro bot_config YAML
     - 末端执行器 链接名称
   * - `` shoulder_link``
     - string
     - 是
     - ro bot_config YAML
     - 用于工作空间 计算的 肩部链接
   * - ``joint_names``
     - st ring[]
     - 是
     - ro bot_config YAML
     - 机械臂组的 关节名称

**来源**：`src/robot_moveit/scripts/moveit_gateway.py:31-42 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/scripts/moveit_gateway.py#L31-L42>`__，
`src/robot_config/robot_config/launch_builders/moveit.py:47-56 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/launch_builders/moveit.py#L47-L56>`__

--------------

核心组件
--------

MoveItGateway 类
~~~~~~~~~~~~~~~~~

``MoveItGateway`` 类（`moveit_gateway.py:24-595 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/moveit_gateway.py#L24-L595>`__）实现为具有多线程回调处理的 ROS2 节点。

**类初始化序列**

.. mermaid::

   graph TB
       INIT["__init__()"]
       CBG["ReentrantCallbackGroup"]
       PARAMS["Declare Parameters"]
       TF2["TF2 Buffer + Listener"]
       MOVEIT2_INIT["MoveIt2 Interface<br/>(pymoveit2)"]
       SUBS["Create Subscriptions"]
       PUBS["Create Publishers"]
       TIMER["10Hz Timer<br/>(publish_ee_pose)"]
       
       INIT --> CBG
       CBG --> PARAMS
       PARAMS --> TF2
       TF2 --> MOVEIT2_INIT
       MOVEIT2_INIT --> SUBS
       SUBS --> PUBS
       PUBS --> TIMER

**来源**：`src/robot_moveit/scripts/moveit_gateway.py:25-79 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/scripts/moveit_gateway.py#L25-L79>`__

关键类成员
~~~~~~~~~~


.. list-table::
   :header-rows: 1

   * - 成员
     - 类型
     - 用途
   * - ``callback_group``
     - ``Reentrant CallbackGroup``
     - 线程安全的回调执行
   * - ``moveit2``
     - ``MoveIt2``
     - pymoveit2 接口到 move_group
   * - ``tf_buffer``
     - ``t f2_ros.Buffer``
     - TF 变换查找
   * - ``tf_listener``
     - ``tf2_ros.Tran sformListener``
     - 用于坐标变换的 TF 监听器
   * - ``latest_joint_state``
     - ``JointState``
     - 用于 IK 种子的 缓存关节状态

**来源**：`src/robot_moveit/scripts/moveit_gateway.py:29-65 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/scripts/moveit_gateway.py#L29-L65>`__

多线程执行模型
~~~~~~~~~~~~~~

节点使用 ``MultiThreadedExecutor`` 和 ``ReentrantCallbackGroup`` 安全处理并发回调：

.. mermaid::

   graph LR
       EXECUTOR["MultiThreadedExecutor"]
       TIMER_CB["Timer Callback<br/>(publish_ee_pose)"]
       JS_CB["JointState Callback"]
       POSE_CB["Pose Command Callback<br/>(IK solving)"]
       
       EXECUTOR --> TIMER_CB
       EXECUTOR --> JS_CB
       EXECUTOR --> POSE_CB
       
       TIMER_CB -.->|"can run concurrently"| JS_CB
       JS_CB -.->|"can run concurrently"| POSE_CB

**来源**：`src/robot_moveit/scripts/moveit_gateway.py:584-592 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/scripts/moveit_gateway.py#L584-L592>`__，
`src/robot_moveit/docs/moveit_gateway.md:325-330 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/docs/moveit_gateway.md#L325-L330>`__

--------------

5DOF 运动学约束处理
-------------------

问题陈述
~~~~~~~~

5DOF 机械臂有 5 个关节角度，但 6DOF 位姿规范需要 3 位置 + 3 姿态参数。这创建了一个欠约束系统，大多数目标姿态在数学上无法到达。

**仅位置 IK 配置**

``kinematics.yaml`` 配置启用仅位置 IK 求解：

.. code:: yaml

   arm:
     kinematics_solver: kdl_kinematics_plugin/KDLKinematicsPlugin
     position_only_ik: True  # 对 5DOF 机械臂至关重要

当 ``position_only_ik: True`` 时：- KDL 使用 ``ChainIkSolverPos`` 而非 ``ChainIkSolverPos_NR`` - 求解器仅优化位置，忽略姿态约束 - 姿态仍作为参考传递但不严格强制 - 最终解根据可选的 ``OrientationConstraint`` 验证

**来源**：
`src/robot_moveit/config/lerobot/so101/kinematics.yaml:1-7 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/config/lerobot/so101/kinematics.yaml#L1-L7>`__，
`src/robot_moveit/docs/moveit_gateway.md:32-61 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/docs/moveit_gateway.md#L32-L61>`__

姿态处理策略
~~~~~~~~~~~~

节点实现两种数学策略来调整目标姿态以适应 5DOF 约束：

策略 1：Z 轴约束（``constrain_to_z_axis_only``）
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

保留 Z 轴方向，同时释放绕 Z 轴的旋转。

.. mermaid::

   graph TB
       QUAT["Input Quaternion"]
       R_MAT["Convert to<br/>Rotation Matrix"]
       Z_EXTRACT["Extract Z-axis<br/>(3rd column)"]
       X_PROJECT["Project X-axis to<br/>plane ⊥ Z-axis"]
       Y_CROSS["Y = Z × X<br/>(cross product)"]
       REBUILD["Rebuild Rotation Matrix<br/>[X | Y | Z]"]
       Q_OUT["Output Quaternion"]
       
       QUAT --> R_MAT
       R_MAT --> Z_EXTRACT
       Z_EXTRACT --> X_PROJECT
       X_PROJECT --> Y_CROSS
       Y_CROSS --> REBUILD
       REBUILD --> Q_OUT

**实现**：- 从旋转矩阵提取 Z 轴：``z_axis = R[:, 2]`` - 将原始 X 轴投影到垂直于 Z 的平面：``x_proj = x - (x·z)z`` - 通过叉积重建 Y 轴：``y = z × x`` - 构建新的正交旋转矩阵：``R' = [x | y | z]``

**来源**：`src/robot_moveit/scripts/moveit_gateway.py:118-175 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/scripts/moveit_gateway.py#L118-L175>`__，
`src/robot_moveit/docs/moveit_gateway.md:63-66 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/docs/moveit_gateway.md#L63-L66>`__

策略 2：肩部 XZ 平面投影（``project_orientation_to_shoulder_xz_plane``）
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

将姿态投影到肩部坐标系的 XZ 平面，与机械臂的自然运动约束对齐。

.. mermaid::

   graph TB
       Q_BASE["Quaternion in<br/>base frame"]
       TF_LOOKUP["TF Lookup:<br/>base → shoulder"]
       Q_SHOULDER["Transform to<br/>shoulder frame"]
       R_SHOULDER["Convert to<br/>Rotation Matrix"]
       CONSTRAIN_Y["Set Y-components<br/>to zero"]
       NORMALIZE["Normalize X and Z axes<br/>in XZ plane"]
       REBUILD_Y["Rebuild Y-axis<br/>Y = Z × X"]
       Q_SHOULDER_OUT["Quaternion in<br/>shoulder frame"]
       TF_BACK["Transform back<br/>to base frame"]
       Q_BASE_OUT["Constrained quaternion<br/>in base frame"]
       
       Q_BASE --> TF_LOOKUP
       TF_LOOKUP --> Q_SHOULDER
       Q_SHOULDER --> R_SHOULDER
       R_SHOULDER --> CONSTRAIN_Y
       CONSTRAIN_Y --> NORMALIZE
       NORMALIZE --> REBUILD_Y
       REBUILD_Y --> Q_SHOULDER_OUT
       Q_SHOULDER_OUT --> TF_BACK
       TF_BACK --> Q_BASE_OUT

**实现**：1. 通过 TF2 获取 base→shoulder 变换：``tf_buffer.lookup_transform(base_link, shoulder_link)`` 2. 将输入四元数旋转到肩部坐标系：``q_shoulder = q_base_to_shoulder * q_base`` 3. 转换为旋转矩阵并将 Y 分量置零：``x_axis[1] = 0``，``z_axis[1] = 0`` 4. 归一化轴并重建正交矩阵 5. 变换回基座坐标系：``q_base' = q_shoulder_to_base * q_shoulder'``

**来源**：`src/robot_moveit/scripts/moveit_gateway.py:177-271 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/scripts/moveit_gateway.py#L177-L271>`__，
`src/robot_moveit/docs/moveit_gateway.md:68-71 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/docs/moveit_gateway.md#L68-L71>`__

--------------

多策略回退系统
--------------

``cmd_pose_callback`` 实现结合姿态策略和容差级别的级联回退系统。

回退层次
~~~~~~~~

.. mermaid::

   graph TB
       START["Receive /cmd_pose"]
       
       subgraph "Strategy Loop (4 strategies)"
           S1["1. Z-axis constraint"]
           S2["2. Shoulder XZ projection"]
           S3["3. Current orientation<br/>(position-only)"]
           S4["4. Default orientation<br/>(identity)"]
       end
       
       subgraph "Tolerance Loop (5 levels per strategy)"
           T1["Strict: (0.1, 0.1, 0.05)"]
           T2["Medium: (0.3, 0.3, 0.1)"]
           T3["Relaxed: (0.5, 0.5, 0.15)"]
           T4["Z-only: (1.0, 1.0, 0.2)"]
           T5["No constraints: None"]
       end
       
       SOLVE["solve_and_move()"]
       SUCCESS{"IK Success?"}
       MOVE["Execute Trajectory"]
       NEXT{"More<br/>tolerances?"}
       NEXT_STRAT{"More<br/>strategies?"}
       FAIL["Log Error:<br/>All strategies failed"]
       
       START --> S1
       S1 --> T1
       T1 --> SOLVE
       SOLVE --> SUCCESS
       SUCCESS -->|Yes| MOVE
       SUCCESS -->|No| NEXT
       NEXT -->|Yes| T2
       NEXT -->|No| NEXT_STRAT
       NEXT_STRAT -->|Yes| S2
       NEXT_STRAT -->|No| FAIL
       
       T2 --> SOLVE
       T3 --> SOLVE
       T4 --> SOLVE
       T5 --> SOLVE

**来源**：`src/robot_moveit/scripts/moveit_gateway.py:316-430 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/scripts/moveit_gateway.py#L316-L430>`__，
`src/robot_moveit/docs/moveit_gateway.md:73-94 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/docs/moveit_gateway.md#L73-L94>`__

容差策略定义
~~~~~~~~~~~~


.. list-table::
   :header-rows: 1

   * - 策略名称
     - 容差 (x, y, z)
     - 角度容差
     - 用例
   * - Strict
     - (0.1, 0.1, 0.05) rad
     - X/Y: ±5.7°, Z: ±2.8°
     - 精确姿态 控制
   * - Medium
     - (0.3, 0.3, 0.1) rad
     - X/Y: ±17°, Z: ±5.7°
     - 中等姿态 灵活性
   * - Relaxed
     - (0.5, 0.5, 0.15) rad
     - X/Y: ±28°, Z: ±8.6°
     - 高姿态 灵活性
   * - Z-axis only
     - (1.0, 1.0, 0.2) rad
     - X/Y: ±57°, Z: ±11.5°
     - 仅 Z 方向 重要
   * - No constraints
     - None
     - N/A
     - 仅位置 控制

**来源**：`src/robot_moveit/scripts/moveit_gateway.py:397-404 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/scripts/moveit_gateway.py#L397-L404>`__，
`src/robot_moveit/docs/moveit_gateway.md:76-82 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/docs/moveit_gateway.md#L76-L82>`__

--------------

IK 求解和执行流水线
-------------------

``solve_and_move()`` 实现
~~~~~~~~~~~~~~~~~~~~~~~~~

核心 IK 求解函数实现以下流水线：

.. mermaid::

   graph TB
       INPUT["solve_and_move()<br/>(target_pose, orientation_tolerance)"]
       
       CHECK_MOVEIT2{"moveit2<br/>initialized?"}
       GET_STATE["Retrieve latest_joint_state"]
       VALIDATE_STATE{"Valid joint state?<br/>(len >= expected joints)"}
       
       CREATE_CONSTRAINTS{"orientation_tolerance<br/>!= None?"}
       BUILD_CONSTRAINT["create_orientation_constraint()<br/>Build OrientationConstraint msg"]
       
       CALL_IK["moveit2.compute_ik_async()<br/>(position, quat, start_state, constraints)"]
       WAIT_FUTURE["Wait for IK result<br/>(max 5 seconds)"]
       
       CHECK_RESULT{"IK solution<br/>found?"}
       EXTRACT_JOINTS["Extract joint_positions<br/>from IK solution"]
       MOVE["move_to_joint()<br/>Execute trajectory"]
       
       RETURN_SUCCESS["return True"]
       RETURN_FAIL["return False"]
       
       INPUT --> CHECK_MOVEIT2
       CHECK_MOVEIT2 -->|No| RETURN_FAIL
       CHECK_MOVEIT2 -->|Yes| GET_STATE
       GET_STATE --> VALIDATE_STATE
       
       VALIDATE_STATE --> CREATE_CONSTRAINTS
       CREATE_CONSTRAINTS -->|Yes| BUILD_CONSTRAINT
       CREATE_CONSTRAINTS -->|No| CALL_IK
       BUILD_CONSTRAINT --> CALL_IK
       
       CALL_IK --> WAIT_FUTURE
       WAIT_FUTURE --> CHECK_RESULT
       CHECK_RESULT -->|Yes| EXTRACT_JOINTS
       CHECK_RESULT -->|No| RETURN_FAIL
       EXTRACT_JOINTS --> MOVE
       MOVE --> RETURN_SUCCESS

**来源**：`src/robot_moveit/scripts/moveit_gateway.py:444-577 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/scripts/moveit_gateway.py#L444-L577>`__

姿态约束创建
~~~~~~~~~~~~

``create_orientation_constraint()`` 方法（`moveit_gateway.py:273-306 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/moveit_gateway.py#L273-L306>`__）构建 MoveIt2 兼容的姿态约束：

**约束参数**：- ``link_name``：末端执行器链接（如 "gripper"）- ``frame_id``：参考坐标系（如 "base"）- ``target_quat``：目标姿态，格式为 (x, y, z, w) - ``absolute_x_axis_tolerance``：绕 X 轴的容差（rad）- ``absolute_y_axis_tolerance``：绕 Y 轴的容差（rad）- ``absolute_z_axis_tolerance``：绕 Z 轴的容差（rad）- ``weight``：约束重要性（1.0 = 严格）

**来源**：`src/robot_moveit/scripts/moveit_gateway.py:273-306 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/scripts/moveit_gateway.py#L273-L306>`__

--------------

工作空间坐标变换
----------------

节点执行坐标变换以提供工作空间调试信息。

基座到肩部变换
~~~~~~~~~~~~~~

当收到位姿命令时，节点计算肩部坐标系中的目标位置：

**变换公式**：

::

   P_shoulder = R_base_to_shoulder × (P_base - T_base_to_shoulder)

其中：- ``P_base``：基座坐标系中的目标位置 - ``T_base_to_shoulder``：从基座到肩部原点的平移 - ``R_base_to_shoulder``：从基座到肩部坐标系的旋转 - ``P_shoulder``：肩部坐标系中的目标位置

**实现**：

.. mermaid::

   graph LR
       TF_LOOKUP["tf_buffer.lookup_transform()<br/>shoulder ← base"]
       EXTRACT_T["Extract translation<br/>(tx, ty, tz)"]
       EXTRACT_R["Extract rotation<br/>quaternion"]
       Q_TO_MAT["quaternion_to_rotation_matrix()"]
       COMPUTE_REL["p_relative =<br/>p_base - translation"]
       APPLY_ROT["p_shoulder =<br/>R × p_relative"]
       CALC_DIST["Distance =<br/>||p_shoulder||"]
       LOG["Log workspace info"]
       
       TF_LOOKUP --> EXTRACT_T
       TF_LOOKUP --> EXTRACT_R
       EXTRACT_R --> Q_TO_MAT
       EXTRACT_T --> COMPUTE_REL
       Q_TO_MAT --> APPLY_ROT
       COMPUTE_REL --> APPLY_ROT
       APPLY_ROT --> CALC_DIST
       CALC_DIST --> LOG

**日志输出示例**：

::

   [INFO] Target Pose: x=-0.046, y=-0.000, z=0.423
   [INFO]   Target in shoulder frame: x=-0.034, y=0.012, z=-0.323
   [INFO]   Distance from base origin: 0.426 m
   [INFO]   Distance from shoulder origin: 0.325 m

**来源**：`src/robot_moveit/scripts/moveit_gateway.py:319-367 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/scripts/moveit_gateway.py#L319-L367>`__，
`src/robot_moveit/docs/moveit_gateway.md:98-119 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/docs/moveit_gateway.md#L98-L119>`__

--------------

数学工具
--------

节点使用 ``scipy.spatial.transform.Rotation`` 和 NumPy 提供四元数和旋转矩阵工具。

四元数操作
~~~~~~~~~~


.. list-table::
   :header-rows: 1

   * - 函数
     - 签名
     - 实现
   * - ``quate rnion_multiply``
     - ``(q1, q2) -> q``
     - ``R.from_ quat(q1) * R.from_quat(q2)``
   * - ``quater nion_conjugate``
     - ``(q) -> q*``
     - ``R.from_quat(q).inv()``
   * - ` `quaternion_to_r otation_matrix``
     - ``(q) -> np.ndarray[3,3]``
     - `` R.from_quat(q).as_matrix()``
   * - ` `rotation_matrix _to_quaternion``
     - ``(R) -> q``
     - `` R.from_matrix(R).as_quat()``

**四元数格式**：所有四元数使用 ``[x, y, z, w]`` 格式（标量在后）。

**来源**：`src/robot_moveit/scripts/moveit_gateway.py:81-116 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/scripts/moveit_gateway.py#L81-L116>`__，
`src/robot_moveit/docs/moveit_gateway.md:229-247 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/docs/moveit_gateway.md#L229-L247>`__

--------------

配置和启动
----------

启动集成
~~~~~~~~

当 ``control_mode`` 包含 "moveit" 时，``MoveItGateway`` 节点通过 robot_config 系统启动。

**启动流程**：

.. mermaid::

   graph TB
       ROBOT_LAUNCH["robot.launch.py<br/>--control_mode moveit_planning"]
       
       CHECK_MODE{"'moveit' in<br/>control_mode?"}
       
       MOVEIT_BUILDER["launch_builders/moveit.py<br/>generate_moveit_nodes()"]
       
       READ_CONFIG["Read robot_config YAML"]
       EXTRACT_PARAMS["Extract MoveIt parameters:<br/>- arm_group_name<br/>- base_link<br/>- ee_link<br/>- shoulder_link<br/>- joint_names"]
       
       INCLUDE_LAUNCH["IncludeLaunchDescription<br/>(so101_moveit.launch.py)"]
       
       LAUNCH_NODES["Launch nodes:<br/>- move_group<br/>- rviz2 (optional)<br/>- moveit_gateway"]
       
       ROBOT_LAUNCH --> CHECK_MODE
       CHECK_MODE -->|Yes| MOVEIT_BUILDER
       CHECK_MODE -->|No| END["Skip MoveIt nodes"]
       
       MOVEIT_BUILDER --> READ_CONFIG
       READ_CONFIG --> EXTRACT_PARAMS
       EXTRACT_PARAMS --> INCLUDE_LAUNCH
       INCLUDE_LAUNCH --> LAUNCH_NODES

**来源**：
`src/robot_config/robot_config/launch_builders/moveit.py:15-78 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/launch_builders/moveit.py#L15-L78>`__，
`src/robot_moveit/launch/so101_moveit.launch.py:1-134 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/launch/so101_moveit.launch.py#L1-L134>`__

机器人配置 YAML 规范
~~~~~~~~~~~~~~~~~~~

MoveIt 网关要求 ``robot_config`` YAML 中包含以下字段：

.. code:: yaml

   moveit:
     arm_group_name: arm           # MoveIt 规划组
     base_link: base              # 基座坐标系
     ee_link: gripper             # 末端执行器链接
     shoulder_link: shoulder      # 肩部链接（用于工作空间计算）

   joints:
     arm:                         # 机械臂关节名称列表
       - "1"
       - "2"
       - "3"
       - "4"
       - "5"

**参数传播**：1. ``robot_config`` YAML 定义 MoveIt 参数 2. ``launch_builders/moveit.py`` 提取参数（`moveit.py:47-56 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/moveit.py#L47-L56>`__）3. 参数作为启动参数传递给 ``so101_moveit.launch.py`` 4. ``so101_moveit.launch.py`` 将参数传递给 ``moveit_gateway`` 节点（`so101_moveit.launch.py:107-120 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/so101_moveit.launch.py#L107-L120>`__）

**来源**：
`src/robot_config/config/robots/test_single_arm_single_cam.yaml:31-35 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/test_single_arm_single_cam.yaml#L31-L35>`__，
`src/robot_config/robot_config/launch_builders/moveit.py:47-71 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/launch_builders/moveit.py#L47-L71>`__

--------------

使用示例
--------

发送位姿命令
~~~~~~~~~~~~

**命令行**：

.. code:: bash

   ros2 topic pub /cmd_pose geometry_msgs/Pose "{
     position: {x: 0.15, y: 0.0, z: 0.25},
     orientation: {x: 0.0, y: 0.0, z: 0.707, w: 0.707}
   }" --once

**预期行为**：1. 节点在 ``/cmd_pose`` 上接收位姿 2. 记录目标位置和肩部坐标系坐标 3. 尝试级联策略的 IK 4. 成功时，通过 MoveIt2 执行关节轨迹 5. 发布更新的 ``/robot_status/ee_pose``

**来源**：`src/robot_moveit/docs/moveit_gateway.md:307-322 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/docs/moveit_gateway.md#L307-L322>`__

监控末端执行器位姿
~~~~~~~~~~~~~~~~~~

.. code:: bash

   ros2 topic echo /robot_status/ee_pose

此话题以 10 Hz 发布当前末端执行器位姿，通过 TF 变换计算。

**来源**：`src/robot_moveit/scripts/moveit_gateway.py:432-442 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/scripts/moveit_gateway.py#L432-L442>`__

--------------

故障排除
--------

IK 失败
~~~~~~~

**症状**：日志消息"IK failed with all strategies!"

**常见原因**：1. 目标位置超出工作空间（检查肩部坐标系距离）2. 目标姿态对 5DOF 机械臂不可能 3. ``kinematics.yaml`` 中未设置 ``position_only_ik: True``

**调试**：- 检查记录的距基座和肩部原点的距离 - 验证 ``kinematics.yaml`` 有 ``position_only_ik: True`` - 查看日志中的姿态约束容差

**来源**：`src/robot_moveit/docs/moveit_gateway.md:339-345 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/docs/moveit_gateway.md#L339-L345>`__

TF 变换失败
~~~~~~~~~~~

**症状**：警告"Failed to get base->shoulder transform"

**常见原因**：1. ``robot_state_publisher`` 未运行 2. 肩部链接未在 URDF 中定义 3. TF 树未完全发布

**调试**：

.. code:: bash

   ros2 run tf2_tools view_frames

**来源**：`src/robot_moveit/docs/moveit_gateway.md:347-350 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/docs/moveit_gateway.md#L347-L350>`__

无效关节状态
~~~~~~~~~~~~

**症状**：警告"Invalid joint state: has X joints, need Y"

**解决方案**：- 验证 ``/joint_states`` 话题包含所有必需关节 - 检查 ``joint_names`` 参数与实际关节名称匹配 - 确保关节名称与 URDF 和 ros2_control 配置中的匹配

**来源**：`src/robot_moveit/scripts/moveit_gateway.py:476-482 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/scripts/moveit_gateway.py#L476-L482>`__

--------------

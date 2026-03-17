5DOF 运动学约束
===============

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

本文档介绍 IB-Robot 框架中 5 自由度（DOF）机械臂的运动学约束处理系统。SO101 机械臂只有 5 个驱动关节，但末端执行器位姿命令指定 6DOF（3 位置 + 3 姿态）。本文档解释数学问题、``MoveItGateway`` 中实现的约束松弛策略，以及成功逆运动学（IK）求解所需的配置。

有关 MoveItGateway 节点的整体架构和位姿命令接口信息，请参阅 `MoveItGateway 节点 <#10.1>`__。有关 MoveIt 启动配置和控制器设置，请参阅 `MoveIt 启动配置 <#10.3>`__。

--------------

5DOF 问题
---------

数学约束
~~~~~~~~

6DOF 位姿规范提供 6 个约束：- **位置**：3 个约束（x, y, z）- **姿态**：3 个约束（roll, pitch, yaw）

5DOF 机械臂只有 5 个关节变量。标准 IK 求解器尝试同时满足所有 6 个约束将因系统过度约束（6 个方程，5 个未知数）而失败并返回 ``NO_IK_SOLUTION`` 错误。

运动学限制
~~~~~~~~~~

SO101 机械臂的 5 个旋转关节可以控制：- 3 DOF 用于末端执行器位置 - 2 DOF 用于末端执行器姿态（通常是工具轴的方向）- **缺失**：1 DOF 用于绕工具轴旋转（roll）

这意味着末端执行器无法实现任意 6DOF 位姿。对于大多数目标姿态，不存在精确解。

**来源**：`src/robot_moveit/docs/moveit_gateway.md:22-51 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/docs/moveit_gateway.md#L22-L51>`__

--------------

配置：仅位置 IK
---------------

运动学配置
~~~~~~~~~~

主要解决方案是在 KDL 运动学求解器中启用仅位置 IK 模式：

.. code:: yaml

   arm:
     kinematics_solver: kdl_kinematics_plugin/KDLKinematicsPlugin
     kinematics_solver_search_resolution: 0.01
     kinematics_solver_timeout: 2.0
     kinematics_solver_attempts: 50
     position_only_ik: True

**来源**：
`src/robot_moveit/config/lerobot/so101/kinematics.yaml:1-7 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/config/lerobot/so101/kinematics.yaml#L1-L7>`__

``position_only_ik: True`` 时的求解器行为
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


.. list-table::
   :header-rows: 1

   * - 方面
     - 标准模式
     - 仅位置模式
   * - **目标**
     - 最小化位置 + 姿态误差
     - 仅最小化位置误差
   * - ** 姿态输入**
     - 硬约束， 无法到达时失败
     - 用作解选择的提示
   * - **解 空间**
     - 需要精确 6DOF 匹配
     - 任何达到位置目标的姿态
   * - **成功 率**
     - 5DOF 机械臂低 （~10-30%）
     - 高（~80-95%）
   * - **求解器 类**
     - `` ChainIkSolverPos_NR``
     - ``ChainIkSolverPos``

传递给 ``compute_ik_async()`` 的姿态四元数仍然影响从满足位置的配置集中选择哪个解，但它不强制严格的姿态匹配。

**来源**：`src/robot_moveit/docs/moveit_gateway.md:33-58 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/docs/moveit_gateway.md#L33-L58>`__

--------------

姿态预处理策略
--------------

即使启用了 ``position_only_ik: True``，``MoveItGateway`` 节点仍应用姿态预处理以改善 IK 收敛性，并引导求解器朝向运动学可行的姿态。

策略 1：仅 Z 轴约束
~~~~~~~~~~~~~~~~~~~

**方法**：``constrain_to_z_axis_only(quat)``

**原理**：- 保留末端执行器 Z 轴方向（2 DOF：pitch + yaw）- 释放绕 Z 轴的旋转（1 DOF：roll）- 使用最小旋转原理保持接近原始姿态

**算法**：

::

   1. 将四元数转换为旋转矩阵 R
   2. 提取并归一化 Z 轴：z = R[:, 2]
   3. 将原始 X 轴投影到垂直于 Z 的平面：x' = x - (x·z)z
   4. 重新正交化：y' = z × x'
   5. 重建旋转矩阵 R' = [x', y', z]
   6. 转换回四元数

**来源**：`src/robot_moveit/scripts/moveit_gateway.py:118-175 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/scripts/moveit_gateway.py#L118-L175>`__

.. mermaid::

   graph TD
       InputQuat["Input Quaternion<br/>(x, y, z, w)"]
       ToMatrix["quaternion_to_rotation_matrix()"]
       ExtractZ["Extract Z-axis<br/>z = R[:, 2]"]
       NormalizeZ["Normalize Z-axis"]
       ProjectX["Project X-axis to<br/>perpendicular plane<br/>x' = x - (x·z)z"]
       CrossY["Compute Y-axis<br/>y' = z × x'"]
       RebuildMatrix["Rebuild rotation matrix<br/>R' = [x', y', z]"]
       ToQuat["rotation_matrix_to_quaternion()"]
       OutputQuat["Constrained Quaternion<br/>(x', y', z', w')"]

       InputQuat --> ToMatrix
       ToMatrix --> ExtractZ
       ExtractZ --> NormalizeZ
       NormalizeZ --> ProjectX
       ProjectX --> CrossY
       CrossY --> RebuildMatrix
       RebuildMatrix --> ToQuat
       ToQuat --> OutputQuat

**图：Z 轴约束算法**

**来源**：`src/robot_moveit/scripts/moveit_gateway.py:118-175 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/scripts/moveit_gateway.py#L118-L175>`__

--------------

策略 2：肩部 XZ 平面投影
~~~~~~~~~~~~~~~~~~~~~~~~

**方法**：``project_orientation_to_shoulder_xz_plane(quat)``

**原理**：- 将姿态变换到肩部坐标系 - 约束旋转轴位于肩部 XZ 平面（Y 分量 = 0）- 变换回基座坐标系

此方法具有几何动机：SO101 的运动链由于其串联结构，自然与肩部 XZ 平面对齐。

**算法**：

::

   1. 查找 TF：base → shoulder（旋转 Q_b2s）
   2. 变换姿态：q_shoulder = Q_b2s * q_base
   3. 转换为旋转矩阵：R_shoulder
   4. 将 Y 分量置零：x_axis[1] = 0, z_axis[1] = 0
   5. 重新归一化和正交化
   6. 转换回：q_shoulder_constrained
   7. 变换到基座：q_base_constrained = Q_s2b * q_shoulder_constrained

**来源**：`src/robot_moveit/scripts/moveit_gateway.py:177-271 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/scripts/moveit_gateway.py#L177-L271>`__

.. mermaid::

   graph TB
       InputQuat["Input Quaternion<br/>in base frame"]
       LookupTF["tf_buffer.lookup_transform()<br/>base → shoulder"]
       Transform1["quaternion_multiply()<br/>q_shoulder = Q_b2s * q_base"]
       ToMatrix["quaternion_to_rotation_matrix()"]
       ZeroY["Zero Y components<br/>x[1]=0, z[1]=0"]
       Renormalize["Renormalize x, z axes"]
       CrossY["y = z × x"]
       RebuildMatrix["Rebuild matrix R'"]
       ToQuat["rotation_matrix_to_quaternion()"]
       Transform2["quaternion_multiply()<br/>q_base' = Q_s2b * q_shoulder'"]
       OutputQuat["Constrained Quaternion<br/>in base frame"]

       InputQuat --> LookupTF
       LookupTF --> Transform1
       Transform1 --> ToMatrix
       ToMatrix --> ZeroY
       ZeroY --> Renormalize
       Renormalize --> CrossY
       CrossY --> RebuildMatrix
       RebuildMatrix --> ToQuat
       ToQuat --> Transform2
       Transform2 --> OutputQuat

**图：肩部 XZ 平面投影算法**

**来源**：`src/robot_moveit/scripts/moveit_gateway.py:177-271 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/scripts/moveit_gateway.py#L177-L271>`__

--------------

分层容差策略
------------

当姿态约束通过 ``Constraints`` 消息传递给 IK 求解器时，求解器验证最终解满足容差边界。``MoveItGateway`` 实现渐进式松弛策略。

容差级别
~~~~~~~~


.. list-table::
   :header-rows: 1

   * - 策略名称
     - X/Y 容差 (rad)
     - Z 容差 (rad)
     - 角度（约）
     - 用例
   * - * *严格**
     - 0.1
     - 0.05
     - ±5.7° (XY), ±2.8° (Z)
     - 高精度 任务
   * - * *中等**
     - 0.3
     - 0.1
     - ±17° (XY), ±5.7° (Z)
     - 通用 操作
   * - ** 宽松**
     - 0.5
     - 0.15
     - ±28° (XY), ±8.6° (Z)
     - 粗略 定位
   * - **仅 Z 轴 **
     - 1.0
     - 0.2
     - ±57° (XY), ±11.5° (Z)
     - 方向 重要， roll 自由
   * - **无 约束**
     - None
     - None
     - N/A
     - 仅位置

**注意**：X 和 Y 容差较大（松弛 roll）是因为 5DOF 机械臂缺乏控制绕 Z 轴旋转的自由度。Z 容差较小以保持工具方向。

**来源**：`src/robot_moveit/scripts/moveit_gateway.py:397-404 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/scripts/moveit_gateway.py#L397-L404>`__，
`src/robot_moveit/docs/moveit_gateway.md:73-82 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/docs/moveit_gateway.md#L73-L82>`__

姿态约束消息
~~~~~~~~~~~~

``create_orientation_constraint()`` 方法构建 ``OrientationConstraint`` 消息：

.. code:: python

   constraint = OrientationConstraint()
   constraint.header.frame_id = frame_id           # "base"
   constraint.link_name = link_name                # "gripper"
   constraint.orientation = target_quat            # (x, y, z, w)
   constraint.absolute_x_axis_tolerance = tol_x
   constraint.absolute_y_axis_tolerance = tol_y
   constraint.absolute_z_axis_tolerance = tol_z
   constraint.weight = 1.0

**来源**：`src/robot_moveit/scripts/moveit_gateway.py:273-306 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/scripts/moveit_gateway.py#L273-L306>`__

--------------

多策略回退工作流
----------------

``cmd_pose_callback()`` 实现嵌套回退循环：

::

   For each orientation preprocessing strategy:
       For each tolerance level:
           Try IK solve
           If success: execute and return
           Else: continue to next tolerance
       Next strategy
   Report failure if all combinations fail

回退序列
~~~~~~~~

.. mermaid::

   graph TD
       Start["Receive /cmd_pose"]
       S1["Strategy 1:<br/>constrain_to_z_axis_only()"]
       S2["Strategy 2:<br/>project_orientation_to_shoulder_xz_plane()"]
       S3["Strategy 3:<br/>Current EE orientation<br/>(position-only move)"]
       S4["Strategy 4:<br/>Default orientation<br/>(0, 0, 0, 1)"]
       
       T1["Tolerance Loop:<br/>Strict → Medium → Relaxed<br/>→ Z-only → None"]
       T2["Tolerance Loop:<br/>Strict → Medium → Relaxed<br/>→ Z-only → None"]
       T3["Tolerance Loop:<br/>Strict → Medium → Relaxed<br/>→ Z-only → None"]
       T4["Tolerance Loop:<br/>Strict → Medium → Relaxed<br/>→ Z-only → None"]
       
       Solve1["solve_and_move()"]
       Solve2["solve_and_move()"]
       Solve3["solve_and_move()"]
       Solve4["solve_and_move()"]
       
       Success["IK Success<br/>Execute Motion"]
       Failure["All strategies failed<br/>Log error"]
       
       Start --> S1
       S1 --> T1
       T1 --> Solve1
       Solve1 -->|Success| Success
       Solve1 -->|Fail all tolerances| S2
       
       S2 --> T2
       T2 --> Solve2
       Solve2 -->|Success| Success
       Solve2 -->|Fail all tolerances| S3
       
       S3 --> T3
       T3 --> Solve3
       Solve3 -->|Success| Success
       Solve3 -->|Fail all tolerances| S4
       
       S4 --> T4
       T4 --> Solve4
       Solve4 -->|Success| Success
       Solve4 -->|Fail all tolerances| Failure

**图：多策略回退决策树**

**来源**：`src/robot_moveit/scripts/moveit_gateway.py:316-430 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/scripts/moveit_gateway.py#L316-L430>`__

代码结构
~~~~~~~~

``cmd_pose_callback`` 中的回退逻辑：

::

   strategies = [
       ("Gripper Z-axis constraint", self.constrain_to_z_axis_only(orig_quat)),
       ("Shoulder XZ plane projection", self.project_orientation_to_shoulder_xz_plane(orig_quat)),
   ]

   # Fallback: current orientation (lookup via TF)
   current_quat = tf_buffer.lookup_transform(base_link, ee_link, ...)
   strategies.append(("Current orientation (position only)", current_quat))

   # Final fallback: identity quaternion
   strategies.append(("Default orientation (no rotation)", (0.0, 0.0, 0.0, 1.0)))

   tolerance_strategies = [
       ("Strict tolerance", (0.1, 0.1, 0.05)),
       ("Medium tolerance", (0.3, 0.3, 0.1)),
       ("Relaxed tolerance", (0.5, 0.5, 0.15)),
       ("Z-axis only", (1.0, 1.0, 0.2)),
       ("No constraints", None),
   ]

   for strategy_name, quat in strategies:
       for tol_name, tolerances in tolerance_strategies:
           if self.solve_and_move(adjusted_pose, orientation_tolerance=tolerances):
               return  # Success

**来源**：`src/robot_moveit/scripts/moveit_gateway.py:372-430 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/scripts/moveit_gateway.py#L372-L430>`__

--------------

带约束的 IK 求解
----------------

``solve_and_move()`` 实现
~~~~~~~~~~~~~~~~~~~~~~~~~

.. mermaid::

   graph TB
       Start["solve_and_move(target_pose,<br/>orientation_tolerance)"]
       ValidateState["Validate latest_joint_state<br/>has required joints"]
       CreateConstraints{"orientation_tolerance<br/>is not None?"}
       BuildConstraint["create_orientation_constraint()<br/>Build OrientationConstraint"]
       NoConstraint["constraints = None"]
       
       ComputeIK["moveit2.compute_ik_async(<br/>position, quat_xyzw,<br/>start_joint_state, constraints)"]
       WaitFuture["Wait for future.done()<br/>(timeout 5.0s)"]
       GetResult["moveit2.get_compute_ik_result(future)"]
       
       CheckResult{"ik_solution<br/>is not None?"}
       ExtractJoints["Extract joint_positions<br/>from solution"]
       MoveJoint["move_to_joint(joint_positions)"]
       Success["Return True"]
       Fail["Log warning<br/>Return False"]
       
       Start --> ValidateState
       ValidateState --> CreateConstraints
       CreateConstraints -->|Yes| BuildConstraint
       CreateConstraints -->|No| NoConstraint
       BuildConstraint --> ComputeIK
       NoConstraint --> ComputeIK
       
       ComputeIK --> WaitFuture
       WaitFuture --> GetResult
       GetResult --> CheckResult
       CheckResult -->|Yes| ExtractJoints
       CheckResult -->|No| Fail
       ExtractJoints --> MoveJoint
       MoveJoint --> Success

**图：solve_and_move() 工作流**

**来源**：`src/robot_moveit/scripts/moveit_gateway.py:444-577 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/scripts/moveit_gateway.py#L444-L577>`__

关键方法调用
~~~~~~~~~~~~


.. list-table::
   :header-rows: 1

   * - 方法
     - 用途
     - 文件位置
   * - ``compute_ik_async()``
     - 异步 IK 计算 (pymoveit2)
     - `moveit_gateway.py:506-534 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/moveit_gateway.py#L506-L534>`__
   * - ``get_compute_ik_result()``
     - 从 future 提取关节解
     - `moveit_gateway.py:545 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/moveit_gateway.py#L545>`__
   * - ``move_to_configuration()``
     - 通过 MoveGroup 执行关节轨迹
     - `moveit_gateway.py:573 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/moveit_gateway.py#L573>`__
   * - ``create_orientation_constraint()``
     - 构建 OrientationConstraint 消息
     - `moveit_gateway.py:273-306 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/moveit_gateway.py#L273-L306>`__

**来源**：`src/robot_moveit/scripts/moveit_gateway.py:444-577 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/scripts/moveit_gateway.py#L444-L577>`__

--------------

配置集成
--------

机器人配置 YAML
~~~~~~~~~~~~~~~

``robot_config`` YAML 包含传递给启动系统的 MoveIt 特定参数：

.. code:: yaml

   moveit:
     arm_group_name: arm
     base_link: base
     ee_link: gripper
     shoulder_link: shoulder

**来源**：
`src/robot_config/config/robots/test_single_arm_single_cam.yaml:30-35 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/test_single_arm_single_cam.yaml#L30-L35>`__

启动构建器集成
~~~~~~~~~~~~~~

``robot_config`` 包中的 ``generate_moveit_nodes()`` 函数提取这些参数并传递给 MoveIt 启动文件：

.. code:: python

   arm_group_name = robot_config['moveit']['arm_group_name']
   base_link = robot_config['moveit']['base_link']
   ee_link = robot_config['moveit']['ee_link']
   shoulder_link = robot_config['moveit']['shoulder_link']

   moveit_launch = IncludeLaunchDescription(
       PythonLaunchDescriptionSource(str(moveit_launch_file)),
       launch_arguments={
           'arm_group_name': arm_group_name,
           'base_link': base_link,
           'ee_link': ee_link,
           'shoulder_link': shoulder_link,
       }.items()
   )

``shoulder_link`` 参数对肩部 XZ 平面投影策略至关重要。

**来源**：
`src/robot_config/robot_config/launch_builders/moveit.py:47-68 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/launch_builders/moveit.py#L47-L68>`__

--------------

坐标系变换
----------

工作空间分析
~~~~~~~~~~~~

``cmd_pose_callback()`` 通过将目标位置变换到肩部坐标系来记录详细的工作空间信息：

::

   1. Lookup transform: base → shoulder (translation T, rotation Q)
   2. Compute relative position: p_relative = p_base - T
   3. Apply rotation: p_shoulder = Q * p_relative
   4. Compute distances from base and shoulder origins

**日志输出示例**：

::

   [INFO] Target Pose: x=-0.046, y=-0.000, z=0.423
   [INFO]   Target in shoulder frame: x=-0.034, y=0.012, z=-0.323
   [INFO]   Distance from base origin: 0.426 m
   [INFO]   Distance from shoulder origin: 0.325 m

这有助于诊断可达性问题，因为 SO101 的典型工作空间从肩关节延伸约 0.3-0.4m。

**来源**：`src/robot_moveit/scripts/moveit_gateway.py:317-367 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/scripts/moveit_gateway.py#L317-L367>`__

--------------

性能特征
--------

典型成功率
~~~~~~~~~~


.. list-table::
   :header-rows: 1

   * - 配置
     - IK 成功率
     - 备注
   * - 标准 6DOF 约束
     - ~10-20%
     - 大多数位姿 无解
   * - ``p osition_only_ik: True`` 仅
     - ~70-80%
     - 适合位置 关键任务
   * - + Z 轴约束 + 中等容差
     - ~85-90%
     - 平衡姿态 和成功率
   * - + 完整回退 流水线
     - ~95-98%
     - 几乎总是 找到解

**来源**：`src/robot_moveit/docs/moveit_gateway.md:26-51 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/docs/moveit_gateway.md#L26-L51>`__

计算成本
~~~~~~~~

回退流水线最多测试 4 策略 × 5 容差级别 = 每个位姿命令 20 次 IK 尝试。典型时间线：

-  单次 IK 尝试：50-200ms（KDL 求解器，50 次尝试）
-  完整回退最坏情况：2-4 秒
-  典型情况（第一次策略成功）：100-300ms

**来源**：
`src/robot_moveit/config/lerobot/so101/kinematics.yaml:4-5 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/config/lerobot/so101/kinematics.yaml#L4-L5>`__

--------------

数学工具
--------

``MoveItGateway`` 类使用 ``scipy.spatial.transform.Rotation`` 和 ``numpy`` 实现四元数和旋转矩阵操作：

.. mermaid::

   classDiagram
       class MoveItGateway {
           +quaternion_multiply(q1, q2)
           +quaternion_conjugate(q)
           +quaternion_to_rotation_matrix(q)
           +rotation_matrix_to_quaternion(R)
           +constrain_to_z_axis_only(quat)
           +project_orientation_to_shoulder_xz_plane(quat)
           +create_orientation_constraint(target_quat, link_name, frame_id, tolerances)
           +cmd_pose_callback(msg)
           +solve_and_move(target_pose, orientation_tolerance)
       }
       
       class scipy_Rotation {
           <<external>>
           +from_quat(quat)
           +from_matrix(R)
           +as_quat()
           +as_matrix()
           +inv()
       }
       
       class numpy {
           <<external>>
           +linalg.norm(vec)
           +dot(a, b)
           +cross(a, b)
           +column_stack(arrays)
       }
       
       MoveItGateway --> scipy_Rotation : uses
       MoveItGateway --> numpy : uses

**图：数学依赖关系**

**来源**：`src/robot_moveit/scripts/moveit_gateway.py:81-175 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/scripts/moveit_gateway.py#L81-L175>`__

关键方法
~~~~~~~~

-  ``quaternion_multiply(q1, q2)``：使用 ``scipy`` 的 Hamilton 乘积 `moveit_gateway.py:82-90 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/moveit_gateway.py#L82-L90>`__
-  ``quaternion_conjugate(q)``：通过 ``R.inv()`` 的逆旋转 `moveit_gateway.py:93-98 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/moveit_gateway.py#L93-L98>`__
-  ``quaternion_to_rotation_matrix(q)``：通过 ``R.as_matrix()`` 的 3×3 矩阵 `moveit_gateway.py:101-107 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/moveit_gateway.py#L101-L107>`__
-  ``rotation_matrix_to_quaternion(R)``：通过 ``R.from_matrix()`` 的四元数 `moveit_gateway.py:110-116 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/moveit_gateway.py#L110-L116>`__

所有操作使用 ``[x, y, z, w]`` 四元数格式（标量在后约定）。

**来源**：`src/robot_moveit/scripts/moveit_gateway.py:81-116 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/scripts/moveit_gateway.py#L81-L116>`__

--------------

故障排除
--------

常见失败模式
~~~~~~~~~~~~


.. list-table::
   :header-rows: 1

   * - 症状
     - 可能原因
     - 解决方案
   * - ` `NO_IK_SOLUTION`` 错误
     - ` `position_only_ik: False``
     - 在 kinematics.yaml 中设置 ``posit ion_only_ik: True``
   * - 成功率低 (~20%)
     - 姿态约束过紧
     - 验证回退流水线 正在运行
   * - 超时错误
     - ``k inematics_solver_timeout`` 过低
     - 增加到 2.0+ 秒
   * - 解的姿态与 预期相差甚远
     - 仅位置模式激活
     - 添加中等容差的 姿态约束
   * - 所有策略失败
     - 目标超出工作空间
     - 检查肩部坐标系距离 （应 < 0.4m）

**来源**：`src/robot_moveit/docs/moveit_gateway.md:339-355 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/docs/moveit_gateway.md#L339-L355>`__

调试日志
~~~~~~~~

启用调试日志以查看策略尝试：

.. code:: bash

   ros2 run robot_moveit moveit_gateway.py --ros-args --log-level debug

示例输出：

::

   [DEBUG] Trying Gripper Z-axis constraint
   [DEBUG]   Failed with Strict tolerance, trying next tolerance...
   [DEBUG]   Failed with Medium tolerance, trying next tolerance...
   [INFO] IK succeeded with Gripper Z-axis constraint + Relaxed tolerance

**来源**：`src/robot_moveit/scripts/moveit_gateway.py:416-428 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/scripts/moveit_gateway.py#L416-L428>`__

--------------

**来源**：`src/robot_moveit/scripts/moveit_gateway.py:1-596 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/scripts/moveit_gateway.py#L1-L596>`__，
`src/robot_moveit/config/lerobot/so101/kinematics.yaml:1-7 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/config/lerobot/so101/kinematics.yaml#L1-L7>`__，
`src/robot_moveit/docs/moveit_gateway.md:1-389 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/docs/moveit_gateway.md#L1-L389>`__，
`src/robot_config/config/robots/test_single_arm_single_cam.yaml:30-35 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/test_single_arm_single_cam.yaml#L30-L35>`__，
`src/robot_config/robot_config/launch_builders/moveit.py:15-78 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/launch_builders/moveit.py#L15-L78>`__

--------------

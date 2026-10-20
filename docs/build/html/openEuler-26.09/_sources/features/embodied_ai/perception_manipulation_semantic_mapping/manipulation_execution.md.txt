# 操作执行

<details>
<summary>相关源码文件</summary>

以下文件被用作生成此 wiki 页面的上下文：

- [docs/so101_place_pipeline_commands.md](https://atomgit.com/openeuler/IB_Robot/blob/openEuler-26.09/docs/so101_place_pipeline_commands.md)
- [src/manipulation_execution/manipulation_execution/__init__.py](https://atomgit.com/openeuler/IB_Robot/blob/openEuler-26.09/src/manipulation_execution/manipulation_execution/__init__.py)
- [src/manipulation_execution/manipulation_execution/contact_compensation.py](https://atomgit.com/openeuler/IB_Robot/blob/openEuler-26.09/src/manipulation_execution/manipulation_execution/contact_compensation.py)
- [src/manipulation_execution/manipulation_execution/grasp_geometry.py](https://atomgit.com/openeuler/IB_Robot/blob/openEuler-26.09/src/manipulation_execution/manipulation_execution/grasp_geometry.py)
- [src/manipulation_execution/manipulation_execution/phases/execution.py](https://atomgit.com/openeuler/IB_Robot/blob/openEuler-26.09/src/manipulation_execution/manipulation_execution/phases/execution.py)
- [src/manipulation_execution/manipulation_execution/phases/flow.py](https://atomgit.com/openeuler/IB_Robot/blob/openEuler-26.09/src/manipulation_execution/manipulation_execution/phases/flow.py)
- [src/manipulation_execution/manipulation_execution/phases/planning.py](https://atomgit.com/openeuler/IB_Robot/blob/openEuler-26.09/src/manipulation_execution/manipulation_execution/phases/planning.py)
- [src/manipulation_execution/manipulation_execution/phases/preparation.py](https://atomgit.com/openeuler/IB_Robot/blob/openEuler-26.09/src/manipulation_execution/manipulation_execution/phases/preparation.py)
- [src/manipulation_execution/manipulation_execution/pick_action_client.py](https://atomgit.com/openeuler/IB_Robot/blob/openEuler-26.09/src/manipulation_execution/manipulation_execution/pick_action_client.py)
- [src/manipulation_execution/manipulation_execution/pick_executor_models.py](https://atomgit.com/openeuler/IB_Robot/blob/openEuler-26.09/src/manipulation_execution/manipulation_execution/pick_executor_models.py)
- [src/manipulation_execution/manipulation_execution/pick_executor_node.py](https://atomgit.com/openeuler/IB_Robot/blob/openEuler-26.09/src/manipulation_execution/manipulation_execution/pick_executor_node.py)
- [src/manipulation_execution/manipulation_execution/placement_executor_node.py](https://atomgit.com/openeuler/IB_Robot/blob/openEuler-26.09/src/manipulation_execution/manipulation_execution/placement_executor_node.py)
- [src/manipulation_execution/manipulation_execution/placement_replay.py](https://atomgit.com/openeuler/IB_Robot/blob/openEuler-26.09/src/manipulation_execution/manipulation_execution/placement_replay.py)
- [src/manipulation_execution/manipulation_execution/so101_geometry.py](https://atomgit.com/openeuler/IB_Robot/blob/openEuler-26.09/src/manipulation_execution/manipulation_execution/so101_geometry.py)
- [src/manipulation_execution/manipulation_execution/so101_kinematics_guard.py](https://atomgit.com/openeuler/IB_Robot/blob/openEuler-26.09/src/manipulation_execution/manipulation_execution/so101_kinematics_guard.py)
- [src/manipulation_execution/package.xml](https://atomgit.com/openeuler/IB_Robot/blob/openEuler-26.09/src/manipulation_execution/package.xml)
- [src/manipulation_execution/resource/manipulation_execution](https://atomgit.com/openeuler/IB_Robot/blob/openEuler-26.09/src/manipulation_execution/resource/manipulation_execution)
- [src/manipulation_execution/setup.cfg](https://atomgit.com/openeuler/IB_Robot/blob/openEuler-26.09/src/manipulation_execution/setup.cfg)
- [src/manipulation_execution/setup.py](https://atomgit.com/openeuler/IB_Robot/blob/openEuler-26.09/src/manipulation_execution/setup.py)
- [src/manipulation_execution/test/test_contact_compensation.py](https://atomgit.com/openeuler/IB_Robot/blob/openEuler-26.09/src/manipulation_execution/test/test_contact_compensation.py)
- [src/manipulation_execution/test/test_grasp_geometry.py](https://atomgit.com/openeuler/IB_Robot/blob/openEuler-26.09/src/manipulation_execution/test/test_grasp_geometry.py)
- [src/manipulation_execution/test/test_pick_executor_candidate_filter.py](https://atomgit.com/openeuler/IB_Robot/blob/openEuler-26.09/src/manipulation_execution/test/test_pick_executor_candidate_filter.py)
- [src/manipulation_execution/test/test_pick_executor_flow.py](https://atomgit.com/openeuler/IB_Robot/blob/openEuler-26.09/src/manipulation_execution/test/test_pick_executor_flow.py)
- [src/manipulation_execution/test/test_pick_executor_frame_time.py](https://atomgit.com/openeuler/IB_Robot/blob/openEuler-26.09/src/manipulation_execution/test/test_pick_executor_frame_time.py)
- [src/manipulation_execution/test/test_pick_executor_orientation_guard.py](https://atomgit.com/openeuler/IB_Robot/blob/openEuler-26.09/src/manipulation_execution/test/test_pick_executor_orientation_guard.py)
- [src/manipulation_execution/test/test_pick_executor_parallel.py](https://atomgit.com/openeuler/IB_Robot/blob/openEuler-26.09/src/manipulation_execution/test/test_pick_executor_parallel.py)
- [src/manipulation_execution/test/test_pick_executor_planning.py](https://atomgit.com/openeuler/IB_Robot/blob/openEuler-26.09/src/manipulation_execution/test/test_pick_executor_planning.py)
- [src/manipulation_execution/test/test_pick_executor_primitive_retry.py](https://atomgit.com/openeuler/IB_Robot/blob/openEuler-26.09/src/manipulation_execution/test/test_pick_executor_primitive_retry.py)
- [src/manipulation_execution/test/test_pick_executor_recovery.py](https://atomgit.com/openeuler/IB_Robot/blob/openEuler-26.09/src/manipulation_execution/test/test_pick_executor_recovery.py)
- [src/manipulation_execution/test/test_placement_modes.py](https://atomgit.com/openeuler/IB_Robot/blob/openEuler-26.09/src/manipulation_execution/test/test_placement_modes.py)
- [src/manipulation_execution/test/test_so101_geometry.py](https://atomgit.com/openeuler/IB_Robot/blob/openEuler-26.09/src/manipulation_execution/test/test_so101_geometry.py)
- [src/manipulation_execution/test/test_so101_kinematics_guard.py](https://atomgit.com/openeuler/IB_Robot/blob/openEuler-26.09/src/manipulation_execution/test/test_so101_kinematics_guard.py)
- [src/robot_config/config/placement_masks/so101_wrist_gripper_sam_mask.png](https://atomgit.com/openeuler/IB_Robot/blob/openEuler-26.09/src/robot_config/config/placement_masks/so101_wrist_gripper_sam_mask.png)
- [src/robot_config/robot_config/grasp_execution_config.py](https://atomgit.com/openeuler/IB_Robot/blob/openEuler-26.09/src/robot_config/robot_config/grasp_execution_config.py)
- [src/robot_config/robot_config/placement_execution_config.py](https://atomgit.com/openeuler/IB_Robot/blob/openEuler-26.09/src/robot_config/robot_config/placement_execution_config.py)
- [src/robot_config/test/test_grasp_execution_config.py](https://atomgit.com/openeuler/IB_Robot/blob/openEuler-26.09/src/robot_config/test/test_grasp_execution_config.py)
- [src/robot_config/test/test_placement_execution_config.py](https://atomgit.com/openeuler/IB_Robot/blob/openEuler-26.09/src/robot_config/test/test_placement_execution_config.py)
- [src/skill_catalog/config/skills/place_in_container/manifest.yaml](https://atomgit.com/openeuler/IB_Robot/blob/openEuler-26.09/src/skill_catalog/config/skills/place_in_container/manifest.yaml)

</details>

## 目的与范围

本页面详述操作执行基础设施（`manipulation_execution` ROS 包），它实现闭环 pick 与 place 执行器、阶段状态机、抓取几何计算、运动学守卫（特别是 SO-101 与 LeKiwi 平台）、重试与失败恢复机制。它桥接高层 agent 技能（`skill_catalog`）与底层运动原语（`moveit_gateway`、`ros2_control`）之间的鸿沟。

---

## 1. Pick 与 Place 执行器架构

操作执行引擎围绕封装多阶段生命周期状态机的 ROS action 服务器（`PickExecutorNode` 及对应的 placement 节点）构建。执行器不执行单体运动序列，而是将不同的操作阶段委托给专注的阶段 mixin。

### 节点布局与入口点

`setup.py` 暴露的控制台脚本包括 `pick_executor_node`、`place_executor_node` 及辅助回放工具 [src/manipulation_execution/setup.py:20-27](https://atomgit.com/openeuler/IB_Robot/blob/openEuler-26.09/src/manipulation_execution/setup.py#L20-L27)。

主编排器 `PickExecutorNode` 继承自多个阶段处理 mixin 与 ROS `Node` 类 [src/manipulation_execution/manipulation_execution/pick_executor_node.py:60-67](https://atomgit.com/openeuler/IB_Robot/blob/openEuler-26.09/src/manipulation_execution/manipulation_execution/pick_executor_node.py#L60-L67)：

- `PickFlowPhase`：action 服务器生命周期、反馈发布、阶段计时与 RPC 等待辅助 [src/manipulation_execution/manipulation_execution/phases/flow.py](https://atomgit.com/openeuler/IB_Robot/blob/openEuler-26.09/src/manipulation_execution/manipulation_execution/phases/flow.py)。
- `ExecutionPhase`：物理候选执行、抓取验证调用、诊断与闭合失败恢复 [src/manipulation_execution/manipulation_execution/phases/execution.py](https://atomgit.com/openeuler/IB_Robot/blob/openEuler-26.09/src/manipulation_execution/manipulation_execution/phases/execution.py)。
- `PreparationPhase`：IK/FK 候选准备、关节状态规范化与目标夹爪校验 [src/manipulation_execution/manipulation_execution/phases/preparation.py](https://atomgit.com/openeuler/IB_Robot/blob/openEuler-26.09/src/manipulation_execution/manipulation_execution/phases/preparation.py)。
- `PlanningPhase`：场景快照获取与抓取规划器服务查询。
- `PickExecutorHelpers`：用于几何与变换处理的工具函数。

```text
Title: "Pick Executor Class Architecture & Mixin Composition"

+-----------------------------------------------------------------+
|                         rclpy.node.Node                         |
+-----------------------------------------------------------------+
                                 ^
                                 | (Multiple Inheritance)
+--------------------------------+--------------------------------+
| PickExecutorNode               | - _PHASE_PROGRESS map          |
| (pick_executor_node.py)        | - Parameter configuration      |
+--------------------------------+--------------------------------+
  |-- inherits --> PickFlowPhase   (flow.py: Action orchestration)
  |-- inherits --> ExecutionPhase  (execution.py: Motion & verification)
  |-- inherits --> PreparationPhase(preparation.py: IK/FK & filtering)
  |-- inherits --> PlanningPhase   (planning.py: Scene & GPD queries)
  |-- inherits --> PickExecutorHelpers (Helper utilities)
```

来源：`src/manipulation_execution/manipulation_execution/pick_executor_node.py`, `src/manipulation_execution/manipulation_execution/phases/flow.py`, `src/manipulation_execution/setup.py`

---

## 2. 阶段状态机与执行流程

pick 执行流水线按严格的线性阶段序列推进，由 `PickExecutorNode` 中定义的 `_PHASE_PROGRESS` 百分比监控 [src/manipulation_execution/manipulation_execution/pick_executor_node.py:70-83](https://atomgit.com/openeuler/IB_Robot/blob/openEuler-26.09/src/manipulation_execution/manipulation_execution/pick_executor_node.py#L70-L83)：

```text
Title: "Pick Action Execution Phase Sequence"

[preflight: 2%] --> [observe: 8%] --> [planning: 18%] --> [selecting: 32%]
                                                                 |
                                                                 v
[release: 99%] <-- [transport: 98%] <-- [verify_close: 74%] <-- [open: 38%]
      |                                                          |
      v                                                          v
[completed: 100%]                                          [approach: 48%]
                                                                 |
                                                                 v
                                                           [descend: 60%]
                                                                 |
                                                                 v
                                                           [close: 68%]
```

### 流程状态与错误处理

执行期间，错误由 `phases/flow.py` 中的 `_is_execution_retryable()` 拦截 [src/manipulation_execution/manipulation_execution/phases/flow.py:45-52](https://atomgit.com/openeuler/IB_Robot/blob/openEuler-26.09/src/manipulation_execution/manipulation_execution/phases/flow.py#L45-L52)，它区分瞬态运动或运动学故障（如 `IK_FAILED`、`RPC_TIMEOUT`、`WORKSPACE_REJECTED`）与永久配置失败，使状态机在中止目标前尝试其他排名候选。

来源：`src/manipulation_execution/manipulation_execution/pick_executor_node.py`, `src/manipulation_execution/manipulation_execution/phases/flow.py`

---

## 3. 抓取几何、运动学守卫与验证

候选操作流程高度依赖健壮的几何评估、坐标变换与运动学边界守卫。

### 关节状态规范化与 IK 工作池

为防止非模型基座关节或无效速度/力矩数组使 MoveIt 插件崩溃，`_kinematics_joint_state()` 将传入的 `JointState` 消息过滤为仅包含带有限位置的已配置臂关节 [src/manipulation_execution/manipulation_execution/phases/preparation.py:76-108](https://atomgit.com/openeuler/IB_Robot/blob/openEuler-26.09/src/manipulation_execution/manipulation_execution/phases/preparation.py#L76-L108) [src/manipulation_execution/test/test_pick_executor_parallel.py:70-84](https://atomgit.com/openeuler/IB_Robot/blob/openEuler-26.09/src/manipulation_execution/test/test_pick_executor_parallel.py#L70-L84)。

可通过 `ik.worker_count`（最多 8 个 worker）配置并行工作池，在不饿死主控制循环的情况下并发评估候选逆运动学 [src/manipulation_execution/manipulation_execution/pick_executor_node.py:120-125](https://atomgit.com/openeuler/IB_Robot/blob/openEuler-26.09/src/manipulation_execution/manipulation_execution/pick_executor_node.py#L120-L125) [src/manipulation_execution/test/test_pick_executor_parallel.py:37-68](https://atomgit.com/openeuler/IB_Robot/blob/openEuler-26.09/src/manipulation_execution/test/test_pick_executor_parallel.py#L37-L68)。

### SO-101 / LeKiwi 运动学守卫（`so101_kinematics_guard.py`）

运动学守卫在接近与闭合阶段强制关节限制与关节 5 的分支连续性，防止线缆缠绕或奇异锁定 [src/manipulation_execution/manipulation_execution/so101_kinematics_guard.py](https://atomgit.com/openeuler/IB_Robot/blob/openEuler-26.09/src/manipulation_execution/manipulation_execution/so101_kinematics_guard.py)：

- **关节 5 绝对限制与 home 增量**：校验关节 5 保持在 home 位置的有界 epsilon 范围内 [src/manipulation_execution/test/test_pick_executor_orientation_guard.py:130-143](https://atomgit.com/openeuler/IB_Robot/blob/openEuler-26.09/src/manipulation_execution/test/test_pick_executor_orientation_guard.py#L130-L143)。
- **分支连续性**：拒绝导致执行阶段间分支突变的解。
- **朝向一致性**：迭代对齐接近轴与闭合轴到预期夹爪坐标系 [src/manipulation_execution/test/test_pick_executor_orientation_guard.py:81-94](https://atomgit.com/openeuler/IB_Robot/blob/openEuler-26.09/src/manipulation_execution/test/test_pick_executor_orientation_guard.py#L81-L94)。

```text
Title: "Grasp Candidate Preparation and Kinematics Guard Pipeline"

+-------------------+     +-----------------------     +-------------------------+
| Ranked Candidates | --> | _kinematics_joint_state()  | _solve_ik / _solve_fk   |
| (from Planner)    |     | (Filters non-arm joints)   | (MoveIt Gateway RPCs)   |
+-------------------+     +----------------------------+-------------------------+
                                                                    |
                                                                    v
+-------------------+     +----------------------------+     +-------------------------+
| PreparedCandidate | <-- | fixed_finger_envelope /    | <-- | so101_kinematics_guard  |
| Object            |     | robust_gap evaluations     |     | (Joint 5 checks & axes) |
+-------------------+     +----------------------------+     +-------------------------+
```

来源：`src/manipulation_execution/manipulation_execution/phases/preparation.py`, `src/manipulation_execution/manipulation_execution/so101_kinematics_guard.py`, `src/robot_config/robot_config/grasp_execution_config.py`

---

## 4. 重试、恢复与放置执行

### 闭合失败恢复

当抓取闭合动作失败或验证返回不确定/失败状态时，`_recover_after_close_failure()` 执行受控的撤退路径 [src/manipulation_execution/manipulation_execution/phases/execution.py:147-170](https://atomgit.com/openeuler/IB_Robot/blob/openEuler-26.09/src/manipulation_execution/manipulation_execution/phases/execution.py#L147-L170)：

1. 使用 `move_to_pose` 将末端执行器垂直提升到预抓取间隙高度。
2. 命令夹爪张开。
3. 依据策略约束重试候选选择或停止。

### 放置执行（`placement_executor_node.py`）

如配套操作文档所述 [docs/so101_place_pipeline_commands.md](https://atomgit.com/openeuler/IB_Robot/blob/openEuler-26.09/docs/so101_place_pipeline_commands.md)，`place_in_container` 依赖固定关节配置（如关节 3 的特定原始编码器目标）而非实时规划，随后在目标容器内进行 Sam2/GroundingDINO 视觉验证 [docs/so101_place_pipeline_commands.md:1-29](https://atomgit.com/openeuler/IB_Robot/blob/openEuler-26.09/docs/so101_place_pipeline_commands.md#L1-L29)。

```text
Title: "Placement Execution and Container Verification Flow"

[place_container Joint Target] --> [open_gripper] --> [Move Joint 3 to Verify Position]
                                                              |
                                                              v
[Return Joint 3 to Rest Position] <-- [Vision Mask Check] <---+
```

来源：`src/manipulation_execution/manipulation_execution/phases/execution.py`, `src/manipulation_execution/manipulation_execution/placement_executor_node.py`, `docs/so101_place_pipeline_commands.md`

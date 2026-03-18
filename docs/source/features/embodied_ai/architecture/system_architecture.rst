系统架构
========

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

本文档全面概述了 IB-Robot 系统架构，解释了组件如何组织成层级、数据如何在系统中流动，以及各个子系统如何交互以实现从数据采集到部署的端到端具身 AI 开发。

有关详细的配置规范，请参阅 `配置系统 (robot_config) <#5>`__。有关此设计背后的基本架构原则，请参阅 `核心概念 <#3>`__。有关各个子系统的详细信息，请参阅 `推理服务 <#7>`__、`动作分发 <#8>`__ 和 `数据流水线 <#9>`__。

--------------

架构概述
--------

IB-Robot 实现了分层架构，每一层为其上层提供明确定义的抽象。系统围绕**单一数据源**原则组织，其中 ``robot_config`` YAML 文件通过契约驱动的合成来驱动所有子系统的行为。

系统层级
~~~~~~~~

.. mermaid::

   graph TB
       subgraph "Layer 1: Global Management"
           RC["robot_config<br/>(Single Source of Truth)<br/>YAML configuration"]
           MSGS["ibrobot_msgs<br/>(Interface Definitions)<br/>Action/Message types"]
       end
       
       subgraph "Layer 2: Application & Planning"
           MOVEIT["robot_moveit<br/>(Motion Planning)<br/>MoveItGateway"]
           TELEOP["robot_teleop<br/>(Teleoperation)<br/>VR/Xbox/IMU control"]
       end
       
       subgraph "Layer 3: Inference & Dispatch"
           INFSVC["inference_service<br/>(Policy Inference)<br/>lerobot_policy_node<br/>pure_inference_node"]
           ACTDISP["action_dispatch<br/>(Action Execution)<br/>action_dispatcher_node<br/>TemporalSmoother"]
       end
       
       subgraph "Layer 4: Protocol Conversion"
           TENSORMSG["tensormsg<br/>(ROS↔Tensor Bridge)<br/>TensorMsgConverter<br/>decode_value"]
       end
       
       subgraph "Layer 5: Data Collection"
           RECORDER["dataset_tools<br/>(Episode Recording)<br/>episode_recorder<br/>bag_to_lerobot"]
       end
       
       subgraph "Layer 6: Control Abstraction"
           ROS2CTRL["ros2_control<br/>(Hardware Interface)<br/>position_controllers<br/>trajectory_controllers"]
           DESC["robot_description<br/>(URDF/SRDF)<br/>Robot models"]
       end
       
       subgraph "Layer 7: Hardware/Simulation"
           HW["so101_hardware<br/>(Feetech SDK)<br/>SO101Hardware"]
           SIM["Gazebo<br/>(gz_ros2_control)<br/>Physics simulation"]
       end
       
       RC -.->|"defines specs"| INFSVC
       RC -.->|"defines specs"| ACTDISP
       RC -.->|"defines specs"| RECORDER
       RC -.->|"defines specs"| ROS2CTRL
       RC -.->|"defines specs"| MOVEIT
       
       MSGS -.->|"types"| INFSVC
       MSGS -.->|"types"| ACTDISP
       MSGS -.->|"types"| RECORDER
       
       MOVEIT -->|"trajectories"| ACTDISP
       TELEOP -->|"commands"| ACTDISP
       INFSVC -->|"action chunks"| ACTDISP
       
       ACTDISP -->|"actions"| TENSORMSG
       TENSORMSG -->|"observations"| INFSVC
       
       RECORDER -->|"subscribes via"| TENSORMSG
       
       TENSORMSG -->|"Float64MultiArray<br/>JointTrajectory"| ROS2CTRL
       ROS2CTRL -->|"JointState"| TENSORMSG
       
       DESC -.->|"URDF"| ROS2CTRL
       DESC -.->|"SRDF"| MOVEIT
       
       ROS2CTRL -->|"hardware_interface"| HW
       ROS2CTRL -->|"hardware_interface"| SIM

**来源：** `README.md:18-43 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L18-L43>`__, `docs/architecture.md:86-177 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/docs/architecture.md#L86-L177>`__,
`src/README.md:20-44 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/README.md#L20-L44>`__

--------------

包架构与依赖
------------

系统由 10 个核心 ROS 2 包组成，具有明确定义的职责和依赖关系。

核心包层次结构
~~~~~~~~~~~~~~

.. mermaid::

   graph LR
       subgraph "Configuration & Interfaces"
           RC["robot_config"]
           MSGS["ibrobot_msgs"]
       end
       
       subgraph "Perception & Data"
           RECORDER["dataset_tools"]
           TENSORMSG["tensormsg"]
       end
       
       subgraph "Execution & Planning"
           INFSVC["inference_service"]
           ACTDISP["action_dispatch"]
           TELEOP["robot_teleop"]
           MOVEIT["robot_moveit"]
       end
       
       subgraph "Hardware & Description"
           DESC["robot_description"]
           HW["so101_hardware"]
       end
       
       RC -->|"depends on"| MSGS
       
       RECORDER -->|"depends on"| RC
       RECORDER -->|"depends on"| MSGS
       RECORDER -->|"uses"| TENSORMSG
       
       TENSORMSG -->|"depends on"| RC
       TENSORMSG -->|"depends on"| MSGS
       
       INFSVC -->|"depends on"| RC
       INFSVC -->|"depends on"| MSGS
       INFSVC -->|"uses"| TENSORMSG
       
       ACTDISP -->|"depends on"| RC
       ACTDISP -->|"depends on"| MSGS
       ACTDISP -->|"uses"| TENSORMSG
       
       TELEOP -->|"depends on"| RC
       
       MOVEIT -->|"depends on"| RC
       MOVEIT -->|"depends on"| DESC
       
       HW -->|"independent"| RC
       HW -->|"uses URDF from"| DESC

**包职责矩阵：**


.. list-table::
   :header-rows: 1

   * - 包
     - 主要职责
     - 关键类/节点
     - 依赖
   * - ``robot_config``
     - 配置管理、启动编排
     - ``load_robot_config``, ``robot.launch.py``, ``launch_builders/*``
     - ``ibrobot_msgs``
   * - ``ibrobot_msgs``
     - 接口定义
     - ``DispatchInfer.action``, ``RecordEpisode.action``, ``VariantsList.msg``
     - None
   * - ``tensormsg``
     - ROS↔张量协议转换
     - ``TensorMsgConverter``, ``decode_value``, ``StreamBuffer``
     - ``robot_config``, ``ibrobot_msgs``
   * - ``inference_service``
     - 策略推理（单体/分布式）
     - ``lerobot_policy_node``, ``pure_inference_node``, ``InferenceCoordinator``
     - ``robot_config``, ``tensormsg``
   * - ``action_dispatch``
     - 带时间平滑的动作执行
     - ``action_dispatcher_node``, ``TemporalSmoother``, ``TopicExecutor``
     - ``robot_config``, ``tensormsg``
   * - ``dataset_tools``
     - Episode 录制和数据集转换
     - ``episode_recorder``, ``bag_to_lerobot``, ``record_cli``
     - ``robot_config``, ``tensormsg``
   * - ``robot_teleop``
     - 遥操作接口
     - 遥操作节点 VR/Xbox/IMU
     - ``robot_config``
   * - ``robot_moveit``
     - 运动规划集成
     - ``MoveItGateway``, MoveIt 配置
     - ``robot_config``, ``robot_description``
   * - ``robot_description``
     - 机器人模型定义
     - URDF, SRDF, 网格
     - None
   * - ``so101_hardware``
     - 硬件驱动
     - ``SO101Hardware`` (ros2_control 插件)
     - None（仅 C++）

**来源：** `README.md:44-71 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L44-L71>`__, `src/README.md:49-84 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/README.md#L49-L84>`__,
`docs/architecture.md:216-265 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/docs/architecture.md#L216-L265>`__

--------------

配置驱动架构
------------

整个系统由 ``robot_config`` YAML 文件驱动，该文件作为所有系统规范的单一数据源。

配置流程
~~~~~~~~

.. mermaid::

   graph TB
       YAML["robot_config YAML<br/>so101_single_arm.yaml"]
       
       subgraph "Configuration Sections"
           ROBOT["robot:<br/>name, joints, models"]
           PERIPH["peripherals:<br/>cameras, sensors"]
           CONTRACT["contract:<br/>observations, actions"]
           MODES["control_modes:<br/>teleop, model_inference,<br/>moveit_planning"]
           ROS2C["ros2_control:<br/>controllers, hardware"]
       end
       
       YAML -->|"parsed by"| LOADER["load_robot_config()<br/>robot_config/loader.py"]
       
       LOADER --> ROBOT
       LOADER --> PERIPH
       LOADER --> CONTRACT
       LOADER --> MODES
       LOADER --> ROS2C
       
       CONTRACT -->|"to_contract()"| CONTRACTOBJ["Contract 对象<br/>ObservationSpec[]<br/>ActionSpec[]"]
       
       CONTRACTOBJ -->|"consumed by"| RECORDER["episode_recorder"]
       CONTRACTOBJ -->|"consumed by"| BAG2LR["bag_to_lerobot"]
       CONTRACTOBJ -->|"consumed by"| INFNODE["lerobot_policy_node"]
       CONTRACTOBJ -->|"consumed by"| DISPNODE["action_dispatcher_node"]
       
       MODES -->|"selects"| ACTMODE["Active Control Mode"]
       ACTMODE -->|"determines"| LAUNCH["Launch Configuration<br/>launch_builders"]
       
       LAUNCH -->|"generates"| CTRLNODES["Control Nodes"]
       LAUNCH -->|"generates"| INFNODES["Inference Nodes"]
       LAUNCH -->|"generates"| EXECNODES["Execution Nodes"]
       
       ROS2C -->|"spawns"| CONTROLLERS["Controller Manager<br/>position_controllers<br/>trajectory_controllers"]

**关键配置文件：**

-  主配置：`src/robot_config/config/robots/so101_single_arm.yaml <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml>`__
-  加载器：`src/robot_config/robot_config/loader.py <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/loader.py>`__
-  启动编排器：
   `src/robot_config/launch/robot.launch.py:87-121 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/launch/robot.launch.py#L87-L121>`__
-  启动构建器：
   `src/robot_config/robot_config/launch_builders/ <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/launch_builders/>`__

**配置到代码映射：**


.. list-table::
   :header-rows: 1

   * - 配置节
     - 代码消费者
     - 关键函数
   * - ``contract.observations``
     - ``lero bot_policy_node``
     - ``_s etup_observation_ subscriptions()`` `src/inference_service/inference_service/lerobot_policy_node.py:242-283 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/lerobot_policy_node.py#L242-L283>`__
   * - ``contract.actions``
     - ``action_ dispatcher_node``
     - ``TopicExec utor.__init__()`` `src/acti on_dispatch/actio n_dispatch/topic_ executor.py <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/acti on_dispatch/actio n_dispatch/topic_ executor.py>`__
   * - ``control_modes``
     - `` robot.launch.py``
     - ` `launch_setup()`` `src/robot_config/launch/robot.launch.py:123-300 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/launch/robot.launch.py#L123-L300>`__
   * - ``models``
     - ``generate_inference_node()``
     - `src/robot_config/robot_config/launch_builders/execution.py:61-157 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/launch_builders/execution.py#L61-L157>`__
   * - ``peripherals``
     - ``generate _camera_nodes()``
     - `src/robot_conf ig/robot_config/l aunch_builders/pe rception.py <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_conf ig/robot_config/l aunch_builders/pe rception.py>`__
   * - ` `ros2_control.controllers``
     - ``generate_ros2_ control_nodes()``
     - `src/robot_c onfig/robot_confi g/launch_builders /control.py <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_c onfig/robot_confi g/launch_builders /control.py>`__

**来源：**
`src/robot_config/config/robots/so101_single_arm.yaml <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml>`__,
`src/robot_config/launch/robot.launch.py:87-175 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/launch/robot.launch.py#L87-L175>`__,
`src/robot_config/robot_config/launch_builders/execution.py:20-157 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/launch_builders/execution.py#L20-L157>`__

--------------

数据流架构
----------

观测流（传感器 → 推理）
~~~~~~~~~~~~~~~~~~~~~~~~~~

.. mermaid::

   graph LR
       CAM["Cameras<br/>/camera/cam_top/image_raw<br/>/camera/cam_wrist/image_raw"]
       JS["Joint State Publisher<br/>/joint_states"]
       
       CAM -->|"sensor_msgs/Image"| OBSCB["_obs_cb()<br/>lerobot_policy_node"]
       JS -->|"sensor_msgs/JointState"| OBSCB
       
       OBSCB -->|"decode_value()"| DECODED["解码后的 numpy 数组<br/>HWC 图像<br/>关节位置"]
       
       DECODED -->|"push(ts, val)"| STREAMBUF["StreamBuffer<br/>每主题 FIFO<br/>带时间戳"]
       
       STREAMBUF -->|"sample(t)"| OBSFRAME["_sample_obs_frame()<br/>Dict[str, np.ndarray]"]
       
       OBSFRAME -->|"observations"| PREPROC["TensorPreprocessor<br/>resize, normalize<br/>stack history"]
       
       PREPROC -->|"batch"| INFENG["PureInferenceEngine<br/>policy.select_action()"]
       
       INFENG -->|"action tensor"| POSTPROC["TensorPostprocessor<br/>denormalize<br/>safety clipping"]
       
       POSTPROC -->|"VariantsList"| DISPINFER["DispatchInfer.Result<br/>action_chunk"]

**关键代码路径：**

1. **观测回调：**
   `src/inference_service/inference_service/lerobot_policy_node.py:381-397 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/lerobot_policy_node.py#L381-L397>`__

   -  ``_obs_cb(msg, spec)`` 接收 ROS 消息
   -  调用来自
      `src/robot_config/robot_config/contract_utils.py <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/contract_utils.py>`__ 的 ``decode_value()``
   -  推送到 ``StreamBuffer`` 进行时间对齐

2. **观测采样：**
   `src/inference_service/inference_service/lerobot_policy_node.py:399-420 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/lerobot_policy_node.py#L399-L420>`__

   -  ``_sample_obs_frame(sample_t_ns)`` 在特定时间戳查询所有缓冲区
   -  处理多个 ``observation.state`` 流（拼接）
   -  对缺失数据返回零填充值

3. **预处理：**
   `src/inference_service/inference_service/core/preprocessor.py <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/core/preprocessor.py>`__

   -  ``TensorPreprocessor.__call__(obs_frame)`` 准备模型输入
   -  调整图像大小、归一化值、堆叠时间历史

**来源：**
`src/inference_service/inference_service/lerobot_policy_node.py:381-420 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/lerobot_policy_node.py#L381-L420>`__,
`src/robot_config/robot_config/contract_utils.py <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/contract_utils.py>`__,
`src/inference_service/inference_service/core/preprocessor.py <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/core/preprocessor.py>`__

动作流（推理 → 硬件）
~~~~~~~~~~~~~~~~~~~~~~~

.. mermaid::

   graph LR
       INFRESULT["推理结果<br/>VariantsList<br/>action chunk (N, action_dim)"]
       
       INFRESULT -->|"TensorMsgConverter.from_variant()"| DECODE["解码为<br/>torch.Tensor 或 np.ndarray"]
       
       DECODE -->|"actions_executed"| SMOOTHER["TemporalSmoother<br/>update(action_chunk, actions_executed)"]
       
       SMOOTHER -->|"指数加权混合"| BLENDED["混合后的动作<br/>平滑重叠区域"]
       
       BLENDED -->|"deque or plan"| QUEUE["动作队列<br/>100 Hz 控制循环"]
       
       QUEUE -->|"get_next_action()"| TOPICEXEC["TopicExecutor<br/>按契约路由"]
       
       TOPICEXEC -->|"Float64MultiArray"| POSCTRL["/arm_position_controller/commands<br/>/gripper_position_controller/commands"]
       
       POSCTRL -->|"FollowJointTrajectory"| ROS2CTRL["ros2_control<br/>PositionJointInterface"]
       
       ROS2CTRL -->|"write()"| HW["so101_hardware<br/>Feetech SDK"]

**关键代码路径：**

1. **动作解码：**
   `src/action_dispatch/action_dispatch/action_dispatcher_node.py:232-278 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatch/action_dispatcher_node.py#L232-L278>`__

   -  ``_result_cb()`` 接收 ``DispatchInfer.Result``
   -  通过 ``TensorMsgConverter.from_variant()`` 将 ``VariantsList`` 转换为 numpy/tensor

2. **时间平滑：**
   `src/action_dispatch/action_dispatch/temporal_smoother.py <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatch/temporal_smoother.py>`__

   -  ``TemporalSmoother.update(action_chunk, actions_executed)`` 对齐并混合
   -  计算
      ``actions_executed = plan_length_at_start - current_plan_length``
   -  应用指数加权：``weight[k] = exp(-coeff * k)``

3. **动作执行：**
   `src/action_dispatch/action_dispatch/action_dispatcher_node.py:172-201 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatch/action_dispatcher_node.py#L172-L201>`__

   -  ``_control_loop()`` 以 100 Hz 运行
   -  从队列/平滑器弹出下一个动作
   -  ``TopicExecutor.execute(action)`` 发布到控制器主题

**来源：**
`src/action_dispatch/action_dispatch/action_dispatcher_node.py:172-278 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatch/action_dispatcher_node.py#L172-L278>`__,
`src/action_dispatch/action_dispatch/temporal_smoother.py <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatch/temporal_smoother.py>`__,
`src/action_dispatch/action_dispatch/topic_executor.py <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatch/topic_executor.py>`__

--------------

控制模式架构
------------

IB-Robot 支持三种不同的控制模式，它们汇聚到同一个 ``ros2_control`` 硬件接口。

控制模式选择与路由
~~~~~~~~~~~~~~~~~~

.. mermaid::

   graph TB
       LAUNCH["robot.launch.py<br/>--control_mode parameter"]
       YAML["default_control_mode<br/>from robot_config YAML"]
       
       LAUNCH -->|"overrides"| ROUTER["控制模式路由器<br/>launch_setup()"]
       YAML -->|"default"| ROUTER
       
       ROUTER -->|"teleop"| TELEOPMODE["遥操作模式"]
       ROUTER -->|"model_inference"| MODELMODE["模型推理模式"]
       ROUTER -->|"moveit_planning"| MOVEITMODE["MoveIt 规划模式"]
       
       subgraph "Mode 1: 遥操作"
           TELEOPDEV["VR/Xbox/IMU 设备"]
           TELEOPNODE["robot_teleop 节点"]
           TELEOPEXEC["TopicExecutor<br/>直接位置控制"]
           
           TELEOPDEV --> TELEOPNODE
           TELEOPNODE --> TELEOPEXEC
       end
       
       subgraph "Mode 2: 模型推理"
           INFNODE["lerobot_policy_node"]
           DISPNODE["action_dispatcher_node"]
           TOPICEXEC["TopicExecutor<br/>100Hz 流式传输"]
           
           INFNODE -->|"action chunks"| DISPNODE
           DISPNODE --> TOPICEXEC
       end
       
       subgraph "Mode 3: MoveIt 规划"
           POSECMD["/cmd_pose<br/>位姿命令"]
           MOVEITGW["MoveItGateway<br/>IK + 规划"]
           ACTIONEXEC["ActionExecutor<br/>FollowJointTrajectory"]
           
           POSECMD --> MOVEITGW
           MOVEITGW --> ACTIONEXEC
       end
       
       TELEOPEXEC --> ROS2CTRL["ros2_control<br/>Hardware Interface"]
       TOPICEXEC --> ROS2CTRL
       ACTIONEXEC --> ROS2CTRL
       
       ROS2CTRL --> HWCHOICE{"use_sim?"}
       HWCHOICE -->|"false"| REAL["so101_hardware"]
       HWCHOICE -->|"true"| SIM["Gazebo gz_ros2_control"]

**控制模式配置：**

每种模式在机器人配置 YAML 的 ``control_modes`` 节中定义：

.. code:: yaml

   control_modes:
     teleop:
       controllers: [arm_position_controller, gripper_position_controller]
       inference:
         enabled: false
     
     model_inference:
       controllers: [arm_position_controller, gripper_position_controller]
       inference:
         enabled: true
         model: act_policy
         execution_mode: monolithic  # or distributed
       executor:
         type: topic
     
     moveit_planning:
       controllers: [arm_trajectory_controller, gripper_trajectory_controller]
       inference:
         enabled: false
       executor:
         type: action

**模式选择逻辑：**
`src/robot_config/launch/robot.launch.py:176-196 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/launch/robot.launch.py#L176-L196>`__

**来源：** `src/robot_config/launch/robot.launch.py:123-300 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/launch/robot.launch.py#L123-L300>`__,
`src/robot_config/config/robots/so101_single_arm.yaml <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml>`__,
`README.md:121-154 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L121-L154>`__

--------------

推理执行模式
------------

推理服务支持两种执行架构：**单体**\ （一体化进程）和**分布式**\ （边缘-云端分离）。

单体模式架构
~~~~~~~~~~~~

.. mermaid::

   graph TB
       SENSORS["传感器<br/>相机 + JointState"]
       
       subgraph "lerobot_policy_node 进程"
           COORD["InferenceCoordinator"]
           
           subgraph "零拷贝流水线"
               PRE["TensorPreprocessor<br/>CPU 预处理"]
               ENG["PureInferenceEngine<br/>GPU 推理<br/>policy.select_action()"]
               POST["TensorPostprocessor<br/>CPU 后处理"]
           end
           
           COORD --> PRE
           PRE -->|"torch.Tensor<br/>(无序列化)"| ENG
           ENG -->|"torch.Tensor<br/>(无序列化)"| POST
       end
       
       SENSORS -->|"ROS topics"| COORD
       POST -->|"VariantsList"| DISP["action_dispatcher_node"]
       DISP --> ROBOT["机器人控制"]

**关键实现：**
`src/inference_service/inference_service/lerobot_policy_node.py:285-304 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/lerobot_policy_node.py#L285-L304>`__

-  ``_setup_monolithic_mode()`` 创建 ``InferenceCoordinator``
-  所有组件在同一进程中运行，共享内存
-  预处理、推理和后处理之间零序列化开销
-  ``_execute_monolithic()`` 位于
   `src/inference_service/inference_service/lerobot_policy_node.py:491-493 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/lerobot_policy_node.py#L491-L493>`__

分布式模式架构
~~~~~~~~~~~~~~

.. mermaid::

   graph TB
       subgraph "设备节点（机器人 CPU）"
           SENSORS["传感器"]
           EDGENODE["lerobot_policy_node<br/>(边缘代理)"]
           PRE["TensorPreprocessor<br/>仅 CPU"]
           POST["TensorPostprocessor<br/>仅 CPU"]
           
           SENSORS --> EDGENODE
           EDGENODE --> PRE
           POST --> DISP["action_dispatcher_node"]
       end
       
       subgraph "云端节点（GPU 服务器）"
           CLOUDNODE["pure_inference_node"]
           ENG["PureInferenceEngine<br/>GPU 推理"]
           
           CLOUDNODE --> ENG
       end
       
       PRE -->|"/preprocessed/batch<br/>VariantsList<br/>ROS2 topic"| CLOUDNODE
       ENG -->|"/inference/action<br/>VariantsList<br/>ROS2 topic"| POST
       
       DISP --> ROBOT["机器人控制"]

**关键实现：**
`src/inference_service/inference_service/lerobot_policy_node.py:306-351 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/lerobot_policy_node.py#L306-L351>`__

1. **边缘节点设置：** ``_setup_distributed_mode()``

   -  创建 ``TensorPreprocessor`` 和 ``TensorPostprocessor`` (仅 CPU)
   -  在 ``/preprocessed/batch`` 上发布，订阅 ``/inference/action``
   -  维护 ``_pending_requests`` 字典，使用 threading.Event 进行同步

2. **分布式执行：**
   `src/inference_service/inference_service/lerobot_policy_node.py:495-554 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/lerobot_policy_node.py#L495-L554>`__

   -  ``_execute_distributed()`` 在本地预处理
   -  生成 UUID ``request_id``，嵌入批次中
   -  发布到云端，阻塞等待 ``threading.Event.wait(timeout)``
   -  云端结果回调 ``_cloud_result_callback()`` 通过 ``request_id`` 匹配

3. **云端节点：**
   `src/inference_service/inference_service/pure_inference_node.py <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/pure_inference_node.py>`__

   -  纯 GPU 推理服务
   -  订阅 ``/preprocessed/batch``，发布到 ``/inference/action``
   -  在结果中添加 ``_latency_ms``

**配置：**

.. code:: yaml

   inference:
     execution_mode: distributed  # or monolithic
     request_timeout: 5.0
     cloud_inference_topic: /preprocessed/batch
     cloud_result_topic: /inference/action

**来源：**
`src/inference_service/inference_service/lerobot_policy_node.py:285-584 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/lerobot_policy_node.py#L285-L584>`__,
`src/inference_service/inference_service/pure_inference_node.py <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/pure_inference_node.py>`__,
`src/inference_service/README.en.md:1-130 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/README.en.md#L1-L130>`__

--------------

数据采集与训练流水线
--------------------

录制架构
~~~~~~~~

.. mermaid::

   graph TB
       HUMAN["人类专家"]
       CONTROLLER["VR/Xbox/IMU 控制器"]
       ROBOT["物理机器人"]
       
       HUMAN --> CONTROLLER
       CONTROLLER -->|"遥操作命令"| TELEOPNODE["robot_teleop"]
       TELEOPNODE --> ROBOT
       
       SENSORS["相机 + 关节状态"]
       ROBOT --> SENSORS
       
       RECORDCLI["record_cli<br/>(交互式提示)"]
       
       RECORDCLI -->|"RecordEpisode.Goal<br/>(operator_prompt)"| RECORDER["episode_recorder<br/>Action Server"]
       
       SENSORS -->|"订阅（持久）"| RECORDER
       
       RECORDER -->|"rosbag2_py.SequentialWriter"| BAG["ROS2 Bag<br/>/tmp/episodes/<timestamp><br/>MCAP 格式"]
       
       BAG -->|"metadata.yaml"| META["Episode 元数据<br/>operator_prompt<br/>duration_ns<br/>contract fingerprint"]

**录制实现：**
`src/dataset_tools/dataset_tools/episode_recorder.py:161-274 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/dataset_tools/episode_recorder.py#L161-L274>`__

1. **持久订阅：** 在节点启动时为所有契约主题创建

   -  ``_make_sub()`` 使用契约驱动的 QoS 创建订阅
   -  除非 ``_flags.is_recording``，否则回调为空操作

2. **Episode 生命周期：**

   -  ``execute_callback()`` 开始录制
      `src/dataset_tools/dataset_tools/episode_recorder.py:351-493 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/dataset_tools/episode_recorder.py#L351-L493>`__
   -  使用唯一目录打开 ``rosbag2_py.SequentialWriter``
   -  从 ``contract.max_duration_s`` 创建超时定时器
   -  按接收顺序直接写入消息（无缓冲）

3. **元数据注入：**
   `src/dataset_tools/dataset_tools/episode_recorder.py:494-547 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/dataset_tools/episode_recorder.py#L494-L547>`__

   -  关闭写入器后，修改 ``metadata.yaml``
   -  在 ``custom_data`` 字段中嵌入 ``operator_prompt``

数据集转换流水线
~~~~~~~~~~~~~~~~

.. mermaid::

   graph LR
       BAG["ROS2 Bag 文件<br/>(MCAP)"]
       
       BAG -->|"rosbag2_py.SequentialReader"| B2L["bag_to_lerobot<br/>转换脚本"]
       
       CONTRACT["robot_config YAML<br/>(Contract)"]
       CONTRACT -.->|"定义规范"| B2L
       
       B2L -->|"1. decode_value()"| DECODED["解码后的流<br/>每主题"]
       B2L -->|"2. resample()"| RESAMPLED["按 rate_hz 重采样<br/>对齐时间戳"]
       B2L -->|"3. feature_from_spec()"| FEATURES["LeRobot 特征<br/>张量形状"]
       
       RESAMPLED -->|"每帧"| WRITER["LeRobotDataset.add_frame()"]
       
       WRITER --> LRDS["LeRobot v3 数据集<br/>videos/*.mp4<br/>data/*.parquet<br/>meta/info.json"]

**转换实现：**
`src/dataset_tools/dataset_tools/bag_to_lerobot.py:233-648 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/dataset_tools/bag_to_lerobot.py#L233-L648>`__

1. **契约加载：**
   `src/dataset_tools/dataset_tools/bag_to_lerobot.py:216-230 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/dataset_tools/bag_to_lerobot.py#L216-L230>`__

   -  ``_load_contract_from_robot_config()`` 加载用于录制的相同契约
   -  确保训练-部署对齐

2. **流规划：**
   `src/dataset_tools/dataset_tools/bag_to_lerobot.py:151-210 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/dataset_tools/bag_to_lerobot.py#L151-L210>`__

   -  ``_plan_streams()`` 将契约规范映射到 bag 主题
   -  为每个主题创建 ``_Stream`` 缓冲区

3. **重采样：**
   `src/dataset_tools/dataset_tools/bag_to_lerobot.py:521-531 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/dataset_tools/bag_to_lerobot.py#L521-L531>`__

   -  应用来自 contract_utils 的 ``resample()``
   -  使用每个规范的 ``resample_policy`` （hold/asof/drop）
   -  按 ``contract.rate_hz`` 对齐到统一的 ``ticks_ns``

4. **特征生成：**
   `src/dataset_tools/dataset_tools/bag_to_lerobot.py:288-362 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/dataset_tools/bag_to_lerobot.py#L288-L362>`__

   -  ``feature_from_spec()`` 创建 LeRobot 兼容的特征字典
   -  处理图像/视频编码、浮点数组、任务字符串

**来源：**
`src/dataset_tools/dataset_tools/episode_recorder.py:161-547 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/dataset_tools/episode_recorder.py#L161-L547>`__,
`src/dataset_tools/dataset_tools/bag_to_lerobot.py:216-648 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/dataset_tools/bag_to_lerobot.py#L216-L648>`__,
`src/dataset_tools/README.md <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/README.md>`__

--------------

动作分发与时间平滑
------------------

``action_dispatcher_node`` 实现了一个复杂的拉取式执行系统，具有跨帧时间平滑功能用于动作块。

分发架构
~~~~~~~~

.. mermaid::

   graph TB
       TIMER["控制循环定时器<br/>100 Hz"]
       
       TIMER --> CHECK{"队列长度<br/>< watermark?"}
       
       CHECK -->|"是"| REQUEST["发送 DispatchInfer Goal<br/>记录 plan_length_at_start"]
       CHECK -->|"否"| EXECUTE
       
       REQUEST -->|"异步 action client"| INFSERVER["lerobot_policy_node<br/>DispatchInfer Server"]
       
       INFSERVER -->|"Result<br/>VariantsList"| RESULT["_result_cb()"]
       
       RESULT -->|"解码"| TENSOR["action_chunk 张量<br/>(N, action_dim)"]
       
       TENSOR -->|"计算 actions_executed"| ALIGN["时间对齐<br/>actions_executed =<br/>plan_at_start - current_plan"]
       
       ALIGN -->|"TemporalSmoother.update()"| SMOOTH["指数加权混合<br/>weight[k] = exp(-coeff * k)<br/>混合重叠区域"]
       
       SMOOTH --> QUEUE["动作队列/计划<br/>(平滑后)"]
       
       CHECK -->|"否"| EXECUTE["执行下一个动作"]
       QUEUE --> EXECUTE
       
       EXECUTE -->|"TopicExecutor.execute()"| TOPICS["控制器主题<br/>/arm_position_controller/commands<br/>/gripper_position_controller/commands"]

**关键实现细节：**

1. **控制循环：**
   `src/action_dispatch/action_dispatch/action_dispatcher_node.py:172-201 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatch/action_dispatcher_node.py#L172-L201>`__

   -  以 100 Hz 运行（通过 ``control_frequency`` 参数配置）
   -  发布队列大小和平滑状态诊断
   -  当 ``plan_length < watermark`` 时触发推理

2. **推理请求：**
   `src/action_dispatch/action_dispatch/action_dispatcher_node.py:203-220 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatch/action_dispatcher_node.py#L203-L220>`__

   -  在发送目标前记录 ``_plan_length_at_inference_start``
   -  异步 action client 模式，带 future 回调

3. **结果处理：**
   `src/action_dispatch/action_dispatch/action_dispatcher_node.py:232-278 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatch/action_dispatcher_node.py#L232-L278>`__

   -  计算 ``actions_executed = plan_at_start - current_plan``
   -  路由到 ``TemporalSmoother.update()`` 或简单队列替换

时间平滑算法
~~~~~~~~~~~~

时间平滑器解决了在执行前一个动作块时新推理完成时的动作块对齐问题：

.. mermaid::

   graph TB
       subgraph "第一次推理 (t=0)"
           A1["[a1, a2, a3, a4, a5, a6, a7, a8, a9, a10]<br/>chunk_size=10"]
       end
       
       subgraph "执行期间 (t=inference_latency)"
           EXEC["已执行: [a1, a2, a3]<br/>剩余: [a4, a5, a6, a7, a8, a9, a10]<br/>actions_executed=3"]
       end
       
       subgraph "第二次推理 (t=inference_latency)"
           A2["[b1, b2, b3, b4, b5, b6, b7, b8, b9, b10]<br/>新 chunk_size=10"]
       end
       
       subgraph "对齐"
           SKIP["跳过过时: [b1, b2, b3]<br/>相关: [b4, b5, b6, b7, b8, b9, b10]"]
       end
       
       subgraph "平滑"
           OLD["旧计划: [a4, a5, a6, a7, a8, a9, a10]<br/>count=[1, 1, 1, 1, 1, 1, 1]"]
           NEW["新计划: [b4, b5, b6, b7, b8, b9, b10]"]
           OVERLAP["重叠区域: 7 个动作<br/>新尾部: [b8, b9, b10] (本例中无)"]
           
           BLEND["混合[i] =<br/>(old[i] * cumsum[count[i]-1] +<br/>new[i] * weight[count[i]]) /<br/>cumsum[count[i]]<br/><br/>weight[k] = exp(-0.01 * k)<br/>cumsum[k] = sum(weight[0..k])"]
       end
       
       A1 --> EXEC
       EXEC --> A2
       A2 --> SKIP
       SKIP --> OLD
       SKIP --> NEW
       OLD --> OVERLAP
       NEW --> OVERLAP
       OVERLAP --> BLEND
       
       BLEND --> FINAL["最终平滑计划:<br/>[blend(a4,b4), blend(a5,b5), ..., blend(a10,b10)]<br/>长度: 7"]

**平滑实现：**
`src/action_dispatch/action_dispatch/temporal_smoother.py <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatch/temporal_smoother.py>`__

1. **更新方法：**

   .. code:: python

      def update(self, new_actions: torch.Tensor, actions_executed: int) -> int:
          # 对齐：跳过已执行的动作
          relevant_new = new_actions[actions_executed:]

          # 确定重叠和新尾部
          overlap_len = min(len(self._plan), len(relevant_new))

          # 用指数权重混合重叠区域
          for i in range(overlap_len):
              self._count[i] += 1
              weight = self._temporal_weights[self._count[i]]
              cumsum = self._cumulative_sum[self._count[i]]

              blended = (self._plan[i] * cumsum_prev + relevant_new[i] * weight) / cumsum
              self._plan[i] = blended

          # 追加新尾部
          self._plan.extend(relevant_new[overlap_len:])

2. **权重预计算：**
   `src/action_dispatch/action_dispatch/temporal_smoother.py <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatch/temporal_smoother.py>`__

   -  预计算 ``weight[k] = exp(-temporal_ensemble_coeff * k)`` 对于
      k=0..chunk_size
   -  预计算 ``cumulative_sum[k]`` 用于快速混合
   -  默认 ``temporal_ensemble_coeff = 0.01`` （来自 ACT 论文）

**来源：**
`src/action_dispatch/action_dispatch/action_dispatcher_node.py:49-301 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatch/action_dispatcher_node.py#L49-L301>`__,
`src/action_dispatch/action_dispatch/temporal_smoother.py <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatch/temporal_smoother.py>`__,
`src/action_dispatch/README.en.md:212-342 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/README.en.md#L212-L342>`__

--------------

启动系统与节点生成
------------------

启动系统使用模块化构建器模式，每个子系统都有专用的构建器模块。

启动构建器架构
~~~~~~~~~~~~~~

.. mermaid::

   graph TB
       MAIN["robot.launch.py<br/>launch_setup()"]
       
       MAIN -->|"加载"| YAML["robot_config YAML"]
       MAIN -->|"确定"| MODE["活动控制模式"]
       
       MAIN -->|"调用"| BUILDERS["启动构建器"]
       
       subgraph "构建器模块"
           CTRL["control.py<br/>generate_ros2_control_nodes()"]
           PERC["perception.py<br/>generate_camera_nodes()<br/>generate_tf_nodes()"]
           SIM["simulation.py<br/>generate_gazebo_nodes()"]
           EXEC["execution.py<br/>generate_inference_node()<br/>generate_action_dispatch_node()"]
           TELEOP["teleop.py<br/>generate_teleop_nodes()"]
           REC["recording.py<br/>generate_recording_nodes()"]
       end
       
       BUILDERS --> CTRL
       BUILDERS --> PERC
       BUILDERS --> SIM
       BUILDERS --> EXEC
       BUILDERS --> TELEOP
       BUILDERS --> REC
       
       CTRL -->|"返回"| CTRLNODES["节点动作<br/>controller_manager<br/>robot_state_publisher<br/>controller spawners"]
       PERC -->|"返回"| PERCNODES["节点动作<br/>usb_cam<br/>realsense2_camera<br/>static_transform_publisher"]
       SIM -->|"返回"| SIMNODES["IncludeLaunchDescription<br/>gazebo.launch.py"]
       EXEC -->|"返回"| EXECNODES["节点动作<br/>lerobot_policy_node<br/>action_dispatcher_node"]
       TELEOP -->|"返回"| TELEOPNODES["节点动作<br/>robot_teleop"]
       REC -->|"返回"| RECNODES["Node/ExecuteProcess<br/>episode_recorder<br/>ros2 bag record"]
       
       CTRLNODES --> LD["LaunchDescription"]
       PERCNODES --> LD
       SIMNODES --> LD
       EXECNODES --> LD
       TELEOPNODES --> LD
       RECNODES --> LD

**启动构建器模块：**


.. list-table::
   :header-rows: 1

   * - 构建器模块
     - 职责
     - 关键函数
   * - ``control.py``
     - ros2_control 设置、控制器启动
     - ``generate_ros2_control_nodes()`` `src/robot_config/robot_config/launch_builders/control.py <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/launch_builders/control.py>`__
   * - ``perception.py``
     - 相机驱动、TF 树
     - ``generate_camera_nodes()``, ``generate_tf_nodes()`` `src/robot_config/robot_config/launch_builders/perception.py <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/launch_builders/perception.py>`__
   * - ``simulation.py``
     - Gazebo 启动
     - ``generate_gazebo_nodes()`` `src/robot_config/robot_config/launch_builders/simulation.py <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/launch_builders/simulation.py>`__
   * - ``execution.py``
     - 推理和分发节点
     - ``generate_inference_node()``, ``generate_action_dispatch_node()`` `src/robot_config/robot_config/launch_builders/execution.py:20-281 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/launch_builders/execution.py#L20-L281>`__
   * - ``teleop.py``
     - 遥操作节点
     - ``generate_teleop_nodes()`` `src/robot_config/robot_config/launch_builders/teleop.py <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/launch_builders/teleop.py>`__
   * - ``recording.py``
     - Episode 录制
     - ``generate_recording_nodes()`` `src/robot_config/robot_config/launch_builders/recording.py:21-168 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/launch_builders/recording.py#L21-L168>`__

**参数流：**

启动参数 → ``context.launch_configurations`` → 构建器函数 → 节点参数

来自执行构建器的示例
`src/robot_config/robot_config/launch_builders/execution.py:81-138 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/launch_builders/execution.py#L81-L138>`__：

.. code:: python

   robot_config_path = robot_config.get('_config_path', '')
   model_name = inference_config["model"]
   models = robot_config.get("models", {})
   model_config = models[model_name]

   node_params = {
       'robot_config_path': robot_config_path,
       'name': model_config.get('name', 'lerobot_policy'),
       'repo_id': model_config.get('repo_id'),
       'checkpoint': model_config.get('checkpoint'),
       'device': model_config.get('device', 'auto'),
       'execution_mode': inference_config.get('execution_mode', 'monolithic'),
   }

**来源：** `src/robot_config/launch/robot.launch.py:123-300 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/launch/robot.launch.py#L123-L300>`__,
`src/robot_config/robot_config/launch_builders/execution.py:20-281 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/launch_builders/execution.py#L20-L281>`__,
`src/robot_config/robot_config/launch_builders/control.py <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/launch_builders/control.py>`__

硬件抽象与 ros2_control 集成
----------------------------

系统使用 ``ros2_control`` 作为硬件抽象层，支持真实硬件和仿真使用相同的控制器。

ros2_control 架构
~~~~~~~~~~~~~~~~~

.. mermaid::

   graph TB
       subgraph "控制器层"
           POSCTRL["position_controllers<br/>(JointGroupPositionController)"]
           TRAJCTRL["trajectory_controllers<br/>(JointTrajectoryController)"]
           JSBC["joint_state_broadcaster<br/>(JointStateBroadcaster)"]
       end
       
       subgraph "控制器管理器"
           CTRLMGR["controller_manager"]
           
           POSCTRL -.->|"由...管理"| CTRLMGR
           TRAJCTRL -.->|"由...管理"| CTRLMGR
           JSBC -.->|"由...管理"| CTRLMGR
       end
       
       subgraph "硬件接口"
           HI["hardware_interface::SystemInterface"]
           
           POSCTRL -->|"write()"| HI
           TRAJCTRL -->|"write()"| HI
           HI -->|"read()"| JSBC
       end
       
       subgraph "硬件插件"
           REAL["so101_hardware::SO101Hardware<br/>Feetech SDK<br/>/dev/ttyUSB0"]
           SIM["gz_ros2_control::GazeboSystem<br/>物理仿真"]
       end
       
       HI -.->|"use_sim=false"| REAL
       HI -.->|"use_sim=true"| SIM
       
       REAL -->|"read/write"| MOTORS["物理电机"]
       SIM -->|"read/write"| GAZEBO["Gazebo 物理引擎"]

**控制器配置：**

控制器在机器人配置的 ``ros2_control`` 节中定义：

.. code:: yaml

   ros2_control:
     hardware:
       plugin: so101_hardware/SO101Hardware  # or gz_ros2_control/GazeboSystem
       parameters:
         serial_port: /dev/ttyUSB0
         baudrate: 1000000
     
     controllers:
       - name: arm_position_controller
         type: position_controllers/JointGroupPositionController
         joints: [joint1, joint2, joint3, joint4, joint5]
       
       - name: arm_trajectory_controller
         type: joint_trajectory_controller/JointTrajectoryController
         joints: [joint1, joint2, joint3, joint4, joint5]

**控制器启动：**
`src/robot_config/robot_config/launch_builders/control.py <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/launch_builders/control.py>`__

控制构建器生成通过 ``controller_manager`` 激活控制器的 spawner 节点：

.. code:: python

   spawner_nodes = []
   for controller_name in active_controllers:
       spawner = Node(
           package='controller_manager',
           executable='spawner',
           arguments=[controller_name],
           output='screen',
       )
       spawner_nodes.append(spawner)

**硬件接口实现：** `src/so101_hardware/ <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/so101_hardware/>`__

``SO101Hardware`` 插件实现
``hardware_interface::SystemInterface``： - ``on_init()``：打开串口，初始化 Feetech SDK - ``read()``：从电机读取关节位置/速度 - ``write()``：向电机写入位置命令

**来源：**
`src/robot_config/robot_config/launch_builders/control.py <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/launch_builders/control.py>`__,
`src/so101_hardware/ <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/so101_hardware/>`__,
`src/robot_config/config/robots/so101_single_arm.yaml <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml>`__

--------------

构建系统与环境管理
------------------

构建架构
~~~~~~~~

.. mermaid::

   graph TB
       SETUP["setup.sh<br/>(一次性初始化)"]
       
       SETUP -->|"1. git submodule update"| SUBMOD["下载 src/ 子模块<br/>libs/lerobot"]
       SETUP -->|"2. create venv"| VENV["Python venv<br/>与 ROS Python 隔离"]
       SETUP -->|"3. pip install"| DEPS["ML 依赖<br/>torch, lerobot<br/>numpy<1.2"]
       SETUP -->|"4. generate"| SHRC[".shrc_local<br/>环境脚本"]
       
       VENV -->|"激活"| ACTIVATE["source venv/bin/activate"]
       
       BUILD["build.sh<br/>(增量构建)"]
       
       BUILD -->|"1. source venv"| ACTIVATE
       BUILD -->|"2. pip install -e"| LEROBOT["libs/lerobot<br/>可编辑模式"]
       BUILD -->|"3. source ROS"| ROS["/opt/ros/humble/setup.sh"]
       BUILD -->|"4. colcon build"| COLCON["构建 ROS 包<br/>--mixin dev/release/debug"]
       
       COLCON -->|"生成"| INSTALL["install/<br/>setup.sh<br/>包二进制"]

**构建 Mixin：** `scripts/build.sh:19-67 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/scripts/build.sh#L19-L67>`__

构建系统支持不同构建配置的 mixin：


.. list-table::
   :header-rows: 1

   * - Mixin
     - 描述
     - 用例
   * - ``dev``
     - 调试符号，无测试，符号链接安装
     - 默认开发
   * - ``debug``
     - 带符号的完整调试构建
     - 调试
   * - ``release``
     - 优化构建，无调试
     - 生产部署
   * - ``test``
     - 启用测试
     - CI/CD
   * - ``asan``
     - AddressSanitizer
     - 内存调试
   * - ``tsan``
     - ThreadSanitizer
     - 并发调试

**虚拟环境管理：** `scripts/build.sh:125-157 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/scripts/build.sh#L125-L157>`__

构建脚本确保正确的 venv 激活和依赖安装：

.. code:: bash

   setup_venv() {
       local venv_paths=(
           "${WORKSPACE}/venv"
           "/home/ros/colcon_venv/venv"
           "${VIRTUAL_ENV:-}"
       )
       
       for venv in "${venv_paths[@]}"; do
           if [[ -n "${venv}" && -f "${venv}/bin/activate" ]]; then
               source "${venv}/bin/activate"
               return 0
           fi
       done
   }

**LeRobot 集成：** `scripts/build.sh:162-178 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/scripts/build.sh#L162-L178>`__

构建脚本以可编辑模式安装 LeRobot 并确保 NumPy 兼容性：

.. code:: bash

   PIP_BIN="${WORKSPACE}/venv/bin/pip"
   "${PIP_BIN}" install -e "${WORKSPACE}/libs/lerobot" --quiet
   "${PIP_BIN}" install "numpy<2" "opencv-python-headless<4.12" --quiet

**来源：** `scripts/build.sh:1-229 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/scripts/build.sh#L1-L229>`__, `scripts/setup.sh <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/scripts/setup.sh>`__,
`README.md:75-118 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L75-L118>`__

--------------

总结：关键架构模式
------------------

1. 单一数据源
~~~~~~~~~~~~~

所有系统行为由 ``robot_config`` YAML 文件驱动。Contract 抽象确保录制、训练和推理使用相同的数据处理流水线。

**文件：** `src/robot_config/config/robots/so101_single_arm.yaml <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml>`__,
`src/robot_config/robot_config/loader.py <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/loader.py>`__

2. 契约驱动设计
~~~~~~~~~~~~~~~~

``Contract`` 数据类定义观测、动作及其 ROS 到张量的映射。消费者使用共享工具（``decode_value``、``resample``、``feature_from_spec``）确保一致性。

**文件：** `src/robot_config/robot_config/contract_utils.py <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/contract_utils.py>`__,
`src/tensormsg/tensormsg/converter.py <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/tensormsg/tensormsg/converter.py>`__

3. 模块化启动构建器
~~~~~~~~~~~~~~~~~~~~~~

启动文件生成被拆分为特定领域的构建器（控制、感知、执行等），可根据控制模式和配置进行组合。

**文件：** `src/robot_config/robot_config/launch_builders/ <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/launch_builders/>`__

4. 双执行模式
~~~~~~~~~~~~~~

推理服务支持单体（零拷贝、单机）和分布式（边缘-云端）模式，使用相同的 Action Server 接口。

**文件：**
`src/inference_service/inference_service/lerobot_policy_node.py <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/lerobot_policy_node.py>`__,
`src/inference_service/inference_service/pure_inference_node.py <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/pure_inference_node.py>`__

5. 时间平滑
~~~~~~~~~~~~

跨帧动作块平滑消除了在前一个块执行期间新推理完成时的运动不连续性。

**文件：**
`src/action_dispatch/action_dispatch/temporal_smoother.py <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatch/temporal_smoother.py>`__

6. 硬件抽象
~~~~~~~~~~~

``ros2_control`` 框架为真实硬件和仿真提供统一接口，实现无缝模式切换。

**文件：** `src/so101_hardware/ <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/so101_hardware/>`__,
`src/robot_config/robot_config/launch_builders/control.py <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/launch_builders/control.py>`__

配置系统 (robot_config)
=======================

.. toctree::
   :titlesonly:
   :hidden:

   robot_configuration_files
   contract_definition
   peripheral_configuration
   launch_system
   configuration_validation

.. raw:: html

   <details>

相关源文件

以下文件用作生成此 wiki 页面的上下文：

-  `.colcon/defaults.yaml <.colcon/defaults.yaml>`__
-  `.colcon/mixin/build.mixin.yaml <.colcon/mixin/build.mixin.yaml>`__
-  `.colcon/mixin/index.yaml <.colcon/mixin/index.yaml>`__
-  `.gitignore <.gitignore>`__
-  `.vscode/c_cpp_properties.json <.vscode/c_cpp_properties.json>`__
-  `.vscode/extensions.json <.vscode/extensions.json>`__
-  `.vscode/launch.json <.vscode/launch.json>`__
-  `.vscode/settings.json <.vscode/settings.json>`__
-  `.vscode/tasks.json <.vscode/tasks.json>`__
-  `scripts/validate_config.py <scripts/validate_config.py>`__
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

``robot_config`` 包提供了一个统一的配置系统，作为机器人硬件、外设、控制模式和 ML 策略 I/O 契约的**单一事实来源**。它通过将 ros2_control 参数、相机驱动、遥操作设置和推理契约整合到单个 YAML 文件中，消除了配置重复。

**相关页面：** 有关特定契约字段（观测、动作、QoS）的详细信息，请参阅 `契约定义 <#5.2>`__。有关外设驱动配置，请参阅 `外设配置 <#5.3>`__。有关启动文件生成，请参阅 `启动系统 <#5.4>`__。有关验证脚本，请参阅 `配置验证 <#5.5>`__。

--------------

目的与范围
----------

配置系统解决以下问题：

- **配置漂移**：此前，关节定义、相机参数和 ML 契约分散在多个文件中
- **冗余**：相同的相机分辨率或关节名称在 URDF、ros2_control 配置和 ML 契约中被重复定义
- **模式切换**：不同的控制范式（遥操作、模型推理、MoveIt 规划）需要单独的启动文件
- **训练-部署对齐**：记录数据与推理观测之间的不匹配导致失败

``robot_config`` 包通过以下方式解决这些问题：

1. **集中配置**：一个 YAML 文件（``so101_single_arm.yaml``）定义所有硬件和软件参数
2. **合成下游配置**：ros2_control、相机驱动和契约从 YAML 自动生成
3. **强制一致性**：共享引用（如契约中的 ``peripheral: top``）确保相机元数据正确传播
4. **支持多模式控制**：单一配置支持遥操作、模型推理和 MoveIt 模式

--------------

系统架构
--------

.. mermaid::

   graph TB
       subgraph "Single Source of Truth"
           YAML["robot_config YAML<br/>so101_single_arm.yaml"]
       end
       
       subgraph "Configuration Loading"
           LOADER["load_robot_config()<br/>loader.py:147"]
           DATACLASS["RobotConfig<br/>config.py:105"]
           VALIDATOR["validate_control_mode_config()<br/>contract_builder.py:9"]
       end
       
       subgraph "Contract Synthesis"
           TOCONTRACT["RobotConfig.to_contract()<br/>config.py:133"]
           CONTRACT["Contract<br/>contract_utils.py:83"]
           SPECVIEW["SpecView<br/>contract_utils.py:112"]
       end
       
       subgraph "Launch Builders"
           ROBOT_LAUNCH["robot.launch.py<br/>launch/robot.launch.py:123"]
           CONTROL_BUILDER["generate_ros2_control_nodes()<br/>launch_builders/control.py"]
           PERCEPTION_BUILDER["generate_camera_nodes()<br/>launch_builders/perception.py"]
           EXEC_BUILDER["generate_execution_nodes()<br/>launch_builders/execution.py"]
           TELEOP_BUILDER["generate_teleop_nodes()<br/>launch_builders/teleop.py"]
           RECORDING_BUILDER["generate_recording_nodes()<br/>launch_builders/recording.py"]
       end
       
       subgraph "Runtime System"
           ROS2CTRL["ros2_control_node"]
           CAMERAS["usb_cam / realsense_node"]
           INFERENCE["lerobot_policy_node"]
           DISPATCHER["action_dispatcher_node"]
           RECORDER["episode_recorder"]
           TELEOP["robot_teleop"]
       end
       
       YAML --> LOADER
       LOADER --> DATACLASS
       DATACLASS --> VALIDATOR
       VALIDATOR --> TOCONTRACT
       TOCONTRACT --> CONTRACT
       CONTRACT --> SPECVIEW
       
       DATACLASS --> ROBOT_LAUNCH
       ROBOT_LAUNCH --> CONTROL_BUILDER
       ROBOT_LAUNCH --> PERCEPTION_BUILDER
       ROBOT_LAUNCH --> EXEC_BUILDER
       ROBOT_LAUNCH --> TELEOP_BUILDER
       ROBOT_LAUNCH --> RECORDING_BUILDER
       
       CONTROL_BUILDER --> ROS2CTRL
       PERCEPTION_BUILDER --> CAMERAS
       EXEC_BUILDER --> INFERENCE
       EXEC_BUILDER --> DISPATCHER
       TELEOP_BUILDER --> TELEOP
       RECORDING_BUILDER --> RECORDER
       
       CONTRACT -.->|"observations/actions"| INFERENCE
       CONTRACT -.->|"topics to record"| RECORDER
       CONTRACT -.->|"action topics"| DISPATCHER

**源文件：** `src/robot_config/robot_config/loader.py:147-207 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/loader.py#L147-L207>`__,
`src/robot_config/robot_config/config.py:105-132 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/config.py#L105-L132>`__,
`src/robot_config/launch/robot.launch.py:123-137 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/launch/robot.launch.py#L123-L137>`__

--------------

配置文件结构
------------

顶层部分
~~~~~~~~

.. code:: yaml

   robot:
     name: so101_single_arm             # 机器人标识符
     type: so101                         # 机器人硬件类型
     robot_type: so_101                  # LeRobot 数据集元数据
     
     models: {}                          # 策略检查点库
     joints: {}                          # 统一关节定义 (DRY)
     control_modes: {}                   # teleop | model_inference | moveit_planning
     ros2_control: {}                    # 硬件插件配置
     peripherals: []                     # 相机和传感器
     contract: {}                        # 观测和动作 (ML I/O)
     teleoperation: {}                   # 主臂 / 手柄配置
     recording: {}                       # Bag 录制设置

各部分在子页面 5.1-5.5 中有详细说明。

**源文件：**
`src/robot_config/config/robots/so101_single_arm.yaml:5-329 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L5-L329>`__

--------------

配置加载流程
------------

.. mermaid::

   sequenceDiagram
       participant L as robot.launch.py
       participant Loader as load_robot_config()
       participant YAML as so101_single_arm.yaml
       participant RC as RobotConfig
       participant Val as validate_control_mode_config()
       participant Contract as to_contract()
       
       L->>Loader: load_robot_config(config_path)
       Loader->>YAML: read YAML file
       YAML-->>Loader: robot_data dict
       Loader->>RC: construct RobotConfig dataclass
       Note over Loader,RC: Resolves $(find pkg), $(env VAR)
       RC-->>Loader: RobotConfig instance
       Loader->>Val: validate_control_mode_config(robot_config, mode)
       Note over Val: Check model refs, observations, controllers
       Val-->>Loader: validation OK or raise ContractSynthesisError
       Loader->>Contract: robot_config.to_contract()
       Note over Contract: Synthesize Contract from observations/actions
       Contract-->>Loader: Contract instance
       Loader-->>L: RobotConfig + Contract

**关键函数：**


.. list-table::
   :header-rows: 1

   * - 函数
     - 文件
     - 用途
   * - ``load_robot_config()``
     - `loader.py:147-207 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/loader.py#L147-L207>`__
     - 解析 YAML，解析路径， 解析 YAML，解析路径， 构造 ``RobotConfig``
   * - ``validat e_control_mode_config()``
     - `contract_builder.py:9-103 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/py#L9-L103>`__
     - 在启动前验证模式引用 tract_builder.
   * - ``Ro botConfig.to_contract()``
     - `config.py:133-228 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/-从观测/动作合成#L133-L228>`__
     - ``Contract``

**源文件：** `src/robot_config/robot_config/loader.py:147-207 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/loader.py#L147-L207>`__,
`src/robot_config/robot_config/contract_builder.py:9-103 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/contract_builder.py#L9-L103>`__,
`src/robot_config/robot_config/config.py:133-228 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/config.py#L133-L228>`__

--------------

配置类
------

核心数据类
~~~~~~~~~~

.. mermaid::

   classDiagram
       class RobotConfig {
           +str name
           +str type
           +str robot_type
           +Ros2ControlConfig ros2_control
           +List~CameraConfig~ peripherals
           +ContractExtensionConfig contract
           +get_camera(name) CameraConfig
           +to_contract() Contract
       }
       
       class Ros2ControlConfig {
           +str hardware_plugin
           +Dict params
           +str urdf_path
       }
       
       class CameraConfig {
           +str name
           +str driver
           +int width, height, fps
           +str frame_id
           +Dict transform
       }
       
       class ContractExtensionConfig {
           +str base_contract
           +List~ContractObservation~ observations
           +List~ContractAction~ actions
           +float rate_hz
           +float max_duration_s
       }
       
       class Contract {
           +str name
           +float rate_hz
           +List~ObservationSpec~ observations
           +List~ActionSpec~ actions
       }
       
       class SpecView {
           +str key
           +str topic
           +str ros_type
           +bool is_action
           +List~str~ names
           +Tuple image_resize
       }
       
       RobotConfig --> Ros2ControlConfig
       RobotConfig --> CameraConfig
       RobotConfig --> ContractExtensionConfig
       RobotConfig --> Contract : to_contract()
       Contract --> SpecView : iter_specs()

**源文件：** `src/robot_config/robot_config/config.py:8-232 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/config.py#L8-L232>`__,
`src/robot_config/robot_config/contract_utils.py:26-211 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/contract_utils.py#L26-L211>`__

--------------

控制模式架构
------------

配置系统支持三种控制模式，每种模式具有不同的控制器类型和推理设置：


.. list-table::
   :header-rows: 1

   * - 控制模式
     - 控制器
     - 推理
     - 用途
   * - ``teleop``
     - posi tion_controllers
     - 禁用
     - 人工遥操作 （主臂、 手柄）
   * - ` `model_inference``
     - posi tion_controllers
     - 启用
     - 端到端策略 （ACT、 Diffusion）
   * - ` `moveit_planning``
     - trajec tory_controllers
     - 可选
     - 基于规划的 策略 （VoxPoser、 VLM）

模式选择流程
~~~~~~~~~~~~

.. mermaid::

   graph LR
       YAML["default_control_mode<br/>in YAML"]
       OVERRIDE["--control_mode<br/>launch arg"]
       VALIDATE["validate_control_mode_config()"]
       CONTROLLERS["generate_ros2_control_nodes()"]
       INFERENCE["generate_execution_nodes()"]
       
       YAML --> VALIDATE
       OVERRIDE -.->|overrides| VALIDATE
       VALIDATE --> CONTROLLERS
       VALIDATE --> INFERENCE
       
       CONTROLLERS --> POS["position_controllers<br/>(teleop, model_inference)"]
       CONTROLLERS --> TRAJ["trajectory_controllers<br/>(moveit_planning)"]
       
       INFERENCE --> ENABLED["with_inference=True<br/>spawn policy + dispatcher"]
       INFERENCE --> DISABLED["with_inference=False<br/>skip inference nodes"]

**配置示例：**

.. code:: yaml

   control_modes:
     model_inference:
       description: "High-frequency end-to-end control mode (ACT/pi0)"
       controllers:
         - joint_state_broadcaster
         - arm_position_controller
         - gripper_position_controller
       inference:
         enabled: true
         execution_mode: "distributed"  # or "monolithic"
         model: so101_act
       executor:
         type: topic
         control_frequency: 50.0

**源文件：**
`src/robot_config/config/robots/so101_single_arm.yaml:46-103 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L46-L103>`__,
`src/robot_config/robot_config/contract_builder.py:9-103 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/contract_builder.py#L9-L103>`__

--------------

启动系统集成
------------

启动构建器模式
~~~~~~~~~~~~~~

``robot.launch.py`` 文件通过专门的构建器编排节点生成：

.. mermaid::

   graph TB
       MAIN["robot.launch.py<br/>launch_setup()"]
       
       subgraph "Builder Modules"
           CTRL["control.py<br/>generate_ros2_control_nodes()"]
           PERCEP["perception.py<br/>generate_camera_nodes()"]
           EXEC["execution.py<br/>generate_execution_nodes()"]
           TELEOP["teleop.py<br/>generate_teleop_nodes()"]
           REC["recording.py<br/>generate_recording_nodes()"]
       end
       
       subgraph "Generated Nodes"
           ROS2CTRL_NODE["ros2_control_node"]
           SPAWNER["controller_spawner"]
           CAM1["usb_cam_node (top)"]
           CAM2["usb_cam_node (wrist)"]
           POL["lerobot_policy_node"]
           DISP["action_dispatcher_node"]
           TEL["robot_teleop_node"]
           EPIREC["episode_recorder"]
       end
       
       MAIN --> CTRL
       MAIN --> PERCEP
       MAIN --> EXEC
       MAIN --> TELEOP
       MAIN --> REC
       
       CTRL --> ROS2CTRL_NODE
       CTRL --> SPAWNER
       PERCEP --> CAM1
       PERCEP --> CAM2
       EXEC --> POL
       EXEC --> DISP
       TELEOP --> TEL
       REC --> EPIREC

**构建器职责：**


.. list-table::
   :header-rows: 1

   * - 构建器
     - 文件
     - 生成内容
   * - ``control.py``
     - `launch_builders/control.py <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/launch_builders/control.py>`__
     - ros2_control_node, controller spawners
   * - ``perception.py``
     - `launch_builders/perception.py <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/launch_builders/perception.py>`__
     - usb_cam / realsense nodes, static_transform_publisher
   * - ``execution.py``
     - `launch_builders/execution.py:1-259 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/launch_builders/execution.py#L1-L259>`__
     - lerobot_policy_node, action_dispatcher_node
   * - ``teleop.py``
     - `launch_builders/teleop.py <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/launch_builders/teleop.py>`__
     - robot_teleop_node （主臂 / 手柄）
   * - ``recording.py``
     - `launch_builders/recording.py:1-226 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/launch_builders/recording.py#L1-L226>`__
     - episode_recorder（分集） 或 ros2 bag record （连续）

**源文件：** `src/robot_config/launch/robot.launch.py:123-318 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/launch/robot.launch.py#L123-L318>`__,
`src/robot_config/robot_config/launch_builders/execution.py:1-259 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/launch_builders/execution.py#L1-L259>`__

--------------

契约合成
--------

契约系统定义 ML 策略的观测（输入）和动作（输出）。``robot_config`` YAML 是合成契约的**单一事实来源**。

合成流程
~~~~~~~~

.. mermaid::

   graph TB
       YAML["robot_config YAML<br/>observations + actions"]
       PERIPH["peripherals section<br/>(camera metadata)"]
       
       TOCONTRACT["RobotConfig.to_contract()"]
       
       OBSSPEC["ObservationSpec<br/>topic, type, image_resize"]
       ACTSPEC["ActionSpec<br/>publish_topic, type, names"]
       
       CONTRACT["Contract<br/>(contract_utils.py)"]
       
       INFERENCE["lerobot_policy_node<br/>(subscribes to obs topics)"]
       RECORDER["episode_recorder<br/>(records obs + act topics)"]
       BAG2LR["bag_to_lerobot<br/>(converts to LeRobot format)"]
       
       YAML --> TOCONTRACT
       PERIPH --> TOCONTRACT
       TOCONTRACT --> OBSSPEC
       TOCONTRACT --> ACTSPEC
       OBSSPEC --> CONTRACT
       ACTSPEC --> CONTRACT
       
       CONTRACT --> INFERENCE
       CONTRACT --> RECORDER
       CONTRACT --> BAG2LR

**外设引用示例：**

.. code:: yaml

   peripherals:
     - type: camera
       name: top
       width: 640
       height: 480
       fps: 30

   contract:
     observations:
       - key: observation.images.top
         topic: /camera/top/image_raw
         peripheral: top  # Auto-fills width/height/fps from peripheral
         image:
           resize: [480, 640]

当调用 ``to_contract()`` 时，``peripheral: top`` 引用会自动将 ``width: 640``、``height: 480``、``fps: 30`` 注入到 ``ObservationSpec`` 中。

**源文件：** `src/robot_config/robot_config/config.py:133-228 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/config.py#L133-L228>`__,
`src/robot_config/config/robots/so101_single_arm.yaml:130-247 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L130-L247>`__

--------------

路径解析
--------

配置加载器解析 ROS 风格的路径替换：


.. list-table::
   :header-rows: 1

   * - 语法
     - 示例
     - 解析方式
   * - ``$(find pkg)``
     - ``$(find rob ot_config)/config/c ontracts/act.yaml``
     - 搜索 install/share 目录
   * - ``$(env VAR)``
     - ``$(env HOME)/.cal ibrate/so101.json``
     - 读取环境变量

**实现：** `robot_config/utils.py:resolve_ros_path() <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/robot_config/utils.py>`__

**源文件：** `src/robot_config/robot_config/loader.py:66-90 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/loader.py#L66-L90>`__,
`src/robot_config/robot_config/utils.py <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/utils.py>`__

--------------

验证系统
--------

``validate_config.py`` 脚本强制执行配置文件之间的一致性：

.. mermaid::

   graph LR
       VALIDATOR["ConfigValidator<br/>validate_config.py:26"]
       YAML["robot_config YAML"]
       CONTROLLERS["so101_controllers.yaml"]
       URDF["so101.urdf.xacro"]
       
       VALIDATOR --> JOINTS["Check joints section"]
       VALIDATOR --> CTRL["Check controller refs"]
       VALIDATOR --> PERIPH["Check peripheral refs"]
       
       JOINTS --> YAML
       CTRL --> CONTROLLERS
       PERIPH --> YAML
       
       VALIDATOR --> OK["Exit 0: OK"]
       VALIDATOR --> FAIL["Exit 1: Errors"]

**验证检查：**

1. **关节一致性**：验证 ``joints.arm`` 和 ``joints.gripper`` 与控制器定义匹配
2. **控制器引用**：确保 ``control_modes.<mode>.controllers`` 存在于 ``ros2_control.controllers`` 中
3. **外设引用**：验证 ``contract.observations[].peripheral`` 存在于 ``peripherals[]`` 中
4. **模型引用**：检查 ``inference.model`` 存在于 ``models`` 部分中

**用法：**

.. code:: bash

   python3 scripts/validate_config.py \
       src/robot_config/config/robots/so101_single_arm.yaml

**源文件：** `scripts/validate_config.py:1-310 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/scripts/validate_config.py#L1-L310>`__,
`src/robot_config/robot_config/contract_builder.py:9-103 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/contract_builder.py#L9-L103>`__

--------------

关键设计模式
------------

单一事实来源
~~~~~~~~~~~~

所有下游配置都从 ``robot_config`` YAML **合成**：

-  ros2_control URDF：由 `control.py:generate_ros2_control_nodes() <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/control.py#Lgenerate_ros2_control_nodes()>`__ 生成
-  相机启动参数：由 `perception.py:generate_camera_nodes() <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/perception.py>`__ 生成
-  ML 契约：由 `config.py:RobotConfig.to_contract() <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/config.py>`__ 合成

这消除了跨文件手动同步关节名称、相机分辨率或主题名称的需要。

基于引用的元数据注入
~~~~~~~~~~~~~~~~~~~~

契约通过名称引用外设，而不是复制元数据：

.. code:: yaml

   peripherals:
     - name: top
       width: 640
       height: 480

   contract:
     observations:
       - key: observation.images.top
         peripheral: top  # Metadata auto-injected

此模式在 `config.py:133-228 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/config.py#L133-L228>`__ 中实现。

模式驱动的节点生成
~~~~~~~~~~~~~~~~~~

启动系统使用活动控制模式有条件地生成节点：

.. code:: python

   if active_control_mode == 'teleop':
       actions.extend(generate_teleop_nodes(robot_config))
       
   if with_inference:  # Auto-detected from mode config
       actions.extend(generate_execution_nodes(robot_config, mode))

参见 `robot.launch.py:243-275 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/robot.launch.py#L243-L275>`__。

**源文件：** `src/robot_config/robot_config/config.py:133-228 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/config.py#L133-L228>`__,
`src/robot_config/launch/robot.launch.py:243-275 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/launch/robot.launch.py#L243-L275>`__

--------------

集成点
------

与 ros2_control 集成
~~~~~~~~~~~~~~~~~~~~

配置系统生成 ros2_control URDF 和控制器启动命令：

.. code:: yaml

   ros2_control:
     hardware_plugin: so101_hardware/SO101SystemHardware
     port: /dev/ttyACM0
     controllers:
       - joint_state_broadcaster
       - arm_position_controller

**生成的节点：** ``ros2_control_node``，每个控制器的 ``controller_spawner``

**源文件：**
`src/robot_config/robot_config/launch_builders/control.py <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/launch_builders/control.py>`__

与推理服务集成
~~~~~~~~~~~~~~

``execution.py`` 构建器生成带有自动合成契约的 ``lerobot_policy_node``：

.. code:: yaml

   inference:
     enabled: true
     model: so101_act
     execution_mode: "distributed"

**传递的参数：**

-  ``checkpoint``：从 ``models.so101_act.path`` 解析
-  ``robot_config_path``：YAML 的绝对路径（用于契约合成）
-  ``execution_mode``："monolithic" 或 "distributed"

**源文件：**
`src/robot_config/robot_config/launch_builders/execution.py:61-127 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/launch_builders/execution.py#L61-L127>`__

与分集记录器集成
~~~~~~~~~~~~~~~~

``recording.py`` 构建器将 ``robot_config_path`` 传递给 ``episode_recorder``：

.. code:: yaml

   recording:
     bag_base_dir: "~/rosbag/episodes"
     storage: mcap

记录器使用 ``robot_config.to_contract()`` 确定要订阅的主题。

**源文件：**
`src/robot_config/robot_config/launch_builders/recording.py:102-168 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/launch_builders/recording.py#L102-L168>`__,
`src/dataset_tools/dataset_tools/episode_recorder.py:194-206 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/dataset_tools/episode_recorder.py#L194-L206>`__

--------------

文件组织
--------

::

   src/robot_config/
   ├── config/
   │   ├── robots/                    # 机器人特定的 YAML 文件
   │   │   ├── so101_single_arm.yaml
   │   │   └── so101_dual_arm.yaml
   │   └── contracts/                 # 基础契约模板（已弃用）
   ├── launch/
   │   └── robot.launch.py            # 主编排器
   ├── robot_config/
   │   ├── config.py                  # 数据类定义
   │   ├── loader.py                  # YAML 加载和解析
   │   ├── contract_utils.py          # 契约合成和运行时
   │   ├── contract_builder.py        # 启动前验证
   │   ├── utils.py                   # 路径解析辅助函数
   │   └── launch_builders/           # 模块化节点生成器
   │       ├── control.py
   │       ├── perception.py
   │       ├── execution.py
   │       ├── teleop.py
   │       ├── recording.py
   │       └── simulation.py
   └── README.md

**源文件：** `src/robot_config/ <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/>`__

--------------

常见使用模式
------------

使用默认模式启动
~~~~~~~~~~~~~~~~

.. code:: bash

   ros2 launch robot_config robot.launch.py robot_config:=so101_single_arm

使用 YAML 中的 ``default_control_mode``。

覆盖控制模式
~~~~~~~~~~~~

.. code:: bash

   ros2 launch robot_config robot.launch.py \
       robot_config:=so101_single_arm \
       control_mode:=teleop \
       record:=true

覆盖为遥操作模式并启用录制。

自定义配置路径
~~~~~~~~~~~~~~

.. code:: bash

   ros2 launch robot_config robot.launch.py \
       config_path:=/path/to/custom.yaml

**源文件：** `src/robot_config/launch/robot.launch.py:21-61 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/launch/robot.launch.py#L21-L61>`__

--------------

下一步
------

有关配置系统特定方面的详细信息：

-  `机器人配置文件 <#5.1>`__：YAML 结构、模型库、关节、ros2_control
-  `契约定义 <#5.2>`__：观测/动作规格、QoS、对齐策略
-  `外设配置 <#5.3>`__：相机驱动、变换、标定
-  `启动系统 <#5.4>`__：启动构建器、动态节点生成
-  `配置验证 <#5.5>`__：``validate_config.py`` 用法和检查

**源文件：** `src/robot_config/README.en.md:1-582 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/README.en.md#L1-L582>`__,
`src/robot_config/launch/robot.launch.py:1-387 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/launch/robot.launch.py#L1-L387>`__

--------------



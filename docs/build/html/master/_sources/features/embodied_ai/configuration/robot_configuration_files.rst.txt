机器人配置文件
==============

.. raw:: html

   <details>

相关源文件

以下文件用于生成此文档页面：

-  `src/robot_config/README.en.md <src/robot_config/README.en.md>`__
-  `src/robot_config/README.md <src/robot_config/README.md>`__
-  `src/robot_config/config/robots/so101_dual_arm.yaml <src/robot_config/config/robots/so101_dual_arm.yaml>`__
-  `src/robot_config/config/robots/so101_single_arm.yaml <src/robot_config/config/robots/so101_single_arm.yaml>`__
-  `src/robot_config/robot_config/loader.py <src/robot_config/robot_config/loader.py>`__
-  `src/tensormsg/tensormsg/converter.py <src/tensormsg/tensormsg/converter.py>`__

.. raw:: html

   </details>

本文档介绍 ``robot_config`` 包中机器人 YAML 配置文件的结构和内容。这些文件作为机器人硬件规格、控制模式、关节定义和模型部署的 **单一数据源**。有关契约定义（观测和动作）的信息，请参阅 `契约定义 <#5.2>`__。有关外设/相机配置详情，请参阅 `外设配置 <#5.3>`__。

机器人配置文件位于 ```src/robot_config/config/robots/`` <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/>`__，遵循标准化的 YAML 模式，由 ```robot_config/loader.py`` <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/>`__ 加载到 ```RobotConfig`` <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/>`__ 数据类层次结构中。

--------------

文件结构概述
------------

机器人配置文件组织为层次化部分，每个部分控制机器人系统的特定方面。下图显示顶层结构：

**图表：机器人配置文件层次结构**

.. mermaid::

   graph TB
       YAML["robot_config YAML<br/>(例如 so101_single_arm.yaml)"]
       
       YAML --> META["robot.name<br/>robot.type<br/>robot.robot_type"]
       YAML --> MODELS["robot.models"]
       YAML --> JOINTS["robot.joints"]
       YAML --> MOVEIT["robot.moveit"]
       YAML --> MODES["robot.control_modes<br/>robot.default_control_mode"]
       YAML --> ROS2CTRL["robot.ros2_control"]
       YAML --> PERIPH["robot.peripherals"]
       YAML --> CONTRACT["robot.contract"]
       YAML --> TELEOP["robot.teleoperation"]
       YAML --> REC["robot.recording"]
       
       META --> LOADER["load_robot_config()"]
       MODELS --> LOADER
       JOINTS --> LOADER
       MOVEIT --> LOADER
       MODES --> LOADER
       ROS2CTRL --> LOADER
       PERIPH --> LOADER
       CONTRACT --> LOADER
       TELEOP --> LOADER
       REC --> LOADER
       
       LOADER --> DATACLASS["RobotConfig dataclass"]
       
       style YAML fill:#f9f9f9,stroke:#333,stroke-width:2px
       style LOADER fill:#e3f2fd,stroke:#1976d2,stroke-width:2px
       style DATACLASS fill:#fff3e0,stroke:#ff9800,stroke-width:2px

**来源：**
`src/robot_config/config/robots/so101_single_arm.yaml:1-329 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L1-L329>`__，
`src/robot_config/robot_config/loader.py:147-214 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/loader.py#L147-L214>`__

--------------

机器人规格部分
--------------

顶层 ``robot`` 部分定义基本的机器人元数据，用于整个系统的识别和数据集标记。

**结构：**

.. code:: yaml

   robot:
     name: so101_single_arm          # 此配置的唯一标识符
     type: so101                     # 硬件类型标识符
     robot_type: so_101              # LeRobot 数据集元数据标签

**字段描述：**


.. list-table::
   :header-rows: 1

   * - 字段
     - 类型
     - 用途
     - 示例
   * - ``name``
     - string
     - 唯一配置标识符， 用于启动参数
     - ``so101_single_arm``
   * - ``type``
     - string
     - 硬件系列标识符
     - ``so101``, ``so101_dual``
   * - ``robot_type``
     - string
     - 数据集元数据标签 (用于 LeRobot 兼容性)
     - ``so_101``, ``aloha``

``name`` 字段在通过 ``robot_config:=so101_single_arm`` 参数启动机器人时被引用。``robot_type`` 在录制和转换为 LeRobot 格式期间嵌入到数据集元数据中。

**来源：**
`src/robot_config/config/robots/so101_single_arm.yaml:5-8 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L5-L8>`__，
`src/robot_config/robot_config/loader.py:175-180 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/loader.py#L175-L180>`__

--------------

模型库
------

``models`` 部分定义可在此机器人上部署的训练策略检查点注册表。此部分将符号模型名称映射到文件系统路径和元数据。

**图表：模型配置映射**

.. mermaid::

   graph LR
       YAML_MODELS["robot.models"]
       
       YAML_MODELS --> MODEL1["so101_act:<br/>path: /path/to/model<br/>policy_type: act<br/>normalization: {...}"]
       YAML_MODELS --> MODEL2["so101_diffusion:<br/>path: /path/to/model<br/>policy_type: diffusion"]
       
       MODEL1 --> INFERENCE["control_modes.model_inference.inference.model:<br/>'so101_act'"]
       
       INFERENCE --> POLICY_NODE["lerobot_policy_node<br/>加载检查点"]
       
       style YAML_MODELS fill:#f9f9f9,stroke:#333,stroke-width:2px
       style INFERENCE fill:#fff3e0,stroke:#ff9800,stroke-width:2px
       style POLICY_NODE fill:#e3f2fd,stroke:#1976d2,stroke-width:2px

**结构：**

.. code:: yaml

   robot:
     models:
       so101_act:
         path: /home/user/models/502000/pretrained_model
         policy_type: act
         normalization:
           action_scale: [0.0314, 0.0314, 0.0314, 0.0314, 0.0314, 0.0008]
           action_offset: [0.0, 0.0, 0.0, 0.0, 0.0, 0.04]
       
       so101_diffusion:
         path: /home/user/models/diffusion/checkpoint
         policy_type: diffusion_policy

**字段描述：**


.. list-table::
   :header-rows: 1

   * - 字段
     - 类型
     - 用途
   * - ``path``
     - string
     - 模型检查点目录的 绝对或相对路径
   * - ``policy_type``
     - string
     - 策略架构标识符 (``act``, ``diffusion_policy``, ``vla``)
   * - ``normalization``
     - dict
     - 可选的归一化参数 用于动作缩放

此处定义的模型由控制模式配置使用其符号名称引用（例如 ``so101_act``）。在推理期间，系统将模型名称解析为检查点路径。

**来源：**
`src/robot_config/config/robots/so101_single_arm.yaml:13-20 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L13-L20>`__

--------------

关节定义（单一数据源）
~~~~~~~~~~~~~~~~~~~~~~~~

``joints`` 部分建立所有控制模式和配置中关节命名和分组的 **单一数据源**。这防止了关节规格的重复和不一致。

**结构：**

.. code:: yaml

   robot:
     joints:
       arm:
         - "1"
         - "2"
         - "3"
         - "4"
         - "5"
       gripper:
         - "6"
       all: ["1", "2", "3", "4", "5", "6"]

**关节组：**


.. list-table::
   :header-rows: 1

   * - 组
     - 描述
     - 用途
   * - ``arm``
     - 机械臂关节
     - MoveIt 规划组、控制器配置
   * - ``gripper``
     - 末端执行器关节
     - 所有控制模式中的独立控制器
   * - ``all``
     - 完整关节集
     - 硬件接口初始化、验证

**双臂配置示例：**

.. code:: yaml

   robot:
     joints:
       left_arm: ["left_1", "left_2", "left_3", "left_4", "left_5"]
       right_arm: ["right_1", "right_2", "right_3", "right_4", "right_5"]
       left_gripper: ["left_6"]
       right_gripper: ["right_6"]

这些关节定义被以下组件引用：

- ```ros2_control.joint_names`` <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/>`__ - 硬件接口配置
- ```contract.observations`` <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/>`__ - 关节状态选择
- ```contract.actions`` <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/>`__ - 动作发布配置
- ```moveit.arm_group_name`` <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/>`__ - MoveIt 规划组

**来源：**
`src/robot_config/config/robots/so101_single_arm.yaml:25-34 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L25-L34>`__，
`src/robot_config/config/robots/so101_dual_arm.yaml:20-32 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_dual_arm.yaml#L20-L32>`__

--------------

MoveIt 配置
-----------

``moveit`` 部分指定 MoveIt2 集成的参数，当 ``control_mode`` 设置为 ``moveit_planning`` 时使用。

**结构：**

.. code:: yaml

   robot:
     moveit:
       arm_group_name: arm           # 必须匹配 joints.arm 键
       base_link: base               # 固定基座帧
       ee_link: gripper              # 末端执行器链接
       shoulder_link: shoulder       # IK 约束的参考链接

**字段映射到 MoveIt 组件：**


.. list-table::
   :header-rows: 1

   * - 字段
     - MoveIt 组件
     - 用途
   * - ``arm_group_name``
     - 规划组名称
     - 引用 ``joints.arm`` 获取组成员
   * - ``base_link``
     - 运动链根节点
     - 运动链起始帧
   * - ``ee_link``
     - 运动链末端
     - IK 目标帧
   * - ``shoulder_link``
     - 约束帧
     - 用于 5-DOF 手臂 的方向约束

``arm_group_name`` 必须对应 ``joints`` 部分中的键。对于双臂机器人，可以指定多个规划组：

.. code:: yaml

   moveit:
     arm_group_name: left_arm    # 单臂命令的主手臂
     left_arm_group: left_arm
     right_arm_group: right_arm

**来源：**
`src/robot_config/config/robots/so101_single_arm.yaml:39-43 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L39-L43>`__，
`src/robot_config/config/robots/so101_dual_arm.yaml:35-39 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_dual_arm.yaml#L35-L39>`__

--------------

控制模式配置
------------

控制模式定义机器人的操作范式。配置指定加载哪些控制器、是否启用推理以及执行器设置。下图显示控制模式选择流程：

**图表：控制模式配置流程**

.. mermaid::

   graph TB
       YAML_DEFAULT["robot.default_control_mode"]
       YAML_MODES["robot.control_modes"]
       
       LAUNCH_PARAM["--control_mode 启动参数"]
       
       YAML_DEFAULT --> SELECTOR["模式选择器<br/>(robot.launch.py)"]
       LAUNCH_PARAM -->|覆盖| SELECTOR
       
       SELECTOR --> MODE_TELEOP["control_modes.teleop"]
       SELECTOR --> MODE_INF["control_modes.model_inference"]
       SELECTOR --> MODE_MOVEIT["control_modes.moveit_planning"]
       
       MODE_TELEOP --> CTRL_POS["controllers:<br/>- arm_position_controller<br/>- gripper_position_controller"]
       MODE_INF --> CTRL_POS
       MODE_MOVEIT --> CTRL_TRAJ["controllers:<br/>- arm_trajectory_controller<br/>- gripper_trajectory_controller"]
       
       MODE_TELEOP --> INF_OFF["inference.enabled: false<br/>inference.force_disable: true"]
       MODE_INF --> INF_ON["inference.enabled: true<br/>inference.model: so101_act<br/>inference.execution_mode: distributed"]
       MODE_MOVEIT --> INF_OFF_2["inference.enabled: false"]
       
       CTRL_POS --> SPAWN["控制器管理器<br/>生成控制器"]
       CTRL_TRAJ --> SPAWN
       
       INF_ON --> POLICY["lerobot_policy_node<br/>启动"]
       
       style SELECTOR fill:#fff3e0,stroke:#ff9800,stroke-width:2px
       style MODE_INF fill:#e3f2fd,stroke:#1976d2,stroke-width:2px
       style INF_ON fill:#c8e6c9,stroke:#388e3c,stroke-width:2px

**来源：**
`src/robot_config/config/robots/so101_single_arm.yaml:46-103 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L46-L103>`__

控制模式结构
~~~~~~~~~~~~

每个控制模式定义为 ``robot.control_modes`` 下的嵌套部分：

.. code:: yaml

   robot:
     default_control_mode: "model_inference"
     
     control_modes:
       teleop:
         description: "Human teleoperation mode (direct control)"
         description_cn: "人工遥操作模式（直接控制）"
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

**控制模式字段：**


.. list-table::
   :header-rows: 1

   * - 字段
     - 类型
     - 用途
   * - ``description``
     - string
     - 人类可读的模式描述（英文）
   * - ``description_cn``
     - string
     - 可选的中文描述
   * - ``controllers``
     - list
     - 要生成的控制器名称 (来自 ``ros2_control.controllers_config``)
   * - ``inference.enabled``
     - bool
     - 是否启动推理服务
   * - ``inference.force_disable``
     - bool
     - 显式阻止推理 (用于遥操作安全)
   * - ``inference.execution_mode``
     - string
     - ``"monolithic"`` 或 ``"distributed"`` (见 `7.2 <#7.2>`__ 和 `7.3 <#7.3>`__)
   * - ``inference.model``
     - string
     - 来自 ``robot.models`` 的模型名称
   * - ``inference.action_server``
     - string
     - 推理分发的动作服务器主题
   * - ``executor.type``
     - string
     - ``"topic"`` (位置控制) 或 ``"action"`` (轨迹控制)
   * - ``executor.mode``
     - string
     - 执行器逻辑的模式标识符
   * - ``executor.control_frequency``
     - float
     - 执行器循环频率（Hz）

**来源：**
`src/robot_config/config/robots/so101_single_arm.yaml:48-103 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L48-L103>`__

模式对比表
~~~~~~~~~~


.. list-table::
   :header-rows: 1

   * - 特性
     - ``teleop``
     - ``model_inference``
     - ``moveit_planning``
   * - **控制器**
     - 位置控制器
     - 位置控制器
     - 轨迹控制器
   * - **推理**
     - 禁用
     - 启用
     - 禁用
   * - **执行器**
     - 基于主题
     - 基于主题
     - 基于动作
   * - **频率**
     - 50 Hz
     - 50-100 Hz
     - 可变（轨迹）
   * - **用例**
     - 人工演示 数据收集
     - ACT/Diffusion Policy 部署
     - VoxPoser/VLM 航点 执行

**来源：** `src/robot_config/README.md:88-207 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/README.md#L88-L207>`__，
`src/robot_config/README.en.md:88-213 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/README.en.md#L88-L213>`__

--------------

ros2_control 配置
-----------------

``ros2_control`` 部分定义硬件抽象层参数、控制器配置文件和硬件插件设置。

**图表：ros2_control 配置到硬件流程**

.. mermaid::

   graph TB
       YAML_R2C["robot.ros2_control"]
       
       YAML_R2C --> HW_PLUGIN["hardware_plugin:<br/>'so101_hardware/SO101SystemHardware'"]
       YAML_R2C --> PARAMS["params:<br/>port: /dev/ttyACM0<br/>calib_file: ~/.calibrate/...<br/>joint_names: [...]<br/>reset_positions: {...}"]
       YAML_R2C --> URDF["urdf_path:<br/>$(find robot_description)/urdf/..."]
       YAML_R2C --> CTRL_CFG["controllers_config:<br/>$(find so101_hardware)/config/so101_controllers.yaml"]
       
       HW_PLUGIN --> LOADER_CODE["load_ros2_control_config()<br/>robot_config/loader.py:66-91"]
       PARAMS --> LOADER_CODE
       URDF --> LOADER_CODE
       
       LOADER_CODE --> R2C_CONFIG["Ros2ControlConfig dataclass"]
       
       R2C_CONFIG --> LAUNCH["ros2_control.launch.py<br/>从配置生成"]
       
       LAUNCH --> HW_IF["SO101SystemHardware<br/>硬件接口"]
       
       HW_IF --> MOTORS["Feetech SDK<br/>电机通信"]
       
       style YAML_R2C fill:#f9f9f9,stroke:#333,stroke-width:2px
       style LOADER_CODE fill:#e3f2fd,stroke:#1976d2,stroke-width:2px
       style HW_IF fill:#fff3e0,stroke:#ff9800,stroke-width:2px

**结构：**

.. code:: yaml

   robot:
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
       controllers_config: $(find so101_hardware)/config/so101_controllers.yaml
       controllers:
         - joint_state_broadcaster
         - arm_controller
         - gripper_controller

**字段描述：**


.. list-table::
   :header-rows: 1

   * - 字段
     - 类型
     - 用途
   * - ``hardware_plugin``
     - string
     - ``pluginlib`` 加载的 完全限定插件名称
   * - ``port``
     - string
     - 硬件通信端口 (例如 ``/dev/ttyACM0``)
   * - ``calib_file``
     - string
     - 标定 JSON 的路径 (支持 ``$(env VAR)`` 替换)
   * - ``joint_names``
     - list
     - 硬件通信顺序中的关节名称
   * - ``reset_positions``
     - dict
     - 每个关节的初始/复位位置 (可选)
   * - ``urdf_path``
     - string
     - URDF/Xacro 文件路径 (支持 ``$(find pkg)`` 语法)
   * - ``controllers_config``
     - string
     - 控制器 YAML 配置的路径
   * - ``controllers``
     - list
     - 自动生成的默认控制器

**路径解析：**

加载器通过 ```resolve_ros_path()`` <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/>`__ 支持 ROS 路径宏：

- ``$(env VAR)`` - 环境变量替换
- ``$(find package_name)`` - ament 包前缀解析

**来源：**
`src/robot_config/config/robots/so101_single_arm.yaml:105-128 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L105-L128>`__，
`src/robot_config/robot_config/loader.py:66-91 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/loader.py#L66-L91>`__，
`src/robot_config/robot_config/utils.py <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/utils.py>`__

--------------

遥操作配置
----------

``teleoperation`` 部分定义 ``teleop`` 模式下使用的人工控制设备设置。

**结构：**

.. code:: yaml

   robot:
     teleoperation:
       enabled: true
       active_device: "so101_leader"
       devices:
         - name: "so101_leader"
           type: "leader_arm"
           port: "/dev/ttyACM1"
           calib_file: "$(env HOME)/.calibrate/so101_leader_calibrate.json"
       safety:
         joint_limits:
           "1": {"min": -2.0693, "max": 2.0709}
           "2": {"min": -1.92, "max": 1.92}
           "3": {"min": -1.6813, "max": 1.6828}
           "4": {"min": -1.65806, "max": 1.65806}
           "5": {"min": -2.9115, "max": 2.9115}
           "6": {"min": 0.0, "max": 1.0}

**字段描述：**


.. list-table::
   :header-rows: 1

   * - 字段
     - 类型
     - 用途
   * - ``enabled``
     - bool
     - 全局遥操作启用标志
   * - ``active_device``
     - string
     - ``devices`` 列表中的活动设备名称
   * - ``devices[].name``
     - string
     - 唯一设备标识符
   * - ``devices[].type``
     - string
     - 设备类型 (``leader_arm``, ``xbox``, ``spacemouse``, ``vr``)
   * - ``devices[].port``
     - string
     - 设备通信端口
   * - ``devices[].calib_file``
     - string
     - 设备特定的标定文件
   * - ``safety.joint_limits``
     - dict
     - 用于安全过滤的关节位置限制

此配置由 ``robot_teleop`` 包使用，用于初始化遥操作设备驱动和安全过滤器。

**来源：**
`src/robot_config/config/robots/so101_single_arm.yaml:306-321 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L306-L321>`__

--------------

录制配置
--------

``recording`` 部分指定回合录制的默认设置。

**结构：**

.. code:: yaml

   robot:
     recording:
       bag_base_dir: "~/rosbag/episodes"
       storage: mcap

**字段描述：**


.. list-table::
   :header-rows: 1

   * - 字段
     - 类型
     - 默认值
     - 用途
   * - ``bag_base_dir``
     - string
     - ``~/rosbag/episodes``
     - ROS2 bag 存储 的基础目录
   * - ``storage``
     - string
     - ``mcap``
     - 存储格式 (``mcap`` 或 ``sqlite3``)

``bag_base_dir`` 作为参数传递给 ``episode_recorder`` 节点，该节点为每个录制会话创建带时间戳的子目录。

**来源：**
`src/robot_config/config/robots/so101_single_arm.yaml:326-328 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L326-L328>`__

--------------

配置加载与验证
--------------

机器人配置通过 ```load_robot_config()`` <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/>`__ 函数加载，该函数执行 YAML 解析、路径解析并返回 ```RobotConfig`` <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/>`__ 数据类实例。

**图表：配置加载流水线**

.. mermaid::

   graph TB
       YAML_FILE["so101_single_arm.yaml"]
       
       YAML_FILE --> LOADER["load_robot_config()<br/>robot_config/loader.py:147"]
       
       LOADER --> PARSE["yaml.safe_load()"]
       
       PARSE --> VALIDATE_STRUCT["验证 'robot' 部分存在"]
       
       VALIDATE_STRUCT --> LOAD_SECTIONS["加载子部分:<br/>- load_ros2_control_config()<br/>- load_camera_config()<br/>- load_contract_config()"]
       
       LOAD_SECTIONS --> RESOLVE["resolve_ros_path()<br/>处理路径宏"]
       
       RESOLVE --> DATACLASS["RobotConfig<br/>dataclass 实例"]
       
       DATACLASS --> VALIDATE_FUNC["validate_config()<br/>robot_config/loader.py:217"]
       
       VALIDATE_FUNC --> CHECK1["检查 hardware_plugin 非空"]
       VALIDATE_FUNC --> CHECK2["检查 calib_file 存在"]
       VALIDATE_FUNC --> CHECK3["检查无重复相机名称"]
       VALIDATE_FUNC --> CHECK4["检查外设引用有效"]
       
       CHECK1 --> ERRORS["错误消息列表<br/>(有效则为空)"]
       CHECK2 --> ERRORS
       CHECK3 --> ERRORS
       CHECK4 --> ERRORS
       
       style LOADER fill:#e3f2fd,stroke:#1976d2,stroke-width:2px
       style DATACLASS fill:#fff3e0,stroke:#ff9800,stroke-width:2px
       style VALIDATE_FUNC fill:#c8e6c9,stroke:#388e3c,stroke-width:2px

**验证检查：**

```validate_config()`` <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/>`__ 函数执行以下检查：

1. **硬件插件检查** - 确保 ``ros2_control.hardware_plugin`` 已指定
2. **标定文件存在性** - 验证标定文件存在（如果指定）
3. **相机名称唯一性** - 检查重复的外设名称
4. **相机参数有效性** - 验证 width、height、fps > 0
5. **外设引用** - 确保契约观测引用有效的外设

**命令行验证：**

.. code:: bash

   python3 src/robot_config/robot_config/scripts/validate_config.py \
       src/robot_config/config/robots/so101_single_arm.yaml

**来源：** `src/robot_config/robot_config/loader.py:147-214 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/loader.py#L147-L214>`__，
`src/robot_config/robot_config/loader.py:217-262 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/loader.py#L217-L262>`__，
`src/robot_config/README.md:358-363 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/README.md#L358-L363>`__

--------------

示例配置文件
------------

仓库提供两个参考配置：

单臂配置
~~~~~~~~

文件：```src/robot_config/config/robots/so101_single_arm.yaml`` <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/>`__

-  **机器人类型：** 单 SO-101 手臂，6 DOF（5 个手臂关节 + 1 个夹爪）
-  **相机：** 3 个相机（顶部、腕部、前置）
-  **控制模式：** teleop、model_inference、moveit_planning
-  **默认模式：** model_inference 与 ACT 策略

**关键特性：**

- 三相机视觉设置（俯视、腕部、前置）
- ACT 策略模型预配置
- 主臂遥操作支持
- MoveIt 集成支持 5-DOF 运动学约束

双臂配置
~~~~~~~~

文件：```src/robot_config/config/robots/so101_dual_arm.yaml`` <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/>`__

-  **机器人类型：** 双 SO-101 手臂（ALOHA 风格双手设置）
-  **相机：** 3 个相机（顶部、left_wrist、right_wrist）
-  **关节组：** left_arm、right_arm、left_gripper、right_gripper
-  **契约：** 双手观测和动作

**与单臂的关键区别：**

- 左/右臂的独立关节组
- 每条手臂的腕部相机
- 统一关节状态主题，带前缀关节名称
- ``robot_type: aloha`` 用于 LeRobot 数据集兼容性

**来源：**
`src/robot_config/config/robots/so101_single_arm.yaml:1-329 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L1-L329>`__，
`src/robot_config/config/robots/so101_dual_arm.yaml:1-212 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_dual_arm.yaml#L1-L212>`__

--------------

与其他组件的集成
----------------

机器人配置文件与多个系统组件集成：

**图表：配置集成点**

.. mermaid::

   graph TB
       CONFIG["so101_single_arm.yaml"]
       
       CONFIG --> LAUNCH["robot.launch.py<br/>启动系统"]
       CONFIG --> RECORDER["episode_recorder<br/>录制服务"]
       CONFIG --> CONVERTER["bag_to_lerobot<br/>数据集转换"]
       CONFIG --> INFERENCE["lerobot_policy_node<br/>推理服务"]
       CONFIG --> TELEOP["robot_teleop<br/>遥操作"]
       CONFIG --> MOVEIT["MoveItGateway<br/>运动规划"]
       
       LAUNCH --> SPAWN_CTRL["从 control_modes<br/>生成控制器"]
       LAUNCH --> SPAWN_CAM["从 peripherals<br/>启动相机驱动"]
       LAUNCH --> SPAWN_INF["如果模式启用<br/>启动推理"]
       
       RECORDER --> CONTRACT_REC["使用 contract.observations<br/>进行主题订阅"]
       CONVERTER --> CONTRACT_CONV["使用契约<br/>进行消息解码"]
       INFERENCE --> CONTRACT_INF["使用 contract.observations<br/>作为输入特征"]
       
       TELEOP --> TELEOP_CFG["使用 teleoperation 部分<br/>进行设备配置"]
       MOVEIT --> MOVEIT_CFG["使用 moveit 部分<br/>作为规划组"]
       
       style CONFIG fill:#fff3e0,stroke:#ff9800,stroke-width:3px
       style CONTRACT_REC fill:#e3f2fd,stroke:#1976d2,stroke-width:2px
       style CONTRACT_CONV fill:#e3f2fd,stroke:#1976d2,stroke-width:2px
       style CONTRACT_INF fill:#e3f2fd,stroke:#1976d2,stroke-width:2px

**集成详情：**

-  **启动系统 (5.4)** - 读取控制模式、生成控制器、启动外设
-  **契约系统 (5.2)** - 使用契约部分进行观测/动作定义
-  **外设 (5.3)** - 使用外设部分进行相机驱动配置
-  **回合录制器** - 订阅 contract.observations 中定义的主题
-  **数据集转换器** - 使用契约将 ROS 消息解码为张量
-  **推理服务** - 从 models 部分加载模型，使用契约进行 I/O
-  **遥操作** - 使用 teleoperation 部分进行设备配置
-  **MoveIt** - 使用 moveit 部分进行规划组和 IK 配置

**来源：**
`src/robot_config/config/robots/so101_single_arm.yaml:1-329 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L1-L329>`__，
`src/robot_config/README.md:1-527 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/README.md#L1-L527>`__

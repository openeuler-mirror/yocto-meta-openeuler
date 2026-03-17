ros2_control 配置
================

.. raw:: html

   <details>

相关源文件

以下文件用作生成此 wiki 页面的上下文：

-  `src/robot_config/README.en.md <src/robot_config/README.en.md>`__
-  `src/robot_config/README.md <src/robot_config/README.md>`__
-  `src/robot_config/config/robots/so101_dual_arm.yaml <src/robot_config/config/robots/so101_dual_arm.yaml>`__
-  `src/robot_config/config/robots/so101_single_arm.yaml <src/robot_config/config/robots/so101_single_arm.yaml>`__
-  `src/robot_config/robot_config/loader.py <src/robot_config/robot_config/loader.py>`__
-  `src/tensormsg/tensormsg/converter.py <src/tensormsg/tensormsg/converter.py>`__

.. raw:: html

   </details>

本文档介绍 robot_config YAML 文件中的 ros2_control 配置系统。它解释了如何指定硬件插件、控制器和关节定义，以实现真实机器人和仿真之间的硬件抽象。

有关整体配置系统架构的信息，请参阅 `配置系统 (robot_config) <#5>`__。有关硬件插件实现细节，请参阅 `硬件插件 <#11.2>`__。有关控制模式选择和执行器集成，请参阅 `控制模式架构 <#3.3>`__。

--------------

目的与范围
---------

robot_config YAML 文件中的 ``ros2_control`` 部分提供了 IB-Robot 系统与 ros2_control 硬件抽象框架之间的配置桥梁。此配置定义：

-  **硬件插件选择**：指定要加载的硬件接口插件（真实硬件或仿真）
-  **硬件参数**：端口、校准文件、关节名称、复位位置
-  **控制器配置**：定义可用的控制器及其自动启动
-  **URDF 集成**：链接到机器人的 URDF/Xacro 描述以获取运动学信息

此配置是硬件接口参数的单一数据源，消除了启动文件、URDF 文件和控制器配置之间的重复。

**来源**：
`src/robot_config/config/robots/so101_single_arm.yaml:104-129 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L104-L129>`__，
`src/robot_config/README.md:1-13 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/README.md#L1-L13>`__

--------------

配置结构
--------

ros2_control 配置位于 robot_config YAML 文件的 ``robot.ros2_control`` 部分。以下是包含所有支持字段的完整结构：

.. code:: yaml

   robot:
     ros2_control:
       # 硬件插件（必需）
       hardware_plugin: so101_hardware/SO101SystemHardware
       
       # 硬件连接参数
       port: /dev/ttyACM0
       calib_file: $(env HOME)/.calibrate/so101_follower_calibrate.json
       
       # 关节定义（必须与 URDF 匹配）
       joint_names: ["1", "2", "3", "4", "5", "6"]
       
       # 可选复位位置（关节名称: 位置弧度）
       reset_positions:
         "1": 0.0
         "2": 0.0
         "3": 0.0
         "4": 0.0
         "5": 0.0
       
       # URDF 路径（controller_manager 必需）
       urdf_path: $(find robot_description)/urdf/lerobot/so101/so101.urdf.xacro
       
       # 控制器配置文件路径
       controllers_config: $(find so101_hardware)/config/so101_controllers.yaml
       
       # 自动启动控制器（可选，用于向后兼容）
       controllers:
         - joint_state_broadcaster
         - arm_controller
         - gripper_controller

**来源**：
`src/robot_config/config/robots/so101_single_arm.yaml:104-129 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L104-L129>`__

--------------

硬件插件配置
------------

插件规范
~~~~~~~~

``hardware_plugin`` 字段使用 ROS2 包资源命名：``<package_name>/<PluginClassName>``。此插件实现了 ros2_control 的 ``hardware_interface::SystemInterface``。


.. list-table::
   :header-rows: 1

   * - 字段
     - 类型
     - 必需
     - 描述
   * - ` `hardware_plugin``
     - string
     - 是
     - 完全限定的 插件类名
   * - ``port``
     - string
     - 否
     - 硬件的串口或 设备路径
   * - ``calib_file``
     - string
     - 否
     - 关节校准 JSON 文件路径
   * - ``joint_names``
     - list[string]
     - 是
     - 关节名称 （必须与 URDF 关节名称匹配）
   * - ` `reset_positions``
     - dict
     - 否
     - 启动时的 初始关节位置 （弧度）
   * - ``urdf_path``
     - string
     - 是
     - 机器人 URDF/Xacro 描述路径

**支持的硬件插件：**

1. **真实硬件**：``so101_hardware/SO101SystemHardware`` - 通过串口与 Feetech 舵机交互
2. **仿真**：``gz_ros2_control/GazeboSimSystem`` - Gazebo 物理仿真（当 ``use_sim:=true`` 时自动选择）

路径解析
~~~~~~~~

所有路径字段支持 ROS2 包路径语法：-
``$(find <package_name>)`` - 解析为包安装前缀 -
``$(env <VAR_NAME>)`` - 解析环境变量 - 绝对路径按原样使用

``resolve_ros_path()`` 函数在配置加载时处理此解析。

**来源**：
`src/robot_config/config/robots/so101_single_arm.yaml:105-118 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L105-L118>`__，
`src/robot_config/robot_config/loader.py:66-91 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/loader.py#L66-L91>`__

--------------

控制器配置
----------

控制器配置文件
~~~~~~~~~~~~~~

``controllers_config`` 字段指定包含 ros2_control 控制器参数定义的 YAML 文件。此文件定义控制器类型、关节分配和控制参数。

**示例**：`src/so101_hardware/config/so101_controllers.yaml <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/so101_hardware/config/so101_controllers.yaml>`__

.. code:: yaml

   controller_manager:
     ros__parameters:
       update_rate: 100  # Hz
       
       # model_inference/teleop 模式的位置控制器
       arm_position_controller:
         type: forward_command_controller/ForwardCommandController
         
       gripper_position_controller:
         type: forward_command_controller/ForwardCommandController
       
       # moveit_planning 模式的轨迹控制器  
       arm_trajectory_controller:
         type: joint_trajectory_controller/JointTrajectoryController
         
       gripper_trajectory_controller:
         type: joint_trajectory_controller/JointTrajectoryController
       
       # 状态广播器（始终活动）
       joint_state_broadcaster:
         type: joint_state_broadcaster/JointStateBroadcaster

   # 单个控制器配置...
   arm_position_controller:
     ros__parameters:
       joints:
         - "1"
         - "2"
         - "3"
         - "4"
         - "5"
       interface_name: position

控制模式特定控制器
~~~~~~~~~~~~~~~~~~

不同的控制模式激活不同的控制器集，如 robot_config 的 ``control_modes`` 部分所定义：

.. mermaid::

   graph TB
       subgraph "Control Mode Configuration"
           YAML["robot_config YAML<br/>control_modes section"]
       end
       
       subgraph "teleop Mode"
           TELEOP_CTRL["Controllers:<br/>- joint_state_broadcaster<br/>- arm_position_controller<br/>- gripper_position_controller"]
       end
       
       subgraph "model_inference Mode"
           MODEL_CTRL["Controllers:<br/>- joint_state_broadcaster<br/>- arm_position_controller<br/>- gripper_position_controller"]
       end
       
       subgraph "moveit_planning Mode"
           MOVEIT_CTRL["Controllers:<br/>- joint_state_broadcaster<br/>- arm_trajectory_controller<br/>- gripper_trajectory_controller"]
       end
       
       subgraph "ros2_control Layer"
           CTRL_MGR["controller_manager"]
           JSB["joint_state_broadcaster"]
           ARM_POS["arm_position_controller<br/>(ForwardCommandController)"]
           GRIP_POS["gripper_position_controller<br/>(ForwardCommandController)"]
           ARM_TRAJ["arm_trajectory_controller<br/>(JointTrajectoryController)"]
           GRIP_TRAJ["gripper_trajectory_controller<br/>(JointTrajectoryController)"]
       end
       
       subgraph "Hardware Interface"
           HW["SO101SystemHardware<br/>or GazeboSimSystem"]
       end
       
       YAML --> TELEOP_CTRL
       YAML --> MODEL_CTRL
       YAML --> MOVEIT_CTRL
       
       TELEOP_CTRL --> CTRL_MGR
       MODEL_CTRL --> CTRL_MGR
       MOVEIT_CTRL --> CTRL_MGR
       
       CTRL_MGR --> JSB
       CTRL_MGR --> ARM_POS
       CTRL_MGR --> GRIP_POS
       CTRL_MGR --> ARM_TRAJ
       CTRL_MGR --> GRIP_TRAJ
       
       JSB --> HW
       ARM_POS --> HW
       GRIP_POS --> HW
       ARM_TRAJ --> HW
       GRIP_TRAJ --> HW

**来源**：
`src/robot_config/config/robots/so101_single_arm.yaml:48-103 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L48-L103>`__，
`src/robot_config/README.md:88-207 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/README.md#L88-L207>`__

--------------

配置加载过程
------------

``robot_config.loader`` 模块中的 ``load_ros2_control_config()`` 函数处理 ros2_control 配置部分并构建 ``Ros2ControlConfig`` 对象。

加载流程
~~~~~~~~

.. mermaid::

   graph LR
       YAML_FILE["so101_single_arm.yaml"]
       
       LOAD_FUNC["load_robot_config()"]
       
       EXTRACT["Extract robot.ros2_control<br/>section"]
       
       ROS2_FUNC["load_ros2_control_config()"]
       
       RESOLVE["resolve_ros_path()<br/>for all path fields"]
       
       CONFIG_OBJ["Ros2ControlConfig object<br/>- hardware_plugin<br/>- params dict<br/>- urdf_path"]
       
       LAUNCH["robot.launch.py<br/>LaunchBuilder"]
       
       YAML_FILE --> LOAD_FUNC
       LOAD_FUNC --> EXTRACT
       EXTRACT --> ROS2_FUNC
       ROS2_FUNC --> RESOLVE
       RESOLVE --> CONFIG_OBJ
       CONFIG_OBJ --> LAUNCH

代码实现
~~~~~~~~

加载逻辑将除 ``hardware_plugin`` 和 ``urdf_path`` 外的所有字段提取到 ``params`` 字典中：

**函数**：``load_ros2_control_config()``
`src/robot_config/robot_config/loader.py:66-91 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/loader.py#L66-L91>`__

.. code:: python

   def load_ros2_control_config(data: Dict[str, Any], config_dir: Optional[Path] = None) -> Ros2ControlConfig:
       params = {}
       for key, value in data.items():
           if key not in ["hardware_plugin", "urdf_path"]:
               # Resolve paths in parameters
               if isinstance(value, str):
                   value = resolve_ros_path(value)
               params[key] = value

       return Ros2ControlConfig(
           hardware_plugin=data.get("hardware_plugin", ""),
           params=params,
           urdf_path=resolve_ros_path(data.get("urdf_path")),
       )

``params`` 字典稍后在 ros2_control 初始化期间传递给硬件插件。这允许硬件插件访问自定义参数，如 ``port``、``calib_file`` 等。

**来源**：`src/robot_config/robot_config/loader.py:66-91 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/loader.py#L66-L91>`__，
`src/robot_config/robot_config/loader.py:147-214 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/loader.py#L147-L214>`__

--------------

与 robot.launch.py 集成
-----------------------

ros2_control 配置通过 ``LaunchBuilder`` 模式与启动系统集成。启动文件根据配置动态生成 ros2_control 节点。

启动时配置流程
~~~~~~~~~~~~~~

.. mermaid::

   graph TB
       LAUNCH_PY["robot.launch.py"]
       
       LOAD_CFG["load_robot_config()<br/>from YAML"]
       
       GET_MODE["Get control_mode<br/>from launch args"]
       
       BUILDER["LaunchBuilder.build()"]
       
       subgraph "Generated Nodes"
           CTRL_MGR_NODE["controller_manager node<br/>--ros-args --param robot_description:=..."]
           
           SPAWN_NODES["spawn_controller nodes<br/>for each controller in mode"]
           
           HW_NODE["Hardware plugin loaded by<br/>controller_manager"]
       end
       
       LAUNCH_PY --> LOAD_CFG
       LOAD_CFG --> GET_MODE
       GET_MODE --> BUILDER
       
       BUILDER --> CTRL_MGR_NODE
       BUILDER --> SPAWN_NODES
       CTRL_MGR_NODE --> HW_NODE

硬件与仿真选择
~~~~~~~~~~~~~~

``use_sim`` 启动参数决定加载哪个硬件插件：


.. list-table::
   :header-rows: 1

   * - ``use_sim`` 值
     - 硬件插件
     - 描述
   * - ``false``（默认）
     - ``so101_hardwar e/SO101SystemHardware``
     - 通过串口的 真实硬件
   * - ``true``
     - ``gz_ros2_co ntrol/GazeboSimSystem``
     - Gazebo 物理 仿真

启动构建器在将配置传递给 controller_manager 之前自动修改 ``hardware_plugin`` 字段。

**来源**：`src/robot_config/README.en.md:414-420 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/README.en.md#L414-L420>`__

--------------

配置验证
--------

``validate_config()`` 函数对 ros2_control 配置执行验证检查：

验证规则
~~~~~~~~

1. **必需字段**：必须指定 ``hardware_plugin``
2. **校准文件**：如果指定了 ``calib_file``，文件必须存在
3. **关节一致性**：ros2_control 配置中的关节名称必须与 URDF 匹配

**验证函数**：
`src/robot_config/robot_config/loader.py:217-262 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/loader.py#L217-L262>`__

.. code:: python

   def validate_config(config: RobotConfig) -> List[str]:
       errors = []
       
       # Validate ros2_control config
       if not config.ros2_control.hardware_plugin:
           errors.append("ros2_control.hardware_plugin is required")
       
       # Check calib_file exists if specified
       if "calib_file" in config.ros2_control.params:
           calib_file = config.ros2_control.params["calib_file"]
           if calib_file and not Path(calib_file).exists():
               errors.append(f"Calibration file not found: {calib_file}")
       
       # ... additional validation logic
       return errors

验证脚本
~~~~~~~~

提供了独立的验证脚本用于配置测试：

.. code:: bash

   python3 src/robot_config/robot_config/scripts/validate_config.py \
       src/robot_config/config/robots/so101_single_arm.yaml

**来源**：`src/robot_config/robot_config/loader.py:217-262 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/loader.py#L217-L262>`__，
`src/robot_config/README.md:357-363 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/README.md#L357-L363>`__

--------------

完整配置示例
------------

以下是包含所有可选字段的完整 ros2_control 配置：

.. code:: yaml

   robot:
     name: so101_single_arm
     type: so101
     
     # 关节定义（单一数据源）
     joints:
       arm: ["1", "2", "3", "4", "5"]
       gripper: ["6"]
       all: ["1", "2", "3", "4", "5", "6"]
     
     # ros2_control 配置
     ros2_control:
       # 硬件插件（必需）
       hardware_plugin: so101_hardware/SO101SystemHardware
       
       # 硬件通信串口
       port: /dev/ttyACM0
       
       # 关节校准文件（支持环境变量）
       calib_file: $(env HOME)/.calibrate/so101_follower_calibrate.json
       
       # 关节名称（必须与 URDF 匹配）
       joint_names: ["1", "2", "3", "4", "5", "6"]
       
       # 启动时复位位置（可选）
       reset_positions:
         "1": 0.0
         "2": 0.0
         "3": 0.0
         "4": 0.0
         "5": 0.0
       
       # 机器人 URDF 路径（支持包路径语法）
       urdf_path: $(find robot_description)/urdf/lerobot/so101/so101.urdf.xacro
       
       # 控制器配置文件
       controllers_config: $(find so101_hardware)/config/so101_controllers.yaml
       
       # 自动启动控制器（已弃用，请使用 control_modes）
       controllers:
         - joint_state_broadcaster
         - arm_controller
         - gripper_controller
     
     # 控制模式定义哪些控制器处于活动状态
     control_modes:
       model_inference:
         description: "High-frequency end-to-end control mode (ACT/pi0)"
         controllers:
           - joint_state_broadcaster
           - arm_position_controller
           - gripper_position_controller
         inference:
           enabled: true
           model: so101_act
       
       moveit_planning:
         description: "MoveIt trajectory planning mode (VoxPoser/VLM)"
         controllers:
           - joint_state_broadcaster
           - arm_trajectory_controller
           - gripper_trajectory_controller

**来源**：
`src/robot_config/config/robots/so101_single_arm.yaml:104-129 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L104-L129>`__，
`src/robot_config/config/robots/so101_single_arm.yaml:48-103 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L48-L103>`__

--------------

参数参考表
----------

核心参数
~~~~~~~~


.. list-table::
   :header-rows: 1

   * - 参数
     - 类型
     - 必需
     - 默认值
     - 描述
   * - ``hard ware_plugin``
     - string
     - 是
     - -
     - 完全限定的 硬件插件 类名
   * - ``port``
     - string
     - 否
     - -
     - 硬件通信 串口路径
   * - ` `calib_file``
     - string
     - 否
     - -
     - 关节校准 JSON 文件路径
   * - `` joint_names``
     - list[string]
     - 是
     - -
     - 与 URDF 匹配 的关节名称列表
   * - ``rese t_positions``
     - dict[string, float]
     - 否
     - ``{}``
     - 初始关节位置 （弧度）
   * - ``urdf_path``
     - string
     - 是
     - -
     - 机器人 URDF/Xacro 文件路径
   * - ``control lers_config``
     - string
     - 否
     - -
     - ros2_control 控制器 YAML 路径
   * - `` controllers``
     - list[string]
     - 否
     - ``[]``
     - 自动启动 控制器列表 （旧版）

硬件特定参数
~~~~~~~~~~~~

可以定义附加参数，硬件插件可通过 ``params`` 字典访问。常见的硬件特定参数：


.. list-table::
   :header-rows: 1

   * - 参数
     - 使用者
     - 类型
     - 描述
   * - ``baudrate``
     - 串口硬件
     - int
     - 串口波特率
   * - ``timeout_ms``
     - 串口硬件
     - int
     - 读写超时（毫秒）
   * - ``max_retries``
     - 串口硬件
     - int
     - 最大通信重试次数
   * - ``debug_mode``
     - 所有插件
     - bool
     - 启用详细硬件日志

**来源**：
`src/robot_config/config/robots/so101_single_arm.yaml:104-129 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L104-L129>`__，
`src/robot_config/robot_config/loader.py:66-91 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/loader.py#L66-L91>`__

--------------

双臂配置
--------

对于双臂机器人（例如 ALOHA 风格的配置），ros2_control 配置遵循相同的结构，但引用双臂 URDF：

.. code:: yaml

   robot:
     name: so101_dual_arm
     type: so101_dual
     
     joints:
       left_arm: ["left_1", "left_2", "left_3", "left_4", "left_5"]
       right_arm: ["right_1", "right_2", "right_3", "right_4", "right_5"]
     
     ros2_control:
       hardware_plugin: so101_hardware/SO101SystemHardware
       port: /dev/ttyACM0
       calib_file: $(env HOME)/.calibrate/so101_dual_calibrate.json
       urdf_path: $(find robot_description)/urdf/lerobot/so101/so101_dual.urdf.xacro

硬件插件必须在内部处理多个手臂，或者在 URDF 中配置单独的硬件插件实例。

**来源**：
`src/robot_config/config/robots/so101_dual_arm.yaml:5-17 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_dual_arm.yaml#L5-L17>`__

--------------

故障排除
--------

常见配置错误
~~~~~~~~~~~~

硬件插件未找到
^^^^^^^^^^^^^^

**错误**：
``Could not find hardware plugin: so101_hardware/SO101SystemHardware``

**解决方案**：确保硬件插件包已构建并 source：

.. code:: bash

   colcon build --packages-select so101_hardware
   source install/setup.bash

校准文件缺失
^^^^^^^^^^^^

**错误**：
``Calibration file not found: /home/user/.calibrate/so101_follower_calibrate.json``

**解决方案**：验证校准文件存在或暂时禁用校准：

.. code:: yaml

   ros2_control:
     # calib_file: $(env HOME)/.calibrate/so101_follower_calibrate.json  # 注释掉

URDF 路径解析失败
^^^^^^^^^^^^^^^^

**错误**：``URDF file not found: $(find robot_description)/urdf/...``

**解决方案**：确保 robot_description 包已构建且路径正确：

.. code:: bash

   ros2 pkg prefix robot_description

控制器生成失败
^^^^^^^^^^^^^^

**错误**：``Controller 'arm_position_controller' not found``

**解决方案**：验证控制器在 controllers_config 文件中定义，并与控制模式规范匹配。

**来源**：`src/robot_config/README.md:470-515 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/README.md#L470-L515>`__

--------------

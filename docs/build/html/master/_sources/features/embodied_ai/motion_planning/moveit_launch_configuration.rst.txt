MoveIt 启动配置
===============

.. raw:: html

   <details>

相关源文件

以下文件用作生成此 wiki 页面的上下文：

-  `src/robot_config/README.en.md <src/robot_config/README.en.md>`__
-  `src/robot_config/README.md <src/robot_config/README.md>`__
-  `src/robot_config/config/robots/so101_dual_arm.yaml <src/robot_config/config/robots/so101_dual_arm.yaml>`__
-  `src/robot_config/config/robots/so101_single_arm.yaml <src/robot_config/config/robots/so101_single_arm.yaml>`__
-  `src/robot_config/config/robots/test_single_arm_single_cam.yaml <src/robot_config/config/robots/test_single_arm_single_cam.yaml>`__
-  `src/robot_config/robot_config/launch_builders/moveit.py <src/robot_config/robot_config/launch_builders/moveit.py>`__
-  `src/robot_config/robot_config/loader.py <src/robot_config/robot_config/loader.py>`__
-  `src/robot_moveit/CMakeLists.txt <src/robot_moveit/CMakeLists.txt>`__
-  `src/robot_moveit/config/lerobot/so101/kinematics.yaml <src/robot_moveit/config/lerobot/so101/kinematics.yaml>`__
-  `src/robot_moveit/docs/moveit_gateway.md <src/robot_moveit/docs/moveit_gateway.md>`__
-  `src/robot_moveit/launch/so101_moveit.launch.py <src/robot_moveit/launch/so101_moveit.launch.py>`__
-  `src/robot_moveit/package.xml <src/robot_moveit/package.xml>`__
-  `src/robot_moveit/scripts/moveit_gateway.py <src/robot_moveit/scripts/moveit_gateway.py>`__
-  `src/tensormsg/tensormsg/converter.py <src/tensormsg/tensormsg/converter.py>`__

.. raw:: html

   </details>

本文档介绍 IB-Robot 中的 MoveIt 2 启动配置系统，该系统为 ``moveit_planning`` 控制模式提供运动规划功能。有关 MoveItGateway 节点的 IK 求解和约束处理信息，请参阅 `10.1 <#10.1>`__。有关 5DOF 运动学约束的详细信息，请参阅 `10.2 <#10.2>`__。

目的与范围
----------

MoveIt 启动配置系统在机器人以 ``moveit_planning`` 控制模式启动时，协调 MoveIt 2 组件的启动。它处理：

-  基于控制模式条件性包含 MoveIt 节点
-  参数从 ``robot_config`` YAML 传播到 MoveIt 启动文件
-  MoveIt 规划组、运动学求解器和控制器的配置
-  可选的运动规划 RViz 可视化

此系统将 robot_config 单一数据源模式与 MoveIt 的配置需求连接起来，确保关节定义、链接名称和规划组参数在整个工作空间中保持一致。

启动架构概述
------------

MoveIt 启动系统使用两级架构：``robot_config`` 中的启动构建器条件性地包含 ``robot_moveit`` 包中的主 MoveIt 启动文件。

.. mermaid::

   graph TB
       subgraph "robot_config Package"
           RobotLaunch["robot.launch.py"]
           MoveItBuilder["launch_builders/moveit.py<br/>generate_moveit_nodes()"]
           RobotYAML["config/robots/so101_single_arm.yaml<br/>moveit: {...}"]
       end
       
       subgraph "robot_moveit Package"
           SO101Launch["launch/so101_moveit.launch.py<br/>generate_launch_description()"]
           MoveItBuilder2["MoveItConfigsBuilder"]
           
           subgraph "MoveIt Configuration Files"
               SRDF["config/.../so101.srdf<br/>planning groups"]
               Kinematics["config/.../kinematics.yaml<br/>position_only_ik: True"]
               JointLimits["config/.../joint_limits.yaml"]
               Controllers["config/.../moveit_controllers.yaml"]
               PilzLimits["config/.../pilz_cartesian_limits.yaml"]
           end
           
           subgraph "Launched Nodes"
               MoveGroup["move_group node<br/>moveit_ros_move_group"]
               RViz["rviz2 node<br/>(conditional)"]
               Gateway["moveit_gateway.py<br/>IK gateway"]
           end
       end
       
       RobotLaunch -->|"control_mode:=moveit_planning"| MoveItBuilder
       MoveItBuilder -->|"read moveit section"| RobotYAML
       MoveItBuilder -->|"IncludeLaunchDescription"| SO101Launch
       
       SO101Launch -->|"loads configurations"| MoveItBuilder2
       MoveItBuilder2 --> SRDF
       MoveItBuilder2 --> Kinematics
       MoveItBuilder2 --> JointLimits
       MoveItBuilder2 --> Controllers
       MoveItBuilder2 --> PilzLimits
       
       SO101Launch --> MoveGroup
       SO101Launch --> RViz
       SO101Launch --> Gateway

**来源**：
`src/robot_config/robot_config/launch_builders/moveit.py:1-79 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/launch_builders/moveit.py#L1-L79>`__，
`src/robot_moveit/launch/so101_moveit.launch.py:1-134 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/launch/so101_moveit.launch.py#L1-L134>`__

配置参数
--------

robot_config YAML 部分
~~~~~~~~~~~~~~~~~~~~~~

``robot_config`` YAML 中的 ``moveit:`` 部分定义传递给启动系统的 MoveIt 特定参数：


.. list-table::
   :header-rows: 1

   * - 参数
     - 类型
     - 描述
     - 示例
   * - ``arm_group_name``
     - string
     - MoveIt 规划组名称
     - ``"arm"``
   * - ``base_link``
     - string
     - 基座坐标系
     - ``"base"``
   * - ``ee_link``
     - string
     - 末端执行器链接名称
     - ``"gripper"``
   * - ``shoulder_link``
     - string
     - 用于 5DOF 约束的肩部链接
     - ``"shoulder"``

**机器人配置示例**：

`src/robot_config/config/robots/so101_single_arm.yaml:37-43 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L37-L43>`__

这些参数由启动构建器提取并作为启动参数传播。

**来源**：
`src/robot_config/config/robots/so101_single_arm.yaml:37-43 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L37-L43>`__，
`src/robot_config/robot_config/launch_builders/moveit.py:46-68 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/launch_builders/moveit.py#L46-L68>`__

启动参数
~~~~~~~~

``so101_moveit.launch.py`` 声明以下控制 MoveIt 行为的启动参数：

.. mermaid::

   graph LR
       subgraph "Launch Arguments"
           IsSim["is_sim<br/>(default: True)"]
           Display["display<br/>(default: True)"]
           JointNames["joint_names<br/>(required)"]
           ArmGroup["arm_group_name<br/>(required)"]
           BaseLink["base_link<br/>(required)"]
           EELink["ee_link<br/>(required)"]
           ShoulderLink["shoulder_link<br/>(required)"]
       end
       
       subgraph "Parameter Consumers"
           MoveGroup["move_group<br/>use_sim_time"]
           RViz2["rviz2<br/>condition"]
           Gateway["moveit_gateway<br/>parameters"]
       end
       
       IsSim --> MoveGroup
       IsSim --> Gateway
       Display --> RViz2
       JointNames --> Gateway
       ArmGroup --> Gateway
       BaseLink --> Gateway
       EELink --> Gateway
       ShoulderLink --> Gateway

**来源**：`src/robot_moveit/launch/so101_moveit.launch.py:13-54 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/launch/so101_moveit.launch.py#L13-L54>`__

启动文件包含流程
----------------

以下图表显示参数如何从 ``robot_config`` 流向 MoveIt 节点：

.. mermaid::

   sequenceDiagram
       participant User
       participant RobotLaunch as robot.launch.py
       participant MoveItBuilder as generate_moveit_nodes()
       participant RobotYAML as robot_config YAML
       participant SO101Launch as so101_moveit.launch.py
       participant MoveItCfg as MoveItConfigsBuilder
       participant Nodes as MoveIt Nodes
       
       User->>RobotLaunch: ros2 launch robot_config robot.launch.py<br/>control_mode:=moveit_planning
       RobotLaunch->>MoveItBuilder: generate_moveit_nodes(config, mode)
       MoveItBuilder->>RobotYAML: Read moveit section
       RobotYAML-->>MoveItBuilder: arm_group_name, base_link, ee_link, shoulder_link
       MoveItBuilder->>RobotYAML: Read joints.arm
       RobotYAML-->>MoveItBuilder: ["1", "2", "3", "4", "5"]
       
       MoveItBuilder->>SO101Launch: IncludeLaunchDescription<br/>joint_names="1 2 3 4 5"<br/>arm_group_name="arm"<br/>base_link="base"<br/>ee_link="gripper"<br/>shoulder_link="shoulder"
       
       SO101Launch->>MoveItCfg: MoveItConfigsBuilder("so101")<br/>.robot_description(...)<br/>.robot_description_semantic(...)<br/>.robot_description_kinematics(...)
       MoveItCfg-->>SO101Launch: moveit_config.to_dict()
       
       SO101Launch->>Nodes: Launch move_group, rviz2, moveit_gateway
       Nodes-->>User: MoveIt services available

**来源**：
`src/robot_config/robot_config/launch_builders/moveit.py:40-78 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/launch_builders/moveit.py#L40-L78>`__，
`src/robot_moveit/launch/so101_moveit.launch.py:56-90 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/launch/so101_moveit.launch.py#L56-L90>`__

MoveItConfigsBuilder 使用
-------------------------

启动文件使用 ``moveit_configs_utils`` 中的 ``MoveItConfigsBuilder`` 加载和合并配置文件：

`src/robot_moveit/launch/so101_moveit.launch.py:61-70 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/launch/so101_moveit.launch.py#L61-L70>`__

配置文件映射：


.. list-table::
   :header-rows: 1

   * - 构建器方法
     - 配置文件
     - 用途
   * - ``.robot_description()``
     - ``urdf/lerobot/so101/so101.urdf.xacro``
     - 机器人运动学模型
   * - ``.robot_description_semantic()``
     - ``config/.../so101.srdf``
     - 规划组、末端执行器
   * - ``.robot_description_kinematics()``
     - ``config/.../kinematics.yaml``
     - IK 求解器配置
   * - ``.joint_limits()``
     - ``config/.../joint_limits.yaml``
     - 速度/加速度限制
   * - ``.trajectory_execution()``
     - ``config/../moveit_controllers.yaml``
     - 控制器映射
   * - ``.planning_pipelines()``
     - ``pipelines=["ompl"]``
     - OMPL 规划器配置

**来源**：`src/robot_moveit/launch/so101_moveit.launch.py:61-90 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/launch/so101_moveit.launch.py#L61-L90>`__

节点配置
--------

move_group 节点
~~~~~~~~~~~~~~~

核心 MoveIt 规划服务使用合并的配置参数启动：

`src/robot_moveit/launch/so101_moveit.launch.py:79-90 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/launch/so101_moveit.launch.py#L79-L90>`__

关键参数：- ``moveit_config.to_dict()``：所有配置文件合并 - ``use_sim_time``：与 ``is_sim`` 启动参数同步 - ``publish_robot_description_semantic``：将 SRDF 发布到 ``/robot_description_semantic`` - ``pilz_cartesian_limits_path``：额外的 Pilz 规划器限制

**来源**：`src/robot_moveit/launch/so101_moveit.launch.py:79-90 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/launch/so101_moveit.launch.py#L79-L90>`__

RViz2 可视化节点
~~~~~~~~~~~~~~~~

RViz 根据 ``display`` 参数条件性启动：

`src/robot_moveit/launch/so101_moveit.launch.py:94-105 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/launch/so101_moveit.launch.py#L94-L105>`__

RViz 配置从
`src/robot_moveit/config/lerobot/so101/moveit.rviz:1-1 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/config/lerobot/so101/moveit.rviz#L1-L1>`__ 加载，包括：- 用于交互式规划的 MotionPlanning 插件 - RobotModel 显示 - PlanningScene 可视化 - TF 坐标树

**来源**：
`src/robot_moveit/launch/so101_moveit.launch.py:92-105 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/launch/so101_moveit.launch.py#L92-L105>`__

moveit_gateway 节点
~~~~~~~~~~~~~~~~~~~

自定义网关节点从 ``robot_config`` 接收参数：

`src/robot_moveit/launch/so101_moveit.launch.py:107-120 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/launch/so101_moveit.launch.py#L107-L120>`__

参数使用 ``PythonExpression`` 构建，将空格分隔的 ``joint_names`` 字符串拆分回列表：

`src/robot_moveit/launch/so101_moveit.launch.py:117 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/launch/so101_moveit.launch.py#L117>`__

**来源**：
`src/robot_moveit/launch/so101_moveit.launch.py:107-120 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/launch/so101_moveit.launch.py#L107-L120>`__

运动学配置
----------

5DOF 机械臂支持最关键的配置文件是 ``kinematics.yaml``：

`src/robot_moveit/config/lerobot/so101/kinematics.yaml:1-7 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/config/lerobot/so101/kinematics.yaml#L1-L7>`__

position_only_ik: True
~~~~~~~~~~~~~~~~~~~~~~

此参数对 5DOF 机械臂 IK 求解至关重要。启用时：

-  KDL 求解器使用 ``ChainIkSolverPos`` 而非 ``ChainIkSolverPos_NR``
-  优化仅针对位置精度，忽略姿态
-  姿态约束仍可通过 ``Constraints`` 消息应用，但用于验证而非优化
-  显著提高 5DOF 机械臂的 IK 成功率

有关 5DOF 运动学约束的详细说明，请参阅 `10.2 <#10.2>`__。

**来源**：
`src/robot_moveit/config/lerobot/so101/kinematics.yaml:1-7 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/config/lerobot/so101/kinematics.yaml#L1-L7>`__，
`src/robot_moveit/docs/moveit_gateway.md:32-58 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/docs/moveit_gateway.md#L32-L58>`__

控制模式集成
------------

MoveIt 启动根据控制模式条件性包含：

.. mermaid::

   graph TB
       LaunchBuilder["generate_moveit_nodes()"]
       CheckMode{"'moveit' in<br/>control_mode.lower()?"}
       FindPkg["get_package_share_directory('robot_moveit')"]
       CheckFile{"so101_moveit.launch.py<br/>exists?"}
       Include["IncludeLaunchDescription"]
       Skip["return []<br/>(no MoveIt)"]
       Warn["Print warning<br/>'MoveIt launch file not found'"]
       
       LaunchBuilder --> CheckMode
       CheckMode -->|"No<br/>(teleop, model_inference)"| Skip
       CheckMode -->|"Yes<br/>(moveit_planning)"| FindPkg
       FindPkg --> CheckFile
       CheckFile -->|Yes| Include
       CheckFile -->|No| Warn
       Warn --> Skip

`src/robot_config/robot_config/launch_builders/moveit.py:29-34 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/launch_builders/moveit.py#L29-L34>`__

此设计确保 MoveIt 节点仅在需要时启动，减少其他控制模式下的资源消耗。

**来源**：
`src/robot_config/robot_config/launch_builders/moveit.py:15-78 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/launch_builders/moveit.py#L15-L78>`__

配置文件依赖图
--------------

.. mermaid::

   graph TB
       subgraph "robot_config Package"
           RobotYAML["so101_single_arm.yaml"]
       end
       
       subgraph "robot_description Package"
           URDF["urdf/lerobot/so101/so101.urdf.xacro"]
       end
       
       subgraph "robot_moveit Package"
           SO101Launch["so101_moveit.launch.py"]
           
           SRDF["so101.srdf"]
           Kinematics["kinematics.yaml"]
           JointLimits["joint_limits.yaml"]
           Controllers["moveit_controllers.yaml"]
           Pilz["pilz_cartesian_limits.yaml"]
       end
       
       subgraph "MoveIt Nodes"
           MoveGroup["move_group"]
           Gateway["moveit_gateway"]
       end
       
       RobotYAML -->|"moveit: {...}"| SO101Launch
       RobotYAML -->|"joints: {...}"| SO101Launch
       
       SO101Launch --> URDF
       SO101Launch --> SRDF
       SO101Launch --> Kinematics
       SO101Launch --> JointLimits
       SO101Launch --> Controllers
       SO101Launch --> Pilz
       
       URDF --> MoveGroup
       SRDF --> MoveGroup
       Kinematics --> MoveGroup
       JointLimits --> MoveGroup
       Controllers --> MoveGroup
       Pilz --> MoveGroup
       
       RobotYAML -->|"parameters"| Gateway
       Kinematics -.->|"IK solver"| Gateway

**来源**：
`src/robot_moveit/launch/so101_moveit.launch.py:58-90 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/launch/so101_moveit.launch.py#L58-L90>`__，
`src/robot_config/robot_config/launch_builders/moveit.py:40-78 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/launch_builders/moveit.py#L40-L78>`__

启动命令示例
------------

基本 MoveIt 启动（带 RViz）
~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code:: bash

   ros2 launch robot_config robot.launch.py \
     robot_config:=so101_single_arm \
     control_mode:=moveit_planning

此命令启动：- ``move_group`` 节点（运动规划服务）- 带 MoveIt 插件的 ``rviz2`` - ``moveit_gateway`` 节点（IK 求解器接口）

无头 MoveIt 启动（不带 RViz）
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code:: bash

   ros2 launch robot_config robot.launch.py \
     robot_config:=so101_single_arm \
     control_mode:=moveit_planning \
     moveit_display:=false

``moveit_display`` 参数作为 ``display`` 参数转发到 ``so101_moveit.launch.py``。

带 MoveIt 的仿真
~~~~~~~~~~~~~~~~

.. code:: bash

   ros2 launch robot_config robot.launch.py \
     robot_config:=so101_single_arm \
     control_mode:=moveit_planning \
     use_sim:=true

为所有 MoveIt 节点设置 ``use_sim_time:=True`` 以与 Gazebo 时钟同步。

**来源**：`src/robot_config/README.en.md:350-354 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/README.en.md#L350-L354>`__

参数映射表
----------

下表显示参数如何从 ``robot_config`` 提取并映射到 MoveIt 启动参数：


.. list-table::
   :header-rows: 1

   * - robot_config 路径
     - 转换
     - 启动参数
     - 消费节点
   * - ``moveit.ar m_group_name``
     - direct
     - ``ar m_group_name``
     - ``mo veit_gateway``
   * - ``move it.base_link``
     - direct
     - ``base_link``
     - ``mo veit_gateway``
   * - ``mo veit.ee_link``
     - direct
     - ``ee_link``
     - ``mo veit_gateway``
   * - ``moveit.s houlder_link``
     - direct
     - ``s houlder_link``
     - ``mo veit_gateway``
   * - ``joints.arm``
     - ``' '.join(list)``
     - ` `joint_names``
     - ``mo veit_gateway``
   * - ``use_sim`` (launch arg)
     - boolean
     - ``is_sim``
     - ` `move_group``, ``mo veit_gateway``
   * - ``mo veit_display`` (launch arg)
     - boolean
     - ``display``
     - ``rviz2`` (condition)

**来源**：
`src/robot_config/robot_config/launch_builders/moveit.py:46-68 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/launch_builders/moveit.py#L46-L68>`__，
`src/robot_moveit/launch/so101_moveit.launch.py:26-54 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/launch/so101_moveit.launch.py#L26-L54>`__

故障排除
--------

MoveIt 启动文件未找到
~~~~~~~~~~~~~~~~~~~~~~

**症状**：启动期间警告消息：

::

   [robot_config] WARNING: MoveIt launch file not found at .../so101_moveit.launch.py
   [robot_config] Continuing without MoveIt...

**原因**：``robot_moveit`` 包未构建或安装。

**解决方案**：

.. code:: bash

   cd ~/IB_Robot
   colcon build --packages-select robot_moveit
   source install/setup.bash

**来源**：
`src/robot_config/robot_config/launch_builders/moveit.py:73-76 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/launch_builders/moveit.py#L73-L76>`__

缺少 MoveIt 配置参数
~~~~~~~~~~~~~~~~~~~~

**症状**：启动失败，提示：

::

   [moveit_gateway-X] rclpy._exceptions.ParameterNotDeclaredException: Parameter 'arm_group_name' is not declared

**原因**：``robot_config`` YAML 中缺少 ``moveit:`` 部分。

**解决方案**：在机器人配置中添加 ``moveit:`` 部分：

.. code:: yaml

   robot:
     moveit:
       arm_group_name: arm
       base_link: base
       ee_link: gripper
       shoulder_link: shoulder

**来源**：
`src/robot_config/config/robots/so101_single_arm.yaml:37-43 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L37-L43>`__

关节名称不匹配
~~~~~~~~~~~~~~

**症状**：MoveIt 规划因关节名称无效而失败。

**原因**：``robot_config`` 中的 ``joints.arm`` 与 URDF 或 SRDF 中的关节名称不匹配。

**解决方案**：使用以下命令验证一致性：

.. code:: bash

   # 检查 URDF 关节
   ros2 topic echo /robot_description --once | grep -A 5 "joint name"

   # 检查 robot_config
   cat src/robot_config/config/robots/so101_single_arm.yaml | grep -A 5 "joints:"

确保关节列表完全匹配。

**来源**：
`src/robot_config/robot_config/launch_builders/moveit.py:47-49 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/launch_builders/moveit.py#L47-L49>`__

IK 求解器频繁失败
~~~~~~~~~~~~~~~~~~~~~~~

**症状**：MoveIt 规划对大多数目标返回 ``NO_IK_SOLUTION``。

**原因**：5DOF 机械臂的 ``kinematics.yaml`` 中未设置 ``position_only_ik: True``。

**解决方案**：验证运动学配置：

`src/robot_moveit/config/lerobot/so101/kinematics.yaml:6 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/config/lerobot/so101/kinematics.yaml#L6>`__

此参数对 5DOF 机械臂至关重要。详情请参阅 `10.2 <#10.2>`__。

**来源**：
`src/robot_moveit/config/lerobot/so101/kinematics.yaml:1-7 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/config/lerobot/so101/kinematics.yaml#L1-L7>`__，
`src/robot_moveit/docs/moveit_gateway.md:32-58 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_moveit/docs/moveit_gateway.md#L32-L58>`__

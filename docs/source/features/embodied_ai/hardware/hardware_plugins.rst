硬件插件
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
-  `src/robot_config/README.en.md <src/robot_config/README.en.md>`__
-  `src/robot_config/README.md <src/robot_config/README.md>`__
-  `src/robot_config/config/robots/so101_dual_arm.yaml <src/robot_config/config/robots/so101_dual_arm.yaml>`__
-  `src/robot_config/config/robots/so101_single_arm.yaml <src/robot_config/config/robots/so101_single_arm.yaml>`__
-  `src/robot_config/robot_config/loader.py <src/robot_config/robot_config/loader.py>`__
-  `src/tensormsg/tensormsg/converter.py <src/tensormsg/tensormsg/converter.py>`__

.. raw:: html

   </details>

目的与范围
----------

本文档介绍 IB-Robot 用于与物理机器人和仿真环境交互的硬件插件实现。硬件插件实现了 ``ros2_control`` 硬件接口，提供了一个统一的抽象层，使相同的控制代码可以在真实硬件和仿真环境中运行。

本文档重点介绍两个主要的硬件插件实现：- ``SO101SystemHardware``：使用 Feetech 舵机 SDK 的 SO-101 机器人真实硬件插件 - ``gz_ros2_control``：基于物理仿真的 Gazebo 仿真插件

有关这些插件在机器人配置系统中的配置方式，请参阅 `ros2_control 配置 <#11.1>`__。有关更广泛的硬件集成策略，请参阅 `硬件集成 <#11>`__。

**来源**：`README.md:1-192 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L1-L192>`__，`docs/architecture.md:1-313 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/docs/architecture.md#L1-L313>`__

--------------

硬件插件架构
------------

IB-Robot 中的硬件插件实现了 ``ros2_control`` 的 ``SystemInterface``，该接口定义了三个生命周期方法：

::

   on_init()    → 加载配置并初始化资源
   on_activate() → 连接硬件并启用控制
   on_deactivate() → 安全断开硬件连接

在每个控制周期中，``ros2_control`` 调用：- ``read()``：从硬件更新关节状态 - ``write()``：向硬件发送命令

这种抽象使相同的控制器和动作调度器能够与物理机器人和仿真环境无缝协作。

硬件插件集成流程
~~~~~~~~~~~~~~~~

.. mermaid::

   graph TB
       subgraph "Application Layer"
           DISP["action_dispatcher_node"]
           CTRL["Controllers<br/>(position/trajectory)"]
       end
       
       subgraph "ros2_control Framework"
           CM["ControllerManager"]
           HWI["HardwareInterface<br/>(SystemInterface)"]
       end
       
       subgraph "Hardware Plugin Layer"
           REAL["SO101SystemHardware"]
           SIM["GazeboSystem"]
       end
       
       subgraph "Physical/Simulated Layer"
           MOTORS["Feetech Servos<br/>(Serial Port)"]
           GAZEBO["Gazebo Physics<br/>Engine"]
       end
       
       DISP -->|"Float64MultiArray<br/>JointTrajectory"| CTRL
       CTRL -->|"Joint Commands"| CM
       CM -->|"write()"| HWI
       CM -->|"read()"| HWI
       
       HWI -.->|"use_sim=false"| REAL
       HWI -.->|"use_sim=true"| SIM
       
       REAL -->|"SDK Commands"| MOTORS
       MOTORS -->|"State Feedback"| REAL
       
       SIM -->|"Apply Forces"| GAZEBO
       GAZEBO -->|"Physics State"| SIM

**来源**：`README.md:18-41 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L18-L41>`__，
`src/robot_config/config/robots/so101_single_arm.yaml:104-121 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L104-L121>`__

--------------

SO101SystemHardware 插件
------------------------

``SO101SystemHardware`` 插件提供了 ``ros2_control`` 与 SO-101 机器人中使用的 Feetech 舵机之间的接口。它实现为一个 C++ 插件，根据机器人配置中的 ``hardware_plugin`` 参数动态加载。

插件配置
~~~~~~~~

硬件插件在机器人配置 YAML 中指定：

.. code:: yaml

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

**来源**：
`src/robot_config/config/robots/so101_single_arm.yaml:105-117 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L105-L117>`__

主要职责
~~~~~~~~


.. list-table::
   :header-rows: 1

   * - 职责
     - 实现细节
   * - **串口通信**
     - 打开并管理与 Feetech 舵机总线的 串口连接
   * - **关节校准**
     - 从 JSON 文件加载校准偏移量， 将 ROS 关节角度映射到舵机位置
   * - **状态读取**
     - 以控制频率（通常 50-100Hz） 轮询舵机位置
   * - **命令写入**
     - 向舵机发送位置命令， 包含安全检查
   * - **错误处理**
     - 检测通信错误和舵机故障

校准文件格式
~~~~~~~~~~~~

校准文件将 ROS 关节坐标映射到物理舵机位置：

.. code:: json

   {
     "1": {
       "offset": 2048,
       "direction": 1,
       "zero_position": 0.0813
     },
     "2": {
       "offset": 2048,
       "direction": -1,
       "zero_position": 3.7905
     }
   }

这使得不同机器人实例能够保持一致的关节角度，尽管存在制造差异。

**来源**：
`src/robot_config/config/robots/so101_single_arm.yaml:105-117 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L105-L117>`__，
`README.md:78-90 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L78-L90>`__

硬件接口结构
~~~~~~~~~~~~

.. mermaid::

   graph LR
       subgraph "SO101SystemHardware Plugin"
           INIT["on_init()<br/>Parse YAML params<br/>Load calibration"]
           ACTIVATE["on_activate()<br/>Open serial port<br/>Initialize servos"]
           READ["read()<br/>Poll servo states<br/>Apply calibration"]
           WRITE["write()<br/>Convert commands<br/>Send to servos"]
       end
       
       subgraph "Feetech SDK"
           SDK["feetech_servo_sdk<br/>Protocol Implementation"]
           SERIAL["Serial Port<br/>/dev/ttyACM0"]
       end
       
       INIT --> ACTIVATE
       ACTIVATE --> READ
       READ --> WRITE
       
       ACTIVATE -->|"SCS_Init()"| SDK
       READ -->|"SCS_ReadPos()"| SDK
       WRITE -->|"SCS_WritePos()"| SDK
       
       SDK <-->|"UART Communication"| SERIAL

**来源**：`scripts/build.sh:142-154 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/scripts/build.sh#L142-L154>`__，
`src/robot_config/config/robots/so101_single_arm.yaml:105-117 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L105-L117>`__

--------------

Gazebo 仿真插件
----------------

Gazebo 仿真插件（``gz_ros2_control``）提供了一个基于物理的仿真环境，模拟真实硬件的行为。这使得无需访问物理机器人即可进行算法开发和测试。

插件选择
~~~~~~~~

当启动文件传递 ``use_sim:=true`` 时，系统会自动选择仿真插件：

.. code:: bash

   # 真实硬件
   ros2 launch robot_config robot.launch.py use_sim:=false

   # 仿真
   ros2 launch robot_config robot.launch.py use_sim:=true

Gazebo 集成架构
~~~~~~~~~~~~~~~

.. mermaid::

   graph TB
       subgraph "ROS2 Layer"
           LAUNCH["robot.launch.py<br/>use_sim parameter"]
           CM["ros2_control<br/>ControllerManager"]
       end
       
       subgraph "Gazebo Layer"
           GZSIM["Gazebo Simulation<br/>Physics Engine"]
           GZPLUGIN["gz_ros2_control<br/>Plugin"]
           MODEL["Robot Model<br/>(URDF + SDF)"]
       end
       
       subgraph "Hardware Interface"
           HWI["HardwareInterface"]
       end
       
       LAUNCH -.->|"use_sim=true"| GZSIM
       LAUNCH -->|"Load controllers"| CM
       
       GZSIM -->|"Loads"| MODEL
       GZSIM -->|"Instantiates"| GZPLUGIN
       
       GZPLUGIN <-->|"read()/write()"| HWI
       HWI <-->|"Commands/States"| CM
       
       GZPLUGIN -->|"Apply Joint Forces"| MODEL
       MODEL -->|"Physics Feedback"| GZPLUGIN

**来源**：`README.md:126-149 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L126-L149>`__，
`src/robot_config/README.md:342-355 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/README.md#L342-L355>`__

仿真功能
~~~~~~~~


.. list-table::
   :header-rows: 1

   * - 功能
     - 描述
   * - **物理仿真**
     - 精确的动力学仿真，包括重力、 惯性和摩擦
   * - **关节限位**
     - 强制执行 URDF 中定义的位置、 速度和力矩限制
   * - **传感器仿真**
     - 仿真的相机、IMU 和关节状态传感器
   * - **实时因子**
     - 可调节的仿真速度， 用于超实时测试
   * - **可视化**
     - Gazebo GUI 中的 3D 可视化， 包含碰撞网格

仿真 URDF 配置
~~~~~~~~~~~~~~

机器人描述包含配置仿真插件的 Gazebo 特定标签：

.. code:: xml

   <gazebo>
     <plugin filename="gz_ros2_control-system" name="gz_ros2_control::GazeboSimSystem">
       <parameters>$(find so101_hardware)/config/so101_controllers.yaml</parameters>
     </plugin>
   </gazebo>

**来源**：
`src/robot_config/config/robots/so101_single_arm.yaml:117 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L117>`__，
`README.md:126-149 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L126-L149>`__

--------------

硬件切换机制
------------

系统使用条件启动逻辑和统一的控制器配置，实现了真实硬件和仿真之间的清晰切换机制。

启动时选择
~~~~~~~~~~

.. mermaid::

   graph TD
       START["robot.launch.py"]
       CHECK{{"use_sim<br/>parameter?"}}
       
       REAL_PATH["Load SO101SystemHardware"]
       SIM_PATH["Launch Gazebo + GazeboSystem"]
       
       SHARED["Load Unified Controllers<br/>so101_controllers.yaml"]
       
       CTRL_MGR["ros2_control<br/>ControllerManager"]
       
       START --> CHECK
       CHECK -->|"false"| REAL_PATH
       CHECK -->|"true"| SIM_PATH
       
       REAL_PATH --> SHARED
       SIM_PATH --> SHARED
       
       SHARED --> CTRL_MGR

**来源**：`README.md:121-154 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L121-L154>`__，
`src/robot_config/README.md:342-355 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/README.md#L342-L355>`__

统一控制器配置
~~~~~~~~~~~~~~

硬件和仿真使用相同的控制器配置文件（``so101_controllers.yaml``），确保行为一致：

.. code:: yaml

   controller_manager:
     ros__parameters:
       update_rate: 100  # 真实硬件和仿真使用相同频率
       
       arm_position_controller:
         type: joint_trajectory_controller/JointTrajectoryController
         joints: ["1", "2", "3", "4", "5"]
         
       gripper_position_controller:
         type: position_controllers/JointGroupPositionController
         joints: ["6"]

这意味着无论机器人是真实的还是仿真的，动作调度器和推理服务的工作方式完全相同。

**来源**：
`src/robot_config/config/robots/so101_single_arm.yaml:119-129 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L119-L129>`__，
`src/robot_config/README.md:48-86 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/README.md#L48-L86>`__

硬件抽象优势
~~~~~~~~~~~~


.. list-table::
   :header-rows: 1

   * - 优势
     - 实际影响
   * - **算法可移植性**
     - 在仿真中训练策略，无需修改代码 即可部署到真实硬件
   * - **安全开发**
     - 首先在仿真中测试潜在危险的行为
   * - **并行开发**
     - 多个开发者可以在硬件使用时 在仿真环境中工作
   * - **持续集成**
     - 自动化测试在仿真中运行， 无需硬件访问
   * - **快速迭代**
     - 超实时仿真用于数据收集

**来源**：`docs/architecture.md:180-184 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/docs/architecture.md#L180-L184>`__，`README.md:6-42 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L6-L42>`__

--------------

硬件插件配置参考
----------------

配置位置
~~~~~~~~

硬件插件参数定义在机器人配置 YAML 的 ``ros2_control`` 部分。系统使用这一单一数据源来配置真实硬件和仿真。

**文件**：
`src/robot_config/config/robots/so101_single_arm.yaml:104-129 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L104-L129>`__

常用参数
~~~~~~~~


.. list-table::
   :header-rows: 1

   * - 参数
     - 类型
     - 描述
     - 示例
   * - `` hardware_plugin``
     - string
     - 完全限定的 插件名称
     - ``so101_hard ware/SO101Sys temHardware``
   * - ``port``
     - string
     - 串口设备路径
     - ``/ dev/ttyACM0``
   * - ``calib_file``
     - path
     - 校准 JSON 文件
     - ``~/.ca librate/so101 _follower_cal ibrate.json``
   * - ``joint_names``
     - list
     - 关节标识符有序列表
     - ``["1", "2", "3", "4" , "5", "6"]``
   * - `` reset_positions``
     - dict
     - 初始关节位置（弧度）
     - ``{"1": 0.0 , "2": 0.0}``
   * - ``urdf_path``
     - path
     - 机器人描述文件
     - ``$(find rob ot_descriptio n)/urdf/...``
   * - ``con trollers_config``
     - path
     - 控制器配置 YAML
     - ``$( find so101_ha rdware)/confi g/so101_contr ollers.yaml``

**来源**：
`src/robot_config/config/robots/so101_single_arm.yaml:104-129 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L104-L129>`__

路径解析
~~~~~~~~

配置系统支持 ROS 风格的路径宏：

-  ``$(find package_name)``：解析为包共享目录
-  ``$(env VAR_NAME)``：解析为环境变量值

这些宏在配置加载时自动展开。

**来源**：`src/robot_config/robot_config/loader.py:1-242 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/loader.py#L1-L242>`__

--------------

硬件插件故障排除
----------------

串口权限问题
~~~~~~~~~~~~

**问题**：``SO101SystemHardware`` 无法打开 ``/dev/ttyACM0``，提示"权限被拒绝"

**解决方案**：

.. code:: bash

   # 将用户添加到 dialout 组
   sudo usermod -a -G dialout $USER

   # 或直接设置权限（临时）
   sudo chmod 666 /dev/ttyACM0

校准文件未找到
~~~~~~~~~~~~~~

**问题**：硬件插件初始化失败，提示"校准文件未找到"

**解决方案**：

.. code:: bash

   # 验证文件是否存在
   ls -l ~/.calibrate/so101_follower_calibrate.json

   # 检查路径解析
   echo $(env HOME)/.calibrate/so101_follower_calibrate.json

仿真插件未加载
~~~~~~~~~~~~~~

**问题**：Gazebo 启动但 ``ros2_control`` 无法找到硬件接口

**解决方案**：

.. code:: bash

   # 验证 gz_ros2_control 已安装
   ros2 pkg list | grep gz_ros2_control

   # 检查 Gazebo 插件路径
   echo $GZ_SIM_SYSTEM_PLUGIN_PATH

**来源**：`README.md:173-187 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L173-L187>`__，
`src/robot_config/README.md:471-516 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/README.md#L471-L516>`__

--------------

总结
----

硬件插件提供了关键的抽象层，使 IB-Robot 能够在仿真和真实硬件之间无缝运行。``SO101SystemHardware`` 插件通过串口通信直接与 Feetech 舵机交互，而 ``gz_ros2_control`` 插件提供基于物理的仿真。两个插件都暴露相同的 ``ros2_control`` 接口，确保控制器、动作调度器和推理服务无论底层硬件如何都能以相同方式工作。

此架构遵循"单一数据源"原则：硬件配置存储在 ``robot_config`` YAML 文件中，系统根据 ``use_sim`` 参数自动选择适当的插件。这种设计消除了代码重复，减少了具身 AI 策略的训练-部署差距。

**来源**：`README.md:1-192 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L1-L192>`__，`docs/architecture.md:1-313 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/docs/architecture.md#L1-L313>`__，
`src/robot_config/config/robots/so101_single_arm.yaml:1-329 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L1-L329>`__

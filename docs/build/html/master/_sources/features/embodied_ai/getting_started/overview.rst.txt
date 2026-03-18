入门指南概述
============

.. raw:: html

   <details>

相关源文件

以下文件用于生成此文档页面的上下文：

-  `.colcon/defaults.yaml <.colcon/defaults.yaml>`__
-  `.colcon/mixin/build.mixin.yaml <.colcon/mixin/build.mixin.yaml>`__
-  `.colcon/mixin/index.yaml <.colcon/mixin/index.yaml>`__
-  `.gitignore <.gitignore>`__
-  `.gitmodules <.gitmodules>`__
-  `.vscode/c_cpp_properties.json <.vscode/c_cpp_properties.json>`__
-  `.vscode/extensions.json <.vscode/extensions.json>`__
-  `.vscode/launch.json <.vscode/launch.json>`__
-  `.vscode/settings.json <.vscode/settings.json>`__
-  `.vscode/tasks.json <.vscode/tasks.json>`__
-  `README.en.md <README.en.md>`__
-  `README.md <README.md>`__
-  `docs/architecture.md <docs/architecture.md>`__
-  `/image/architecture.png </image/architecture.png>`__
-  `docs/roadmap.md <docs/roadmap.md>`__
-  `scripts/build.sh <scripts/build.sh>`__
-  `scripts/setup.sh <scripts/setup.sh>`__
-  `scripts/validate_config.py <scripts/validate_config.py>`__
-  `src/README.md <src/README.md>`__
-  `src/action_dispatch/README.en.md <src/action_dispatch/README.en.md>`__
-  `src/action_dispatch/README.md <src/action_dispatch/README.md>`__

.. raw:: html

   </details>

本页面提供了设置 IB-Robot 开发环境和运行第一个机器人系统的实用指南。它涵盖了开始开发或实验所需的初始工作空间设置、构建过程和基本系统验证步骤。

**范围**：本页面涵盖了从全新仓库克隆到运行机器人系统（仿真或硬件）的基本工作流程。有关详细的环境配置，请参阅 `环境设置 <environment_setup.html>`__。有关构建系统详细信息和混入配置，请参阅 `构建项目 <building_the_project.html>`__。有关架构概念，请参阅 `系统架构 <../architecture/system_architecture.html>`__。

--------------

前提条件
--------

系统要求
~~~~~~~~

IB-Robot 在以下平台配置上开发和测试：


.. list-table::
   :header-rows: 1

   * - 组件
     - 要求
   * - **操作系统**
     - openEuler Embedded 24.03（或兼容的 Linux 发行版）
   * - **ROS 版本**
     - ROS 2 Humble Hawksbill
   * - **Python**
     - 系统 Python 3.11（原生安装）
   * - **Conda**
     - 设置前**必须停用**，以避免库冲突

**重要提示**：设置过程使用 Python 虚拟环境（``venv``）将机器学习依赖（PyTorch、LeRobot）与系统包隔离。在活动的 Conda 环境中运行设置或构建脚本将导致动态库冲突，特别是 ``libstdc++`` 和 NumPy 版本冲突。

来源：`README.md:76-83 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L76-L83>`__，`setup.sh:25-33 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/setup.sh#L25-L33>`__

--------------

快速入门工作流程
----------------

下图展示了从仓库克隆到运行系统的完整工作流程：

图表：初始设置和启动流程
~~~~~~~~~~~~~~~~~~~~~~~~

.. mermaid::

   graph TB
       Clone["git clone IB_Robot"] --> CheckConda{"Conda active?"}
       CheckConda -->|Yes| DeactivateConda["conda deactivate"]
       CheckConda -->|No| RunSetup
       DeactivateConda --> RunSetup["./scripts/setup.sh"]
       
       RunSetup --> SubmoduleInit["git submodule update<br/>--init --recursive"]
       SubmoduleInit --> CreateVenv["python3 -m venv<br/>--system-site-packages venv"]
       CreateVenv --> InstallDeps["Install: torch, lerobot,<br/>numpy<2, scipy, pyserial"]
       InstallDeps --> GenerateShrc["Generate .shrc_local<br/>environment script"]
       
       GenerateShrc --> SourceEnv["source .shrc_local"]
       SourceEnv --> RunBuild["./scripts/build.sh"]
       
       RunBuild --> ColconBuild["colcon build<br/>--mixin dev"]
       ColconBuild --> InstallLerobot["pip install -e<br/>libs/lerobot"]
       
       InstallLerobot --> LaunchSim["ros2 launch robot_config<br/>robot.launch.py<br/>use_sim:=true"]
       LaunchSim --> SystemRunning["Robot System Running<br/>(Gazebo + Controllers)"]
       
       style RunSetup fill:#e3f2fd
       style RunBuild fill:#fff9c4
       style LaunchSim fill:#c8e6c9

来源：`README.md:75-117 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L75-L117>`__，`setup.sh:283-302 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/setup.sh#L283-L302>`__，
`build.sh:189-226 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/build.sh#L189-L226>`__

--------------

分步设置
--------

1. 克隆仓库
~~~~~~~~~~~

.. code:: bash

   git clone https://github.com/wuxiaoqiang12/IB_Robot
   cd IB_Robot

仓库使用 git 子模块管理核心依赖。主要子模块有：- ``libs/lerobot`` - LeRobot 训练框架（Python）- ``src/pymoveit2`` - MoveIt 2 运动规划的 Python 绑定

来源：`.gitmodules:1-10 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.gitmodules#L1-L10>`__

2. 运行初始设置
~~~~~~~~~~~~~~~

执行设置脚本以初始化开发环境：

.. code:: bash

   ./scripts/setup.sh

``setup.sh`` 脚本自动执行以下操作：

子模块管理
^^^^^^^^^^

脚本检测未初始化的子模块并提供选择性初始化选项：

::

   1) All submodules
   2) LeRobot only (libs/lerobot)
   3) PyMoveIt2 only (src/pymoveit2)
   4) Select individually
   0) Skip

对于大多数用户，推荐选项 ``1``（所有子模块）。脚本使用 ``GIT_LFS_SKIP_SMUDGE=1`` 在初始克隆时跳过大文件下载。

来源：`setup.sh:38-135 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/setup.sh#L38-L135>`__

虚拟环境创建
^^^^^^^^^^^^

脚本在 ``venv/`` 创建 Python 虚拟环境，并启用 ``--system-site-packages``。此标志至关重要，因为它允许虚拟环境访问系统 ROS 2 包（特别是 ``rclpy``），同时隔离 ML 依赖：

.. code:: bash

   python3 -m venv --system-site-packages venv

来源：`setup.sh:216-234 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/setup.sh#L216-L234>`__

依赖安装
^^^^^^^^

以下依赖将自动安装：


.. list-table::
   :header-rows: 1

   * - 包
     - 用途
     - 版本约束
   * - ``numpy``
     - 数值计算
     - ``< 2.0`` (ROS 2 Humble 兼容性)
   * - ``setuptools``
     - 构建工具
     - ``>= 71, < 80`` （避免 colcon 冲突）
   * - ``lerobot``
     - ML 训练框架
     - 从 ``libs/lerobot`` 可编辑安装
   * - ``pyserial``
     - 硬件串口通信
     - 最新版
   * - ``feetech-servo-sdk``
     - Feetech 电机驱动
     - 最新版
   * - ``scipy``
     - 科学计算
     - 最新版 （四元数/旋转工具）

**关键修复**：NumPy 2.x 与 ROS 2 Humble 的二进制包不兼容。脚本显式强制 ``numpy<2`` 以防止运行时错误。

来源：`setup.sh:240-262 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/setup.sh#L240-L262>`__

开发者 Fork 设置（可选）
^^^^^^^^^^^^^^^^^^^^^^^^

对于贡献者，脚本提供配置个人 fork 的选项：

::

   Enter your GitCode username (leave empty to skip):

如果提供，脚本将配置：- ``origin`` → 个人 fork - ``upstream`` → 主仓库

来源：`setup.sh:137-177 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/setup.sh#L137-L177>`__

3. 加载环境
~~~~~~~~~~~

每个终端会话都需要加载生成的环境脚本：

.. code:: bash

   source .shrc_local

此脚本：- 激活 Python 虚拟环境（``venv/bin/activate``）- 加载 ROS 2 Humble 设置（``/opt/ros/humble/setup.sh``）- 加载工作空间安装设置（``install/setup.sh``，如果存在）- 设置包含 lerobot 和工作空间包的 ``PYTHONPATH``

来源：`README.md:100-104 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L100-L104>`__

4. 设置 ROS Domain ID
~~~~~~~~~~~~~~~~~~~~~

为避免与网络上其他 ROS 2 系统冲突，设置唯一的域 ID：

.. code:: bash

   export ROS_DOMAIN_ID=42  # 使用 0-232 之间的任意值

这在共享实验室环境中尤为重要。

来源：`README.md:106-110 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L106-L110>`__

5. 构建工作空间
~~~~~~~~~~~~~~~

编译所有 ROS 2 包：

.. code:: bash

   ./scripts/build.sh

构建脚本使用 colcon mixins 进行配置。默认行为是：- **Mixin**：``dev``（调试构建、符号链接安装、无测试）- **Workers**：所有 CPU 核心（``nproc``）- **安装布局**：合并安装（单一 ``install/`` 目录）

脚本还处理 ``lerobot`` Python 包的可编辑安装，并强制 NumPy 版本兼容性。

来源：`build.sh:119-120 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/build.sh#L119-L120>`__，`build.sh:162-178 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/build.sh#L162-L178>`__

--------------

首次启动
--------

启动仿真
~~~~~~~~

要验证安装，在 Gazebo 仿真中启动机器人：

.. code:: bash

   ros2 launch robot_config robot.launch.py \
       robot_config:=so101_single_arm \
       use_sim:=true

此命令：1. 从 `robot_config/config/robots/so101_single_arm.yaml <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/robot_config/config/robots/so101_single_arm.yaml>`__ 加载机器人配置 2. 在 Gazebo Classic 仿真中生成机器人 3. 使用 ``gz_ros2_control`` 插件启动 ``ros2_control`` 硬件接口 4. 启动关节状态发布器和配置的控制器 5. 可选启动推理服务（取决于 ``default_control_mode``）

图表：robot.launch.py 执行流程
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. mermaid::

   graph TB
       LaunchFile["robot.launch.py"] --> LoadConfig["Load YAML from<br/>config/robots/<br/>robot_config.yaml"]
       LoadConfig --> ParseParams["Parse parameters:<br/>- use_sim<br/>- control_mode<br/>- with_inference"]
       
       ParseParams --> BuilderSelect{"Which launch<br/>builders to use?"}
       
       BuilderSelect --> ControlBuilder["build_control_launch()<br/>- ros2_control<br/>- controller_manager<br/>- joint_state_broadcaster"]
       BuilderSelect --> SimBuilder["build_simulation_launch()<br/>- gazebo<br/>- spawn_entity"]
       BuilderSelect --> PeripheralBuilder["build_peripheral_launch()<br/>- camera drivers<br/>- static_transform_publisher"]
       
       ControlBuilder --> HardwareInterface{"use_sim?"}
       HardwareInterface -->|true| GazeboPlugin["gz_ros2_control plugin"]
       HardwareInterface -->|false| RealHW["so101_hardware plugin"]
       
       SimBuilder --> GazeboServer["gzserver<br/>(physics simulation)"]
       SimBuilder --> GazeboClient["gzclient<br/>(visualization)"]
       
       PeripheralBuilder --> CameraNodes["usb_cam_node /<br/>realsense2_camera_node"]
       PeripheralBuilder --> TFPublishers["static_transform_publisher<br/>(camera extrinsics)"]
       
       BuilderSelect --> InferenceCheck{"with_inference<br/>enabled?"}
       InferenceCheck -->|true| InferenceBuilder["build_inference_launch()<br/>- lerobot_policy_node<br/>- action_dispatcher_node"]
       InferenceCheck -->|false| SkipInference["Skip inference service"]
       
       InferenceBuilder --> PolicyNode["lerobot_policy_node<br/>(model inference)"]
       InferenceBuilder --> DispatchNode["action_dispatcher_node<br/>(action execution)"]
       
       style LoadConfig fill:#e3f2fd
       style ControlBuilder fill:#fff9c4
       style SimBuilder fill:#c8e6c9

来源：`README.md:122-154 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L122-L154>`__

--------------

启动参数
--------

``robot.launch.py`` 脚本接受以下参数：


.. list-table::
   :header-rows: 1

   * - 参数
     - 类型
     - 默认值
     - 描述
   * - ``robot_config``
     - string
     - ``so101 _single_arm``
     - 机器人配置名称 （匹配 YAML 文件名）
   * - ``config_path``
     - string
     - ``''``
     - 配置文件的绝对路径 （覆盖 ``robot_config``）
   * - ``use_sim``
     - bool
     - ``false``
     - 使用 Gazebo 仿真 而非真实硬件
   * - ``control_mode``
     - string
     - 从 YAML 读取
     - 覆盖控制模式 （``teleop``、 ``model_inference``、 ``moveit_planning``）
   * - ``with_inference``
     - bool
     - 自动检测
     - 强制启用/禁用 推理服务
   * - ``with_moveit``
     - bool
     - 自动检测
     - 强制启用/禁用 MoveIt 2 核心
   * - ``moveit_display``
     - bool
     - ``true``
     - 启动 RViz 进行 MoveIt 可视化
   * - ``auto_start_controllers``
     - bool
     - ``true``
     - 生成后自动激活控制器

``with_inference`` 和 ``with_moveit`` 的自动检测逻辑检查 ``control_mode`` 参数：- ``control_mode: model_inference`` → ``with_inference=true`` - ``control_mode: moveit_planning`` → ``with_moveit=true``

来源：`README.md:157-169 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L157-L169>`__

--------------

验证步骤
--------

检查运行中的节点
~~~~~~~~~~~~~~~~

列出活动的 ROS 2 节点：

.. code:: bash

   ros2 node list

预期输出（仿真模式）：

::

   /controller_manager
   /gazebo
   /joint_state_broadcaster
   /robot_state_publisher
   /arm_position_controller  # (or arm_trajectory_controller)

检查可用话题
~~~~~~~~~~~~

.. code:: bash

   ros2 topic list

需要验证的关键话题：

::

   /joint_states                        # 关节状态反馈
   /arm_position_controller/commands    # 位置控制输入
   /robot_description                   # URDF 模型
   /tf                                  # 变换树
   /tf_static                           # 静态变换

在 RViz 中可视化
~~~~~~~~~~~~~~~~

如果尚未运行，启动 RViz：

.. code:: bash

   ros2 run rviz2 rviz2

添加显示：1. **RobotModel**\ （使用 ``/robot_description`` 话题）2. **TF**\ （显示坐标系）3. **JointState** 插件（用于手动控制）

来源：`README.md:172-191 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L172-L191>`__

--------------

目录结构概览
------------

成功设置和构建后，您的工作空间结构如下：

::

   IB_Robot/
   ├── .shrc_local              # 生成的环境脚本
   ├── venv/                    # Python 虚拟环境
   │   ├── bin/
   │   │   ├── python3          # Python 解释器
   │   │   └── activate         # venv 激活脚本
   │   └── lib/
   │       └── python3.11/
   │           └── site-packages/  # ML 依赖
   ├── libs/
   │   └── lerobot/             # [子模块] LeRobot 框架
   ├── src/                     # [子模块] 核心 ROS 2 包
   │   ├── robot_config/        # 配置和启动入口点
   │   ├── action_dispatch/     # 动作执行层
   │   ├── tensormsg/           # ROS ↔ Tensor 转换
   │   ├── inference_service/   # 模型推理服务
   │   └── ...
   ├── build/                   # Colcon 构建产物（生成）
   ├── install/                 # 已安装的 ROS 2 包（生成）
   └── log/                     # 构建和运行时日志（生成）

来源：`README.md:44-72 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L44-L72>`__，`src/README.md:1-24 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/README.md#L1-L24>`__

--------------

常见问题与解决方案
------------------

1. 控制器冲突
~~~~~~~~~~~~~

**症状**：控制器无法加载或响应

**解决方案**：清理残留的 ROS 2 进程：

.. code:: bash

   ./scripts/cleanup_ros.sh

来源：`README.md:172-178 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L172-L178>`__

2. 共享内存错误
~~~~~~~~~~~~~~~

**症状**：日志中出现 ``RTPS_TRANSPORT_SHM Error``

**解决方案**：清除 FastDDS 共享内存缓存：

.. code:: bash

   sudo rm -rf /dev/shm/fastrtps_*
   export ROS_LOCALHOST_ONLY=1

来源：`README.md:180-186 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L180-L186>`__

3. NumPy 版本冲突
~~~~~~~~~~~~~~~~~

**症状**：导入 ROS 2 包时出现 ``ImportError`` 或段错误

**解决方案**：验证虚拟环境中的 NumPy 版本：

.. code:: bash

   source venv/bin/activate
   python3 -c "import numpy; print(numpy.__version__)"

版本必须为 ``< 2.0``。如果不正确，重新安装：

.. code:: bash

   pip install "numpy<2" --force-reinstall

来源：`build.sh:176-177 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/build.sh#L176-L177>`__，`setup.sh:244-245 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/setup.sh#L244-L245>`__

4. Gazebo 插件加载失败
~~~~~~~~~~~~~~~~~~~~~~

**症状**：Gazebo 启动但机器人模型未生成

**解决方案**：确保 ``GAZEBO_MODEL_PATH`` 包含机器人描述：

.. code:: bash

   export GAZEBO_MODEL_PATH=$GAZEBO_MODEL_PATH:$(ros2 pkg prefix robot_description)/share

这通常通过加载 ``install/setup.sh`` 处理，但如果使用自定义 shell 配置可能需要手动干预。

--------------

下一步
------

成功完成设置和验证后：

1. **探索控制模式**：参阅 `控制模式架构 <../core_concepts/control_mode_architecture.html>`__ 了解如何在遥操作、模型推理和 MoveIt 规划模式之间切换
2. **配置您的机器人**：在 `配置系统 <../configuration/index.html>`__ 中了解机器人配置系统
3. **数据采集**：开始采集训练用的演示数据 - 参阅 `Episode 录制 <../data_pipeline/episode_recording.html>`__
4. **部署**：使用推理管道部署训练好的策略 - 参阅 `推理管道 <../inference/index.html>`__

有关设置过程的详细信息，包括 Python 虚拟环境故障排除和子模块管理，请参阅 `环境设置 <environment_setup.html>`__。

有关构建系统配置、mixin 使用和 VS Code 集成，请参阅 `构建项目 <building_the_project.html>`__。

来源：`README.md:1-192 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L1-L192>`__，`docs/architecture.md:287-312 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/docs/architecture.md#L287-L312>`__

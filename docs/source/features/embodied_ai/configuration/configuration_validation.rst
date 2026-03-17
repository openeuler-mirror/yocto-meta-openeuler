配置验证
========

.. raw:: html

   <details>

相关源文件

以下文件用于生成此文档页面：

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

.. raw:: html

   </details>

本文档介绍 ``validate_config.py`` 脚本，该脚本用于强制执行 IB-Robot 系统中机器人配置文件的一致性。验证器确保关节定义在 robot_config YAML（单一事实来源）、ros2_control 控制器配置和 MoveIt 规划配置之间保持同步，防止可能导致运行时故障的配置漂移。

有关 robot_config YAML 结构本身的信息，请参阅 `机器人配置文件 <#5.1>`__。有关契约系统的详细信息，请参阅 `契约定义 <#5.2>`__。

--------------

概述
----

IB-Robot 配置系统遵循 DRY（Don't Repeat Yourself）原则，以 robot_config YAML 为权威来源。但是，某些配置必须在派生文件中复制以兼容 ROS2：

-  **ros2_control 控制器**需要在控制器 YAML 文件中显式关节列表
-  **MoveIt 控制器**需要在 MoveIt 配置文件中显式关节列表

验证脚本检测这些派生配置何时偏离事实来源，在部署前捕获错误。它设计用于集成到 CI/CD 管道中，提供自动化的配置一致性检查。

**源码：** `scripts/validate_config.py:1-17 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/scripts/validate_config.py#L1-L17>`__

--------------

验证架构
--------

验证器跨三个配置域执行跨文件一致性检查：

.. mermaid::

   graph TB
       subgraph "事实来源"
           ROBOT_CFG["robot_config YAML<br/>so101_single_arm.yaml"]
           
           JOINTS_DEF["joints:<br/>  arm: [...]<br/>  gripper: [...]<br/>  all: [...]"]
           
           ROBOT_CFG --> JOINTS_DEF
       end
       
       subgraph "派生配置"
           CTRL_CFG["controllers.yaml<br/>ros2_control 配置"]
           MOVEIT_CFG["moveit_controllers.yaml<br/>MoveIt 配置"]
           
           CTRL_ARM["arm_position_controller:<br/>  joints: [...]"]
           CTRL_ARM_TRAJ["arm_trajectory_controller:<br/>  joints: [...]"]
           CTRL_GRIP["gripper_position_controller:<br/>  joints: [...]"]
           CTRL_GRIP_TRAJ["gripper_trajectory_controller:<br/>  joints: [...]"]
           CTRL_JS["joint_state_broadcaster:<br/>  joints: [...]"]
           
           MOVEIT_ARM["arm_trajectory_controller:<br/>  joints: [...]"]
           MOVEIT_GRIP["gripper_trajectory_controller:<br/>  joints: [...]"]
           
           CTRL_CFG --> CTRL_ARM
           CTRL_CFG --> CTRL_ARM_TRAJ
           CTRL_CFG --> CTRL_GRIP
           CTRL_CFG --> CTRL_GRIP_TRAJ
           CTRL_CFG --> CTRL_JS
           
           MOVEIT_CFG --> MOVEIT_ARM
           MOVEIT_CFG --> MOVEIT_GRIP
       end
       
       subgraph "ConfigValidator"
           VALIDATOR["ConfigValidator 类"]
           
           VAL_JOINTS["validate_joints_config()"]
           VAL_CTRL["validate_controller_config()"]
           VAL_MOVEIT["validate_moveit_config()"]
           
           VALIDATOR --> VAL_JOINTS
           VALIDATOR --> VAL_CTRL
           VALIDATOR --> VAL_MOVEIT
       end
       
       JOINTS_DEF -.->|"提取引用"| VAL_JOINTS
       
       VAL_JOINTS -->|"arm_joints"| VAL_CTRL
       VAL_JOINTS -->|"gripper_joints"| VAL_CTRL
       VAL_JOINTS -->|"all_joints"| VAL_CTRL
       
       VAL_JOINTS -->|"arm_joints"| VAL_MOVEIT
       VAL_JOINTS -->|"gripper_joints"| VAL_MOVEIT
       
       CTRL_ARM -.->|"比较"| VAL_CTRL
       CTRL_ARM_TRAJ -.->|"比较"| VAL_CTRL
       CTRL_GRIP -.->|"比较"| VAL_CTRL
       CTRL_GRIP_TRAJ -.->|"比较"| VAL_CTRL
       CTRL_JS -.->|"比较"| VAL_CTRL
       
       MOVEIT_ARM -.->|"比较"| VAL_MOVEIT
       MOVEIT_GRIP -.->|"比较"| VAL_MOVEIT
       
       style ROBOT_CFG fill:#fff,stroke:#333,stroke-width:3px
       style VALIDATOR fill:#fff,stroke:#333,stroke-width:2px

**源码：** `scripts/validate_config.py:26-131 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/scripts/validate_config.py#L26-L131>`__,
`scripts/validate_config.py:133-217 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/scripts/validate_config.py#L133-L217>`__

--------------

验证流程
--------

验证器执行带路径解析和错误累积的多阶段验证管道：

.. mermaid::

   graph TB
       START["main()"]
       
       PARSE["解析 CLI 参数<br/>--robot-config<br/>--controllers-config<br/>--moveit-config<br/>--verbose"]
       
       INIT["ConfigValidator()"]
       
       AUTO_DETECT["自动检测<br/>moveit_config 路径"]
       
       VALIDATE["run_validation()"]
       
       subgraph "阶段 1: 加载机器人配置"
           LOAD_ROBOT["load_yaml()<br/>robot_config_path"]
           
           EXTRACT_JOINTS["提取关节配置:<br/>- arm<br/>- gripper<br/>- all"]
           
           CHECK_UNION{"arm ∪ gripper<br/>= all?"}
           
           WARN_UNION["添加警告:<br/>并集不匹配"]
       end
       
       subgraph "阶段 2: 解析控制器路径"
           AUTO_RESOLVE{"controllers_config<br/>已提供?"}
           
           PARSE_CTRL_PATH["从 robot_config 解析<br/>ros2_control.controllers_config"]
           
           RESOLVE_PATH["resolve_ros_path()<br/>处理 $(find pkg)<br/>处理 $(env VAR)"]
       end
       
       subgraph "阶段 3: 验证控制器"
           LOAD_CTRL["load_yaml()<br/>controllers_config_path"]
           
           CHECK_ARM_POS["比较:<br/>arm_position_controller.joints<br/>与 arm_joints"]
           
           CHECK_ARM_TRAJ["比较:<br/>arm_trajectory_controller.joints<br/>与 arm_joints"]
           
           CHECK_GRIP_POS["比较:<br/>gripper_position_controller.joints<br/>与 gripper_joints"]
           
           CHECK_GRIP_TRAJ["比较:<br/>gripper_trajectory_controller.joints<br/>与 gripper_joints"]
           
           CHECK_JS["比较:<br/>joint_state_broadcaster.joints<br/>与 all_joints"]
       end
       
       subgraph "阶段 4: 验证 MoveIt"
           LOAD_MOVEIT["load_yaml()<br/>moveit_config_path"]
           
           CHECK_MOVEIT_ARM["比较:<br/>arm_trajectory_controller.joints<br/>与 arm_joints"]
           
           CHECK_MOVEIT_GRIP["比较:<br/>gripper_trajectory_controller.joints<br/>与 gripper_joints"]
       end
       
       subgraph "阶段 5: 报告结果"
           PRINT_WARNINGS["打印警告"]
           
           PRINT_ERRORS["打印错误"]
           
           EXIT{"有错误?"}
           
           EXIT_SUCCESS["sys.exit(0)"]
           EXIT_FAIL["sys.exit(1)"]
           EXIT_EXCEPTION["sys.exit(2)"]
       end
       
       START --> PARSE
       PARSE --> INIT
       INIT --> AUTO_DETECT
       AUTO_DETECT --> VALIDATE
       
       VALIDATE --> LOAD_ROBOT
       LOAD_ROBOT --> EXTRACT_JOINTS
       EXTRACT_JOINTS --> CHECK_UNION
       
       CHECK_UNION -->|"否"| WARN_UNION
       CHECK_UNION -->|"是"| AUTO_RESOLVE
       WARN_UNION --> AUTO_RESOLVE
       
       AUTO_RESOLVE -->|"否"| PARSE_CTRL_PATH
       AUTO_RESOLVE -->|"是"| LOAD_CTRL
       
       PARSE_CTRL_PATH --> RESOLVE_PATH
       RESOLVE_PATH --> LOAD_CTRL
       
       LOAD_CTRL --> CHECK_ARM_POS
       CHECK_ARM_POS --> CHECK_ARM_TRAJ
       CHECK_ARM_TRAJ --> CHECK_GRIP_POS
       CHECK_GRIP_POS --> CHECK_GRIP_TRAJ
       CHECK_GRIP_TRAJ --> CHECK_JS
       
       CHECK_JS --> LOAD_MOVEIT
       
       LOAD_MOVEIT --> CHECK_MOVEIT_ARM
       CHECK_MOVEIT_ARM --> CHECK_MOVEIT_GRIP
       
       CHECK_MOVEIT_GRIP --> PRINT_WARNINGS
       PRINT_WARNINGS --> PRINT_ERRORS
       PRINT_ERRORS --> EXIT
       
       EXIT -->|"否"| EXIT_SUCCESS
       EXIT -->|"是"| EXIT_FAIL
       
       VALIDATE -.->|"异常"| EXIT_EXCEPTION

**源码：** `scripts/validate_config.py:219-295 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/scripts/validate_config.py#L219-L295>`__,
`scripts/validate_config.py:297-350 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/scripts/validate_config.py#L297-L350>`__

--------------

关节配置验证
------------

``validate_joints_config()`` 方法从 robot_config YAML 提取并验证关节层次结构：

提取过程
~~~~~~~~

验证器从 ``joints`` 配置块提取三个关节集：


.. list-table::
   :header-rows: 1

   * - 字段
     - 类型
     - 描述
   * - ``arm``
     - ``List[str]``
     - 手臂关节名称（如 ``["joint1", "joint2", ...]``）
   * - ``gripper``
     - ``List[str]``
     - 夹爪关节名称（如 ``["gripper_joint"]``）
   * - ``all``
     - ``List[str]``
     - 完整关节列表（应等于 ``arm ∪ gripper``）

一致性检查
~~~~~~~~~~

验证器验证 ``all_joints == arm_joints ∪ gripper_joints``。如果违反此不变量，记录警告但验证继续，因为这通常是配置错误而非关键故障。

**实现：** `scripts/validate_config.py:103-131 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/scripts/validate_config.py#L103-L131>`__

**源码：** `scripts/validate_config.py:103-131 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/scripts/validate_config.py#L103-L131>`__

--------------

控制器配置验证
--------------

``validate_controller_config()`` 方法确保 ros2_control 控制器声明正确的关节列表：

验证的控制器
~~~~~~~~~~~~


.. list-table::
   :header-rows: 1

   * - 控制器名称
     - 预期关节
     - 用途
   * - `` arm_position_controller``
     - ``arm_joints``
     - 手臂关节的 位置控制
   * - ``ar m_trajectory_controller``
     - ``arm_joints``
     - 手臂关节的 轨迹控制
   * - ``grip per_position_controller``
     - ``gripper_joints``
     - 夹爪的 位置控制
   * - ``grippe r_trajectory_controller``
     - ``gripper_joints``
     - 夹爪的 轨迹控制
   * - `` joint_state_broadcaster``
     - ``all_joints``
     - 所有关节的 关节状态发布

验证逻辑
~~~~~~~~

对于每个控制器，验证器：1. 加载控制器的 ``ros__parameters.joints`` 字段 2. 转换为集合以进行顺序无关的比较 3. 与 robot_config 中的预期关节集比较 4. 如果集合不完全匹配则记录错误

如果配置文件中未找到控制器，验证器记录警告并继续（支持可能仅使用部分控制器的配置）。

**实现：** `scripts/validate_config.py:133-175 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/scripts/validate_config.py#L133-L175>`__

**源码：** `scripts/validate_config.py:133-175 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/scripts/validate_config.py#L133-L175>`__

--------------

MoveIt 配置验证
---------------

``validate_moveit_config()`` 方法验证 MoveIt 控制器配置，其结构与 ros2_control 控制器不同：

MoveIt 控制器结构
~~~~~~~~~~~~~~~~~

MoveIt 控制器嵌套在 ``moveit_simple_controller_manager`` 下，仅需要轨迹控制器（而非位置控制器）：


.. list-table::
   :header-rows: 1

   * - 控制器名称
     - 预期关节
     - 用途
   * - ``ar m_trajectory_controller``
     - ``arm_joints``
     - 手臂规划的 轨迹执行
   * - ``grippe r_trajectory_controller``
     - ``gripper_joints``
     - 夹爪规划的 轨迹执行

优雅降级
~~~~~~~~

MoveIt 配置在 IB-Robot 中是可选的（某些机器人可能不使用运动规划）。如果未找到或无法解析 MoveIt 配置文件，验证器记录警告但返回 ``True``，允许验证成功。

**实现：** `scripts/validate_config.py:177-217 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/scripts/validate_config.py#L177-L217>`__

**源码：** `scripts/validate_config.py:177-217 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/scripts/validate_config.py#L177-L217>`__

--------------

ROS 路径解析
------------

``resolve_ros_path()`` 方法处理配置文件中常用的 ROS 风格路径替换：

支持的替换模式
~~~~~~~~~~~~~~

.. mermaid::

   graph LR
       INPUT["带替换的路径字符串"]
       
       FIND_PATTERN["模式: $(find package)"]
       ENV_PATTERN["模式: $(env VAR)"]
       
       subgraph "$(find package) 解析"
           SEARCH_PATHS["搜索路径:<br/>1. ../package<br/>2. ../../package<br/>3. /opt/ros/humble/share/package<br/>4. install/package/share/package"]
           
           FIRST_MATCH["返回第一个<br/>存在的路径"]
           
           ERROR_FIND["FileNotFoundError:<br/>包未找到"]
       end
       
       subgraph "$(env VAR) 解析"
           READ_ENV["os.environ.get(VAR)"]
           
           CHECK_ENV{"变量已设置?"}
           
           SUBSTITUTE["替换值"]
           
           ERROR_ENV["ValueError:<br/>环境变量未设置"]
       end
       
       INPUT --> FIND_PATTERN
       INPUT --> ENV_PATTERN
       
       FIND_PATTERN --> SEARCH_PATHS
       SEARCH_PATHS --> FIRST_MATCH
       SEARCH_PATHS --> ERROR_FIND
       
       ENV_PATTERN --> READ_ENV
       READ_ENV --> CHECK_ENV
       CHECK_ENV -->|"是"| SUBSTITUTE
       CHECK_ENV -->|"否"| ERROR_ENV
       
       FIRST_MATCH --> RECURSE["递归调用<br/>resolve_ros_path()"]
       SUBSTITUTE --> RECURSE

示例解析
~~~~~~~~

给定配置路径：

.. code:: yaml

   ros2_control:
     controllers_config: "$(find robot_config)/config/controllers/controllers.yaml"

解析器：1. 检测 ``$(find robot_config)`` 模式 2. 在工作空间和安装目录中搜索 ``robot_config`` 包 3. 用解析的绝对路径替换 4. 返回完全解析的路径用于 YAML 加载

**实现：** `scripts/validate_config.py:53-101 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/scripts/validate_config.py#L53-L101>`__

**源码：** `scripts/validate_config.py:53-101 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/scripts/validate_config.py#L53-L101>`__

--------------

错误与警告处理
--------------

``ConfigValidator`` 类分别累积错误和警告：

错误类别
~~~~~~~~


.. list-table::
   :header-rows: 1

   * - 类别
     - 严重程度
     - 行为
   * - **配置不匹配**
     - 错误
     - robot_config 与 派生文件之间的 关节列表不匹配
   * - **缺少必需字段**
     - 错误
     - robot_config 中 未找到 ``joints`` 配置
   * - **文件未找到**
     - 异常（退出码 2）
     - 必需的配置文件 不存在
   * - **解析错误**
     - 异常（退出码 2）
     - YAML 文件无法解析

警告类别
~~~~~~~~


.. list-table::
   :header-rows: 1

   * - 类别
     - 严重程度
     - 行为
   * - **并集不匹配**
     - 警告
     - ``all`` 关节 ≠ ``arm ∪ gripper``
   * - **缺少可选控制器**
     - 警告
     - 配置中未找到 预期的控制器
   * - **MoveIt 配置未找到**
     - 警告
     - MoveIt 配置文件 不存在（非致命）
   * - **路径解析失败**
     - 警告
     - 无法解析 ``$(find pkg)`` 或 ``$(env VAR)``

退出码
~~~~~~

验证器使用标准 Unix 退出码：

.. code:: python

   # 退出码 0: 所有验证通过
   sys.exit(0)

   # 退出码 1: 发现配置错误
   sys.exit(1)

   # 退出码 2: 文件未找到或解析错误
   sys.exit(2)

**源码：** `scripts/validate_config.py:26-44 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/scripts/validate_config.py#L26-L44>`__,
`scripts/validate_config.py:276-294 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/scripts/validate_config.py#L276-L294>`__

--------------

使用示例
--------

基本验证
~~~~~~~~

验证默认的 SO101 机器人配置：

.. code:: bash

   python scripts/validate_config.py

这使用默认路径 ``src/robot_config/config/robots/so101_single_arm.yaml`` 并自动解析控制器和 MoveIt 配置。

自定义机器人配置
~~~~~~~~~~~~~~~~

验证自定义机器人配置文件：

.. code:: bash

   python scripts/validate_config.py \
     --robot-config src/robot_config/config/robots/custom_robot.yaml

显式控制器路径
~~~~~~~~~~~~~~

覆盖自动解析并指定显式控制器配置路径：

.. code:: bash

   python scripts/validate_config.py \
     --robot-config src/robot_config/config/robots/so101_single_arm.yaml \
     --controllers-config src/robot_config/config/controllers/custom_controllers.yaml \
     --moveit-config src/robot_moveit/config/lerobot/so101/moveit_controllers.yaml

详细输出
~~~~~~~~

启用详细日志以查看详细的验证进度：

.. code:: bash

   python scripts/validate_config.py --verbose

详细模式显示：- 加载的关节列表 - 各控制器验证结果 - 路径解析步骤 - 每个验证阶段的成功指示器

**源码：** `scripts/validate_config.py:297-323 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/scripts/validate_config.py#L297-L323>`__

--------------

CI/CD 集成
----------

验证器设计用于集成到持续集成管道中，防止配置漂移进入生产环境：

GitHub Actions 示例
~~~~~~~~~~~~~~~~~~~

.. code:: yaml

   name: 配置验证

   on: [push, pull_request]

   jobs:
     validate:
       runs-on: ubuntu-22.04
       steps:
         - uses: actions/checkout@v3
         
         - name: 安装依赖
           run: |
             pip install pyyaml
         
         - name: 验证机器人配置
           run: |
             python scripts/validate_config.py --verbose

Pre-commit 钩子
~~~~~~~~~~~~~~~

创建 ``.git/hooks/pre-commit``：

.. code:: bash

   #!/bin/bash
   python scripts/validate_config.py
   if [ $? -ne 0 ]; then
       echo "配置验证失败。提交已中止。"
       exit 1
   fi

配置更改时自动验证
~~~~~~~~~~~~~~~~~~

监控配置文件并触发验证：

.. code:: bash

   # 监控配置文件的更改
   inotifywait -m src/robot_config/config/ -e modify |
   while read path action file; do
       echo "配置已更改: $file"
       python scripts/validate_config.py || echo "验证失败!"
   done

**源码：** `scripts/validate_config.py:1-17 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/scripts/validate_config.py#L1-L17>`__,
`scripts/validate_config.py:334-346 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/scripts/validate_config.py#L334-L346>`__

--------------

日志与诊断
----------

``ConfigValidator.log()`` 方法提供带严重程度过滤的结构化输出：

日志级别
~~~~~~~~

=========== ====== ==============================
级别       符号   行为
=========== ====== ==============================
``INFO``    ℹ      仅在详细模式下显示
``WARNING`` ⚠      始终显示
``ERROR``   ✗      始终显示
``SUCCESS`` ✓      始终显示
=========== ====== ==============================

示例输出
~~~~~~~~

::

   ============================================================
   IB Robot 配置验证
   ============================================================
   ℹ 加载机器人配置: src/robot_config/config/robots/so101_single_arm.yaml
   ℹ 手臂关节: ['joint1', 'joint2', 'joint3', 'joint4', 'joint5']
   ℹ 夹爪关节: ['gripper_joint']
   ✓ 所有关节: ['gripper_joint', 'joint1', 'joint2', 'joint3', 'joint4', 'joint5']

   验证控制器配置: src/robot_config/config/controllers/controllers.yaml
   ✓ arm_position_controller: ✓
   ✓ arm_trajectory_controller: ✓
   ✓ gripper_position_controller: ✓
   ✓ gripper_trajectory_controller: ✓
   ✓ joint_state_broadcaster: ✓

   验证 MoveIt 配置: src/robot_moveit/config/lerobot/so101/moveit_controllers.yaml
   ✓ MoveIt arm_trajectory_controller: ✓
   ✓ MoveIt gripper_trajectory_controller: ✓

   ============================================================
   验证摘要
   ============================================================

   ✓ 所有配置验证通过

**源码：** `scripts/validate_config.py:34-43 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/scripts/validate_config.py#L34-L43>`__,
`scripts/validate_config.py:276-294 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/scripts/validate_config.py#L276-L294>`__

--------------

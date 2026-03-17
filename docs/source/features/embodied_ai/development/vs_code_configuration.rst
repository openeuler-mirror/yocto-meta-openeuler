VS Code 配置
============

.. raw:: html

   <details>

相关源文件

以下文件用于生成此 Wiki 页面的上下文：

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

本文档介绍 IB_Robot 工作区中的 VS Code 配置文件，包括 Python 环境集成、ROS2 工具支持、构建任务和调试配置。这些设置实现了无缝开发，为 Python 和 C++ 组件提供正确的 IntelliSense、代码导航和调试功能。

有关构建系统本身的信息（colcon mixin 和编译选项），请参阅 `构建系统与 Mixin <#13.2>`__。有关调试策略和测试基础设施，请参阅 `调试与测试 <#13.3>`__。

--------------

Python 环境集成
--------------

工作区配置 VS Code 使用项目的虚拟环境，并正确解析 ROS2、LeRobot 和工作区包之间的 Python 导入。

解释器与路径配置
~~~~~~~~~~~~~~~~

Python 解释器配置为使用工作区虚拟环境，位于 `.vscode/settings.json:2 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.vscode/settings.json#L2>`__:

.. code:: json

   "python.defaultInterpreterPath": "${workspaceFolder}/venv/bin/python3"

Python 分析和自动补全按以下顺序搜索路径 `.vscode/settings.json:3-16 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.vscode/settings.json#L3-L16>`__:


.. list-table::
   :header-rows: 1

   * - 优先级
     - 路径
     - 用途
   * - 1
     - ``${workspa ceFolder}/libs /lerobot/src``
     - LeRobot 库源码 （子模块）
   * - 2
     - ``${workspac eFolder}/src``
     - 工作区 ROS2 包
   * - 3
     - ``/opt /ros/humble/li b/python3.10/s ite-packages``
     - ROS2 Humble Python 包
   * - 4
     - ``/opt/ros/h umble/local/li b/python3.10/d ist-packages``
     - ROS2 本地包
   * - 5
     - ``${workspaceF older}/venv/li b/python3.10/s ite-packages``
     - 虚拟环境包

此配置使 IntelliSense 能够解析以下导入：- ROS2 包（``rclpy``、``sensor_msgs``、``std_msgs`` 等）- LeRobot 库（``lerobot.common.robot_devices``、策略类）- 工作区包（``robot_config``、``tensormsg``、``inference_service`` 等）

终端环境
~~~~~~~~

集成终端自动配置 ``PYTHONPATH`` `.vscode/settings.json:17-19 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.vscode/settings.json#L17-L19>`__:

.. code:: json

   "terminal.integrated.env.linux": {
       "PYTHONPATH": "${workspaceFolder}/libs/lerobot/src:${workspaceFolder}/src:/opt/ros/humble/lib/python3.10/site-packages:/opt/ros/humble/local/lib/python3.10/dist-packages:${PYTHONPATH}"
   }

这确保从终端运行的 Python 脚本可以导入所有必要的模块，无需手动设置环境。

**图：Python 路径解析架构**

.. mermaid::

   graph TB
       subgraph "VS Code Python Extension"
           INTERP["defaultInterpreterPath<br/>${workspaceFolder}/venv/bin/python3"]
           ANALYSIS["python.analysis.extraPaths[]"]
           AUTOCOMPLETE["python.autoComplete.extraPaths[]"]
           TERMINAL["terminal.integrated.env.linux.PYTHONPATH"]
       end
       
       subgraph "Import Resolution Order"
           LEROBOT["libs/lerobot/src<br/>Priority 1"]
           WORKSPACE["src/<br/>Priority 2"]
           ROS_LIB["/opt/ros/humble/lib/python3.10/site-packages<br/>Priority 3"]
           ROS_LOCAL["/opt/ros/humble/local/lib/python3.10/dist-packages<br/>Priority 4"]
           VENV["venv/lib/python3.10/site-packages<br/>Priority 5"]
       end
       
       subgraph "Capabilities Enabled"
           INTELLI["IntelliSense<br/>Code completion"]
           GOTO["Go to Definition<br/>Cross-package navigation"]
           LINT["Linting & Type Checking<br/>Pylance analysis"]
           RUN["Run/Debug<br/>Import resolution"]
       end
       
       ANALYSIS --> LEROBOT
       ANALYSIS --> WORKSPACE
       ANALYSIS --> ROS_LIB
       ANALYSIS --> ROS_LOCAL
       ANALYSIS --> VENV
       
       AUTOCOMPLETE --> LEROBOT
       AUTOCOMPLETE --> WORKSPACE
       AUTOCOMPLETE --> ROS_LIB
       AUTOCOMPLETE --> ROS_LOCAL
       AUTOCOMPLETE --> VENV
       
       TERMINAL --> LEROBOT
       TERMINAL --> WORKSPACE
       TERMINAL --> ROS_LIB
       TERMINAL --> ROS_LOCAL
       
       LEROBOT --> INTELLI
       WORKSPACE --> INTELLI
       ROS_LIB --> INTELLI
       
       LEROBOT --> GOTO
       WORKSPACE --> GOTO
       
       ANALYSIS --> LINT
       
       TERMINAL --> RUN

**来源:** `.vscode/settings.json:2-19 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.vscode/settings.json#L2-L19>`__

--------------

ROS2 集成
---------

工作区通过 RDE（ROS 开发环境）扩展配置 ROS2 工具支持。

ROS 发行版与设置
~~~~~~~~~~~~~~~~

ROS2 Humble 配置为目标发行版 `.vscode/settings.json:29-32 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.vscode/settings.json#L29-L32>`__:

.. code:: json

   "ros.distro": "humble",
   "ros.setupSource": "/opt/ros/humble/setup.sh",
   "rde.ros.distro": "humble",
   "rde.ros.setupSource": "/opt/ros/humble/setup.sh"

这些设置启用：- ROS2 命令面板集成 - 启动文件语法高亮 - 包发现和导航 - 终端中的 ROS2 CLI 集成

**来源:** `.vscode/settings.json:29-32 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.vscode/settings.json#L29-L32>`__

--------------

构建任务
--------

VS Code 任务提供对带有正确环境 source 的 colcon 构建命令的快速访问。

默认构建任务
~~~~~~~~~~~~

默认构建任务以 release 模式编译整个工作区 `.vscode/tasks.json:4-17 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.vscode/tasks.json#L4-L17>`__:


.. list-table::
   :header-rows: 1

   * - 属性
     - 值
   * - Label
     - ``colcon build``
   * - Type
     - ``shell``
   * - Command
     - ``sourc e /opt/ros/humble/setup.sh && source venv/bin/activa te && colcon build --symli nk-install --cmake-args -D CMAKE_BUILD_TYPE=Release``
   * - Shortcut
     - ``Ctrl+Shift+B``（默认 构建任务）

关键特性：- Source ROS2 Humble 环境 - 激活 Python 虚拟环境 - 使用 ``--symlink-install`` 加快迭代（Python 文件是符号链接，非复制）- 默认以 ``Release`` 模式构建 - 始终在新面板中显示输出

选择性包构建
~~~~~~~~~~~~

选择性构建任务仅编译包含当前文件的包 `.vscode/tasks.json:18-24 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.vscode/tasks.json#L18-L24>`__:

.. code:: json

   {
       "label": "colcon build selected",
       "command": "source /opt/ros/humble/setup.sh && source venv/bin/activate && colcon build --symlink-install --packages-select ${relativeFileDirname}"
   }

此任务使用 ``${relativeFileDirname}`` 从当前文件路径自动检测包。

**图：构建任务执行流程**

.. mermaid::

   graph LR
       subgraph "User Action"
           SHORTCUT["Ctrl+Shift+B<br/>or Task Menu"]
       end
       
       subgraph "tasks.json Configuration"
           DEFAULT["colcon build<br/>isDefault: true"]
           SELECTED["colcon build selected<br/>${relativeFileDirname}"]
       end
       
       subgraph "Environment Setup"
           ROS_SOURCE["source /opt/ros/humble/setup.sh"]
           VENV_ACT["source venv/bin/activate"]
       end
       
       subgraph "Colcon Execution"
           SYMLINK["--symlink-install"]
           CMAKE["--cmake-args -DCMAKE_BUILD_TYPE=Release"]
           PKG_SEL["--packages-select <package>"]
           
           BUILD_ALL["Build all packages in src/"]
           BUILD_ONE["Build single package"]
       end
       
       subgraph "Output"
           BUILD_DIR["build/<br/>Intermediate files"]
           INSTALL_DIR["install/<br/>Merged install space"]
           LOG_DIR["log/<br/>Build logs"]
       end
       
       SHORTCUT --> DEFAULT
       SHORTCUT --> SELECTED
       
       DEFAULT --> ROS_SOURCE
       SELECTED --> ROS_SOURCE
       
       ROS_SOURCE --> VENV_ACT
       VENV_ACT --> SYMLINK
       
       SYMLINK --> CMAKE
       SYMLINK --> PKG_SEL
       
       CMAKE --> BUILD_ALL
       PKG_SEL --> BUILD_ONE
       
       BUILD_ALL --> BUILD_DIR
       BUILD_ONE --> BUILD_DIR
       
       BUILD_DIR --> INSTALL_DIR
       BUILD_DIR --> LOG_DIR

**来源:** `.vscode/tasks.json:1-26 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.vscode/tasks.json#L1-L26>`__

--------------

调试配置
--------

工作区为调试 ROS2 Python 节点提供启动配置。

通用 Python 节点调试器
~~~~~~~~~~~~~~~~~~~~~~

通用配置调试当前打开的 Python 文件 `.vscode/launch.json:4-13 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.vscode/launch.json#L4-L13>`__:

.. code:: json

   {
       "name": "ROS2: Debug Python Node (Current File)",
       "type": "python",
       "request": "launch",
       "program": "${file}",
       "console": "integratedTerminal",
       "env": {
           "PYTHONPATH": "${workspaceFolder}/libs/lerobot_ros2:${workspaceFolder}/venv/lib/python3.10/site-packages:/opt/ros/humble/lib/python3.10/site-packages:${PYTHONPATH}"
       }
   }

**用法:** 1. 打开 Python 节点文件（如 ``action_dispatcher_node.py``）2. 设置断点 3. 按 ``F5`` 或从调试菜单选择此配置 4. 节点在附加调试器的情况下运行

动作分发器节点配置
~~~~~~~~~~~~~~~~~~

为 ``action_dispatcher_node`` 预配置的启动器 `.vscode/launch.json:14-27 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.vscode/launch.json#L14-L27>`__:


.. list-table::
   :header-rows: 1

   * - 属性
     - 值
   * - Program
     - ``${wo rkspaceFolder}/src/action_ dispatch/action_dispatch/a ction_dispatcher_node.py``
   * - Arguments
     - ``-- ros-args -p robot_name:=te st_single_arm_single_cam``
   * - Environment
     - 自定义 ``PYTHONPATH``， 包含 LeRobot 和 ROS2 路径

此配置演示如何调试带有特定参数的节点。可以按照此模式添加其他节点配置。

**图：调试配置结构**

.. mermaid::

   graph TB
       subgraph "launch.json Configurations"
           GENERIC["ROS2: Debug Python Node (Current File)<br/>program: ${file}"]
           SPECIFIC["ROS2: Action Dispatcher Node<br/>program: action_dispatcher_node.py<br/>args: --ros-args -p robot_name:=..."]
       end
       
       subgraph "Environment Setup"
           PYTHONPATH["PYTHONPATH<br/>libs/lerobot_ros2<br/>venv/lib/python3.10/site-packages<br/>/opt/ros/humble/lib/python3.10/site-packages"]
       end
       
       subgraph "Debugger Features"
           BREAKPOINT["Breakpoints<br/>Pause execution"]
           INSPECT["Variable Inspection<br/>Watch expressions"]
           STACK["Call Stack<br/>Frame navigation"]
           CONSOLE["Debug Console<br/>REPL evaluation"]
       end
       
       subgraph "Target Process"
           RCL["rclpy.init()"]
           NODE["Node creation<br/>Subscriptions/Publishers"]
           SPIN["rclpy.spin()<br/>Event loop"]
       end
       
       GENERIC --> PYTHONPATH
       SPECIFIC --> PYTHONPATH
       
       PYTHONPATH --> RCL
       
       RCL --> NODE
       NODE --> SPIN
       
       GENERIC --> BREAKPOINT
       SPECIFIC --> BREAKPOINT
       
       BREAKPOINT --> INSPECT
       BREAKPOINT --> STACK
       BREAKPOINT --> CONSOLE
       
       SPIN -.->|controlled by| BREAKPOINT

**来源:** `.vscode/launch.json:1-28 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.vscode/launch.json#L1-L28>`__

--------------

推荐扩展
--------

工作区推荐 ROS2 和 Python 开发的基本扩展 `.vscode/extensions.json:2-11 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.vscode/extensions.json#L2-L11>`__:


.. list-table::
   :header-rows: 1

   * - 扩展
     - 用途
   * - ``ms-python.python``
     - Python IntelliSense、调试、 代码检查
   * - ``ms-vscode.cpptools``
     - ros2_control 插件的 C++ IntelliSense
   * - ``vadimcn.vscode-lldb``
     - 使用 LLDB 进行 C++ 调试
   * - ``ms-vscode.cmake-tools``
     - CMake 项目管理
   * - ``redhat.vscode-yaml``
     - YAML 语法高亮和验证
   * - `` vscot-team.vscode-smart-column``
     - 智能列选择
   * - ``Ranch-Hand-Robotics.rde-pack``
     - ROS 开发环境
   * - ``anthropic.claude-code``
     - AI 辅助开发

打开工作区时，如果缺少这些扩展，VS Code 会提示安装。

**来源:** `.vscode/extensions.json:1-12 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.vscode/extensions.json#L1-L12>`__

--------------

C++ IntelliSense 配置
---------------------

C++ IntelliSense 配置用于 ROS2 Humble 开发 `.vscode/c_cpp_properties.json:3-14 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.vscode/c_cpp_properties.json#L3-L14>`__:

.. code:: json

   {
       "name": "ROS2-Humble",
       "includePath": [
           "${workspaceFolder}/**",
           "/opt/ros/humble/include/**",
           "/usr/include/**"
       ],
       "cppStandard": "c++17",
       "intelliSenseMode": "linux-gcc-x64",
       "compilerPath": "/usr/bin/gcc"
   }

此配置启用：- ROS2 C++ API 的代码补全（``rclcpp``、``sensor_msgs`` 等）- ROS2 头文件的跳转到定义 - C++ 硬件插件中的错误检测（如 ``so101_hardware``）- C++17 标准合规性检查

**来源:** `.vscode/c_cpp_properties.json:1-17 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.vscode/c_cpp_properties.json#L1-L17>`__

--------------

工作区设置
----------

搜索排除
~~~~~~~~

搜索功能排除构建产物以提高性能 `.vscode/settings.json:23-28 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.vscode/settings.json#L23-L28>`__:

.. code:: json

   "search.exclude": {
       "**/build": true,
       "**/install": true,
       "**/log": true,
       "**/venv": true
   }

这些目录由 colcon 和 Python 虚拟环境设置生成，不应在代码中搜索。

文件关联
~~~~~~~~

仓库管理的自定义文件关联 `.vscode/settings.json:20-22 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.vscode/settings.json#L20-L22>`__:

.. code:: json

   "files.associations": {
       "*.repos": "yaml"
   }

``.repos`` 文件（由 ``vcstool`` 用于管理 git 子模块）被视为 YAML 以进行语法高亮。

**来源:** `.vscode/settings.json:20-28 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.vscode/settings.json#L20-L28>`__

--------------

配置文件层次结构
----------------

**图：VS Code 配置文件关系**

.. mermaid::

   graph TB
       subgraph "VS Code Workspace Root"
           WORKSPACE[".vscode/<br/>Configuration directory"]
       end
       
       subgraph "Python & ROS2"
           SETTINGS["settings.json<br/>defaultInterpreterPath<br/>python.analysis.extraPaths<br/>ros.distro: humble"]
           
           LAUNCH["launch.json<br/>Debug configurations<br/>PYTHONPATH env vars"]
       end
       
       subgraph "Build & Tasks"
           TASKS["tasks.json<br/>colcon build<br/>colcon build selected"]
           
           COLCON_DEF[".colcon/defaults.yaml<br/>merge-install: true<br/>event-handlers"]
           
           MIXIN_IDX[".colcon/mixin/index.yaml<br/>References build.mixin.yaml"]
           
           MIXIN_BUILD[".colcon/mixin/build.mixin.yaml<br/>debug, release, dev, prod"]
       end
       
       subgraph "C++ Development"
           CPP_PROPS["c_cpp_properties.json<br/>ROS2-Humble configuration<br/>cppStandard: c++17"]
       end
       
       subgraph "Developer Experience"
           EXTENSIONS["extensions.json<br/>Recommended extensions<br/>ms-python.python<br/>Ranch-Hand-Robotics.rde-pack"]
       end
       
       subgraph "Environment Validation"
           GITIGNORE[".gitignore<br/>build/, install/, log/<br/>venv/, models/"]
           
           VALIDATE["scripts/validate_config.py<br/>Validates configuration consistency"]
       end
       
       WORKSPACE --> SETTINGS
       WORKSPACE --> LAUNCH
       WORKSPACE --> TASKS
       WORKSPACE --> CPP_PROPS
       WORKSPACE --> EXTENSIONS
       
       TASKS -.->|invokes| COLCON_DEF
       COLCON_DEF -.->|loads| MIXIN_IDX
       MIXIN_IDX -.->|references| MIXIN_BUILD
       
       SETTINGS -.->|excludes from search| GITIGNORE
       
       VALIDATE -.->|checks| SETTINGS

**来源:** `.vscode/settings.json:1-33 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.vscode/settings.json#L1-L33>`__,
`.vscode/tasks.json:1-26 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.vscode/tasks.json#L1-L26>`__, `.vscode/launch.json:1-28 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.vscode/launch.json#L1-L28>`__,
`.vscode/c_cpp_properties.json:1-17 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.vscode/c_cpp_properties.json#L1-L17>`__,
`.vscode/extensions.json:1-12 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.vscode/extensions.json#L1-L12>`__, `.colcon/defaults.yaml:1-23 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.colcon/defaults.yaml#L1-L23>`__,
`.colcon/mixin/index.yaml:1-4 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.colcon/mixin/index.yaml#L1-L4>`__,
`.colcon/mixin/build.mixin.yaml:1-19 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.colcon/mixin/build.mixin.yaml#L1-L19>`__, `.gitignore:1-20 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.gitignore#L1-L20>`__

--------------

与构建系统集成
--------------

VS Code 配置通过环境变量和路径解析与工作区构建系统集成。`构建系统与 Mixin <#13.2>`__ 页面记录了构建任务引用的 colcon mixin 配置：

=========== =================================== ======================
Mixin       CMake 参数                         使用场景
=========== =================================== ======================
``debug``   ``-DCMAKE_BUILD_TYPE=Debug``        调试 C++ 插件
``release`` ``-DCMAKE_BUILD_TYPE=Release``      生产构建
``dev``     ``Debug + --symlink-install``       快速 Python 迭代
``prod``    ``Release + -DTRACETOOLS_DISABLED`` 部署构建
=========== =================================== ======================

这些 mixin 可以从命令行调用：

.. code:: bash

   colcon build --mixin dev

默认 VS Code 构建任务使用 release 模式，但开发者可以为其他 mixin 创建额外任务。

**来源:** `.colcon/mixin/build.mixin.yaml:1-19 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.colcon/mixin/build.mixin.yaml#L1-L19>`__,
`.vscode/tasks.json:4-17 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.vscode/tasks.json#L4-L17>`__

--------------

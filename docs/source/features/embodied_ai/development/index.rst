开发指南
========

.. toctree::
   :titlesonly:
   :hidden:

   vs_code_configuration
   build_system_and_mixins
   debugging_and_testing

.. raw:: html

   <details>

相关源文件

以下文件用作生成此 wiki 页面的上下文：

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
-  `scripts/setup.sh <scripts/setup.sh>`__
-  `scripts/validate_config.py <scripts/validate_config.py>`__

.. raw:: html

   </details>

本页面为参与 IB-Robot 代码库开发的开发者提供实用指南。内容涵盖环境配置、IDE 设置、构建系统使用、调试技术和验证工作流程。有关初始设置说明，请参阅 `入门指南 <#2>`__。有关特定包的开发详情，请参考 `包参考 <#12>`__。

--------------

开发环境架构
------------

IB-Robot 开发环境由三个集成层组成：带有 ROS 2 系统站点包的 Python 虚拟环境、带有工作区特定 mixin 的 colcon 构建系统，以及用于 IntelliSense 和调试的 VS Code 配置。

.. mermaid::

   graph TB
       subgraph "Layer 1: Environment Setup"
           SETUP["setup.sh<br/>Environment Initialization"]
           
           subgraph "Conda Detection"
               CONDA_CHECK["check_conda()<br/>CONDA_PREFIX detection"]
               CONDA_BLOCK["Exit with error<br/>if Conda active"]
           end
           
           subgraph "Git Submodule Management"
               SUBMOD_DETECT["Check .git directories<br/>libs/lerobot, src/pymoveit2"]
               SUBMOD_PROMPT["Interactive selection<br/>All/LeRobot/PyMoveIt2/Individual"]
               SUBMOD_UPDATE["git submodule update<br/>--init --recursive"]
           end
           
           subgraph "Python venv Creation"
               VENV_CREATE["python3 -m venv<br/>--system-site-packages"]
               VENV_DEPS["pip install requirements<br/>numpy<2, setuptools<80"]
               LEROBOT_INSTALL["pip install -e libs/lerobot"]
               HW_DEPS["pip install pyserial<br/>feetech-servo-sdk"]
           end
           
           SETUP --> CONDA_CHECK
           CONDA_CHECK --> CONDA_BLOCK
           CONDA_CHECK --> SUBMOD_DETECT
           SUBMOD_DETECT --> SUBMOD_PROMPT
           SUBMOD_PROMPT --> SUBMOD_UPDATE
           SUBMOD_UPDATE --> VENV_CREATE
           VENV_CREATE --> VENV_DEPS
           VENV_DEPS --> LEROBOT_INSTALL
           LEROBOT_INSTALL --> HW_DEPS
       end
       
       subgraph "Layer 2: Build System"
           COLCON[".colcon/defaults.yaml<br/>merge-install: true"]
           
           subgraph "Mixin Definitions"
               MIXIN_INDEX[".colcon/mixin/index.yaml"]
               MIXIN_BUILD[".colcon/mixin/build.mixin.yaml"]
               
               DEBUG_MIXIN["debug mixin<br/>CMAKE_BUILD_TYPE=Debug"]
               RELEASE_MIXIN["release mixin<br/>CMAKE_BUILD_TYPE=Release"]
               DEV_MIXIN["dev mixin<br/>symlink-install + Debug"]
               PROD_MIXIN["prod mixin<br/>Release + no testing"]
           end
           
           MIXIN_INDEX --> MIXIN_BUILD
           MIXIN_BUILD --> DEBUG_MIXIN
           MIXIN_BUILD --> RELEASE_MIXIN
           MIXIN_BUILD --> DEV_MIXIN
           MIXIN_BUILD --> PROD_MIXIN
       end
       
       subgraph "Layer 3: VS Code Integration"
           SETTINGS[".vscode/settings.json<br/>Python interpreter + paths"]
           TASKS[".vscode/tasks.json<br/>colcon build tasks"]
           LAUNCH[".vscode/launch.json<br/>Debug configurations"]
           EXTENSIONS[".vscode/extensions.json<br/>Recommended tools"]
           
           CPP_PROPS[".vscode/c_cpp_properties.json<br/>C++ IntelliSense"]
       end
       
       HW_DEPS -.->|provides Python env| SETTINGS
       COLCON -.->|used by| TASKS
       MIXIN_BUILD -.->|applied in| TASKS
       SETTINGS -.->|configures| LAUNCH

**来源**: `scripts/setup.sh:1-307 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/scripts/setup.sh#L1-L307>`__,
`.vscode/settings.json:1-33 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.vscode/settings.json#L1-L33>`__, `.colcon/defaults.yaml:1-23 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.colcon/defaults.yaml#L1-L23>`__,
`.colcon/mixin/build.mixin.yaml:1-19 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.colcon/mixin/build.mixin.yaml#L1-L19>`__,
`.vscode/tasks.json:1-26 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.vscode/tasks.json#L1-L26>`__

--------------

Python 虚拟环境配置
------------------

工作区使用启用了 ``--system-site-packages`` 的 Python 虚拟环境，以便在隔离项目依赖的同时访问 ROS 2 系统安装的 ``rclpy``。

关键依赖项
~~~~~~~~~~


.. list-table::
   :header-rows: 1

   * - 包
     - 版本约束
     - 原因
   * - ``numpy``
     - ``<2``
     - ROS 2 Humble 组件需要 NumPy 1.x API
   * - ``setuptools``
     - ``>=71,<80``
     - 平衡 LeRobot 需求与 colcon 兼容性
   * - ``lerobot``
     - 可编辑安装
     - 开发修改 立即生效
   * - ``pyserial``
     - 最新版本
     - Feetech 舵机 通信
   * - ``feetech-servo-sdk``
     - 最新版本
     - SO-101 硬件 接口
   * - ``scipy``
     - 最新版本
     - 四元数/旋转 矩阵转换
   * - ``gitlint``
     - 最新版本
     - 提交消息 验证

设置流程
~~~~~~~~

虚拟环境由 `scripts/setup.sh:216-278 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/scripts/setup.sh#L216-L278>`__ 创建：

.. code:: bash

   # Create venv with system site packages
   python3 -m venv --system-site-packages venv

   # Activate and install dependencies
   source venv/bin/activate
   pip install --upgrade pip
   pip install "numpy<2"
   pip install "setuptools<80" "setuptools>=71"
   pip install -e libs/lerobot
   pip install pyserial feetech-servo-sdk scipy
   pip install gitlint
   gitlint install-hook

Conda 冲突检测
~~~~~~~~~~~~~~

如果检测到 Conda 环境处于活动状态，设置脚本将阻止执行 `scripts/setup.sh:25-33 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/scripts/setup.sh#L25-L33>`__：

.. code:: python

   check_conda() {
       if [[ -n "${CONDA_PREFIX}" ]]; then
           log_error "Active Conda environment detected"
           log_warn "Conda environments conflict with ROS 2 Python libraries"
           exit 1
       fi
   }

**原因**：Conda 的包隔离可能会覆盖 ROS 2 系统包，导致 ``rclpy`` 和 ``tf2_ros`` 的导入冲突。

**来源**: `scripts/setup.sh:216-278 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/scripts/setup.sh#L216-L278>`__,
`scripts/setup.sh:25-33 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/scripts/setup.sh#L25-L33>`__

--------------

Git 子模块管理
--------------

工作区包含 `.gitmodules:1-11 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.gitmodules#L1-L11>`__ 中定义的两个子模块：


.. list-table::
   :header-rows: 1

   * - 子模块
     - 路径
     - 用途
   * - ``lerobot_ros2``
     - ``libs/lerobot``
     - 带有 ROS 2 集成的 LeRobot 库
   * - ``pymoveit2``
     - ``src/pymoveit2``
     - MoveIt 2 的 Python API

交互式初始化
~~~~~~~~~~~~

设置脚本提供选择性子模块初始化 `scripts/setup.sh:38-135 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/scripts/setup.sh#L38-L135>`__：

.. mermaid::

   graph LR
       START["setup.sh execution"]
       CHECK{"Submodules<br/>initialized?"}
       
       PROMPT_UPDATE["Prompt: Update all?"]
       UPDATE_ALL["git submodule update<br/>--init --recursive"]
       
       PROMPT_SELECT["Menu:<br/>1. All<br/>2. LeRobot only<br/>3. PyMoveIt2 only<br/>4. Individual<br/>0. Skip"]
       
       INIT_ALL["Initialize all submodules"]
       INIT_LEROBOT["Initialize libs/lerobot"]
       INIT_PYMOVEIT["Initialize src/pymoveit2"]
       INIT_CUSTOM["Interactive per-submodule"]
       
       START --> CHECK
       CHECK -->|All exist| PROMPT_UPDATE
       CHECK -->|Some missing| PROMPT_SELECT
       
       PROMPT_UPDATE -->|Yes| UPDATE_ALL
       PROMPT_UPDATE -->|No| SKIP
       
       PROMPT_SELECT -->|1| INIT_ALL
       PROMPT_SELECT -->|2| INIT_LEROBOT
       PROMPT_SELECT -->|3| INIT_PYMOVEIT
       PROMPT_SELECT -->|4| INIT_CUSTOM
       PROMPT_SELECT -->|0| SKIP
       
       SKIP["Continue without update"]

开发者 Fork 配置
~~~~~~~~~~~~~~~~

对于拥有个人 fork 的贡献者，设置脚本可以重新配置远程仓库 `scripts/setup.sh:137-177 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/scripts/setup.sh#L137-L177>`__：

.. code:: bash

   # Prompts for GitCode username
   # Sets: origin → user's fork
   #       upstream → original repository
   git remote set-url origin git@gitcode.com:${USERNAME}/IB_Robot.git
   git remote add upstream git@atomgit.com:openeuler/IB_Robot.git

   # Also configures submodule fork
   cd libs/lerobot
   git remote set-url origin git@gitcode.com:${USERNAME}/lerobot_ros2.git
   git remote add upstream <original-lerobot-url>

**来源**: `.gitmodules:1-11 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.gitmodules#L1-L11>`__, `scripts/setup.sh:38-177 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/scripts/setup.sh#L38-L177>`__

--------------

VS Code 配置
------------

工作区设置架构
~~~~~~~~~~~~~~

`.vscode/settings.json:1-33 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.vscode/settings.json#L1-L33>`__ 文件配置 Python IntelliSense 和 ROS 2 集成：

.. mermaid::

   graph TB
       subgraph "Python Configuration"
           INTERP["defaultInterpreterPath<br/>workspaceFolder/venv/bin/python3"]
           
           ANALYSIS_PATHS["python.analysis.extraPaths"]
           AUTOCOMPLETE_PATHS["python.autoComplete.extraPaths"]
           
           PATH_LEROBOT["libs/lerobot/src"]
           PATH_SRC["src"]
           PATH_ROS_LIB["/opt/ros/humble/lib/python3.10/site-packages"]
           PATH_ROS_LOCAL["/opt/ros/humble/local/lib/python3.10/dist-packages"]
           PATH_VENV["venv/lib/python3.10/site-packages"]
       end
       
       subgraph "Terminal Environment"
           TERM_ENV["terminal.integrated.env.linux"]
           PYTHONPATH["PYTHONPATH environment variable"]
       end
       
       subgraph "File Associations"
           REPOS_YAML["*.repos files → YAML"]
       end
       
       subgraph "Search Exclusions"
           EXCLUDE_BUILD["build/"]
           EXCLUDE_INSTALL["install/"]
           EXCLUDE_LOG["log/"]
           EXCLUDE_VENV["venv/"]
       end
       
       subgraph "ROS Integration"
           ROS_DISTRO["ros.distro: humble"]
           ROS_SETUP["ros.setupSource<br/>/opt/ros/humble/setup.sh"]
       end
       
       INTERP --> ANALYSIS_PATHS
       INTERP --> AUTOCOMPLETE_PATHS
       
       ANALYSIS_PATHS --> PATH_LEROBOT
       ANALYSIS_PATHS --> PATH_SRC
       ANALYSIS_PATHS --> PATH_ROS_LIB
       ANALYSIS_PATHS --> PATH_ROS_LOCAL
       ANALYSIS_PATHS --> PATH_VENV
       
       AUTOCOMPLETE_PATHS --> PATH_LEROBOT
       AUTOCOMPLETE_PATHS --> PATH_SRC
       AUTOCOMPLETE_PATHS --> PATH_ROS_LIB

**关键配置值**：


.. list-table::
   :header-rows: 1

   * - 设置
     - 值
     - 用途
   * - ``python.de faultInterpreterPath``
     - ``${w orkspaceFolder}/v env/bin/python3``
     - 使用工作区 venv
   * - ``python .analysis.extraPaths``
     - LeRobot, src, ROS 路径
     - 启用导入 解析
   * - ``terminal.integrated. env.linux.PYTHONPATH``
     - 合并路径
     - 确保终端使用 正确的导入
   * - ``ros.distro``
     - ``humble``
     - RDE 扩展 ROS 版本
   * - ``search.exclude``
     - ``build/``, ``install/``, ``log/``, ``venv/``
     - 改善搜索 性能

推荐扩展
~~~~~~~~

`.vscode/extensions.json:1-13 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.vscode/extensions.json#L1-L13>`__ 列出了必要的扩展：


.. list-table::
   :header-rows: 1

   * - 扩展 ID
     - 用途
   * - ``ms-python.python``
     - Python 语言支持和 调试
   * - ``ms-vscode.cpptools``
     - C++ IntelliSense（用于 ros2_control 插件）
   * - ``vadimcn.vscode-lldb``
     - C++ LLDB 调试器
   * - ``ms-vscode.cmake-tools``
     - CMake 集成
   * - ``redhat.vscode-yaml``
     - YAML 模式验证
   * - ``Ranch-Hand-Robotics.rde-pack``
     - ROS 开发环境包
   * - ``anthropic.claude-code``
     - 可选 AI 助手

C++ IntelliSense 配置
~~~~~~~~~~~~~~~~~~~~~

`.vscode/c_cpp_properties.json:1-17 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.vscode/c_cpp_properties.json#L1-L17>`__ 配置 C++ 语言功能：

.. code:: json

   {
       "configurations": [
           {
               "name": "ROS2-Humble",
               "includePath": [
                   "${workspaceFolder}/**",
                   "/opt/ros/humble/include/**",
                   "/usr/include/**"
               ],
               "cppStandard": "c++17",
               "intelliSenseMode": "linux-gcc-x64"
           }
       ]
   }

**来源**: `.vscode/settings.json:1-33 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.vscode/settings.json#L1-L33>`__,
`.vscode/extensions.json:1-13 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.vscode/extensions.json#L1-L13>`__,
`.vscode/c_cpp_properties.json:1-17 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.vscode/c_cpp_properties.json#L1-L17>`__

--------------

构建系统和 Mixin
----------------

Colcon 工作区默认设置
~~~~~~~~~~~~~~~~~~~~

`.colcon/defaults.yaml:1-23 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.colcon/defaults.yaml#L1-L23>`__ 设置工作区范围的构建行为：

.. code:: yaml

   build:
     merge-install: true  # Single install/ directory
     event-handlers:
       - console_cohesion+  # Grouped output per package
     base-paths:
       - src

**为什么使用 ``merge-install``**：所有包合并到单个 ``install/`` 目录树中，而不是单独的 ``install/<package>`` 目录。这简化了环境加载（一个 ``setup.bash`` 而不是多个），并减少磁盘使用。

Mixin 系统架构
~~~~~~~~~~~~~~

Mixin 系统通过 `.colcon/mixin/build.mixin.yaml:1-19 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.colcon/mixin/build.mixin.yaml#L1-L19>`__ 提供可重用的构建配置：

.. mermaid::

   graph TB
       subgraph "Build Mode Mixins"
           DEBUG["debug<br/>CMAKE_BUILD_TYPE=Debug<br/>COMPILE_COMMANDS=ON"]
           RELEASE["release<br/>CMAKE_BUILD_TYPE=Release<br/>COMPILE_COMMANDS=ON"]
           REL_DEB["rel-with-deb-info<br/>CMAKE_BUILD_TYPE=RelWithDebInfo"]
       end
       
       subgraph "Testing Mixins"
           TEST["test<br/>BUILD_TESTING=ON"]
           NO_TEST["no-test<br/>BUILD_TESTING=OFF"]
           LINT["lint<br/>BUILD_TESTING=ON<br/>AMENT_LINT_AUTO=ON"]
       end
       
       subgraph "Workflow Mixins"
           DEV["dev<br/>symlink-install: true<br/>Debug + no testing"]
           PROD["prod<br/>Release + no testing<br/>TRACETOOLS_DISABLED=ON"]
       end
       
       USAGE["colcon build --mixin dev"]
       
       USAGE -.->|applies| DEV
       DEV -.->|combines| DEBUG
       DEV -.->|combines| NO_TEST

常用构建命令
~~~~~~~~~~~~


.. list-table::
   :header-rows: 1

   * - 命令
     - 用例
   * - ``colcon build --mixin dev``
     - **开发**：调试符号、符号链接安装、 快速迭代
   * - ` `colcon build --mixin release``
     - **性能测试**：优化代码、 构建较慢
   * - ``colcon build --mixin prod``
     - **生产部署**：Release + 无测试 + 无追踪
   * - ``co lcon build --mixin debug test``
     - **带调试的测试**：调试符号 + 测试目标
   * - ``colcon build --packages-select <pkg>``
     - **单个包**：仅构建指定的包及其依赖
   * - ``colcon build --packages-up-to <pkg>``
     - **包及其依赖**：构建目标包及所有 上游依赖

VS Code 构建任务
~~~~~~~~~~~~~~~~

`.vscode/tasks.json:1-26 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.vscode/tasks.json#L1-L26>`__ 定义了两个构建任务：

.. code:: json

   {
       "tasks": [
           {
               "label": "colcon build",
               "command": "source /opt/ros/humble/setup.sh && source venv/bin/activate && colcon build --symlink-install --cmake-args -DCMAKE_BUILD_TYPE=Release",
               "group": {"kind": "build", "isDefault": true}
           },
           {
               "label": "colcon build selected",
               "command": "colcon build --packages-select ${relativeFileDirname}"
           }
       ]
   }

**用法**：- ``Ctrl+Shift+B`` 触发默认的 "colcon build" 任务 - "colcon build selected" 仅构建包含当前文件的包

**来源**: `.colcon/defaults.yaml:1-23 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.colcon/defaults.yaml#L1-L23>`__,
`.colcon/mixin/build.mixin.yaml:1-19 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.colcon/mixin/build.mixin.yaml#L1-L19>`__,
`.vscode/tasks.json:1-26 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.vscode/tasks.json#L1-L26>`__

--------------

调试配置
--------

Python 节点调试
~~~~~~~~~~~~~~

`.vscode/launch.json:1-28 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.vscode/launch.json#L1-L28>`__ 提供两个 Python 调试配置：

配置 1：调试当前文件
^^^^^^^^^^^^^^^^^^^^

.. code:: json

   {
       "name": "ROS2: Debug Python Node (Current File)",
       "type": "python",
       "request": "launch",
       "program": "${file}",
       "console": "integratedTerminal",
       "env": {
           "PYTHONPATH": "libs/lerobot_ros2:venv/lib/python3.10/site-packages:/opt/ros/humble/lib/python3.10/site-packages"
       }
   }

**用法**：打开任意 Python 节点文件，按 ``F5`` 直接调试。

配置 2：特定节点（action_dispatcher_node）
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code:: json

   {
       "name": "ROS2: Action Dispatcher Node",
       "type": "python",
       "request": "launch",
       "program": "src/action_dispatch/action_dispatch/action_dispatcher_node.py",
       "args": ["--ros-args", "-p", "robot_name:=test_single_arm_single_cam"],
       "env": {
           "PYTHONPATH": "libs/lerobot_ros2:venv/lib/python3.10/site-packages:/opt/ros/humble/lib/python3.10/site-packages"
       }
   }

**用法**：从调试下拉菜单中选择 "ROS2: Action Dispatcher Node"，按 ``F5``。

调试工作流程
~~~~~~~~~~~~

.. mermaid::

   graph LR
       OPEN["Open Python node file"]
       SET_BP["Set breakpoints"]
       SELECT["Select debug configuration"]
       LAUNCH["Press F5"]
       
       DEBUG["Debugger attaches"]
       INTERACT["Inspect variables<br/>Step through code<br/>Evaluate expressions"]
       
       OPEN --> SET_BP
       SET_BP --> SELECT
       SELECT --> LAUNCH
       LAUNCH --> DEBUG
       DEBUG --> INTERACT

C++ 调试
~~~~~~~~

对于 C++ 节点（例如 ``robot_hardware`` 中的硬件插件）：

1. 使用调试符号构建：``colcon build --mixin debug``
2. 生成编译命令：由 mixin 自动启用
3. 使用 ``vadimcn.vscode-lldb`` 扩展进行调试
4. 附加到运行中的进程或通过 ``launch.json`` 启动

**来源**: `.vscode/launch.json:1-28 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.vscode/launch.json#L1-L28>`__

--------------

配置验证
--------

validate_config.py 脚本
~~~~~~~~~~~~~~~~~~~~~~~

`scripts/validate_config.py:1-351 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/scripts/validate_config.py#L1-L351>`__ 强制执行机器人配置文件之间的一致性：

.. mermaid::

   graph TB
       START["validate_config.py"]
       
       subgraph "Step 1: Load robot_config"
           LOAD_ROBOT["Load YAML<br/>so101_single_arm.yaml"]
           EXTRACT_JOINTS["Extract joints.arm<br/>joints.gripper<br/>joints.all"]
           VALIDATE_UNION{"arm ∪ gripper<br/>== all?"}
       end
       
       subgraph "Step 2: Resolve Controllers"
           RESOLVE_PATH["Resolve $(find package)<br/>from ros2_control.controllers_config"]
           LOAD_CTRL["Load controllers YAML"]
       end
       
       subgraph "Step 3: Validate Controllers"
           CHECK_ARM_POS["arm_position_controller<br/>joints == arm"]
           CHECK_ARM_TRAJ["arm_trajectory_controller<br/>joints == arm"]
           CHECK_GRIP_POS["gripper_position_controller<br/>joints == gripper"]
           CHECK_GRIP_TRAJ["gripper_trajectory_controller<br/>joints == gripper"]
           CHECK_JS_BROAD["joint_state_broadcaster<br/>joints == all"]
       end
       
       subgraph "Step 4: Validate MoveIt"
           LOAD_MOVEIT["Load moveit_controllers.yaml"]
           CHECK_MOVEIT_ARM["arm_trajectory_controller<br/>joints == arm"]
           CHECK_MOVEIT_GRIP["gripper_trajectory_controller<br/>joints == gripper"]
       end
       
       SUMMARY["Print summary:<br/>Errors + Warnings"]
       EXIT{"Errors?"}
       
       START --> LOAD_ROBOT
       LOAD_ROBOT --> EXTRACT_JOINTS
       EXTRACT_JOINTS --> VALIDATE_UNION
       VALIDATE_UNION -->|Warning if mismatch| RESOLVE_PATH
       
       RESOLVE_PATH --> LOAD_CTRL
       LOAD_CTRL --> CHECK_ARM_POS
       CHECK_ARM_POS --> CHECK_ARM_TRAJ
       CHECK_ARM_TRAJ --> CHECK_GRIP_POS
       CHECK_GRIP_POS --> CHECK_GRIP_TRAJ
       CHECK_GRIP_TRAJ --> CHECK_JS_BROAD
       
       CHECK_JS_BROAD --> LOAD_MOVEIT
       LOAD_MOVEIT --> CHECK_MOVEIT_ARM
       CHECK_MOVEIT_ARM --> CHECK_MOVEIT_GRIP
       
       CHECK_MOVEIT_GRIP --> SUMMARY
       SUMMARY --> EXIT
       EXIT -->|Yes| FAIL["Exit code 1"]
       EXIT -->|No| SUCCESS["Exit code 0"]

执行的验证检查
~~~~~~~~~~~~~~


.. list-table::
   :header-rows: 1

   * - 配置文件
     - 检查的控制器
     - 预期关节
   * - ``controllers.yaml``
     - ``arm_ position_controller``
     - ``joints.arm``
   * - ``controllers.yaml``
     - ``arm_tr ajectory_controller``
     - ``joints.arm``
   * - ``controllers.yaml``
     - ``gripper_ position_controller``
     - ``joints.gripper``
   * - ``controllers.yaml``
     - ``gripper_tr ajectory_controller``
     - ``joints.gripper``
   * - ``controllers.yaml``
     - ``join t_state_broadcaster``
     - ``joints.all``
   * - ``move it_controllers.yaml``
     - ``arm_tr ajectory_controller``
     - ``joints.arm``
   * - ``move it_controllers.yaml``
     - ``gripper_tr ajectory_controller``
     - ``joints.gripper``

运行验证
~~~~~~~~

.. code:: bash

   # Default: validate src/robot_config/config/robots/so101_single_arm.yaml
   python scripts/validate_config.py

   # Verbose output
   python scripts/validate_config.py --verbose

   # Custom robot config
   python scripts/validate_config.py --robot-config path/to/robot.yaml

   # Specify MoveIt config explicitly
   python scripts/validate_config.py --moveit-config path/to/moveit_controllers.yaml

CI/CD 集成
~~~~~~~~~~

退出代码：- ``0``：所有验证通过 - ``1``：发现配置错误 - ``2``：文件未找到或解析错误

**在 CI 中使用**：

.. code:: yaml

   - name: Validate Configuration
     run: python scripts/validate_config.py
     # Fails build if exit code != 0

**来源**: `scripts/validate_config.py:1-351 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/scripts/validate_config.py#L1-L351>`__

--------------

贡献工作流程
------------

Git 提交规范
~~~~~~~~~~~~

工作区使用 ``gitlint`` 进行提交消息验证，由 `scripts/setup.sh:264-268 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/scripts/setup.sh#L264-L268>`__ 安装：

.. code:: bash

   pip install gitlint
   gitlint install-hook  # Installs pre-commit hook

**提交消息格式**\ （由 gitlint 强制执行）：

::

   <type>(<scope>): <subject>

   <body>

   <footer>

**示例**：

::

   feat(inference): add distributed execution mode

   Implement device-edge-cloud architecture for compute offloading.
   TensorPreprocessor runs on robot CPU, PureInferenceEngine on GPU server.

   Closes #42

开发周期
~~~~~~~~

.. mermaid::

   graph TB
       FORK["Fork repository<br/>on GitCode"]
       CLONE["Clone your fork"]
       SETUP["Run setup.sh"]
       
       BRANCH["Create feature branch<br/>git checkout -b feat/xyz"]
       CODE["Make changes"]
       TEST["Test locally"]
       
       VALIDATE["Run validate_config.py"]
       LINT["Lint checks (gitlint)"]
       COMMIT["git commit -m 'feat: ...'"]
       
       PUSH["git push origin feat/xyz"]
       PR["Create Pull Request"]
       
       FORK --> CLONE
       CLONE --> SETUP
       SETUP --> BRANCH
       BRANCH --> CODE
       CODE --> TEST
       TEST --> VALIDATE
       VALIDATE --> LINT
       LINT --> COMMIT
       COMMIT --> PUSH
       PUSH --> PR
       
       PR -.->|Review feedback| CODE

分支命名约定
~~~~~~~~~~~~

============= ================== ======================================
前缀          用途               示例
============= ================== ======================================
``feat/``     新功能             ``feat/add-depth-camera-support``
``fix/``      错误修复           ``fix/action-queue-overflow``
``refactor/`` 代码重构           ``refactor/split-preprocessor-module``
``docs/``     文档               ``docs/update-inference-guide``
``test/``     测试添加           ``test/add-temporal-smoother-tests``
============= ================== ======================================

提交前检查清单
~~~~~~~~~~~~~~

推送前：

1. **构建通过**：``colcon build --mixin dev``
2. **配置有效**：``python scripts/validate_config.py``
3. **测试通过**：``colcon test --packages-select <modified-packages>``
4. **代码格式化**：遵循 ROS 2 Python 风格指南
5. **提交消息**：遵循 gitlint 约定
6. **子模块更新**：如果修改了子模块，单独提交子模块更新

**来源**: `scripts/setup.sh:264-268 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/scripts/setup.sh#L264-L268>`__

--------------

快速参考
--------

环境激活
~~~~~~~~

.. code:: bash

   # Source ROS 2
   source /opt/ros/humble/setup.sh

   # Activate venv
   source venv/bin/activate

   # Source workspace
   source install/setup.bash

常用开发命令
~~~~~~~~~~~~


.. list-table::
   :header-rows: 1

   * - 任务
     - 命令
   * - **完整构建**
     - ``colcon build --mixin dev``
   * - **单个包**
     - ``co lcon build --packages-select robot_config``
   * - **清理构建**
     - ``rm -rf build/ install/ log/ && colcon build --mixin dev``
   * - **运行验证**
     - ``py thon scripts/validate_config.py --verbose``
   * - **更新子模块**
     - ``git submodule update --remote --merge``
   * - **格式化 Python**
     - ``black src/<package>/<package>/*.py``（如 已配置）
   * - **列出包**
     - ``colcon list``

故障排除
~~~~~~~~


.. list-table::
   :header-rows: 1

   * - 问题
     - 解决方案
   * - **rclpy 导入错误**
     - 确保使用 ``--system-site-packages`` 创建 venv
   * - **NumPy 版本冲突**
     - 在 venv 中执行 ``pip install "numpy<2"``
   * - **子模块未初始化**
     - ``gi t submodule update --init --recursive``
   * - **VS Code 无法找到导入**
     - 检查 ``.vscode/settings.json`` extraPaths
   * - **构建失败并出现 mixin 错误**
     - 确保 ``.colcon/mixin/`` 文件存在
   * - **配置验证失败**
     - 检查 YAML 文件中的关节定义是否一致

**来源**: `scripts/setup.sh:1-307 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/scripts/setup.sh#L1-L307>`__,
`.vscode/settings.json:1-33 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.vscode/settings.json#L1-L33>`__,
`.colcon/mixin/build.mixin.yaml:1-19 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.colcon/mixin/build.mixin.yaml#L1-L19>`__

--------------



构建项目
========

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
-  `README.en.md <README.en.md>`__
-  `README.md <README.md>`__
-  `docs/architecture.md <docs/architecture.md>`__
-  `/image/architecture.png </image/architecture.png>`__
-  `docs/roadmap.md <docs/roadmap.md>`__
-  `scripts/build.sh <scripts/build.sh>`__
-  `scripts/validate_config.py <scripts/validate_config.py>`__
-  `src/README.md <src/README.md>`__
-  `src/action_dispatch/README.en.md <src/action_dispatch/README.en.md>`__
-  `src/action_dispatch/README.md <src/action_dispatch/README.md>`__

.. raw:: html

   </details>

本页介绍如何使用 ``colcon`` 构建系统构建 IB-Robot 工作区，通过 mixin 配置构建选项，以及将构建过程与 VS Code 集成以实现高效开发工作流。

有关环境设置说明（虚拟环境创建、子模块初始化和依赖安装），请参阅 `环境设置 <#2.1>`__。

--------------

构建系统概述
------------

IB-Robot 使用 ``colcon``，即标准的 ROS 2 构建工具，在工作区中编译 C++ 包并安装 Python 包。构建系统通过工作区默认设置、自定义 mixin 和统一的 ``build.sh`` 脚本的组合进行配置。

**关键组件：** - ``colcon``: 编排 CMake（C++）和 setuptools（Python）的元构建系统 - **工作区默认设置**: `.colcon/defaults.yaml:1-23 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.colcon/defaults.yaml#L1-L23>`__ 提供工作区范围设置 - **Mixin 系统**: `.colcon/mixin/build.mixin.yaml:1-19 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.colcon/mixin/build.mixin.yaml#L1-L19>`__ 定义可重用的构建配置 - **构建脚本**: `scripts/build.sh:1-229 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/scripts/build.sh#L1-L229>`__ 封装 colcon 并提供便捷功能

构建系统架构
~~~~~~~~~~~~

.. mermaid::

   graph TB
       Developer["Developer"]
       
       subgraph "Build Entry Points"
           BuildScript["build.sh<br/>(scripts/build.sh)"]
           DirectColcon["colcon build<br/>(direct invocation)"]
           VSCodeTask["VS Code Task<br/>(.vscode/tasks.json)"]
       end
       
       subgraph "Configuration Layer"
           Defaults[".colcon/defaults.yaml<br/>workspace settings"]
           MixinIndex[".colcon/mixin/index.yaml"]
           MixinDefs[".colcon/mixin/build.mixin.yaml<br/>build configs"]
       end
       
       subgraph "Virtual Environment"
           VenvSetup["venv activation<br/>(venv/bin/activate)"]
           LeRobotInstall["lerobot editable install<br/>(libs/lerobot)"]
           NumpyAlign["numpy<2 opencv<4.12<br/>(ROS 2 Humble compat)"]
       end
       
       subgraph "Build Execution"
           ColconCore["colcon build<br/>(merge-install)"]
           CMake["CMake<br/>(C++ packages)"]
           Setuptools["setuptools<br/>(Python packages)"]
       end
       
       subgraph "Output"
           BuildDir["build/<br/>(intermediate)"]
           InstallDir["install/<br/>(final artifacts)"]
           LogDir["log/<br/>(build logs)"]
       end
       
       Developer --> BuildScript
       Developer --> VSCodeTask
       Developer --> DirectColcon
       
       BuildScript --> VenvSetup
       BuildScript --> MixinIndex
       VenvSetup --> LeRobotInstall
       LeRobotInstall --> NumpyAlign
       
       MixinIndex --> MixinDefs
       MixinDefs --> ColconCore
       Defaults --> ColconCore
       DirectColcon --> ColconCore
       VSCodeTask --> ColconCore
       
       NumpyAlign --> ColconCore
       
       ColconCore --> CMake
       ColconCore --> Setuptools
       
       CMake --> BuildDir
       Setuptools --> BuildDir
       BuildDir --> InstallDir
       ColconCore --> LogDir

**来源**: `scripts/build.sh:1-229 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/scripts/build.sh#L1-L229>`__,
`.colcon/defaults.yaml:1-23 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.colcon/defaults.yaml#L1-L23>`__,
`.colcon/mixin/build.mixin.yaml:1-19 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.colcon/mixin/build.mixin.yaml#L1-L19>`__,
`.vscode/tasks.json:1-26 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.vscode/tasks.json#L1-L26>`__

--------------

使用构建脚本
------------

``build.sh`` 脚本是构建工作区的推荐方式。它处理虚拟环境激活、依赖安装和构建配置。

基本用法
~~~~~~~~

.. code:: bash

   # 默认开发构建（debug + symlink-install + no tests）
   ./scripts/build.sh

   # 发布构建（优化）
   ./scripts/build.sh --mixin release

   # 调试构建并启用测试
   ./scripts/build.sh --mixin debug test

   # 清理构建（删除 CMake 缓存）
   ./scripts/build.sh --clean --mixin release

命令行选项
~~~~~~~~~~


.. list-table::
   :header-rows: 1

   * - 选项
     - 描述
     - 示例
   * - ``--mixin NAME [NAME...]``
     - 应用一个或多个构建 mixin
     - ``--mi xin release test``
   * - ` `--list-mixins``
     - 显示可用的 mixin 并 退出
     - ``--list-mixins``
   * - ``--clean``
     - 清理构建（运行 ``cmake-clean-cache``）
     - ``--clean``
   * - ``--this``
     - 仅构建当前目录中的 包
     - ``--this``
   * - ` `-v, --verbose``
     - 显示详细构建输出
     - ``-v``
   * - ``-h, --help``
     - 显示帮助信息
     - ``--help``
   * - ``-- ARGS...``
     - 传递额外参数给 colcon
     - ``-- --packages- select tensormsg``

**来源**: `scripts/build.sh:20-51 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/scripts/build.sh#L20-L51>`__

构建脚本工作流
~~~~~~~~~~~~~~

.. mermaid::

   sequenceDiagram
       participant User
       participant BuildScript as "build.sh"
       participant Venv as "Virtual Environment"
       participant LeRobot as "libs/lerobot"
       participant Colcon as "colcon build"
       
       User->>BuildScript: ./scripts/build.sh --mixin release
       
       BuildScript->>BuildScript: Parse arguments<br/>(lines 78-117)
       BuildScript->>Venv: Check for venv in workspace<br/>(lines 126-140)
       
       alt venv found
           BuildScript->>Venv: source venv/bin/activate
           BuildScript->>Venv: Ensure pyserial, feetech-sdk<br/>(lines 142-154)
       end
       
       BuildScript->>LeRobot: Check libs/lerobot exists
       alt lerobot found
           BuildScript->>LeRobot: pip install -e libs/lerobot<br/>(line 172)
           BuildScript->>Venv: Force numpy<2, opencv<4.12<br/>(line 177)
       end
       
       BuildScript->>BuildScript: source /opt/ros/humble/setup.sh<br/>(line 183)
       BuildScript->>BuildScript: Build mixin arguments<br/>(lines 192-196)
       
       BuildScript->>Colcon: colcon build<br/>--mixin release<br/>--merge-install<br/>--symlink-install
       Colcon->>Colcon: Process src/ packages
       Colcon-->>BuildScript: Build complete
       
       BuildScript-->>User: "Build complete. Source with: source install/setup.sh"

**来源**: `scripts/build.sh:78-229 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/scripts/build.sh#L78-L229>`__

--------------

Mixin 系统
----------

Mixin 提供可组合的可重用构建配置。
IB-Robot 在 `.colcon/mixin/build.mixin.yaml:1-19 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.colcon/mixin/build.mixin.yaml#L1-L19>`__ 中定义工作区本地 mixin。

可用的 Mixin
~~~~~~~~~~~~


.. list-table::
   :header-rows: 1

   * - Mixin
     - CMake 构建 类型
     - 测试
     - 编译命令
     - 使用场景
   * - ``dev``
     - Debug
     - OFF
     - ON
     - ***默认**： 快速增量 构建开发
   * - ``debug``
     - Debug
     - -
     - ON
     - 带完整符号 调试
   * - ``release``
     - Release
     - -
     - ON
     - 优化的生产 构建
   * - ``rel-with -deb-info``
     - Rel WithDebInfo
     - -
     - ON
     - 带调试符号 的优化构建
   * - ``test``
     - -
     - ON
     - -
     - 启用测试 目标
   * - ``no-test``
     - -
     - OFF
     - -
     - 禁用测试 目标
   * - ``lint``
     - -
     - ON + Linting
     - -
     - CI 代码检查
   * - ``prod``
     - Release
     - OFF
     - -
     - 生产 （无调试， 无追踪）

**来源**: `.colcon/mixin/build.mixin.yaml:2-18 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.colcon/mixin/build.mixin.yaml#L2-L18>`__

Mixin 组合
~~~~~~~~~~

多个 mixin 可以组合以创建自定义构建配置：

.. code:: bash

   # 调试构建并启用测试和 Address Sanitizer（如存在 ASan mixin）
   ./scripts/build.sh --mixin debug test asan

   # 发布构建不带测试（用于部署）
   ./scripts/build.sh --mixin release no-test

Mixin 继承链
~~~~~~~~~~~~

.. mermaid::

   graph LR
       subgraph "Workspace Defaults"
           DefaultMerge["merge-install: true"]
           DefaultBase["base-paths: [src]"]
           DefaultEvents["event-handlers:<br/>console_cohesion+"]
       end
       
       subgraph "Mixin: dev (Default)"
           DevDebug["CMAKE_BUILD_TYPE=Debug"]
           DevSymlink["symlink-install: true"]
           DevNoTest["BUILD_TESTING=OFF"]
           DevCompileCmd["EXPORT_COMPILE_COMMANDS=ON"]
       end
       
       subgraph "Mixin: release"
           RelRelease["CMAKE_BUILD_TYPE=Release"]
           RelCompileCmd["EXPORT_COMPILE_COMMANDS=ON"]
       end
       
       subgraph "Mixin: test"
           TestOn["BUILD_TESTING=ON"]
       end
       
       subgraph "Final colcon Command"
           ColconCmd["colcon build<br/>--merge-install<br/>--symlink-install<br/>--base-paths src<br/>--event-handlers console_cohesion+<br/>--cmake-args<br/>-DCMAKE_BUILD_TYPE=Release<br/>-DCMAKE_EXPORT_COMPILE_COMMANDS=ON<br/>-DBUILD_TESTING=ON"]
       end
       
       DefaultMerge --> ColconCmd
       DefaultBase --> ColconCmd
       DefaultEvents --> ColconCmd
       
       RelRelease --> ColconCmd
       RelCompileCmd --> ColconCmd
       TestOn --> ColconCmd
       
       style DevDebug fill:#e0e0e0
       style DevSymlink fill:#e0e0e0
       style DevNoTest fill:#e0e0e0
       style DevCompileCmd fill:#e0e0e0

**示例**: ``./scripts/build.sh --mixin release test`` 组合工作区默认设置与 ``release`` 和 ``test`` mixin。

**来源**: `.colcon/defaults.yaml:5-18 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.colcon/defaults.yaml#L5-L18>`__,
`.colcon/mixin/build.mixin.yaml:3-18 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.colcon/mixin/build.mixin.yaml#L3-L18>`__,
`scripts/build.sh:192-226 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/scripts/build.sh#L192-L226>`__

--------------

虚拟环境集成
------------

构建脚本自动管理 Python 虚拟环境，将 ML 依赖与 ROS 2 系统安装隔离。

依赖安装流程
~~~~~~~~~~~~

.. mermaid::

   graph TB
       Start["Build script starts"]
       
       subgraph "venv Setup (lines 125-157)"
           CheckVenv{"venv exists?"}
           ActivateVenv["Activate venv<br/>(source venv/bin/activate)"]
           CheckPySerial{"pyserial<br/>installed?"}
           InstallPySerial["pip install pyserial"]
           CheckFeetech{"feetech-servo-sdk<br/>installed?"}
           InstallFeetech["pip install feetech-servo-sdk"]
       end
       
       subgraph "LeRobot Setup (lines 162-178)"
           CheckLeRobot{"libs/lerobot<br/>exists?"}
           VenvPipCheck{"venv/bin/pip<br/>exists?"}
           InstallLeRobot["pip install -e libs/lerobot"]
           ForceNumpy["pip install numpy<2<br/>opencv-python-headless<4.12"]
       end
       
       subgraph "ROS 2 Environment"
           SourceROS["source /opt/ros/humble/setup.sh"]
           SourceInstall["source install/setup.sh<br/>(if exists)"]
       end
       
       Start --> CheckVenv
       CheckVenv -->|Yes| ActivateVenv
       CheckVenv -->|No| CheckLeRobot
       ActivateVenv --> CheckPySerial
       CheckPySerial -->|No| InstallPySerial
       CheckPySerial -->|Yes| CheckFeetech
       InstallPySerial --> CheckFeetech
       CheckFeetech -->|No| InstallFeetech
       CheckFeetech -->|Yes| CheckLeRobot
       InstallFeetech --> CheckLeRobot
       
       CheckLeRobot -->|Yes| VenvPipCheck
       CheckLeRobot -->|No| SourceROS
       VenvPipCheck -->|Yes| InstallLeRobot
       VenvPipCheck -->|No| SourceROS
       InstallLeRobot --> ForceNumpy
       ForceNumpy --> SourceROS
       
       SourceROS --> SourceInstall
       SourceInstall --> ColconBuild["Execute colcon build"]

**关键修复**: 第 176-177 行强制安装 ``numpy<2`` 和 ``opencv-python-headless<4.12`` 以确保 ROS 2 Humble 兼容性。NumPy 2.x 由于 ABI 更改会破坏许多 ROS 2 包。

**来源**: `scripts/build.sh:125-178 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/scripts/build.sh#L125-L178>`__

--------------

VS Code 集成
------------

VS Code 配置为通过任务、Python 环境检测和 C++ IntelliSense 与 IB-Robot 构建系统无缝协作。

Python 环境配置
~~~~~~~~~~~~~~~~

工作区配置为自动使用 ``venv`` Python 解释器：


.. list-table::
   :header-rows: 1

   * - 设置
     - 值
     - 用途
   * - ``python.de faultInterpreterPath``
     - ``${w orkspaceFolder}/v env/bin/python3``
     - 使用 venv Python
   * - ``python .analysis.extraPaths``
     - ``li bs/lerobot/src``, ``src``, ROS 2 paths
     - 启用导入
   * - ``python.aut oComplete.extraPaths``
     - 同上
     - 启用自动补全
   * - ``terminal. integrated.env.linux``
     - ` `PYTHONPATH=...``
     - 在终端中注入 PYTHONPATH

**来源**: `.vscode/settings.json:2-18 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.vscode/settings.json#L2-L18>`__

构建任务
~~~~~~~~

预配置了两个构建任务：

**1. 完整工作区构建**\ （默认任务，Ctrl+Shift+B）:

.. code:: json

   {
       "label": "colcon build",
       "command": "source /opt/ros/humble/setup.sh && source venv/bin/activate && colcon build --symlink-install --cmake-args -DCMAKE_BUILD_TYPE=Release"
   }

**2. 构建当前包**\ （选择性构建）:

.. code:: json

   {
       "label": "colcon build selected",
       "command": "source /opt/ros/humble/setup.sh && source venv/bin/activate && colcon build --symlink-install --packages-select ${relativeFileDirname}"
   }

**来源**: `.vscode/tasks.json:4-25 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.vscode/tasks.json#L4-L25>`__

C++ IntelliSense 配置
~~~~~~~~~~~~~~~~~~~~~

工作区包含 ROS 2 和系统包含路径以实现准确的代码导航：

.. code:: json

   {
       "includePath": [
           "${workspaceFolder}/**",
           "/opt/ros/humble/include/**",
           "/usr/include/**"
       ],
       "cppStandard": "c++17",
       "intelliSenseMode": "linux-gcc-x64"
   }

**来源**: `.vscode/c_cpp_properties.json:4-14 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.vscode/c_cpp_properties.json#L4-L14>`__

调试配置
~~~~~~~~

提供了两个用于调试 Python 节点的启动配置：

**1. 调试当前文件**:

.. code:: json

   {
       "name": "ROS2: Debug Python Node (Current File)",
       "type": "python",
       "program": "${file}",
       "env": {
           "PYTHONPATH": "..."
       }
   }

**2. 调试动作分发器节点**:

.. code:: json

   {
       "name": "ROS2: Action Dispatcher Node",
       "program": "${workspaceFolder}/src/action_dispatch/action_dispatch/action_dispatcher_node.py",
       "args": ["--ros-args", "-p", "robot_name:=test_single_arm_single_cam"]
   }

**来源**: `.vscode/launch.json:4-27 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.vscode/launch.json#L4-L27>`__

--------------

常用构建工作流
--------------

首次构建
~~~~~~~~

运行 ``setup.sh`` 后（见 `环境设置 <#2.1>`__）:

.. code:: bash

   # 完整工作区构建（默认 dev 模式）
   ./scripts/build.sh

   # Source 安装
   source install/setup.sh

   # 验证构建
   ros2 pkg list | grep -E "(robot_config|tensormsg|action_dispatch)"

增量开发构建
~~~~~~~~~~~~

修改代码时：

.. code:: bash

   # 使用 symlink-install 重新构建（Python 更改立即生效）
   ./scripts/build.sh

   # 对于 C++ 更改，仅重新构建受影响的包
   ./scripts/build.sh -- --packages-select so101_hardware

   # 或使用 VS Code：按 Ctrl+Shift+B

清理发布构建
~~~~~~~~~~~~

测试部署配置时：

.. code:: bash

   # 清理所有 CMake 缓存并优化重新构建
   ./scripts/build.sh --clean --mixin release

   # 验证无调试符号
   file install/lib/so101_hardware/libso101_hardware.so
   # 应仅在调试构建中显示 "not stripped"

测试构建
~~~~~~~~

运行测试时：

.. code:: bash

   # 启用测试构建
   ./scripts/build.sh --mixin test

   # 运行所有测试
   colcon test --packages-select tensormsg

   # 查看测试结果
   colcon test-result --verbose

构建单个包
~~~~~~~~~~

处理特定包时：

.. code:: bash

   # 选项 1：使用 build.sh
   ./scripts/build.sh -- --packages-select action_dispatch

   # 选项 2：从包目录
   cd src/action_dispatch
   ../../scripts/build.sh --this

   # 选项 3：直接使用 colcon（必须先 source 环境）
   source .shrc_local
   colcon build --packages-select action_dispatch --symlink-install

--------------

构建输出结构
------------

::

   IB_Robot/
   ├── build/                    # 中间构建产物（CMake 缓存、目标文件）
   │   ├── action_dispatch/
   │   ├── tensormsg/
   │   └── so101_hardware/
   ├── install/                  # 最终安装（source 此目录）
   │   ├── setup.sh             # 主设置脚本（source 所有包）
   │   ├── local_setup.sh       # 本地设置（仅此工作区）
   │   ├── lib/                 # 编译的库和可执行文件
   │   │   ├── python3.10/site-packages/  # Python 包
   │   │   └── so101_hardware/  # C++ 库
   │   └── share/               # 包资源（启动文件、配置等）
   │       ├── robot_config/
   │       ├── robot_description/
   │       └── robot_moveit/
   └── log/                      # 构建和测试日志
       └── latest_build/
           ├── events.log       # 构建事件时间线
           └── logger_all.log   # 所有包的组合输出

**关键文件**: - ``install/setup.sh``: 每次构建后 source 此文件以更新环境变量 - ``log/latest_build/logger_all.log``: 检查此文件以查看构建错误 - ``build/*/compile_commands.json``: 被 clangd/IntelliSense 用于 C++ 代码分析

**来源**: `.gitignore:1-9 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.gitignore#L1-L9>`__, `scripts/build.sh:189-229 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/scripts/build.sh#L189-L229>`__

--------------

故障排除
--------

构建失败并出现导入错误
~~~~~~~~~~~~~~~~~~~~~~

**症状**: ``ModuleNotFoundError: No module named 'lerobot'``

**原因**: 虚拟环境未激活或 lerobot 未以可编辑模式安装。

**解决方法**:

.. code:: bash

   # 确保 venv 已激活
   source venv/bin/activate

   # 重新安装 lerobot
   pip install -e libs/lerobot

   # 重新构建
   ./scripts/build.sh

CMake 缓存损坏
~~~~~~~~~~~~~~

**症状**: 构建失败并显示 "CMake Error: … does not match …"

**解决方法**:

.. code:: bash

   # 清理所有 CMake 缓存
   ./scripts/build.sh --clean

   # 或手动删除 build 目录
   rm -rf build/ install/
   ./scripts/build.sh

NumPy 版本冲突
~~~~~~~~~~~~~~

**症状**: ``ImportError: numpy.core.multiarray failed to import`` 或类似的 ABI 错误

**原因**: NumPy 2.x 与 ROS 2 Humble 的预编译绑定不兼容。

**解决方法**: 构建脚本在第 177 行自动安装 ``numpy<2``。如果问题持续：

.. code:: bash

   source venv/bin/activate
   pip install --force-reinstall "numpy<2" "opencv-python-headless<4.12"

VS Code IntelliSense 不工作
~~~~~~~~~~~~~~~~~~~~~~~~~~~

**症状**: 尽管构建成功，VS Code 中仍显示导入错误。

**解决方法**: 1. 重新加载 VS Code: ``Ctrl+Shift+P`` → "Developer: Reload Window" 2. 选择正确的 Python 解释器: ``Ctrl+Shift+P`` → "Python: Select Interpreter" → ``venv/bin/python3`` 3. 验证终端中的 ``PYTHONPATH``: ``echo $PYTHONPATH`` 应包含 ``libs/lerobot/src``

**来源**: `scripts/build.sh:162-178 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/scripts/build.sh#L162-L178>`__, `README.md:172-186 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L172-L186>`__

构建系统与 Mixin
================

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

目的与范围
----------

本文档介绍 IB-Robot 工作区中使用的 colcon 构建系统配置和 mixin 系统。内容包括工作区级默认设置、不同配置（debug、release、dev、prod）的构建 mixin，以及用于简化开发的 VS Code 集成。

有关初始环境设置和首次构建项目，请参阅 `入门指南 <#2>`__。有关构建任务之外的 VS Code 特定开发设置，请参阅 `VS Code 配置 <#13.1>`__。有关调试配置，请参阅 `调试与测试 <#13.3>`__。

--------------

构建系统概述
------------

IB-Robot 工作区使用 **colcon**\ （集体构建），这是标准的 ROS2 构建工具，可协调具有不同构建系统（C++ 使用 CMake，Python 使用 setuptools）的多个包的构建。Colcon 提供工作区级配置、依赖管理和并行构建。

工作区目录结构
~~~~~~~~~~~~~~

::

   IB_Robot/
   ├── src/                    # 源码包
   │   ├── robot_config/
   │   ├── inference_service/
   │   └── ...
   ├── build/                  # 中间构建产物 (git-ignored)
   ├── install/                # 带覆盖的安装空间 (git-ignored)
   ├── log/                    # 构建和测试日志 (git-ignored)
   ├── venv/                   # Python 虚拟环境 (git-ignored)
   ├── .colcon/                # 工作区级 colcon 配置
   │   ├── defaults.yaml       # 默认 colcon 参数
   │   └── mixin/              # 本地 mixin 定义
   │       ├── index.yaml
   │       └── build.mixin.yaml
   └── .vscode/
       └── tasks.json          # VS Code 构建任务

工作区遵循标准的 ROS2 覆盖模式，其中 ``install/`` 包含已构建的包及其设置脚本。``build/`` 目录包含 CMake 产物和 Python 构建元数据，而 ``log/`` 存储详细的构建和测试输出。

**来源:** `.gitignore:1-20 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.gitignore#L1-L20>`__, `.colcon/defaults.yaml:1-23 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.colcon/defaults.yaml#L1-L23>`__

--------------

工作区默认配置
--------------

``.colcon/defaults.yaml`` 中的工作区级默认设置自动应用于所有 colcon 命令，无需重复指定常用参数。

默认构建配置
~~~~~~~~~~~~

.. mermaid::

   graph TB
       subgraph "Workspace Defaults Application"
           CMD["colcon build"]
           DEFAULTS[".colcon/defaults.yaml"]
           
           subgraph "Applied Settings"
               MERGE["merge-install: true<br/>Single install/ tree"]
               EVENTS["event-handlers:<br/>console_cohesion+"]
               BASEPATH["base-paths:<br/>- src"]
           end
           
           EXPANDED["Expanded Command:<br/>colcon build --merge-install<br/>--base-paths src<br/>--event-handlers console_cohesion+"]
       end
       
       CMD --> DEFAULTS
       DEFAULTS --> MERGE
       DEFAULTS --> EVENTS
       DEFAULTS --> BASEPATH
       MERGE --> EXPANDED
       EVENTS --> EXPANDED
       BASEPATH --> EXPANDED

**图：工作区默认设置自动展开**

关键默认设置
~~~~~~~~~~~~


.. list-table::
   :header-rows: 1

   * - 设置
     - 值
     - 用途
   * - ``merge-install``
     - ``true``
     - 将所有包合并到单个 ``install/`` 目录， 而非独立的 ``install/<package>`` 目录。简化环境 source 操作。
   * - ``event-handlers``
     - ``co nsole_cohesion+``
     - 按包分组控制台输出， 使并行构建日志 更易读。
   * - ``base-paths``
     - ``src``
     - 指定源码包目录 （允许多个源树）。

``merge-install`` 设置特别重要，因为它创建了扁平的 ``install/`` 结构，简化了覆盖设置并减少了需要 source 的设置脚本数量。

**来源:** `.colcon/defaults.yaml:5-18 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.colcon/defaults.yaml#L5-L18>`__

--------------

构建 Mixin 系统
----------------

什么是 Mixin？
~~~~~~~~~~~~~~~~~~~~~~

Mixin 是存储在 YAML 文件中的可重用 colcon 命令行参数集。它们使开发者能够在不同构建配置（debug、release、development、production）之间切换，而无需记住复杂的参数列表。Mixin 是可组合的——多个 mixin 可以在单个构建命令中组合使用。

Mixin 架构
~~~~~~~~~~

.. mermaid::

   graph LR
       subgraph "Mixin Definition"
           INDEX[".colcon/mixin/index.yaml"]
           BUILD_MIXIN[".colcon/mixin/build.mixin.yaml"]
           
           INDEX -->|"references"| BUILD_MIXIN
       end
       
       subgraph "Mixin Usage"
           USER_CMD["colcon build<br/>--mixin dev"]
           LOOKUP["Mixin Lookup"]
           RESOLVED["Resolved Arguments:<br/>--symlink-install<br/>-DCMAKE_BUILD_TYPE=Debug<br/>-DCMAKE_EXPORT_COMPILE_COMMANDS=ON<br/>-DBUILD_TESTING=OFF"]
           
           USER_CMD --> LOOKUP
           LOOKUP --> BUILD_MIXIN
           BUILD_MIXIN --> RESOLVED
       end
       
       subgraph "CMake Invocation"
           CMAKE["cmake invocation with<br/>resolved flags"]
           RESOLVED --> CMAKE
       end

**图：Mixin 解析与应用流程**

位于 ``.colcon/mixin/index.yaml`` 的 mixin 索引声明可用的 mixin 文件，而 ``build.mixin.yaml`` 包含实际的 mixin 定义。

**来源:** `.colcon/mixin/index.yaml:1-4 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.colcon/mixin/index.yaml#L1-L4>`__,
`.colcon/mixin/build.mixin.yaml:1-19 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.colcon/mixin/build.mixin.yaml#L1-L19>`__

可用的构建 Mixin
----------------

工作区提供了多个预配置的 mixin，针对不同的开发和部署场景进行了优化。所有 mixin 都启用 ``CMAKE_EXPORT_COMPILE_COMMANDS`` 以支持 IDE 集成（clangd、IntelliSense）。

构建配置 Mixin
~~~~~~~~~~~~~~


.. list-table::
   :header-rows: 1

   * - Mixin 名称
     - CMake 构建
     - 符号链接 安装
     - 测试
     - 使用场景
   * - ``debug``
     - Debug
     - 否
     - 默认
     - 带调试符号 调试，无优化
   * - ``release``
     - Release
     - 否
     - 默认
     - 完全优化， 无调试符号
   * - ``rel-wit h-deb-info``
     - Re lWithDebInfo
     - 否
     - 默认
     - 优化但可调试
   * - ``dev``
     - Debug
     - **是**
     - OFF
     - 快速迭代开发 （符号链接 Python 文件）
   * - ``prod``
     - Release
     - 否
     - OFF
     - 生产部署 （禁用追踪）

测试与代码检查 Mixin
~~~~~~~~~~~~~~~~~~~~


.. list-table::
   :header-rows: 1

   * - Mixin 名称
     - CMake 参数
     - 用途
   * - ``test``
     - ``-DBUILD_TESTING=ON``
     - 启用测试目标构建
   * - ``no-test``
     - ``-DBUILD_TESTING=OFF``
     - 跳过测试构建（更快）
   * - ``lint``
     - ``-DBUILD_TESTING=O N -DAMENT_LINT_AUTO=ON``
     - 启用代码检查

Mixin 定义参考
~~~~~~~~~~~~~~

开发 Mixin (``dev``)
^^^^^^^^^^^^^^^^^^^^

.. code:: yaml

   dev:
     symlink-install: true
     cmake-args: 
       - "-DCMAKE_BUILD_TYPE=Debug"
       - "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON"
       - "-DBUILD_TESTING=OFF"

**用途:** 开发过程中的快速迭代。``symlink-install`` 标志在 ``install/`` 中创建指向 Python 源文件的符号链接，因此对 ``.py`` 文件的更改立即生效，无需重新构建。启用调试符号用于调试。禁用测试以减少构建时间。

**用法:** ``colcon build --mixin dev``

生产 Mixin (``prod``)
^^^^^^^^^^^^^^^^^^^^^

.. code:: yaml

   prod:
     cmake-args:
       - "-DCMAKE_BUILD_TYPE=Release"
       - "-DBUILD_TESTING=OFF"
       - "-DTRACETOOLS_DISABLED=ON"

**用途:** 优化的生产构建。完全编译器优化（``-O3``），无调试符号，禁用测试，禁用 ROS2 追踪以最小化开销。

**用法:** ``colcon build --mixin prod``

调试 Mixin (``debug``)
^^^^^^^^^^^^^^^^^^^^^^

.. code:: yaml

   debug:
     cmake-args:
       - "-DCMAKE_BUILD_TYPE=Debug"
       - "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON"

**用途:** 带符号且无优化的标准调试配置。适用于 GDB/LLDB 调试。

**用法:** ``colcon build --mixin debug``

发布 Mixin (``release``)
^^^^^^^^^^^^^^^^^^^^^^^^

.. code:: yaml

   release:
     cmake-args:
       - "-DCMAKE_BUILD_TYPE=Release"
       - "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON"

**用途:** 带编译命令的优化发布构建，用于 IDE 支持。用于基准测试和性能测试。

**用法:** ``colcon build --mixin release``

**来源:** `.colcon/mixin/build.mixin.yaml:1-19 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.colcon/mixin/build.mixin.yaml#L1-L19>`__

组合 Mixin
----------

Mixin 可以组合以创建自定义配置。参数会合并，如果存在冲突，后面的 mixin 会覆盖前面的。

常用 Mixin 组合
~~~~~~~~~~~~~~~

.. code:: bash

   # 启用测试的开发构建
   colcon build --mixin dev test

   # 带代码检查的发布构建
   colcon build --mixin release lint

   # 排除特定包的调试构建
   colcon build --mixin debug --packages-skip robot_moveit

Mixin 组合流程
~~~~~~~~~~~~~~

.. mermaid::

   graph TB
       subgraph "Command"
           CMD["colcon build<br/>--mixin dev test"]
       end
       
       subgraph "Mixin 1: dev"
           DEV_ARGS["symlink-install: true<br/>-DCMAKE_BUILD_TYPE=Debug<br/>-DCMAKE_EXPORT_COMPILE_COMMANDS=ON<br/>-DBUILD_TESTING=OFF"]
       end
       
       subgraph "Mixin 2: test"
           TEST_ARGS["-DBUILD_TESTING=ON"]
       end
       
       subgraph "Merged Arguments"
           MERGED["symlink-install: true<br/>-DCMAKE_BUILD_TYPE=Debug<br/>-DCMAKE_EXPORT_COMPILE_COMMANDS=ON<br/>-DBUILD_TESTING=ON<br/>(test overrides dev)"]
       end
       
       CMD --> DEV_ARGS
       CMD --> TEST_ARGS
       DEV_ARGS --> MERGED
       TEST_ARGS --> MERGED

**图：Mixin 参数合并**

**来源:** `.colcon/mixin/build.mixin.yaml:1-19 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.colcon/mixin/build.mixin.yaml#L1-L19>`__

--------------

构建输出结构
------------

目录用途
~~~~~~~~

.. mermaid::

   graph TB
       subgraph "Source Space"
           SRC["src/<br/>Python + CMake packages"]
       end
       
       subgraph "Build Space"
           BUILD["build/<br/>CMake artifacts<br/>Python .egg-info<br/>compile_commands.json"]
       end
       
       subgraph "Install Space"
           INSTALL["install/<br/>setup.bash/zsh/sh<br/>lib/ (shared libraries)<br/>bin/ (executables)<br/>share/ (resources)<br/>local/lib/python3.10/"]
       end
       
       subgraph "Log Space"
           LOG["log/<br/>build logs per package<br/>test results<br/>stdout/stderr"]
       end
       
       SRC -->|"colcon build"| BUILD
       BUILD -->|"install step"| INSTALL
       BUILD -->|"logs"| LOG
       
       GITIGNORE[".gitignore<br/>excludes build/, install/, log/"]
       
       BUILD -.->|"git ignored"| GITIGNORE
       INSTALL -.->|"git ignored"| GITIGNORE
       LOG -.->|"git ignored"| GITIGNORE

**图：构建输出目录结构**

安装空间布局（Merge-Install）
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

使用 ``merge-install: true``，安装空间具有扁平结构：

::

   install/
   ├── setup.bash           # ROS2 覆盖设置脚本
   ├── setup.sh
   ├── setup.zsh
   ├── local_setup.*        # 本地覆盖（无递归 source）
   ├── lib/                 # 共享库
   │   ├── libso101_hardware.so
   │   └── python3.10/site-packages/
   │       ├── robot_config/
   │       ├── inference_service/
   │       └── ...
   ├── share/               # 包资源
   │   ├── robot_config/
   │   ├── robot_moveit/
   │   └── ...
   └── bin/                 # 可执行文件（如有）

此结构意味着 source ``install/setup.bash`` 会将所有已构建的包覆盖到环境中。

**来源:** `.colcon/defaults.yaml:6-8 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.colcon/defaults.yaml#L6-L8>`__, `.gitignore:1-8 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.gitignore#L1-L8>`__

--------------

VS Code 集成
------------

构建任务配置
~~~~~~~~~~~~

工作区为常用构建操作提供了预配置的 VS Code 任务。这些任务出现在命令面板的 "Tasks: Run Task" 下。

.. mermaid::

   graph TB
       subgraph "VS Code Tasks"
           TASK_FILE[".vscode/tasks.json"]
           
           subgraph "Task Definitions"
               DEFAULT["colcon build<br/>(Default Task)<br/>Ctrl+Shift+B"]
               SELECTED["colcon build selected<br/>(Current Package)"]
           end
           
           TASK_FILE --> DEFAULT
           TASK_FILE --> SELECTED
       end
       
       subgraph "Task Execution"
           ENV_SETUP["source /opt/ros/humble/setup.sh<br/>source venv/bin/activate"]
           BUILD_CMD["colcon build<br/>--symlink-install<br/>-DCMAKE_BUILD_TYPE=Release"]
           
           DEFAULT --> ENV_SETUP
           ENV_SETUP --> BUILD_CMD
       end
       
       subgraph "Output"
           TERMINAL["New Terminal Panel<br/>Build Output"]
           BUILD_CMD --> TERMINAL
       end

**图：VS Code 任务执行流程**

可用的构建任务
~~~~~~~~~~~~~~

默认构建任务
^^^^^^^^^^^^

.. code:: json

   {
     "label": "colcon build",
     "command": "source /opt/ros/humble/setup.sh && source venv/bin/activate && colcon build --symlink-install --cmake-args -DCMAKE_BUILD_TYPE=Release",
     "group": {
       "kind": "build",
       "isDefault": true
     }
   }

**触发:** ``Ctrl+Shift+B`` 或 "Tasks: Run Build Task"

**配置:** 使用 symlink-install 和 Release 构建类型。不使用 mixin（使用内联参数）。

构建选中包任务
^^^^^^^^^^^^^^

.. code:: json

   {
     "label": "colcon build selected",
     "command": "source /opt/ros/humble/setup.sh && source venv/bin/activate && colcon build --symlink-install --packages-select ${relativeFileDirname}",
     "group": "build"
   }

**触发:** 命令面板 → "Tasks: Run Task" → "colcon build selected"

**用途:** 仅构建包含当前打开文件的包。``${relativeFileDirname}`` 变量解析为包名。适用于单个包的快速迭代。

扩展构建任务
~~~~~~~~~~~~

要添加自定义构建配置（如调试构建或基于 mixin 的任务），扩展 ``.vscode/tasks.json``:

.. code:: json

   {
     "label": "colcon build (dev mixin)",
     "type": "shell",
     "command": "source /opt/ros/humble/setup.sh && source venv/bin/activate && colcon build --mixin dev",
     "group": "build"
   }

**来源:** `.vscode/tasks.json:1-26 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.vscode/tasks.json#L1-L26>`__

--------------

构建工作流示例
--------------

典型开发工作流
~~~~~~~~~~~~~~

.. code:: bash

   # 使用开发 mixin 进行初始完整构建
   colcon build --mixin dev

   # 修改 Python 文件后（由于 symlink-install 无需重新构建）
   # 只需 source 覆盖
   source install/setup.bash

   # 修改 CMake 包或更改 C++ 代码后
   colcon build --mixin dev --packages-select robot_hardware

   # 提交前：验证配置
   python scripts/validate_config.py --verbose

   # 用于部署的生产构建
   colcon build --mixin prod

清理重建
~~~~~~~~

.. code:: bash

   # 删除所有构建产物
   rm -rf build/ install/ log/

   # 使用特定 mixin 进行全新构建
   colcon build --mixin dev

选择性包构建
~~~~~~~~~~~~

.. code:: bash

   # 仅构建推理相关包
   colcon build --packages-select inference_service tensormsg --mixin dev

   # 构建包及其依赖
   colcon build --packages-up-to action_dispatch --mixin dev

   # 跳过问题包
   colcon build --packages-skip robot_moveit --mixin release

**来源:** `.colcon/mixin/build.mixin.yaml:14-18 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.colcon/mixin/build.mixin.yaml#L14-L18>`__,
`.vscode/tasks.json:1-26 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.vscode/tasks.json#L1-L26>`__

--------------

构建系统集成点
--------------

与配置系统的交互
~~~~~~~~~~~~~~~~

构建系统生成包含机器人配置文件和启动系统的安装空间。配置验证脚本操作源文件，但检查与构建输出的一致性。

.. mermaid::

   graph TB
       subgraph "Build Process"
           SRC_CONFIG["src/robot_config/<br/>config/robots/*.yaml"]
           BUILD["colcon build"]
           INSTALL_CONFIG["install/share/robot_config/<br/>config/robots/*.yaml"]
           
           SRC_CONFIG -->|"copy to install"| BUILD
           BUILD --> INSTALL_CONFIG
       end
       
       subgraph "Validation"
           VALIDATE["scripts/validate_config.py"]
           CHECKS["Joint consistency<br/>Controller config<br/>MoveIt config"]
           
           VALIDATE -->|"reads source"| SRC_CONFIG
           VALIDATE --> CHECKS
       end
       
       subgraph "Runtime"
           LAUNCH["robot.launch.py"]
           INSTALL_CONFIG -->|"loads at runtime"| LAUNCH
       end

**图：构建系统与配置验证**

Python 虚拟环境
~~~~~~~~~~~~~~~~

工作区使用 Python 虚拟环境（``venv/``），必须在构建前激活：

.. code:: bash

   source venv/bin/activate
   colcon build --mixin dev

VS Code 任务在构建前自动激活 venv。venv 包含：- LeRobot 库和依赖 - ROS2 Python 包覆盖在系统 ROS2 之上 - 开发工具（pytest、black 等）

**来源:** `.vscode/tasks.json:7 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.vscode/tasks.json#L7>`__,
`.vscode/settings.json:2 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.vscode/settings.json#L2>`__, `scripts/validate_config.py:1-350 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/scripts/validate_config.py#L1-L350>`__

--------------

性能考虑
--------

构建时间优化
~~~~~~~~~~~~


.. list-table::
   :header-rows: 1

   * - 策略
     - 命令
     - 构建时间减少
   * - 并行构建
     - ``colcon bu ild --paralle l-workers 8``
     - ~50%（8 核 CPU）
   * - 跳过测试
     - ``colc on build --mi xin no-test``
     - ~20%
   * - 选择性构建
     - ``colcon bui ld --packages -select pkg``
     - 90%+（取决于包）
   * - 符号链接安装
     - ``colcon build --syml ink-install``
     - Python 更改无需重新构建

按使用场景推荐的配置
~~~~~~~~~~~~~~~~~~~~


.. list-table::
   :header-rows: 1

   * - 使用场景
     - 推荐命令
     - 理由
   * - **日常开发**
     - ``colcon build --mixin dev``
     - 符号链接 + 调试符号 + 跳过测试
   * - **测试更改**
     - ``colcon build --mixin dev test --packages-up-to <pkg>``
     - 仅重新构建 受影响的包
   * - **CI/CD 流水线**
     - ``co lcon build --mixin release lint``
     - 优化 + 代码检查
   * - **生产部署**
     - ``colcon build --mixin prod``
     - 最大优化， 最小开销
   * - **调试 C++**
     - ``colcon build --mixi n debug --packages-select <pkg>``
     - 完整调试符号， 单个包

**来源:** `.colcon/defaults.yaml:9-10 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.colcon/defaults.yaml#L9-L10>`__,
`.colcon/mixin/build.mixin.yaml:1-19 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.colcon/mixin/build.mixin.yaml#L1-L19>`__

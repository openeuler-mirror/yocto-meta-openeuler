调试与测试
===========

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
-  `src/action_dispatch/action_dispatch/init.py <src/action_dispatch/action_dispatch/__init__.py>`__
-  `src/action_dispatch/action_dispatch/temporal_smoother.py <src/action_dispatch/action_dispatch/temporal_smoother.py>`__
-  `src/action_dispatch/test/test_temporal_smoother.py <src/action_dispatch/test/test_temporal_smoother.py>`__

.. raw:: html

   </details>

本文档介绍 IB-Robot 开发的调试和测试基础设施。内容包括 VS Code 调试配置、使用 pytest 进行单元测试、用于调试的构建系统配置，以及配置验证工具。

有关通用 VS Code 设置和环境配置，请参阅 `VS Code 配置 <#13.1>`__。有关构建系统详情，请参阅 `构建系统与 Mixin <#13.2>`__。

--------------

VS Code 调试基础设施
--------------------

工作区提供了预配置的启动配置，用于调试带有正确环境设置的 Python ROS2 节点。

Python 环境配置
~~~~~~~~~~~~~~~~

Python 调试器需要显式配置 ``PYTHONPATH`` 以定位 ROS2 包、LeRobot 库和工作区包。

`.vscode/settings.json:1-33 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.vscode/settings.json#L1-L33>`__

.. code:: yaml

   Key Path Configurations:
   - venv/bin/python3              # 项目虚拟环境
   - libs/lerobot/src              # LeRobot 库
   - src                           # 工作区 ROS2 包
   - /opt/ros/humble/lib/python3.10/site-packages

**来源**: `.vscode/settings.json:1-33 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.vscode/settings.json#L1-L33>`__

--------------

启动配置
~~~~~~~~

工作区在 `.vscode/launch.json:1-28 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.vscode/launch.json#L1-L28>`__ 中定义了两个主要调试配置：

通用 Python 节点调试器
^^^^^^^^^^^^^^^^^^^^^^^^

.. code:: json

   "name": "ROS2: Debug Python Node (Current File)"

将当前打开的 Python 文件作为独立脚本进行调试。使用工作区范围的 ``PYTHONPATH`` 配置。

**使用场景**: 在开发过程中调试单个节点，逐步执行初始化代码。

动作分发器节点调试器
^^^^^^^^^^^^^^^^^^^^^

.. code:: json

   "name": "ROS2: Action Dispatcher Node"

为 ``action_dispatcher_node.py`` 预配置的调试器，带有特定的 ROS 参数：- 设置 ``robot_name`` 参数为 ``test_single_arm_single_cam`` - 包含所有必需的路径配置

**使用场景**: 调试动作分发管道、时间平滑和队列管理。

**来源**: `.vscode/launch.json:1-28 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.vscode/launch.json#L1-L28>`__

--------------

调试环境图
~~~~~~~~~~

.. mermaid::

   graph TB
       subgraph "VS Code Debugger"
           LAUNCH["launch.json<br/>Debug Configurations"]
           SETTINGS["settings.json<br/>Python paths"]
           
           LAUNCH --> DEBUG_CURRENT["Debug Current File"]
           LAUNCH --> DEBUG_DISPATCHER["Debug Action Dispatcher"]
       end
       
       subgraph "Python Path Resolution"
           VENV["${workspaceFolder}/venv"]
           LEROBOT["${workspaceFolder}/libs/lerobot/src"]
           SRC["${workspaceFolder}/src"]
           ROS2["/opt/ros/humble/lib/python3.10/site-packages"]
           
           SETTINGS --> VENV
           SETTINGS --> LEROBOT
           SETTINGS --> SRC
           SETTINGS --> ROS2
       end
       
       subgraph "Target Nodes"
           NODE_CURRENT["Current File<br/>(any .py)"]
           NODE_DISPATCHER["action_dispatcher_node.py"]
           
           DEBUG_CURRENT --> NODE_CURRENT
           DEBUG_DISPATCHER --> NODE_DISPATCHER
       end
       
       VENV -.->|import path| NODE_CURRENT
       LEROBOT -.->|import path| NODE_CURRENT
       SRC -.->|import path| NODE_CURRENT
       ROS2 -.->|import path| NODE_CURRENT
       
       VENV -.->|import path| NODE_DISPATCHER
       LEROBOT -.->|import path| NODE_DISPATCHER
       SRC -.->|import path| NODE_DISPATCHER
       ROS2 -.->|import path| NODE_DISPATCHER

**来源**: `.vscode/launch.json:1-28 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.vscode/launch.json#L1-L28>`__,
`.vscode/settings.json:1-33 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.vscode/settings.json#L1-L33>`__

--------------

使用 pytest 进行单元测试
------------------------

代码库使用 pytest 进行 Python 模块的单元测试。测试文件遵循 ``test_*.py`` 命名约定。

示例：TemporalSmoother 测试套件
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

``test_temporal_smoother.py`` 模块展示了全面的测试模式：

`src/action_dispatch/test/test_temporal_smoother.py:1-247 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/test/test_temporal_smoother.py#L1-L247>`__

测试结构
^^^^^^^^

::

   test_temporal_smoother.py
   ├── TestTemporalSmootherConfig      # 配置验证测试
   │   ├── test_default_config()
   │   ├── test_custom_config()
   │   └── test_invalid_chunk_size()
   ├── TestTemporalSmoother            # 核心算法测试
   │   ├── test_basic_update_and_get()
   │   ├── test_disabled_smoothing()
   │   ├── test_cross_frame_smoothing()
   │   ├── test_tensor_input()
   │   ├── test_reset()
   │   └── test_empty_input()
   ├── TestTemporalSmootherManager     # 管理 API 测试
   │   ├── test_manager_basic()
   │   ├── test_manager_toggle()
   │   └── test_manager_peek()
   └── TestSmoothingFormula            # 数学正确性测试
       ├── test_weight_calculation()
       ├── test_positive_coeff_weights()
       └── test_cumulative_weights()

关键测试模式
^^^^^^^^^^^^

**配置验证**

`src/action_dispatch/test/test_temporal_smoother.py:23-48 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/test/test_temporal_smoother.py#L23-L48>`__

.. code:: python

   def test_invalid_chunk_size(self):
       with pytest.raises(ValueError):
           TemporalSmootherConfig(chunk_size=0)

**数值正确性**

`src/action_dispatch/test/test_temporal_smoother.py:91-118 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/test/test_temporal_smoother.py#L91-L118>`__

测试验证跨帧平滑产生的值介于旧动作块和新动作块之间，不完全等于任何一个：

.. code:: python

   assert not np.allclose(first_action.numpy(), np.ones(7) * 1.0)
   assert not np.allclose(first_action.numpy(), np.ones(7) * 2.0)

**边界情况处理**

`src/action_dispatch/test/test_temporal_smoother.py:146-161 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/test/test_temporal_smoother.py#L146-L161>`__

测试空输入、1D 数组重塑和空计划错误。

**来源**:
`src/action_dispatch/test/test_temporal_smoother.py:1-247 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/test/test_temporal_smoother.py#L1-L247>`__

--------------

运行测试
~~~~~~~~

.. code:: bash

   # 运行包中的所有测试
   pytest src/action_dispatch/test/

   # 运行特定测试文件
   pytest src/action_dispatch/test/test_temporal_smoother.py

   # 运行并显示详细输出
   pytest src/action_dispatch/test/test_temporal_smoother.py -v

   # 运行特定测试类
   pytest src/action_dispatch/test/test_temporal_smoother.py::TestTemporalSmoother

   # 运行特定测试方法
   pytest src/action_dispatch/test/test_temporal_smoother.py::TestTemporalSmoother::test_cross_frame_smoothing

**来源**:
`src/action_dispatch/test/test_temporal_smoother.py:245-247 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/test/test_temporal_smoother.py#L245-L247>`__

--------------

构建系统调试配置
----------------

colcon 构建系统通过 mixin 支持多种构建配置。

可用的 Mixin
~~~~~~~~~~~~

`.colcon/mixin/build.mixin.yaml:1-19 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.colcon/mixin/build.mixin.yaml#L1-L19>`__


.. list-table::
   :header-rows: 1

   * - Mixin
     - 用途
     - CMake 参数
   * - ``debug``
     - 带调试符号的调试构建
     - ` `-DCMAKE_BUILD_TYPE=Debug``
   * - ``release``
     - 优化的生产构建
     - ``- DCMAKE_BUILD_TYPE=Release``
   * - ``rel- with-deb-info``
     - 带调试符号的优化构建
     - ``-DCMAKE_ BUILD_TYPE=RelWithDebInfo``
   * - ``test``
     - 启用测试构建
     - ``-DBUILD_TESTING=ON``
   * - ``no-test``
     - 禁用测试构建
     - ``-DBUILD_TESTING=OFF``
   * - ``lint``
     - 启用代码检查
     - ``-DAMENT_LINT_AUTO=ON``
   * - ``dev``
     - 开发模式
     - Debug + symlink-install + no tests
   * - ``prod``
     - 生产模式
     - Release + no tests + no tracing

构建配置流程
~~~~~~~~~~~~

.. mermaid::

   graph TB
       subgraph "Mixin Loading"
           INDEX[".colcon/mixin/index.yaml"]
           BUILD_MIXIN[".colcon/mixin/build.mixin.yaml"]
           
           INDEX -->|references| BUILD_MIXIN
       end
       
       subgraph "Mixin Definitions"
           DEBUG["debug:<br/>CMAKE_BUILD_TYPE=Debug<br/>EXPORT_COMPILE_COMMANDS=ON"]
           RELEASE["release:<br/>CMAKE_BUILD_TYPE=Release<br/>EXPORT_COMPILE_COMMANDS=ON"]
           DEV["dev:<br/>symlink-install: true<br/>Debug + no tests"]
           PROD["prod:<br/>Release + no tests<br/>TRACETOOLS_DISABLED=ON"]
           
           BUILD_MIXIN --> DEBUG
           BUILD_MIXIN --> RELEASE
           BUILD_MIXIN --> DEV
           BUILD_MIXIN --> PROD
       end
       
       subgraph "Build Commands"
           CMD_DEBUG["colcon build --mixin debug"]
           CMD_DEV["colcon build --mixin dev"]
           CMD_PROD["colcon build --mixin prod"]
           
           DEBUG -.->|applied by| CMD_DEBUG
           DEV -.->|applied by| CMD_DEV
           PROD -.->|applied by| CMD_PROD
       end
       
       subgraph "Build Output"
           BUILD_DIR["build/<br/>CMake artifacts"]
           INSTALL_DIR["install/<br/>Runtime files"]
           COMPILE_DB["compile_commands.json<br/>for IntelliSense"]
           
           CMD_DEBUG --> BUILD_DIR
           CMD_DEBUG --> INSTALL_DIR
           CMD_DEBUG --> COMPILE_DB
       end

**来源**: `.colcon/mixin/build.mixin.yaml:1-19 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.colcon/mixin/build.mixin.yaml#L1-L19>`__,
`.colcon/mixin/index.yaml:1-4 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.colcon/mixin/index.yaml#L1-L4>`__

--------------

使用示例
~~~~~~~~

.. code:: bash

   # 调试构建并生成 compile_commands.json
   colcon build --mixin debug

   # 开发构建带 symlink-install
   colcon build --mixin dev

   # 生产构建（优化，无调试符号）
   colcon build --mixin prod

   # 调试构建并启用测试
   colcon build --mixin debug test

   # 组合多个 mixin
   colcon build --mixin dev lint

**来源**: `.colcon/mixin/build.mixin.yaml:1-19 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.colcon/mixin/build.mixin.yaml#L1-L19>`__

--------------

配置验证
--------

``validate_config.py`` 脚本强制执行 YAML 文件间的配置一致性。

验证架构
~~~~~~~~

.. mermaid::

   graph TB
       subgraph "Input Files"
           ROBOT_CONFIG["robot_config YAML<br/>so101_single_arm.yaml"]
           CTRL_CONFIG["controllers YAML<br/>auto-resolved from robot_config"]
           MOVEIT_CONFIG["MoveIt controllers YAML<br/>(optional)"]
       end
       
       subgraph "ConfigValidator Class"
           LOAD["load_yaml()<br/>Parse YAML files"]
           RESOLVE["resolve_ros_path()<br/>Handle $(find) and $(env)"]
           VALIDATE_JOINTS["validate_joints_config()<br/>Extract joint definitions"]
           VALIDATE_CTRL["validate_controller_config()<br/>Check controller joints"]
           VALIDATE_MOVEIT["validate_moveit_config()<br/>Check MoveIt joints"]
           
           LOAD --> RESOLVE
           RESOLVE --> VALIDATE_JOINTS
           VALIDATE_JOINTS --> VALIDATE_CTRL
           VALIDATE_CTRL --> VALIDATE_MOVEIT
       end
       
       subgraph "Validation Checks"
           CHECK1["arm + gripper = all joints"]
           CHECK2["Controller joints match robot_config"]
           CHECK3["MoveIt joints match robot_config"]
           
           VALIDATE_JOINTS --> CHECK1
           VALIDATE_CTRL --> CHECK2
           VALIDATE_MOVEIT --> CHECK3
       end
       
       subgraph "Output"
           ERRORS["errors: List[str]<br/>Configuration mismatches"]
           WARNINGS["warnings: List[str]<br/>Non-critical issues"]
           SUMMARY["Validation Summary<br/>Exit code 0/1/2"]
           
           CHECK1 --> ERRORS
           CHECK2 --> ERRORS
           CHECK3 --> WARNINGS
           
           ERRORS --> SUMMARY
           WARNINGS --> SUMMARY
       end
       
       ROBOT_CONFIG --> LOAD
       CTRL_CONFIG --> LOAD
       MOVEIT_CONFIG --> LOAD

**来源**: `scripts/validate_config.py:1-351 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/scripts/validate_config.py#L1-L351>`__

--------------

验证逻辑
~~~~~~~~

验证器实现 DRY（Don't Repeat Yourself）原则，确保关节列表一致：

`scripts/validate_config.py:103-131 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/scripts/validate_config.py#L103-L131>`__

**关键验证**:

1. **关节集合一致性**: 验证 ``joints.all == joints.arm ∪ joints.gripper``
2. **控制器关节匹配**: 验证控制器配置使用正确的关节子集
3. **MoveIt 关节匹配**: 确保 MoveIt 控制器引用正确的关节

路径解析
^^^^^^^^

`scripts/validate_config.py:53-101 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/scripts/validate_config.py#L53-L101>`__

支持 ROS 风格的路径替换：- ``$(find package_name)`` - 搜索工作区 install、src 和 ``/opt/ros/`` - ``$(env VAR_NAME)`` - 读取环境变量

--------------

使用方法
~~~~~~~~

.. code:: bash

   # 验证默认机器人配置
   python scripts/validate_config.py

   # 验证特定配置并显示详细输出
   python scripts/validate_config.py \
       --robot-config src/robot_config/config/robots/so101_single_arm.yaml \
       --verbose

   # 显式指定所有配置
   python scripts/validate_config.py \
       --robot-config src/robot_config/config/robots/so101_single_arm.yaml \
       --controllers-config src/so101_moveit/config/lerobot/so101/ros2_controllers.yaml \
       --moveit-config src/robot_moveit/config/lerobot/so101/moveit_controllers.yaml

退出码
^^^^^^

==== =============================
代码 含义
==== =============================
0    所有验证通过
1    发现配置错误
2    文件未找到或解析错误
==== =============================

**来源**: `scripts/validate_config.py:10-16 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/scripts/validate_config.py#L10-L16>`__,
`scripts/validate_config.py:297-350 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/scripts/validate_config.py#L297-L350>`__

--------------

调试工作流
----------

调试 Python 节点
~~~~~~~~~~~~~~~~

工作流 1：调试当前文件
^^^^^^^^^^^^^^^^^^^^^^

1. 在 VS Code 中打开 Python 节点文件
2. 在代码中设置断点
3. 按 ``F5`` 或选择 "ROS2: Debug Python Node (Current File)"
4. 调试器使用正确的 ``PYTHONPATH`` 配置启动

**使用场景**: 在开发过程中快速调试单个节点。

工作流 2：带 ROS 参数调试
^^^^^^^^^^^^^^^^^^^^^^^^^

对于需要特定 ROS 参数的节点，创建自定义启动配置：

.. code:: json

   {
       "name": "Debug My Node",
       "type": "python",
       "request": "launch",
       "program": "${workspaceFolder}/src/my_package/my_package/my_node.py",
       "args": [
           "--ros-args", 
           "-p", "robot_name:=my_robot",
           "-p", "use_sim:=false"
       ],
       "env": {
           "PYTHONPATH": "${workspaceFolder}/libs/lerobot/src:..."
       }
   }

**来源**: `.vscode/launch.json:14-27 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.vscode/launch.json#L14-L27>`__

--------------

调试构建问题
~~~~~~~~~~~~

启用编译命令
^^^^^^^^^^^^

所有 debug/release mixin 都启用 ``CMAKE_EXPORT_COMPILE_COMMANDS=ON``：

`.colcon/mixin/build.mixin.yaml:3-7 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.colcon/mixin/build.mixin.yaml#L3-L7>`__

这会为 C++ IntelliSense 生成 ``build/*/compile_commands.json``。

构建输出分析
^^^^^^^^^^^^

.. code:: bash

   # 带详细输出构建
   colcon build --event-handlers console_direct+

   # 在调试模式下构建特定包
   colcon build --packages-select my_package --mixin debug

   # 显示 CMake 配置
   colcon build --cmake-args --trace

**来源**: `.colcon/defaults.yaml:12-14 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.colcon/defaults.yaml#L12-L14>`__

--------------

调试动作分发管道
~~~~~~~~~~~~~~~~

预配置的动作分发器调试器支持逐步调试：

1. **动作队列管理**: 在 ``ActionDispatcherNode._control_loop_callback()`` 中设置断点
2. **时间平滑**: 在 ``TemporalSmoother.update()`` 或 ``_apply_smoothing()`` 中设置断点
3. **推理触发**: 在 ``_trigger_inference_if_needed()`` 中设置断点

**推荐断点**: -
`src/action_dispatch/action_dispatch/temporal_smoother.py:145-206 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatch/temporal_smoother.py#L145-L206>`__
- ``update()`` 方法 -
`src/action_dispatch/action_dispatch/temporal_smoother.py:208-246 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatch/temporal_smoother.py#L208-L246>`__
- ``_apply_smoothing()`` 方法

**来源**: `.vscode/launch.json:14-27 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.vscode/launch.json#L14-L27>`__,
`src/action_dispatch/action_dispatch/temporal_smoother.py:1-322 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/action_dispatch/temporal_smoother.py#L1-L322>`__

--------------

测试模式
--------

单元测试组织
~~~~~~~~~~~~

测试应放置在 ``<package>/test/test_<module>.py``:

::

   src/my_package/
   ├── my_package/
   │   ├── __init__.py
   │   ├── my_module.py
   │   └── my_node.py
   └── test/
       ├── test_my_module.py
       └── test_my_node.py

测试类结构
~~~~~~~~~~

将相关测试组织成与代码结构匹配的类：

.. code:: python

   class TestMyConfig:
       """Tests for configuration dataclass."""
       def test_default_config(self):
           ...
       def test_invalid_config(self):
           ...

   class TestMyClass:
       """Tests for main class functionality."""
       def test_basic_operation(self):
           ...
       def test_edge_case(self):
           ...

**来源**:
`src/action_dispatch/test/test_temporal_smoother.py:23-243 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/test/test_temporal_smoother.py#L23-L243>`__

--------------

使用 NumPy/Torch 进行数值测试
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

对于数值算法，使用 ``np.testing.assert_array_almost_equal()``
或 ``torch.allclose()``:

.. code:: python

   # From test_temporal_smoother.py
   np.testing.assert_array_almost_equal(
       action, 
       expected_action,
       decimal=6
   )

   # 验证值在有效范围内（非精确相等）
   assert not np.allclose(smoothed, old_value)
   assert not np.allclose(smoothed, new_value)

**来源**:
`src/action_dispatch/test/test_temporal_smoother.py:89-118 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/test/test_temporal_smoother.py#L89-L118>`__,
`src/action_dispatch/test/test_temporal_smoother.py:224-243 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/test/test_temporal_smoother.py#L224-L243>`__

--------------

异常测试
~~~~~~~~

测试无效输入是否引发适当的异常：

.. code:: python

   def test_invalid_chunk_size(self):
       with pytest.raises(ValueError):
           TemporalSmootherConfig(chunk_size=0)
       with pytest.raises(ValueError):
           TemporalSmootherConfig(chunk_size=-1)

   def test_get_next_action_raises_on_empty(self):
       with pytest.raises(IndexError):
           smoother.get_next_action()

**来源**:
`src/action_dispatch/test/test_temporal_smoother.py:43-48 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/test/test_temporal_smoother.py#L43-L48>`__,
`src/action_dispatch/test/test_temporal_smoother.py:156-161 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/test/test_temporal_smoother.py#L156-L161>`__

--------------

集成测试设置
~~~~~~~~~~~~

对于 ROS2 集成测试，初始化 ROS 上下文：

.. code:: python

   import rclpy
   import pytest

   @pytest.fixture
   def ros_context():
       rclpy.init()
       yield
       rclpy.shutdown()

   def test_node_lifecycle(ros_context):
       node = MyNode()
       # Test node...
       node.destroy_node()

--------------

推荐扩展
--------

工作区推荐特定的 VS Code 扩展以获得最佳调试体验：

`.vscode/extensions.json:1-13 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.vscode/extensions.json#L1-L13>`__

================================ =================================
扩展                             用途
================================ =================================
``ms-python.python``             Python 调试和 IntelliSense
``ms-vscode.cpptools``           C++ 调试和 IntelliSense
``vadimcn.vscode-lldb``          原生代码的 LLDB 调试器
``ms-vscode.cmake-tools``        CMake 集成
``redhat.vscode-yaml``           YAML 语法和验证
``Ranch-Hand-Robotics.rde-pack`` ROS 开发环境包
================================ =================================

**来源**: `.vscode/extensions.json:1-13 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.vscode/extensions.json#L1-L13>`__

--------------

总结
----

IB-Robot 调试和测试基础设施提供：

1. **VS Code 集成**: 预配置的启动配置，带有正确的 Python 路径解析
2. **单元测试**: 基于 pytest 的测试套件，具有全面的覆盖模式
3. **构建配置**: 用于 debug/release/development 构建的 Colcon mixin
4. **配置验证**: YAML 一致性的自动验证
5. **调试工作流**: 常见调试场景的文档化模式

有关工作区设置，请参阅 `VS Code 配置 <#13.1>`__。有关构建系统详情，请参阅 `构建系统与 Mixin <#13.2>`__。

**来源**: `.vscode/ <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.vscode/>`__ 中的所有文件, `.colcon/ <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.colcon/>`__,
`scripts/validate_config.py:1-351 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/scripts/validate_config.py#L1-L351>`__,
`src/action_dispatch/test/test_temporal_smoother.py:1-247 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/action_dispatch/test/test_temporal_smoother.py#L1-L247>`__

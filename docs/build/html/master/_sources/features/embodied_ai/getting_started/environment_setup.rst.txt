环境设置
========

.. raw:: html

   <details>

相关源文件

以下文件用于生成此 Wiki 页面的上下文：

-  `.gitmodules <.gitmodules>`__
-  `scripts/setup.sh <scripts/setup.sh>`__

.. raw:: html

   </details>

本文档详细介绍了以 ``setup.sh`` 脚本为中心的 IB-Robot 环境初始化过程。内容包括先决条件检查、git 子模块管理、系统依赖安装和 Python 虚拟环境配置。

有关设置后构建工作区的信息，请参阅 `构建项目 <#2.2>`__。有关驱动系统的配置文件详情，请参阅 `配置系统 <#5>`__。

--------------

概述
----

环境设置过程准备一个集成了 LeRobot 功能的 ROS 2 Humble 工作区。``setup.sh`` 脚本协调四个主要阶段：

1. **环境验证** - 检测冲突的 Python 环境（Conda）
2. **仓库管理** - 初始化 git 子模块（LeRobot 和 PyMoveIt2）
3. **系统依赖** - 通过 ``rosdep`` 安装 ROS 2 包
4. **Python 环境** - 创建可访问系统 ROS 2 包的隔离 venv

--------------

设置工作流
----------

以下图表展示了 ``scripts/setup.sh`` 执行的完整设置序列：

.. mermaid::

   graph TB
       START["./scripts/setup.sh"]
       
       START --> CHECK_CONDA["check_conda()"]
       
       CHECK_CONDA -->|"CONDA_PREFIX set"| ERROR_CONDA["Exit with error:<br/>Deactivate conda first"]
       CHECK_CONDA -->|"No conda active"| SUBMODULE["update_submodules()"]
       
       SUBMODULE --> CHECK_INIT{"All submodules<br/>initialized?"}
       
       CHECK_INIT -->|"Yes"| ASK_UPDATE["Prompt:<br/>Update submodules?"]
       CHECK_INIT -->|"No"| ASK_INIT["Interactive selection:<br/>1) All<br/>2) LeRobot only<br/>3) PyMoveIt2 only<br/>4) Individual"]
       
       ASK_UPDATE -->|"Yes"| GIT_UPDATE["git submodule update<br/>--init --recursive"]
       ASK_UPDATE -->|"No"| FORK_SETUP
       
       ASK_INIT --> GIT_INIT["git submodule update<br/>--init --recursive [path]"]
       
       GIT_UPDATE --> FORK_SETUP["setup_developer_forks()"]
       GIT_INIT --> FORK_SETUP
       
       FORK_SETUP --> PROMPT_USER["Prompt for<br/>GitCode username"]
       PROMPT_USER -->|"Provided"| CONFIG_REMOTES["Configure remotes:<br/>origin = fork<br/>upstream = original"]
       PROMPT_USER -->|"Skipped"| SYSTEM_DEPS
       
       CONFIG_REMOTES --> SYSTEM_DEPS["install_system_deps()"]
       
       SYSTEM_DEPS --> PKG_MGR{"Package<br/>manager?"}
       PKG_MGR -->|"apt-get"| APT_UPDATE["apt-get update<br/>rosdep update"]
       PKG_MGR -->|"dnf"| DNF_UPDATE["dnf update<br/>rosdep update"]
       
       APT_UPDATE --> ROSDEP["rosdep install<br/>--from-paths src<br/>--skip-keys [...]"]
       DNF_UPDATE --> ROSDEP
       
       ROSDEP --> VENV["setup_python_venv()"]
       
       VENV --> CREATE_VENV["python3 -m venv<br/>--system-site-packages<br/>venv/"]
       CREATE_VENV --> ACTIVATE["source venv/bin/activate"]
       
       ACTIVATE --> PIP_UPGRADE["pip install --upgrade pip"]
       PIP_UPGRADE --> NUMPY["pip install 'numpy<2'"]
       NUMPY --> SETUPTOOLS["pip install 'setuptools<80' 'setuptools>=71'"]
       SETUPTOOLS --> LEROBOT_CHECK{"libs/lerobot<br/>exists?"}
       
       LEROBOT_CHECK -->|"Yes"| LEROBOT_INSTALL["pip install -e libs/lerobot"]
       LEROBOT_CHECK -->|"No"| HARDWARE_DEPS
       
       LEROBOT_INSTALL --> HARDWARE_DEPS["pip install pyserial<br/>feetech-servo-sdk"]
       HARDWARE_DEPS --> SCIPY["pip install scipy"]
       SCIPY --> GITLINT["pip install gitlint<br/>gitlint install-hook"]
       
       GITLINT --> VERIFY["Verification:<br/>import rclpy"]
       
       VERIFY -->|"Success"| COMPLETE["Setup complete"]
       VERIFY -->|"Failure"| ERROR_VERIFY["Exit with error:<br/>rclpy not accessible"]
       
       COMPLETE --> NEXT["Next step:<br/>./scripts/build.sh"]

**来源**: `scripts/setup.sh:1-307 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/scripts/setup.sh#L1-L307>`__

--------------

先决条件
--------

运行 ``setup.sh`` 前，请确保已安装以下组件：

================ ================= =====================
组件             版本              验证命令
================ ================= =====================
Ubuntu/openEuler 22.04 / Embedded  ``lsb_release -a``
ROS 2 Humble     基础安装          ``ros2 --version``
Git              2.x               ``git --version``
Python 3         3.10+             ``python3 --version``
================ ================= =====================

**关键**: 运行设置前必须安装并 source ROS 2 Humble。脚本假设 ``/opt/ros/humble/setup.sh`` 存在。

**来源**: `scripts/setup.sh:273-277 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/scripts/setup.sh#L273-L277>`__

--------------

Git 子模块管理
--------------

工作区依赖两个作为 git 子模块管理的外部仓库：

.. mermaid::

   graph LR
       ROOT["IB_Robot<br/>(main repository)"]
       
       ROOT -->|"submodule"| LEROBOT["libs/lerobot"]
       ROOT -->|"submodule"| PYMOVEIT["src/pymoveit2"]
       
       LEROBOT -->|"origin"| LEROBOT_URL["git@gitcode.com:<br/>openeuler/lerobot_ros2.git"]
       PYMOVEIT -->|"origin"| PYMOVEIT_URL["https://github.com/<br/>AndrejOrsula/pymoveit2.git"]
       
       LEROBOT -.->|"if fork setup"| LEROBOT_FORK["git@gitcode.com:<br/>username/lerobot_ros2.git"]
       ROOT -.->|"if fork setup"| ROOT_FORK["git@gitcode.com:<br/>username/IB_Robot.git"]

子模块初始化策略
~~~~~~~~~~~~~~~~

``update_submodules()`` 函数 `scripts/setup.sh:38-135 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/scripts/setup.sh#L38-L135>`__ 提供交互式初始化：


.. list-table::
   :header-rows: 1

   * - 选项
     - 初始化的子模块
     - 使用场景
   * - 1 - All
     - LeRobot + PyMoveIt2
     - 完整开发设置
   * - 2 - LeRobot only
     - libs/lerobot
     - 无 MoveIt 的 训练/推理
   * - 3 - PyMoveIt2 only
     - src/pymoveit2
     - 无 AI 的运动规划
   * - 4 - Individual
     - 每个模块用户选择
     - 自定义配置
   * - 0 - Skip
     - 无
     - 使用现有子模块状态

**Git LFS 优化**: 脚本设置 ``GIT_LFS_SKIP_SMUDGE=1``
`scripts/setup.sh:73,100,105,110,121 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/scripts/setup.sh#L73>`__ 以在初始克隆时跳过下载大型模型文件，减少设置时间。

开发者 Fork 配置
~~~~~~~~~~~~~~~~

对于有个人 fork 的贡献者，``setup_developer_forks()``
`scripts/setup.sh:137-177 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/scripts/setup.sh#L137-L177>`__ 配置双远程：

::

   origin   → git@gitcode.com:username/IB_Robot.git      (你的 fork)
   upstream → git@atomgit.com:openeuler/IB_Robot.git     (原始仓库)

这启用了用于贡献的标准 fork-and-pull 工作流。

**来源**: `.gitmodules:1-11 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/.gitmodules#L1-L11>`__, `scripts/setup.sh:38-177 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/scripts/setup.sh#L38-L177>`__

--------------

系统依赖安装
------------

``install_system_deps()`` 函数 `scripts/setup.sh:182-214 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/scripts/setup.sh#L182-L214>`__ 使用 ``rosdep`` 安装 ROS 2 包依赖：

.. code:: bash

   rosdep install \
       --from-paths src \
       --ignore-src \
       --rosdistro=humble \
       -y -r \
       --skip-keys "catkin roscpp lerobot trimesh[easy] simple-parsing cupy-cuda12x ctl_system_interface numpy_lessthan_2 ament_python feetech-servo-sdk pyserial"

跳过的依赖
~~~~~~~~~~

以下包从 ``rosdep`` 安装中排除，因为它们单独处理：

======================== =========================================
包                       排除原因
======================== =========================================
``lerobot``              通过 pip 在 venv 中安装（可编辑模式）
``trimesh[easy]``        Python 依赖，非 ROS 包
``simple-parsing``       LeRobot 的 Python 依赖
``cupy-cuda12x``         GPU 特定，可选依赖
``feetech-servo-sdk``    通过 pip 在硬件依赖中安装
``pyserial``             通过 pip 在硬件依赖中安装
``numpy_lessthan_2``     自定义 rosdep 键，在 venv 中处理
``ctl_system_interface`` 自定义包，从源码构建
======================== =========================================

**来源**: `scripts/setup.sh:182-214 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/scripts/setup.sh#L182-L214>`__

--------------

Python 虚拟环境
----------------

虚拟环境设置是最关键的组件，确保 ROS 2 系统包与 LeRobot 依赖之间的兼容性。

虚拟环境架构
~~~~~~~~~~~~

.. mermaid::

   graph TB
       subgraph "System Python 3.10"
           SYS_RCLPY["rclpy<br/>(ROS 2 core)"]
           SYS_TF2["tf2_ros"]
           SYS_CV_BRIDGE["cv_bridge"]
       end
       
       subgraph "venv/ (with --system-site-packages)"
           VENV_PIP["pip 24.x"]
           VENV_NUMPY["numpy 1.26.x<br/>(forced < 2.0)"]
           VENV_SETUPTOOLS["setuptools 71-79<br/>(colcon compatible)"]
           VENV_LEROBOT["lerobot<br/>(editable install)"]
           VENV_TORCH["torch 2.x<br/>(LeRobot dependency)"]
           VENV_HARDWARE["pyserial<br/>feetech-servo-sdk"]
           VENV_SCIPY["scipy"]
           VENV_GITLINT["gitlint"]
       end
       
       VENV_NUMPY -.->|"inherits from system"| SYS_RCLPY
       VENV_LEROBOT --> VENV_TORCH
       VENV_LEROBOT --> VENV_NUMPY
       
       SYS_RCLPY -.->|"accessible via<br/>--system-site-packages"| VENV_PIP
       SYS_TF2 -.->|"accessible"| VENV_PIP
       SYS_CV_BRIDGE -.->|"accessible"| VENV_PIP

关键配置：–system-site-packages
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

venv 使用 ``--system-site-packages`` 标志创建
`scripts/setup.sh:231 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/scripts/setup.sh#L231>`__:

.. code:: bash

   python3 -m venv --system-site-packages "${WORKSPACE}/venv"

**原因**: ROS 2 Python 包（``rclpy``、``tf2_ros`` 等）通过 apt/dnf 系统级安装。没有此标志，venv 将与这些包隔离，破坏 ROS 2 集成。

NumPy 版本约束
~~~~~~~~~~~~~~

脚本强制使用 NumPy 1.x `scripts/setup.sh:244-245 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/scripts/setup.sh#L244-L245>`__:

.. code:: bash

   python3 -m pip install "numpy<2" --quiet

**原因**: ROS 2 Humble 的系统包（特别是 ``cv_bridge`` 和传感器数据转换器）是针对 NumPy 1.x ABI 编译的。NumPy 2.0 引入了破坏性的 C API 更改，会导致 ROS 2 组件出现段错误。

Setuptools 版本范围
~~~~~~~~~~~~~~~~~~~

脚本安装特定的 setuptools 范围
`scripts/setup.sh:248 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/scripts/setup.sh#L248>`__:

.. code:: bash

   python3 -m pip install "setuptools<80" "setuptools>=71" --quiet

**原因**: - ``>= 71`` LeRobot 构建系统所需 - ``< 80`` ``colcon build`` 兼容性所需（setuptools 80+ 弃用了 ament_python 使用的功能）

LeRobot 可编辑安装
~~~~~~~~~~~~~~~~~~

如果 ``libs/lerobot`` 存在，它以可编辑模式安装
`scripts/setup.sh:251-254 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/scripts/setup.sh#L251-L254>`__:

.. code:: bash

   python3 -m pip install -e "${WORKSPACE}/libs/lerobot"

**好处**: 对 LeRobot 库代码的更改立即生效，无需重新安装，这对策略开发和调试至关重要。

验证过程
~~~~~~~~

脚本验证 ROS 2 可访问性 `scripts/setup.sh:271-277 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/scripts/setup.sh#L271-L277>`__:

.. code:: bash

   source /opt/ros/humble/setup.sh
   python3 -c "import rclpy; print('ROS 2 Humble connection successful')"

如果失败，venv 配置错误，无法运行 ROS 2 节点。

**来源**: `scripts/setup.sh:216-278 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/scripts/setup.sh#L216-L278>`__

--------------

环境验证
--------

Conda 冲突检测
~~~~~~~~~~~~~~

``check_conda()`` 函数 `scripts/setup.sh:25-33 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/scripts/setup.sh#L25-L33>`__ 防止在活动 Conda 环境中设置：

.. code:: bash

   if [[ -n "${CONDA_PREFIX}" ]]; then
       log_error "Active Conda environment detected at: ${CONDA_PREFIX}"
       exit 1
   fi

**原因**: Conda 环境覆盖系统 Python 路径，导致与 ROS 2 系统安装的包冲突。常见故障包括：- ``rclpy`` 导入错误（Conda 的 Python 与系统 Python 版本不匹配）- 共享库加载失败（混合 ``libpython`` 版本）- ``cv_bridge`` 段错误（NumPy ABI 不兼容）

**解决方法**: 执行 ``setup.sh`` 前运行 ``conda deactivate``。

**来源**: `scripts/setup.sh:25-33 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/scripts/setup.sh#L25-L33>`__

--------------

完整依赖图
----------

以下图表映射设置期间安装的完整依赖链：

.. mermaid::

   graph TB
       SETUP["setup.sh"]
       
       subgraph "Phase 1: System Dependencies (rosdep)"
           ROSDEP_APT["apt packages:<br/>- ros-humble-*<br/>- python3-venv<br/>- python3-pip"]
           ROSDEP_ROS["ROS 2 packages:<br/>- usb_cam<br/>- image_transport<br/>- moveit_ros<br/>- gazebo_ros2_control"]
       end
       
       subgraph "Phase 2: Python venv"
           VENV_CORE["Core:<br/>- pip (latest)<br/>- numpy < 2<br/>- setuptools 71-79"]
           VENV_LEROBOT_PKG["LeRobot:<br/>- torch<br/>- transformers<br/>- datasets<br/>- diffusers"]
           VENV_HW["Hardware:<br/>- pyserial<br/>- feetech-servo-sdk"]
           VENV_UTILS["Utilities:<br/>- scipy<br/>- gitlint"]
       end
       
       subgraph "Phase 3: Git Submodules"
           SUBMOD_LEROBOT["libs/lerobot<br/>(editable install)"]
           SUBMOD_PYMOVEIT["src/pymoveit2<br/>(source package)"]
       end
       
       SETUP --> ROSDEP_APT
       SETUP --> ROSDEP_ROS
       SETUP --> VENV_CORE
       
       VENV_CORE --> VENV_LEROBOT_PKG
       VENV_CORE --> VENV_HW
       VENV_CORE --> VENV_UTILS
       
       VENV_LEROBOT_PKG --> SUBMOD_LEROBOT
       
       SETUP --> SUBMOD_LEROBOT
       SETUP --> SUBMOD_PYMOVEIT

**来源**: `scripts/setup.sh:182-278 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/scripts/setup.sh#L182-L278>`__

--------------

使用示例
--------

典型的首次设置：

.. code:: bash

   # 1. 克隆仓库
   git clone <repository-url> ~/ib_robot_ws
   cd ~/ib_robot_ws

   # 2. Source ROS 2
   source /opt/ros/humble/setup.bash

   # 3. 运行设置脚本
   ./scripts/setup.sh

   # 交互式提示:
   # - Initialize all submodules? [y/N]: y
   # - Enter GitCode username (leave empty to skip): <enter>

   # 4. 设置完成，激活 venv
   source venv/bin/activate

   # 5. 验证环境
   python3 -c "import rclpy; import lerobot; print('Environment ready')"

成功设置后，继续 `构建项目 <#2.2>`__。

**来源**: `scripts/setup.sh:1-307 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/scripts/setup.sh#L1-L307>`__

--------------

故障排除
--------


.. list-table::
   :header-rows: 1

   * - 问题
     - 症状
     - 解决方法
   * - **Conda 冲突**
     - ``Active Conda e nvironment detected``
     - 设置前运行 ``conda deactivate``
   * - **rosdep 失败**
     - ``ERROR: the follow ing packages/stacks c ould not have their r osdep keys resolved``
     - 更新 rosdep: ``rosdep upd ate --rosdistro=humble``
   * - **rclpy 导入错误**
     - ``Modu leNotFoundError: No m odule named 'rclpy'``
     - 使用 ``--system-site-packages`` 标志重建 venv
   * - **NumPy ABI 崩溃**
     - cv_bridge 中出现段错误
     - 确保 venv 中安装了 ``numpy<2``
   * - **子模块为空**
     - ``libs/lerobot`` 目录 存在但为空
     - 删除目录并重新运行 ``git s ubmodule update --init``
   * - **Git LFS 超时**
     - 大文件下载挂起
     - 克隆前设置 ``export GIT_LFS_SKIP_SMUDGE=1``

**来源**: `scripts/setup.sh:25-33 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/scripts/setup.sh#L25-L33>`__, `scripts/setup.sh:271-277 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/scripts/setup.sh#L271-L277>`__

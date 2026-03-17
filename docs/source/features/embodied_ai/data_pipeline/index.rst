数据服务
========

.. toctree::
   :titlesonly:
   :hidden:

   teleoperation_and_data_collection
   episode_recording
   dataset_conversion_bag_to_lerobot
   training_integration
   deployment_feedback_loop

.. raw:: html

   <details>

相关源文件

以下文件用作生成此文档页面的上下文：

-  `README.en.md <README.en.md>`__
-  `README.md <README.md>`__
-  `docs/architecture.md <docs/architecture.md>`__
-  `/image/architecture.png </image/architecture.png>`__
-  `docs/roadmap.md <docs/roadmap.md>`__
-  `scripts/build.sh <scripts/build.sh>`__
-  `src/README.md <src/README.md>`__
-  `src/action_dispatch/README.en.md <src/action_dispatch/README.en.md>`__
-  `src/action_dispatch/README.md <src/action_dispatch/README.md>`__
-  `src/action_dispatch/action_dispatch/action_dispatcher_node.py <src/action_dispatch/action_dispatch/action_dispatcher_node.py>`__
-  `src/dataset_tools/README.md <src/dataset_tools/README.md>`__
-  `src/dataset_tools/dataset_tools/bag_to_lerobot.py <src/dataset_tools/dataset_tools/bag_to_lerobot.py>`__
-  `src/dataset_tools/dataset_tools/episode_recorder.py <src/dataset_tools/dataset_tools/episode_recorder.py>`__
-  `src/inference_service/inference_service/lerobot_policy_node.py <src/inference_service/inference_service/lerobot_policy_node.py>`__
-  `src/robot_config/launch/robot.launch.py <src/robot_config/launch/robot.launch.py>`__
-  `src/robot_config/robot_config/config.py <src/robot_config/robot_config/config.py>`__
-  `src/robot_config/robot_config/contract_builder.py <src/robot_config/robot_config/contract_builder.py>`__
-  `src/robot_config/robot_config/contract_utils.py <src/robot_config/robot_config/contract_utils.py>`__
-  `src/robot_config/robot_config/launch_builders/execution.py <src/robot_config/robot_config/launch_builders/execution.py>`__
-  `src/robot_config/robot_config/launch_builders/recording.py <src/robot_config/robot_config/launch_builders/recording.py>`__

.. raw:: html

   </details>

目的与范围
----------

本文档描述 IB-Robot 中的完整数据服务，涵盖从人类示教到数据集创建、模型训练以及部署回机器人的端到端流程。该管道实现了**契约驱动架构**，确保训练数据与部署观测之间的一致性，消除了机器学习部署中常见的训练-服务偏差问题。

关于管道内特定子系统，请参阅：- 遥操作接口与数据采集工作流：`9.1 <#9.1>`__ - 回合录制实现细节：`9.2 <#9.2>`__ - 数据集转换工具（``bag_to_lerobot``）：`9.3 <#9.3>`__ - 外部训练集成：`9.4 <#9.4>`__ - 在线评估与反馈循环：`9.5 <#9.5>`__

**来源**：README.md:1-192, docs/architecture.md:1-313

--------------

系统概述
--------

IB-Robot 数据服务通过系统化的流程将人类专家示教转化为可部署的 AI 策略。其核心创新在于使用 **robot_config YAML 作为唯一事实来源**，其中契约定义贯穿所有管道阶段，保证训练数据与部署观测经过相同的处理。

该管道包含六个主要阶段：


.. list-table::
   :header-rows: 1

   * - 阶段
     - 目的
     - 关键组件
     - 输出
   * - **采集**
     - 捕捉专家示教
     - ``robot_teleop``、遥操作设备
     - 人类控制信号
   * - **录制**
     - 保存多模态传感器数据
     - ``episode_recorder``、``record_cli``
     - ROS2 bag 文件（MCAP 格式）
   * - **转换**
     - 转换为训练格式
     - ``bag_to_lerobot``
     - LeRobot v3 数据集（parquet + video）
   * - **训练**
     - 从示教中学习策略
     - 外部 ``lerobot`` 库
     - 策略检查点（.pt 文件）
   * - **部署**
     - 执行学习到的策略
     - ``lerobot_policy_node``、``action_dispatcher_node``
     - 机器人动作
   * - **评估**
     - 记录部署性能
     - 可选的 ``episode_recorder``
     - 用于迭代的新回合

**来源**：README.md:1-192, src/dataset_tools/dataset_tools/bag_to_lerobot.py:1-73

--------------

端到端管道架构
--------------

.. mermaid::

   graph TB
       subgraph "Phase_1[Phase 1: Data Collection]"
           Human["Human Expert<br/>(VR/Xbox/IMU controller)"]
           TeleopNode["robot_teleop node<br/>(package: robot_teleop)"]
           Robot1["Physical Robot<br/>Execution"]
           
           Human -->|control signals| TeleopNode
           TeleopNode -->|/joint_commands| Robot1
       end
       
       subgraph "Phase_2[Phase 2: Recording]"
           RecorderServer["episode_recorder<br/>(EpisodeRecorderServer)"]
           RecordCLI["record_cli<br/>(interactive trigger)"]
           Sensors["Multimodal Sensors<br/>(cameras + /joint_states)"]
           BagFiles["ROS2 Bag Files<br/>(MCAP storage)"]
           
           Robot1 --> Sensors
           Sensors -->|subscribe topics| RecorderServer
           RecordCLI -->|RecordEpisode Action| RecorderServer
           RecorderServer -->|rosbag2_py.SequentialWriter| BagFiles
       end
       
       subgraph "Phase_3[Phase 3: Dataset Conversion]"
           BagToLR["bag_to_lerobot<br/>(export_bags_to_lerobot)"]
           RobotConfig["robot_config YAML<br/>(Contract definition)"]
           LRDataset["LeRobot v3 Dataset<br/>(videos/ + data/)"]
           
           BagFiles --> BagToLR
           RobotConfig -.->|"Contract (Single Source of Truth)"| BagToLR
           BagToLR -->|"LeRobotDataset.create()"| LRDataset
       end
       
       subgraph "Phase_4[Phase 4: Training (External)]"
           LRLib["lerobot library<br/>(Hugging Face)"]
           PolicyCkpt["Policy Checkpoint<br/>(.pt file)"]
           
           LRDataset --> LRLib
           LRLib -->|"train(policy_type='act')"| PolicyCkpt
       end
       
       subgraph "Phase_5[Phase 5: Deployment]"
           PolicyNode["lerobot_policy_node<br/>(LeRobotPolicyNode)"]
           DispatchNode["action_dispatcher_node<br/>(ActionDispatcherNode)"]
           Sensors2["Multimodal Sensors<br/>(runtime)"]
           Robot2["Physical Robot<br/>Execution"]
           
           PolicyCkpt --> PolicyNode
           RobotConfig -.->|"same Contract"| PolicyNode
           Sensors2 -->|observations| PolicyNode
           PolicyNode -->|"DispatchInfer Action"| DispatchNode
           DispatchNode -->|/joint_commands| Robot2
           Robot2 --> Sensors2
       end
       
       subgraph "Phase_6[Phase 6: Feedback Loop (Optional)]"
           RecorderServer2["episode_recorder<br/>(online evaluation)"]
           BagFiles2["New Episodes<br/>(iterative improvement)"]
           
           Robot2 -.->|deployment data| RecorderServer2
           RecorderServer2 -.-> BagFiles2
           BagFiles2 -.-> BagToLR
       end
       
       style RobotConfig fill:#fff3e0,stroke:#ff9800,stroke-width:3px

**图表**：完整数据服务流程

此图展示了 ``robot_config.yaml`` 中的契约如何作为唯一事实来源，确保 ``bag_to_lerobot`` 和 ``lerobot_policy_node`` 以相同方式处理数据。

**来源**：README.md:1-192, src/dataset_tools/dataset_tools/bag_to_lerobot.py:1-718, src/dataset_tools/dataset_tools/episode_recorder.py:1-650

--------------

阶段一：数据采集
----------------

人类专家使用遥操作接口控制机器人。系统支持多种输入设备，由 ``robot_teleop`` 包处理（详见 `9.1 <#9.1>`__）。在遥操作过程中，机器人实时执行动作，同时所有传感器数据流传输到 ROS2 话题。

**支持的遥操作模式**：- **VR 控制器**：6-DOF 空间追踪，用于直观操作- **Xbox 手柄**：按钮/摇杆映射，用于离散控制- **移动端 IMU**：手机方向传感器，用于末端执行器控制- **主从臂**：直接运动学对应

遥操作节点发布到 ``/joint_commands`` 或 ``/arm_position_controller/commands`` 等话题，然后由机器人的 ros2_control 层执行。

**来源**：README.md:27-29, src/robot_config/robot_config/launch_builders/recording.py:1-226

--------------

阶段二：回合录制
----------------

录制架构
~~~~~~~~

系统提供两种录制模式，均在 ``dataset_tools`` 包中实现：

连续录制模式
^^^^^^^^^^^^

传统的 ``ros2 bag record``，从启动到关闭持续捕获所有话题。生成单个 MCAP 文件。

**启动命令**：

.. code:: bash

   ros2 launch robot_config robot.launch.py record:=true

**实现**：`src/robot_config/robot_config/launch_builders/recording.py:58-100 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/launch_builders/recording.py#L58-L100>`__

回合录制模式
^^^^^^^^^^^^

基于动作服务器的触发式录制，将每个示教保存为带有语义元数据（操作员提示）的独立回合。这是模仿学习数据集的**推荐模式**。

**启动命令**：

.. code:: bash

   ros2 launch robot_config robot.launch.py record:=true record_mode:=episodic
   # 在另一个终端：
   ros2 run dataset_tools record_cli

**实现**：`src/robot_config/robot_config/launch_builders/recording.py:102-169 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/launch_builders/recording.py#L102-L169>`__

回合录制器内部架构
~~~~~~~~~~~~~~~~~~

.. mermaid::

   graph TB
       subgraph "EpisodeRecorderServer Node"
           ActionServer["RecordEpisode Action Server<br/>(ibrobot_msgs/action/RecordEpisode)"]
           CancelService["Trigger Service<br/>(record_episode/cancel)"]
           
           subgraph "Contract-Driven Subscriptions"
               ObsSubs["Observation Subscriptions<br/>(from contract.observations)"]
               TaskSubs["Task Subscriptions<br/>(from contract.tasks)"]
               ActionSubs["Action Subscriptions<br/>(from contract.actions)"]
           end
           
           WriterLock["WriterState<br/>(threading.Lock)"]
           BagWriter["rosbag2_py.SequentialWriter<br/>(MCAP storage)"]
           
           Timers["Episode Timers<br/>(feedback + timeout)"]
       end
       
       RecordCLI["record_cli<br/>(interactive prompt)"]
       RobotConfig["robot_config.yaml<br/>(Contract)"]
       
       RecordCLI -->|"send_goal_async(prompt='...')"| ActionServer
       CancelService -->|"cancel current episode"| ActionServer
       
       RobotConfig -.->|"defines topics/types/QoS"| ObsSubs
       RobotConfig -.->|"defines topics/types/QoS"| TaskSubs
       RobotConfig -.->|"defines topics/types/QoS"| ActionSubs
       
       ActionServer -->|"start recording"| WriterLock
       WriterLock --> BagWriter
       
       ObsSubs -->|"serialize_message()"| BagWriter
       TaskSubs -->|"serialize_message()"| BagWriter
       ActionSubs -->|"serialize_message()"| BagWriter
       
       ActionServer --> Timers
       Timers -.->|"timeout after max_duration_s"| ActionServer

**图表**：回合录制器架构

``EpisodeRecorderServer`` 节点在启动时根据契约创建订阅，然后在录制会话期间将传入消息直接写入 bag。此阶段不进行缓冲或对齐。

**关键设计决策**：- **流式写入 bag**：消息在接收时立即写入，最小化内存开销- **契约驱动订阅**：所有话题/类型/QoS 来自 ``contract.observations``、``contract.tasks`` 和 ``contract.actions``- **元数据嵌入**：操作员提示写入 bag 的 ``metadata.yaml`` custom_data 字段- **线程安全写入器**：``WriterState.writer_lock`` 保护并发访问

**来源**：src/dataset_tools/dataset_tools/episode_recorder.py:1-650, src/robot_config/robot_config/launch_builders/recording.py:102-169

录制输出结构
~~~~~~~~~~~~

每个回合保存为一个目录，包含：

::

   ~/rosbag_demos/episodes/1234567890_123456789/
   ├── metadata.yaml          # Bag 元数据 + 操作员提示
   └── rosbag.mcap            # MCAP 格式的所有消息

``metadata.yaml`` 文件嵌入契约指纹和操作员提示：

.. code:: yaml

   rosbag2_bagfile_information:
     duration:
       nanoseconds: 45000000000  # 45 秒
     custom_data:
       lerobot.operator_prompt: "pick up the red cube"
       ibrobot.contract_fingerprint: "sha256:abc123..."

**来源**：src/dataset_tools/dataset_tools/episode_recorder.py:314-371

--------------

阶段三：数据集转换
------------------

契约驱动转换
~~~~~~~~~~~~

``bag_to_lerobot`` 工具将 ROS2 bag 转换为 LeRobot v3 数据集格式。其关键设计原则是**使用与推理管道完全相同的契约和处理工具**，保证训练-部署一致性。

.. mermaid::

   graph TB
       subgraph "bag_to_lerobot Processing Pipeline"
           Input["ROS2 Bag Files<br/>(MCAP format)"]
           
           subgraph "Contract Loading"
               LoadConfig["load_robot_config()<br/>(from robot_config.yaml)"]
               ToContract["robot_config.to_contract()<br/>(synthesize Contract)"]
               IterSpecs["iter_specs(contract)<br/>(extract SpecViews)"]
           end
           
           subgraph "Message Decoding (Shared with Inference)"
               DecodeValue["decode_value()<br/>(from contract_utils)"]
               StampSelect["stamp_from_header_ns()<br/>(timestamp selection)"]
           end
           
           subgraph "Resampling (Shared with Inference)"
               Resample["resample()<br/>(policy: hold/asof/drop)"]
               AlignTicks["align to rate_hz ticks<br/>(contract.rate_hz)"]
           end
           
           subgraph "Feature Synthesis (Shared with Inference)"
               FeatureFromSpec["feature_from_spec()<br/>(shape + dtype)"]
               ZeroPad["zero_pad()<br/>(missing value handling)"]
           end
           
           Output["LeRobot v3 Dataset<br/>(videos/ + data/)"]
       end
       
       RobotConfigYAML["robot_config.yaml<br/>(Single Source of Truth)"]
       
       Input --> LoadConfig
       RobotConfigYAML -.->|"loaded by"| LoadConfig
       LoadConfig --> ToContract
       ToContract --> IterSpecs
       
       IterSpecs --> DecodeValue
       DecodeValue --> StampSelect
       StampSelect --> Resample
       Resample --> AlignTicks
       AlignTicks --> FeatureFromSpec
       FeatureFromSpec --> ZeroPad
       ZeroPad --> Output
       
       style RobotConfigYAML fill:#fff3e0,stroke:#ff9800,stroke-width:3px

**图表**：bag_to_lerobot 处理管道

此处显示的每个函数（蓝色方框中）都是离线转换与在线推理之间的**共享代码**，确保处理方式一致。

**来源**：src/dataset_tools/dataset_tools/bag_to_lerobot.py:1-718, src/robot_config/robot_config/contract_utils.py:1-800

转换流程
~~~~~~~~

转换遵循以下步骤：

**1. 从 robot_config.yaml 加载契约**

`src/dataset_tools/dataset_tools/bag_to_lerobot.py:216-231 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/dataset_tools/bag_to_lerobot.py#L216-L231>`__

.. code:: python

   def _load_contract_from_robot_config(robot_config_path: Path) -> Contract:
       from robot_config.loader import load_robot_config
       robot_config = load_robot_config(str(robot_config_path))
       contract = robot_config.to_contract()
       return contract

**2. 根据契约规划流**

`src/dataset_tools/dataset_tools/bag_to_lerobot.py:151-211 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/dataset_tools/bag_to_lerobot.py#L151-L211>`__

为每个观测和动作规格创建一个 ``_Stream`` 缓冲区，检查 bag 是否包含所需话题。

**3. 使用共享的 ``decode_value()`` 解码消息**

`src/dataset_tools/dataset_tools/bag_to_lerobot.py:454-482 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/dataset_tools/bag_to_lerobot.py#L454-L482>`__

使用 ``lerobot_policy_node`` 在推理期间使用的**完全相同的解码器**：

.. code:: python

   val = decode_value(st.ros_type, msg, sv)

**4. 按契约频率重采样**

`src/dataset_tools/dataset_tools/bag_to_lerobot.py:517-532 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/dataset_tools/bag_to_lerobot.py#L517-L532>`__

使用指定的 ``resample_policy``（hold/asof/drop）将所有流重采样到契约的 ``rate_hz``：

.. code:: python

   resampled[key] = resample(
       pol, ts, st.val, ticks_ns, step_ns, st.spec.asof_tol_ms
   )

**5. 构建特征字典**

`src/dataset_tools/dataset_tools/bag_to_lerobot.py:288-363 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/dataset_tools/bag_to_lerobot.py#L288-L363>`__

使用 ``feature_from_spec()`` 生成特征元数据，确保张量形状与模型期望完全匹配。

**6. 写入 LeRobot 数据集**

`src/dataset_tools/dataset_tools/bag_to_lerobot.py:372-648 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/dataset_tools/bag_to_lerobot.py#L372-L648>`__

使用 LeRobot 的 ``LeRobotDataset.create()`` API 写入 parquet 文件和视频文件：

.. code:: python

   ds = LeRobotDataset.create(
       repo_id=repo_id,
       fps=int(contract.rate_hz),
       features=features,
       use_videos=use_videos,
   )

输出数据集结构
~~~~~~~~~~~~~~

转换后的数据集遵循 LeRobot v3 格式：

::

   output/
   ├── videos/
   │   ├── observation.images.top/
   │   │   └── chunk-000/
   │   │       └── file-000.mp4
   │   └── observation.images.wrist/
   │       └── chunk-000/
   │           └── file-000.mp4
   ├── data/
   │   └── chunk-000/
   │       └── file-000.parquet  # observation.state, action, timestamps
   ├── meta/
   │   ├── info.json             # 数据集元数据 + ibrobot_fingerprint
   │   ├── tasks.parquet         # 任务提示
   │   ├── stats.json            # 数据集统计信息
   │   └── episodes/
   │       └── 000000/
   │           └── episode.parquet  # 每回合元数据

**关键文件**：- ``meta/info.json``：包含契约指纹，用于训练期间验证- ``data/*.parquet``：observation.state、actions 和时间戳的列式存储- ``videos/*.mp4``：H.264 编码视频流（若使用 ``--no-videos`` 则为 ``images/*.png``）

**来源**：src/dataset_tools/dataset_tools/bag_to_lerobot.py:59-72, src/dataset_tools/dataset_tools/bag_to_lerobot.py:639-648

处理多个 observation.state 规格
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

当契约包含来自不同话题的多个 ``observation.state`` 规格（如 ``/joint_states`` + ``/gripper_state``）时，``bag_to_lerobot`` 会将其合并：

`src/dataset_tools/dataset_tools/bag_to_lerobot.py:329-342 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/dataset_tools/bag_to_lerobot.py#L329-L342>`__

.. code:: python

   if state_specs:
       all_names = []
       total_shape = 0
       for sv in state_specs:
           all_names.extend(sv.names)
           total_shape += len(sv.names)
       
       features["observation.state"] = {
           "dtype": "float32",
           "shape": (total_shape,),
           "names": all_names
       }

在帧组装期间，值会被拼接：

`src/dataset_tools/dataset_tools/bag_to_lerobot.py:538-556 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/dataset_tools/bag_to_lerobot.py#L538-L556>`__

**来源**：src/dataset_tools/dataset_tools/bag_to_lerobot.py:329-556

--------------

阶段四：训练集成
----------------

训练在 Hugging Face LeRobot 库中**外部进行**。IB-Robot 以 LeRobot v3 格式提供数据集，该库处理所有训练逻辑。

训练工作流
~~~~~~~~~~

**1. 推送数据集到 Hugging Face Hub（可选）**

.. code:: bash

   python -m lerobot.common.datasets.push_dataset_to_hub \
       --repo-id <username>/rosbag_v30 \
       --local-dir output/

**2. 训练策略**

.. code:: bash

   python lerobot/scripts/train.py \
       policy=act \
       dataset_repo_id=<username>/rosbag_v30 \
       training.offline_steps=50000

**3. 检查点输出** 训练脚本将检查点保存到：

::

   outputs/<timestamp>/checkpoints/
   └── last/
       ├── pretrained_model/
       │   ├── config.json        # 模型架构 + input_features
       │   └── model.safetensors  # 训练权重
       └── training_state.pth     # 优化器状态

支持的策略类型
~~~~~~~~~~~~~~

LeRobot 库支持多种 IB-Robot 可部署的策略架构：


.. list-table::
   :header-rows: 1

   * - 策略类型
     - 描述
     - 典型用例
   * - **ACT**
     - Action Chunking Transformer
     - 具有时序依赖的操作任务
   * - **Diffusion Policy**
     - 去噪扩散用于动作序列
     - 复杂、多模态动作分布
   * - **TDMPC**
     - Temporal Difference Model Predictive Control
     - 基于模型的强化学习
   * - **VLA (Vision- Language-Action)**
     - 大型多模态模型 （如 OpenVLA）
     - 自然语言条件化任务

**来源**：README.md:33-35, docs/architecture.md:199-202

--------------

阶段五：部署
------------

策略加载与推理
~~~~~~~~~~~~~~

训练后的策略由 ``lerobot_policy_node`` 加载，该节点使用**相同的契约**处理运行时观测。

.. mermaid::

   graph TB
       subgraph "lerobot_policy_node Initialization"
           LoadPolicyConfig["Load config.json<br/>(model's input_features)"]
           LoadRobotConfig["Load robot_config.yaml<br/>(all available observations)"]
           FilterObs["Filter observations<br/>(intersect input_features)"]
           CreateSubs["Create subscriptions<br/>(filtered observations only)"]
       end
       
       subgraph "Runtime Inference Loop"
           ActionGoal["DispatchInfer Goal<br/>(from action_dispatcher_node)"]
           SampleObs["_sample_obs_frame()<br/>(from StreamBuffers)"]
           
           subgraph "Shared Processing (Same as Conversion)"
               DecodeValue2["decode_value()<br/>(decode messages)"]
               Resample2["StreamBuffer.sample()<br/>(timestamp alignment)"]
           end
           
           InferCoord["InferenceCoordinator<br/>(or distributed mode)"]
           ActionResult["DispatchInfer Result<br/>(action chunk tensor)"]
       end
       
       PolicyCkpt["Policy Checkpoint<br/>(.pt file)"]
       RobotConfigYAML2["robot_config.yaml<br/>(Single Source of Truth)"]
       
       PolicyCkpt --> LoadPolicyConfig
       RobotConfigYAML2 -.-> LoadRobotConfig
       LoadPolicyConfig --> FilterObs
       LoadRobotConfig --> FilterObs
       FilterObs --> CreateSubs
       
       ActionGoal --> SampleObs
       CreateSubs -.->|"messages pushed to StreamBuffers"| SampleObs
       SampleObs --> DecodeValue2
       DecodeValue2 --> Resample2
       Resample2 --> InferCoord
       InferCoord --> ActionResult
       
       style RobotConfigYAML2 fill:#fff3e0,stroke:#ff9800,stroke-width:3px

**图表**：部署推理管道

关键保证是 ``decode_value()`` 和 ``StreamBuffer.sample()`` 是 ``bag_to_lerobot`` 使用的**完全相同的函数**，确保训练-部署一致性。

**来源**：src/inference_service/inference_service/lerobot_policy_node.py:1-700, src/robot_config/robot_config/contract_utils.py:1-800

按模型需求过滤观测
~~~~~~~~~~~~~~~~~~

``lerobot_policy_node`` 根据模型的 ``config.json`` 自动过滤观测：

`src/inference_service/inference_service/lerobot_policy_node.py:180-204 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/lerobot_policy_node.py#L180-L204>`__

.. code:: python

   def _load_policy_config(self):
       config_path = Path(policy_path) / "config.json"
       with open(config_path, "r") as f:
           self._policy_config = json.load(f)
       
       # Extract required input features
       input_features = self._policy_config.get("input_features", {})
       self._required_inputs = set(input_features.keys())

`src/inference_service/inference_service/lerobot_policy_node.py:216-231 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/lerobot_policy_node.py#L216-L231>`__

.. code:: python

   # Filter by model's required inputs
   if self._required_inputs:
       self._obs_specs = [
           s for s in all_obs_specs 
           if s.key in self._required_inputs
       ]

这允许**单个 robot_config.yaml** 支持具有不同观测需求的多个模型。硬件配置（契约）定义所有**可用**观测，而每个模型的 ``config.json`` 指定其**需要**的子集。

**来源**：src/inference_service/inference_service/lerobot_policy_node.py:180-241

--------------

阶段六：反馈循环
----------------

在线评估录制
~~~~~~~~~~~~

在部署期间，相同的 ``episode_recorder`` 可选择性地录制策略执行，用于评估或作为额外的训练数据：

.. code:: bash

   # 终端 1：部署策略
   ros2 launch robot_config robot.launch.py \
       control_mode:=model_inference \
       record:=true \
       record_mode:=episodic

   # 终端 2：触发评估回合录制
   ros2 run dataset_tools record_cli

这创建了一个**持续改进循环**：1. 部署训练后的策略 2. 录制执行回合 3. 转换为 LeRobot 格式 4. 与原始训练数据合并或微调 5. 重新部署改进后的策略

领域适应用例
~~~~~~~~~~~~

反馈循环对于**领域适应**特别有价值：


.. list-table::
   :header-rows: 1

   * - 训练数据
     - 部署环境
     - 适应策略
   * - 仿真示教
     - 真实机器人
     - 录制真实机器人修正，微调策略
   * - 实验室示教
     - 生产环境
     - 录制生产失败案例，扩充训练集
   * - 单物体示教
     - 多物体场景
     - 录制成功泛化案例，更新数据集

**来源**：src/robot_config/robot_config/launch_builders/recording.py:102-169

--------------

关键设计原则
------------

1. 契约作为唯一事实来源
~~~~~~~~~~~~~~~~~~~~~~

``robot_config.yaml`` 中的契约定义贯穿每个管道阶段：


.. list-table::
   :header-rows: 1

   * - 管道阶段
     - 契约用途
   * - **录制**
     - 定义订阅的话题及其 QoS 设置
   * - **转换**
     - 定义如何解码消息和重采样流
   * - **推理**
     - 定义收集哪些观测以及如何处理它们

此架构消除了训练与部署之间的配置漂移。

**来源**：src/dataset_tools/dataset_tools/bag_to_lerobot.py:14-19, src/robot_config/robot_config/contract_utils.py:1-100

2. 离线与在线共享代码
~~~~~~~~~~~~~~~~~~~~

以下函数在转换和推理中**完全相同**：


.. list-table::
   :header-rows: 1

   * - 函数
     - 用途
     - 位置
   * - ``decode_value()``
     - 将 ROS 消息解码为 Python/NumPy
     - `robot_config/contract_utils.py:400-500 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/robot_config/contract_utils.py#L400-L500>`__
   * - ``resample()``
     - 流的时间对齐
     - `robot_config/contract_utils.py:600-700 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/robot_config/contract_utils.py#L600-L700>`__
   * - ``feature_from_spec()``
     - 生成特征元数据
     - `robot_config/contract_utils.py:200-300 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/robot_config/contract_utils.py#L200-L300>`__
   * - ``zero_pad()``
     - 处理缺失观测
     - `robot_config/contract_utils.py:180-200 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/robot_config/contract_utils.py#L180-L200>`__

**来源**：src/dataset_tools/dataset_tools/bag_to_lerobot.py:92-108, src/robot_config/robot_config/contract_utils.py:1-800

3. 时间戳对齐策略
~~~~~~~~~~~~~~~~

契约支持三种时间戳选择策略：


.. list-table::
   :header-rows: 1

   * - 策略
     - 行为
     - 用例
   * - ``contract``
     - 使用每个规格的 ``stamp_src`` 设置
     - 混合来源（部分 header，部分 receive）
   * - ``receive``
     - 使用 bag 接收时间戳
     - 无 header 的低延迟传感器
   * - ``header``
     - 使用消息 header 时间戳
     - 带硬件时间戳的相机

重采样策略：

======== ============================= ===============================
策略     行为                          用例
======== ============================= ===============================
``hold`` 前向填充最后一个有效值       关节状态（无插值）
``asof`` 返回容差范围内的值           同步流
``drop`` 无匹配时设为零               可选观测
======== ============================= ===============================

**来源**：src/dataset_tools/dataset_tools/bag_to_lerobot.py:244-273, src/robot_config/robot_config/contract_utils.py:600-700

4. 视频编码优化
~~~~~~~~~~~~~~

对于图像观测，管道支持两种存储格式：

**视频模式**\ （默认，``use_videos=True``）：- 将图像流编码为 H.264 MP4 文件- 显著减少数据集大小（10-50 倍压缩）- 需要支持 H.264 编码器的 ``opencv-python``

**图像模式**\ （``--no-videos``）：- 每帧存储单独的 PNG 文件- 存储占用更大但调试更简单- 无编码器依赖

**来源**：src/dataset_tools/dataset_tools/bag_to_lerobot.py:238-243

--------------

命令参考
--------

录制命令
~~~~~~~~

**连续录制**：

.. code:: bash

   ros2 launch robot_config robot.launch.py \
       robot_config:=so101_single_arm \
       control_mode:=teleop \
       record:=true

**回合录制**：

.. code:: bash

   # 终端 1：启动录制器
   ros2 launch robot_config robot.launch.py \
       robot_config:=so101_single_arm \
       control_mode:=teleop \
       record:=true \
       record_mode:=episodic

   # 终端 2：交互式录制触发
   ros2 run dataset_tools record_cli

**来源**：src/robot_config/robot_config/launch_builders/recording.py:45-50

转换命令
~~~~~~~~

**单个 Bag 转换**：

.. code:: bash

   python -m dataset_tools.bag_to_lerobot \
       --bag /path/to/episode_dir \
       --robot-config /path/to/robot_config.yaml \
       --out /path/to/output

**多个 Bag 转换**：

.. code:: bash

   python -m dataset_tools.bag_to_lerobot \
       --bags /path/to/ep1 /path/to/ep2 /path/to/ep3 \
       --robot-config /path/to/robot_config.yaml \
       --out /path/to/output \
       --repo-id my_dataset_v1

**转换选项**：- ``--timestamp {contract,bag,header}``：时间戳选择策略- ``--no-videos``：存储 PNG 图像而非 MP4 视频- ``--chunk-size 1000``：Parquet/视频分块大小- ``--image-threads 4``：并行图像编码线程数

**来源**：src/dataset_tools/dataset_tools/bag_to_lerobot.py:653-694

--------------

故障排除
--------

Bag 转换失败并提示"No contract topics found"
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**原因**：bag 中的话题与契约定义不匹配。

**解决方案**：检查：1. 指定了正确的 ``robot_config.yaml`` 2. bag 包含与 ``contract.observations`` 和 ``contract.actions`` 匹配的话题 3. 运行 ``ros2 bag info /path/to/bag`` 检查可用话题

**来源**：src/dataset_tools/dataset_tools/bag_to_lerobot.py:176-210

时间戳对齐问题
~~~~~~~~~~~~~~

**症状**：数据集帧大多为零值或严重错位。

**原因**：契约中的 ``resample_policy`` 或 ``asof_tol_ms`` 设置不正确。

**解决方案**：- 对关节状态使用 ``hold`` 策略（无需插值）- 对同步相机使用 ``asof`` 策略并设置适当容差- 如果消息到达有抖动，增加 ``asof_tol_ms``

**来源**：src/robot_config/robot_config/contract_utils.py:600-700

视频编码失败
~~~~~~~~~~~~

**症状**：``bag_to_lerobot`` 在写入视频时崩溃。

**原因**：OpenCV 缺少 H.264 编码器支持。

**解决方案**：

.. code:: bash

   # 选项 1：使用图像模式
   python -m dataset_tools.bag_to_lerobot --no-videos ...

   # 选项 2：安装支持 H.264 的 OpenCV
   pip install opencv-python-headless

**来源**：src/dataset_tools/dataset_tools/bag_to_lerobot.py:238-243

--------------



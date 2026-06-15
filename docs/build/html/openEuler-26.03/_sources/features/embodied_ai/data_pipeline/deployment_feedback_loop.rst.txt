部署反馈循环
============

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
-  `src/action_dispatch/action_dispatch/action_dispatcher_node.py <src/action_dispatch/action_dispatch/action_dispatcher_node.py>`__
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

本文档介绍 IB-Robot 中的部署反馈循环机制，该机制通过记录部署机器人的数据并将其反馈到训练流水线，实现持续改进和域适应。

**范围**：本文档涵盖部署期间的在线评估数据收集、与 episode recorder 的集成，以及将部署数据纳入训练的工作流程。有关初始演示数据收集，请参阅 `Episode Recording <#9.2>`__。有关数据集转换详情，请参阅 `Dataset Conversion (bag_to_lerobot) <#9.3>`__。

--------------

概述
----

部署反馈循环通过使部署的机器人记录其真实世界执行数据用于后续训练迭代，从而闭合数据生命周期。这支持：

-  **域适应**：使模型适应初始训练期间未见的新环境或任务
-  **失败分析**：记录失败案例以进行针对性重新训练
-  **性能改进**：收集边缘案例和困难场景
-  **持续学习**：随时间逐步提升模型性能

反馈循环与现有数据流水线无缝集成，使用与初始数据收集相同的工具（``episode_recorder``、``bag_to_lerobot``）。

**来源**：README.md:74-78, docs/architecture.md:70-78

--------------

反馈循环架构
------------

以下图表显示部署反馈如何集成到整体数据生命周期：

.. mermaid::

   graph TB
       subgraph "Phase 5: Deployment"
           INF["lerobot_policy_node<br/>(Inference)"]
           DISP["action_dispatcher_node"]
           ROBOT["Physical Robot"]
           
           INF -->|"action chunks"| DISP
           DISP -->|"execute"| ROBOT
       end
       
       subgraph "Phase 6: Feedback Loop (Optional)"
           RECORD["episode_recorder<br/>(Action Server)"]
           CLI["record_cli<br/>(Manual trigger)"]
           AUTO["Automatic trigger<br/>(Future)"]
           
           CLI -.->|"trigger recording"| RECORD
           AUTO -.->|"on failure/success"| RECORD
           
           ROBOT -->|"observations + actions"| RECORD
           RECORD -->|"ROS2 Bag"| BAG["Deployment Episode<br/>(MCAP)"]
       end
       
       subgraph "Phase 7: Dataset Update"
           BAG -->|"bag_to_lerobot"| CONVERT["Dataset Conversion"]
           CONVERT -->|"append to dataset"| DS["LeRobot v3 Dataset<br/>(Updated)"]
           
           DS -->|"retrain"| TRAIN["lerobot library<br/>(Training)"]
           TRAIN -->|"new checkpoint"| MODEL["Updated Policy<br/>(.pt file)"]
       end
       
       MODEL -.->|"redeploy"| INF
       
       style RECORD fill:#fff3e0,stroke:#ff9800,stroke-width:2px
       style BAG fill:#f3e5f5,stroke:#9c27b0,stroke-width:2px
       style DS fill:#f3e5f5,stroke:#9c27b0,stroke-width:2px

**关键工作流程**：1. 机器人运行部署的策略（``lerobot_policy_node``）2. 操作员触发记录（``record_cli``）或自动触发器激活 3. Episode recorder 捕获包含观测和动作的 ROS2 bag 4. Bag 转换为 LeRobot 格式并追加到数据集 5. 模型在增强数据集上重新训练 6. 更新的模型重新部署

**来源**：README.md:74-78,
src/dataset_tools/dataset_tools/bag_to_lerobot.py:1-73,
src/dataset_tools/dataset_tools/episode_recorder.py:1-60

--------------

部署期间的记录模式
------------------

IB-Robot 支持两种可在部署期间使用的记录模式：


.. list-table::
   :header-rows: 1

   * - 模式
     - 描述
     - 用例
     - 触发方式
   * - **Epis odic**
     - 按需记录 单个 episode
     - 选择性记录 有趣的案例
     - 手动 (``record_cli``) 或 程序化
   * - ** Contin uous**
     - 从启动到 关闭记录所有内容
     - 完整部署 日志记录
     - 自动（启动参数）

Episodic 记录（推荐用于反馈循环）
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Episodic 记录是部署反馈的首选模式，因为它允许选择性捕获特定场景：

.. code:: bash

   # 启动机器人并启用 episodic 记录
   ros2 launch robot_config robot.launch.py \
       robot_config:=so101_single_arm \
       control_mode:=model_inference \
       use_sim:=false \
       record:=true \
       record_mode:=episodic

这会在后台启动 ``episode_recorder`` Action Server。要在单独的终端中触发记录，运行：

.. code:: bash

   ros2 run dataset_tools record_cli

CLI 会提示输入操作员描述（任务提示），该描述嵌入在 bag 元数据中。

**来源**：src/robot_config/launch/robot.launch.py:28-33,
src/robot_config/robot_config/launch_builders/recording.py:102-168

Continuous 记录
~~~~~~~~~~~~~~~

Continuous 记录自动捕获所有部署数据：

.. code:: bash

   # 启动 continuous 记录
   ros2 launch robot_config robot.launch.py \
       robot_config:=so101_single_arm \
       control_mode:=model_inference \
       record:=true \
       record_mode:=continuous

这会在 ``~/rosbag/<robot_name>_<timestamp>.mcap`` 创建单个 bag 文件，从启动记录到关闭。

**来源**：
src/robot_config/robot_config/launch_builders/recording.py:58-100

--------------

Episode Recorder 集成
---------------------

Action Server 接口
~~~~~~~~~~~~~~~~~~

``episode_recorder`` 节点暴露一个管理记录生命周期的 ``RecordEpisode`` Action Server：

.. mermaid::

   graph LR
       subgraph "Client Side"
           CLI["record_cli"]
           CUSTOM["Custom trigger<br/>(Python/C++)"]
       end
       
       subgraph "Episode Recorder Node"
           SERVER["RecordEpisode<br/>Action Server"]
           WRITER["rosbag2<br/>SequentialWriter"]
           SUBS["Topic Subscriptions<br/>(from contract)"]
       end
       
       CLI -->|"RecordEpisode.Goal<br/>(prompt)"| SERVER
       CUSTOM -->|"RecordEpisode.Goal"| SERVER
       
       SERVER -->|"open bag"| WRITER
       SUBS -->|"stream messages"| WRITER
       
       SERVER -.->|"Feedback<br/>(seconds_remaining)"| CLI
       SERVER -.->|"Result<br/>(success/message)"| CLI

**Action 定义**\ （`ibrobot_msgs/action/RecordEpisode.action <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/ibrobot_msgs/action/RecordEpisode.action>`__）：
- **Goal**：``string prompt`` - 操作员对任务的描述 - **Feedback**：``int32 seconds_remaining``，``string feedback_message`` - **Result**：``bool success``，``string message``，``string bag_path``

**来源**：src/dataset_tools/dataset_tools/episode_recorder.py:243-273

契约驱动的订阅
~~~~~~~~~~~~~~

Episode recorder 使用 robot_config 契约作为记录哪些话题的单一数据源：

`src/dataset_tools/dataset_tools/episode_recorder.py:229-242 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/dataset_tools/episode_recorder.py#L229-L242>`__

.. code:: python

   # Derive unified topic list from contract sections
   obs = self._contract.observations or []
   tks = self._contract.tasks or []
   acts = self._contract.actions or []
   self._topics: list[Tuple[str, str, Dict]] = []
   self._topics += [(o.topic, o.type, o.qos or {}) for o in obs]
   self._topics += [(t.topic, t.type, t.qos or {}) for t in tks]
   self._topics += [(a.publish_topic, a.type, a.publish_qos or {}) for a in acts]

这确保部署记录捕获与模型训练时完全相同的观测和动作。

**来源**：src/dataset_tools/dataset_tools/episode_recorder.py:176-242

--------------

触发记录：record_cli
--------------------

``record_cli`` 工具提供在部署期间触发 episodic 记录的交互式接口：

.. mermaid::

   graph TB
       START["User runs:<br/>ros2 run dataset_tools record_cli"]
       PROMPT["CLI prompts:<br/>'Describe the task'"]
       INPUT["User enters:<br/>'pick red cube and place in bin'"]
       SEND["CLI sends RecordEpisode.Goal<br/>to episode_recorder"]
       
       RECORDING["Episode Recorder:<br/>- Opens new bag<br/>- Streams messages<br/>- Shows countdown"]
       
       COMPLETE["Recording complete<br/>Bag saved to:<br/>~/rosbag_demos/episodes/<timestamp>"]
       
       START --> PROMPT
       PROMPT --> INPUT
       INPUT --> SEND
       SEND --> RECORDING
       RECORDING --> COMPLETE
       
       style RECORDING fill:#e3f2fd,stroke:#1976d2,stroke-width:2px
       style COMPLETE fill:#c8e6c9,stroke:#388e3c,stroke-width:2px

**交互流程**：1. 在终端运行 ``record_cli`` 2. 输入描述性提示（如"从桌上拿起红色方块"）3. 记录自动开始 4. 按 Ctrl+C 或等待 ``max_duration_s`` 超时 5. Bag 保存，提示嵌入元数据

提示对训练至关重要 - 它启用语言条件策略并帮助按任务类型组织数据集。

**来源**：
src/robot_config/robot_config/launch_builders/recording.py:124-125,
src/dataset_tools/dataset_tools/episode_recorder.py:415-420

--------------

数据质量和标注
--------------

什么是好的反馈数据
~~~~~~~~~~~~~~~~~~

并非所有部署数据都对训练有价值。高质量的反馈数据应具备：


.. list-table::
   :header-rows: 1

   * - 标准
     - 描述
     - 示例
   * - **新颖**
     - 覆盖训练集中未见过的场景
     - 新物体类型、 光照条件
   * - **正确标注**
     - 提示准确描述发生了什么
     - 如果机器人失败， 不要用"拿起方块"
   * - **完整**
     - 从开始到结束的完整 episode
     - 避免部分记录
   * - **多样**
     - 同一任务的多种变体
     - 不同起始位姿、 速度
   * - **信息丰富**
     - 包含挑战性或边缘案例
     - 接近失败、 错误恢复

记录策略
~~~~~~~~

**成功案例**：在新环境中记录成功执行以使模型适应域偏移。

**失败案例**：记录失败并附带纠正性提示。例如：
- 实际执行：机器人打翻杯子 - 提示："失败尝试 - 杯子被打翻" - 之后，记录纠正性演示并附带提示："成功拿起不稳定的杯子"

**干预数据**：如果机器人在任务中途需要人工干预，将失败和纠正动作作为单独的 episode 记录。

**来源**：src/dataset_tools/dataset_tools/bag_to_lerobot.py:415-420

--------------

处理反馈数据
------------

将部署 Bag 转换为 LeRobot 格式
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

一旦部署 episode 被记录，使用 ``bag_to_lerobot`` 将其转换为 LeRobot v3 格式：

.. code:: bash

   # 转换单个部署 episode
   python3 -m dataset_tools.bag_to_lerobot \
       --bag ~/rosbag_demos/episodes/1234567890_123456789 \
       --robot-config /path/to/robot_config.yaml \
       --out ~/datasets/my_task_v2

   # 转换多个部署 episode
   python3 -m dataset_tools.bag_to_lerobot \
       --bags ~/rosbag_demos/episodes/episode_001 \
              ~/rosbag_demos/episodes/episode_002 \
              ~/rosbag_demos/episodes/episode_003 \
       --robot-config /path/to/robot_config.yaml \
       --out ~/datasets/my_task_v2

**关键**：使用与部署期间使用的**相同的 robot_config.yaml**。这确保记录和转换之间的契约一致性。

**来源**：src/dataset_tools/dataset_tools/bag_to_lerobot.py:653-693

追加到现有数据集
~~~~~~~~~~~~~~~~

``bag_to_lerobot`` 工具自动将新 episode 追加到现有数据集：

.. code:: python

   # If dataset exists at out_root, LeRobot appends new episodes
   ds = LeRobotDataset.create(
       repo_id=repo_id,
       fps=fps,
       features=features,
       root=out_root,  # Existing dataset path
       # ...
   )
   # New episodes are added with incremented episode indices

这允许在多个部署会话中增量增长数据集。

**来源**：src/dataset_tools/dataset_tools/bag_to_lerobot.py:371-395

--------------

持续改进工作流
--------------

端到端反馈循环流程
~~~~~~~~~~~~~~~~~~

.. mermaid::

   graph TB
       subgraph "Week 1: Initial Deployment"
           DEPLOY1["Deploy v1 model<br/>50 training episodes"]
           OBSERVE1["Monitor performance<br/>Identify edge cases"]
           RECORD1["Record 10 deployment episodes<br/>(failures + edge cases)"]
       end
       
       subgraph "Week 2: Dataset Augmentation"
           CONVERT1["bag_to_lerobot<br/>Add 10 episodes to dataset"]
           DATASET1["Updated dataset:<br/>60 episodes total"]
           RETRAIN1["Retrain on augmented data<br/>lerobot library"]
           MODEL1["v2 checkpoint<br/>(improved on edge cases)"]
       end
       
       subgraph "Week 3: Redeployment"
           DEPLOY2["Deploy v2 model<br/>Monitor improvements"]
           EVAL["Evaluate performance<br/>Compare v1 vs v2"]
           RECORD2["Record new edge cases<br/>(if any)"]
       end
       
       subgraph "Week 4: Iteration"
           CONVERT2["Append new episodes"]
           RETRAIN2["Retrain v3"]
       end
       
       DEPLOY1 --> OBSERVE1
       OBSERVE1 --> RECORD1
       RECORD1 --> CONVERT1
       CONVERT1 --> DATASET1
       DATASET1 --> RETRAIN1
       RETRAIN1 --> MODEL1
       MODEL1 --> DEPLOY2
       DEPLOY2 --> EVAL
       EVAL --> RECORD2
       RECORD2 --> CONVERT2
       CONVERT2 --> RETRAIN2
       
       style DEPLOY1 fill:#e3f2fd,stroke:#1976d2,stroke-width:2px
       style DATASET1 fill:#f3e5f5,stroke:#9c27b0,stroke-width:2px
       style DEPLOY2 fill:#e3f2fd,stroke:#1976d2,stroke-width:2px

**典型迭代周期**：

1. **部署**：启动启用 episodic 记录的机器人
2. **监控**：观察机器人性能，记录失败模式
3. **记录**：为有趣的案例触发记录（失败、边缘案例、新颖场景）
4. **转换**：将部署 bag 处理为 LeRobot 格式
5. **增强**：与现有数据集合并
6. **重新训练**：在增强数据上训练新模型版本
7. **重新部署**：更新部署的检查点
8. **评估**：测量性能改进
9. **迭代**：重复循环

**来源**：README.md:74-78

--------------

用例
----

域适应
~~~~~~

**场景**：在实验室 A 训练的模型需要在具有不同光照和背景的实验室 B 中工作。

**工作流程**：1. 在实验室 B 部署模型 2. 记录 20-30 个在实验室 B 成功执行的 episode 3. 追加到原始数据集 4. 使用实验室 A 和实验室 B 数据重新训练 5. 重新部署适应的模型

**来源**：README.md:70-78

失败恢复
~~~~~~~~

**场景**：模型在特定物体类型（如透明物体）上失败。

**工作流程**：1. 在部署期间识别失败模式 2. 记录带描述性提示的失败 episode（"失败拿起 - 透明杯子"）3. 通过遥操作收集纠正性演示 4. 在合并数据上重新训练 5. 验证在透明物体上的改进

**来源**：src/dataset_tools/dataset_tools/bag_to_lerobot.py:415-420

任务扩展
~~~~~~~~

**场景**：扩展模型以处理新的任务变体。

**工作流程**：1. 部署基础模型 2. 记录新任务变体（不同物体大小、位姿等）3. 用新变体增强数据集 4. 重新训练以扩展任务覆盖 5. 重新部署泛化模型

--------------

配置参考
--------

robot_config.yaml 中的记录配置
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code:: yaml

   robot:
     name: so101_single_arm
     
     # 记录设置
     recording:
       bag_base_dir: "~/rosbag_demos/episodes"  # 部署 bag 保存位置
       storage_preset_profile: "zstd_fast"       # 压缩（可选）
     
     # 契约定义记录内容
     contract:
       rate_hz: 20
       max_duration_s: 90
       observations:
         - key: "observation.images.top"
           topic: "/camera/top/image_raw"
           # ... 其他观测
       actions:
         - key: "action"
           publish_topic: "/joint_commands"
           # ... 其他动作

**来源**：
src/robot_config/robot_config/launch_builders/recording.py:135-139,
src/dataset_tools/dataset_tools/episode_recorder.py:180-210

启动参数
~~~~~~~~


.. list-table::
   :header-rows: 1

   * - 参数
     - 类型
     - 默认值
     - 描述
   * - ``record``
     - bool
     - ``false``
     - 启动时启用记录
   * - ``record_mode``
     - string
     - ``'continuous'``
     - ``'continuous'`` 或 ``'episodic'``
   * - ``bag_base_dir``
     - string
     - ``'~/rosbag_d emos/episodes'``
     - 部署 bag 目录

**用法**：

.. code:: bash

   ros2 launch robot_config robot.launch.py \
       record:=true \
       record_mode:=episodic

**来源**：src/robot_config/launch/robot.launch.py:60-61

--------------

最佳实践
--------

记录指南
~~~~~~~~

1. **反馈循环始终使用 episodic 模式**：启用高价值数据的选择性记录
2. **编写描述性提示**：具体说明机器人在做什么或尝试什么
3. **记录完整 episode**：在机器人运动开始前开始，任务完成后结束
4. **准确记录失败**：不要在提示中将失败标记为成功
5. **保持多样性**：记录同一任务的多种变体

数据集管理
~~~~~~~~~~

1. **版本化数据集**：为重大数据集更新使用单独的输出目录
2. **跟踪 episode 来源**：维护哪些 bag 来自部署 vs. 遥操作的日志
3. **验证契约一致性**：记录和转换始终使用相同的 robot_config.yaml
4. **监控数据集增长**：确保成功和失败案例的平衡表示
5. **定期清理**：训练前删除重复或低质量的 episode

训练集成
~~~~~~~~

1. **增量训练**：追加少量数据时从之前的检查点开始重新训练
2. **系统评估**：在保留测试案例上比较新模型与旧版本
3. **跟踪指标**：记录跨版本的成功率、失败模式和性能改进
4. **A/B 测试**：在初始重新部署期间并行运行新旧模型

**来源**：src/dataset_tools/dataset_tools/bag_to_lerobot.py:1-73,
README.md:98-120

训练集成
========

.. raw:: html

   <details>

相关源文件

以下文件用于生成此 wiki 页面的上下文：

-  `README.en.md <README.en.md>`__
-  `README.md <README.md>`__
-  `docs/architecture.md <docs/architecture.md>`__
-  `/image/architecture.png </image/architecture.png>`__
-  `docs/roadmap.md <docs/roadmap.md>`__
-  `scripts/build.sh <scripts/build.sh>`__
-  `src/README.md <src/README.md>`__
-  `src/action_dispatch/README.en.md <src/action_dispatch/README.en.md>`__
-  `src/action_dispatch/README.md <src/action_dispatch/README.md>`__
-  `src/dataset_tools/README.md <src/dataset_tools/README.md>`__

.. raw:: html

   </details>

目的与范围
----------

本文档介绍 IB-Robot 如何与外部 **LeRobot 训练库** 集成以训练具身 AI 策略。内容涵盖 lerobot 库的设置、数据集格式兼容性、训练工作流程，以及训练后的模型检查点如何存储和引用以用于部署。

有关通过遥操作收集演示数据的信息，请参阅 `遥操作与数据收集 <#9.1>`__。有关将 ROS2 bag 转换为训练所需的 LeRobot 数据集格式，请参阅 `数据集转换 (bag_to_lerobot) <#9.3>`__。有关将训练后的模型部署回机器人，请参阅页面 `策略节点 <#7.4>`__。

--------------

训练架构概述
------------

IB-Robot 遵循 **关注点分离** 理念，其中 **数据收集和机器人控制** 由 ROS2 工作空间处理，而 **模型训练** 则委托给外部 LeRobot 库。这种架构实现了：

-  使用完整的 LeRobot 生态系统和社区模型
-  将重型 ML 依赖与 ROS2 运行时隔离
-  灵活地在不同机器上训练（云 GPU 服务器、工作站）
-  与上游 LeRobot 更新兼容

训练生命周期图
~~~~~~~~~~~~~~

.. mermaid::

   graph LR
       subgraph "IB-Robot ROS2 Workspace"
           A["Robot<br/>Teleoperation"]
           B["episode_recorder"]
           C["ROS2 Bag<br/>(MCAP)"]
           D["bag_to_lerobot<br/>Converter"]
           E["LeRobot v3<br/>Dataset"]
       end
       
       subgraph "External Training Environment"
           F["lerobot library<br/>libs/lerobot/"]
           G["Training Script<br/>lerobot/scripts/train.py"]
           H["Policy Checkpoint<br/>.pt file"]
       end
       
       subgraph "Deployment"
           I["robot_config YAML<br/>models section"]
           J["lerobot_policy_node"]
       end
       
       A --> B
       B --> C
       C --> D
       D --> E
       E --> F
       F --> G
       G --> H
       H --> I
       I --> J
       
       style F fill:#fff3e0,stroke:#ff9800,stroke-width:2px
       style H fill:#fff9c4,stroke:#fbc02d,stroke-width:2px
       style I fill:#fff3e0,stroke:#ff9800,stroke-width:2px

**来源**：cluster-README.md-7406cf73,
cluster-src/dataset_tools/README.md-03eaf360

--------------

LeRobot 库集成
--------------

库位置与设置
~~~~~~~~~~~~

LeRobot 训练框架作为 **Git 子模块** 集成在 IB-Robot 工作空间中：

::

   IB_Robot/
   ├── libs/
   │   └── lerobot/              # [子模块] LeRobot 训练框架
   │       ├── lerobot/
   │       │   ├── scripts/
   │       │   │   └── train.py  # 主训练入口点
   │       │   ├── common/
   │       │   │   └── policies/ # 策略实现 (ACT, Diffusion 等)
   │       │   └── configs/      # 训练配置
   │       └── pyproject.toml
   └── venv/                     # Python 虚拟环境

**安装过程**：

setup.sh 脚本（参见 `2.1 <#2.1>`__）自动处理 lerobot 安装：

1. **子模块初始化**：
   ``git submodule update --init --recursive``
2. **可编辑安装**：使用 ``-e`` 标志将 lerobot 安装到 venv
3. **依赖解析**：安装 PyTorch、numpy<2.0 和其他 ML 依赖

build.sh 脚本也会在每次构建前确保 lerobot 已安装：

`scripts/build.sh:162-177 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/scripts/build.sh#L162-L177>`__

**来源**：README.md-7406cf73, scripts/build.sh-5.04

--------------

数据集格式兼容性
----------------

LeRobot v3 数据集结构
~~~~~~~~~~~~~~~~~~~~~~~~

IB-Robot 的 ``bag_to_lerobot`` 转换器（参见 `9.3 <#9.3>`__）生成 **LeRobot v3 格式** 的数据集，这是 lerobot 训练库期望的原生格式：

::

   dataset_name/
   ├── videos/
   │   ├── observation.images.top/
   │   │   └── chunk-000/
   │   │       └── file-000.mp4
   │   ├── observation.images.wrist/
   │   └── observation.images.front/
   ├── data/
   │   └── chunk-000/
   │       └── file-000.parquet      # 包含动作/状态的回合数据
   └── meta/
       ├── info.json                  # 数据集元数据
       ├── tasks.parquet              # 回合任务描述
       ├── stats.json                 # 归一化统计信息
       └── episodes/                  # 每个回合的元数据

契约驱动的特征映射
~~~~~~~~~~~~~~~~~~

IB-Robot 与 LeRobot 训练之间的关键连接是 robot_config YAML 中定义的 **Contract（契约）**。此契约嵌入在数据集元数据中，确保：

1. **观测键** 与策略期望的完全匹配
2. **动作维度** 与机器人自由度对齐
3. **归一化统计信息** 正确计算

.. mermaid::

   graph TB
       subgraph "robot_config YAML"
           RC["contract:<br/>- observations<br/>- actions<br/>- rate_hz"]
       end
       
       subgraph "Dataset Conversion"
           BAG["bag_to_lerobot"]
           META["meta/info.json"]
           STATS["meta/stats.json"]
       end
       
       subgraph "Training Configuration"
           POLICY_CFG["Policy config.json"]
           TRAIN_CFG["Training YAML"]
       end
       
       subgraph "Trained Model"
           CKPT["checkpoint.pt"]
           MODEL_META["config.json<br/>(input_features)"]
       end
       
       RC --> BAG
       BAG --> META
       BAG --> STATS
       META --> POLICY_CFG
       STATS --> TRAIN_CFG
       POLICY_CFG --> CKPT
       TRAIN_CFG --> CKPT
       CKPT --> MODEL_META
       
       style RC fill:#fff3e0,stroke:#ff9800,stroke-width:2px
       style MODEL_META fill:#fff9c4,stroke:#fbc02d,stroke-width:2px

**来源**：
cluster-src/dataset_tools/dataset_tools/bag_to_lerobot.py-ef20288b,
cluster-src/robot_config/config/robots/so101_single_arm.yaml-a9ae727a

训练工作流程
------------

步骤 1：准备数据集
~~~~~~~~~~~~~~~~~~

收集演示并将 bag 转换为 LeRobot 格式后（参见 `9.2 <#9.2>`__ 和 `9.3 <#9.3>`__）：

.. code:: bash

   # 验证数据集结构
   ls -R /path/to/dataset/
   # 应显示：videos/, data/, meta/

   # 检查数据集信息
   cat /path/to/dataset/meta/info.json

步骤 2：配置训练
~~~~~~~~~~~~~~~~

在 lerobot 库中创建训练配置 YAML：

**ACT 策略示例**
（``libs/lerobot/lerobot/configs/policy/act_so101.yaml``）：

.. code:: yaml

   # 策略架构
   policy:
     name: act
     input_shapes:
       observation.images.top: [3, 480, 640]
       observation.images.wrist: [3, 480, 640]
       observation.state: [6]
     output_shapes:
       action: [6]
     
     # ACT 特定参数
     n_action_steps: 100
     chunk_size: 100
     hidden_dim: 512
     dim_feedforward: 3200
     n_encoder_layers: 4
     n_decoder_layers: 1

   # 训练参数
   training:
     offline_steps: 50000
     batch_size: 8
     lr: 1e-5
     lr_scheduler: cosine
     gradient_clip_norm: 10
     
   # 数据集
   dataset_repo_id: local
   root: /path/to/dataset

**关键配置参数**：

================== ==================================================
参数               描述
================== ==================================================
``input_shapes``   必须与 Contract 观测匹配
``output_shapes``  必须与 Contract 动作匹配
``n_action_steps`` 每次推理预测的未来动作数量
``chunk_size``     总动作序列长度（用于分块模型）
``offline_steps``  总训练迭代次数
================== ==================================================

步骤 3：执行训练
~~~~~~~~~~~~~~~~

导航到 lerobot 库并运行训练：

.. code:: bash

   # 激活虚拟环境
   source venv/bin/activate

   # 导航到 lerobot
   cd libs/lerobot

   # 运行训练
   python lerobot/scripts/train.py \
       policy=act_so101 \
       dataset_repo_id=local \
       root=/path/to/dataset \
       output_dir=/path/to/checkpoints \
       wandb.enable=true \
       wandb.project=so101_training

**训练脚本流程**：

.. mermaid::

   graph TB
       START["python train.py"]
       LOAD_CFG["Load policy config<br/>(act_so101.yaml)"]
       LOAD_DS["Load LeRobotDataset<br/>(from root path)"]
       INIT_POL["Initialize Policy<br/>(ACTPolicy class)"]
       TRAIN_LOOP["Training Loop<br/>(offline_steps)"]
       SAVE_CKPT["Save checkpoint.pt<br/>+ config.json"]
       
       START --> LOAD_CFG
       LOAD_CFG --> LOAD_DS
       LOAD_DS --> INIT_POL
       INIT_POL --> TRAIN_LOOP
       TRAIN_LOOP --> SAVE_CKPT
       
       subgraph "Per Iteration"
           SAMPLE["Sample batch from dataset"]
           FORWARD["Forward pass through policy"]
           LOSS["Compute loss (MSE, BCE)"]
           BACKWARD["Backward pass + optimizer step"]
           
           SAMPLE --> FORWARD
           FORWARD --> LOSS
           LOSS --> BACKWARD
       end
       
       TRAIN_LOOP --> SAMPLE
       BACKWARD -.->|repeat| SAMPLE

**来源**：cluster-README.md-7406cf73,
cluster-src/action_dispatch/README.en.md-5.34

--------------

模型检查点与配置
----------------

检查点结构
~~~~~~~~~~

训练完成后，输出目录包含：

::

   checkpoints/
   └── act_so101_20240315_123456/
       ├── checkpoints/
       │   ├── 010000/
       │   │   └── pretrained_model/
       │   │       ├── model.safetensors    # 模型权重
       │   │       └── config.json          # 模型元数据
       │   ├── 020000/
       │   └── 050000/                      # 最终检查点
       ├── config.yaml                      # 完整训练配置
       └── training.log

config.json 结构
~~~~~~~~~~~~~~~~

嵌入在每个检查点中的 ``config.json`` 文件对部署至关重要：

.. code:: json

   {
     "input_features": {
       "observation.images.top": {
         "shape": [3, 480, 640],
         "dtype": "float32"
       },
       "observation.images.wrist": {
         "shape": [3, 480, 640],
         "dtype": "float32"
       },
       "observation.state": {
         "shape": [6],
         "dtype": "float32"
       }
     },
     "output_features": {
       "action": {
         "shape": [6],
         "dtype": "float32"
       }
     },
     "policy_type": "act",
     "n_action_steps": 100,
     "chunk_size": 100
   }

**关键字段**：


.. list-table::
   :header-rows: 1

   * - 字段
     - 用途
   * - ``input_features``
     - 定义策略期望的观测（过滤 Contract）
   * - ``output_features``
     - 定义动作维度
   * - ``policy_type``
     - 推理服务用于实例化正确的策略类
   * - ``n_action_steps``
     - action_dispatcher_node 用于分块管理

**来源**：cluster-src/inference_service/README.en.md-2537d748

--------------

与 robot_config 集成
--------------------

引用训练模型
~~~~~~~~~~~~

训练完成后，检查点路径注册到 robot_config YAML：

.. code:: yaml

   robot:
     name: so101_single_arm
     
     models:
       - name: act_reach_and_grasp
         path: /path/to/checkpoints/act_so101_20240315_123456/checkpoints/050000/pretrained_model
         policy_type: act
         
       - name: diffusion_pick_place
         path: /path/to/checkpoints/diffusion_so101_20240320_091234/checkpoints/100000/pretrained_model
         policy_type: diffusion_policy

部署时的模型加载
~~~~~~~~~~~~~~~~

当推理服务启动时（参见 `7.4 <#7.4>`__），它会：

1. **读取 robot_config** 查找模型路径
2. **从检查点加载 config.json**
3. **基于 ``input_features`` 过滤观测**
4. **使用 ``policy_type`` 实例化策略**
5. **从 ``model.safetensors`` 加载权重**

**模型加载流程**：

.. mermaid::

   graph TB
       LAUNCH["robot.launch.py"]
       LOAD_CFG["Load robot_config YAML"]
       FIND_MODEL["Find model by name<br/>(from models section)"]
       POLICY_NODE["lerobot_policy_node"]
       LOAD_META["Load config.json"]
       FILTER_OBS["Filter Contract observations<br/>by input_features"]
       INIT_POLICY["Initialize policy class<br/>(ACTPolicy, DiffusionPolicy)"]
       LOAD_WEIGHTS["Load model.safetensors"]
       READY["Inference Ready"]
       
       LAUNCH --> LOAD_CFG
       LOAD_CFG --> FIND_MODEL
       FIND_MODEL --> POLICY_NODE
       POLICY_NODE --> LOAD_META
       LOAD_META --> FILTER_OBS
       FILTER_OBS --> INIT_POLICY
       INIT_POLICY --> LOAD_WEIGHTS
       LOAD_WEIGHTS --> READY

**来源**：
cluster-src/robot_config/config/robots/so101_single_arm.yaml-a9ae727a,
cluster-README.md-7406cf73

--------------

支持的策略类型
--------------

IB-Robot 与 lerobot 库中的以下策略类型集成：


.. list-table::
   :header-rows: 1

   * - 策略类型
     - 描述
     - 关键参数
     - 动作格式
   * - **ACT**
     - Action Chunking Transformer
     - ``chunk_size``, ` `n_action_steps``
     - 分块（100 步）
   * - **Diffusion Policy**
     - 基于扩散的 轨迹生成
     - ``n_d iffusion_steps``, ` `action_horizon``
     - 分块（可变）
   * - **VLA** (Pi0, SmolVLA)
     - 视觉-语言- 动作模型
     - ``llm_backbone``, ` `vision_encoder``
     - 逐步
   * - **CNN Policy**
     - 简单的 基于 CNN 的 策略
     - ` `encoder_layers``
     - 逐步

策略特定的训练注意事项
~~~~~~~~~~~~~~~~~~~~~~

**ACT (Action Chunking Transformer)**: - 需要 ``chunk_size`` = ``n_action_steps`` (通常为 100) - 最适合平滑、连续的操作任务 - 训练时间: 单 GPU 上 50k 步约 12-24 小时

**Diffusion Policy**: - 推理时需要多步去噪 - 计算成本较高, 但在多模态分布上表现更好 - 训练时间: 单 GPU 上 100k 步约 24-48 小时

**VLA (Vision-Language-Action)**: - 数据集中需要任务语言提示 - 可以零样本泛化到新任务 - 训练时间: 不定 (通常预训练, 微调约 6-12 小时)

**来源**：cluster-src/action_dispatch/README.en.md-5.34,
cluster-README.md-7406cf73

--------------

训练最佳实践
------------

数据需求
~~~~~~~~


.. list-table::
   :header-rows: 1

   * - 策略类型
     - 最少回合数
     - 推荐回合数
     - 每回合时长
   * - ACT
     - 50
     - 200+
     - 30-60 秒
   * - Diffusion Policy
     - 100
     - 300+
     - 30-60 秒
   * - VLA (fine-tuning)
     - 20
     - 50+
     - 可变

硬件推荐
~~~~~~~~

========= ====================== ==================
组件      最低配置               推荐配置
========= ====================== ==================
GPU       NVIDIA RTX 3060 (12GB) NVIDIA A100 (40GB)
CPU       8 核                   16+ 核
RAM       32GB                   64GB+
存储      100GB SSD              500GB+ NVMe SSD
========= ====================== ==================

监控训练
~~~~~~~~

lerobot 库支持 Weights & Biases (wandb) 进行训练监控：

.. code:: yaml

   # 在训练配置中
   wandb:
     enable: true
     project: so101_training
     entity: your_username

**关键监控指标**：- ``train/loss``：应平滑下降 - ``train/action_mse``：动作预测误差 - ``train/grad_norm``：梯度幅度（不应爆炸）- ``eval/success_rate``：如果运行评估回合

**来源**：cluster-README.md-7406cf73,
cluster-docs/architecture.md-4.71

--------------

故障排除
--------

常见训练问题
~~~~~~~~~~~~


.. list-table::
   :header-rows: 1

   * - 问题
     - 原因
     - 解决方案
   * - `` KeyError: 'observa tion.images.top'``
     - 数据集与策略配置 不匹配
     - 验证 ``input_shapes`` 与数据集特征匹配
   * - ``RuntimeError: CU DA out of memory``
     - 批次大小过大
     - 在训练配置中减小 ``batch_size``
   * - ``Los s not decreasing``
     - 学习率过高/过低
     - 尝试 ``lr: 1e-5`` 到 ``1e-4`` 范围
   * - ``Mod el overfits (high train, low eval)``
     - 回合太少或步数 太多
     - 收集更多数据或减少 ``offline_steps``

数据集验证
~~~~~~~~~~

训练前，验证转换后的数据集：

.. code:: bash

   # 检查数据集完整性
   python -c "
   from lerobot.common.datasets.lerobot_dataset import LeRobotDataset
   dataset = LeRobotDataset('local', root='/path/to/dataset')
   print(f'Episodes: {dataset.num_episodes}')
   print(f'Frames: {dataset.num_frames}')
   print(f'Features: {dataset.features}')
   "

**来源**：cluster-src/dataset_tools/README.md-03eaf360

--------------

总结
----

IB-Robot 中的训练集成遵循清晰的分离原则：

1. **数据收集**\ （ROS2 工作空间）：遥操作 → episode_recorder → ROS2 bags
2. **数据转换**\ （ROS2 工作空间）：bag_to_lerobot → LeRobot v3 数据集
3. **训练**\ （外部 lerobot 库）：train.py → 模型检查点
4. **部署**\ （ROS2 工作空间）：robot_config YAML → lerobot_policy_node

robot_config YAML 中定义的 **Contract** 作为唯一事实来源，确保数据收集、训练和部署之间的一致性。lerobot 库作为 Git 子模块集成并以可编辑模式安装，允许开发者利用完整的 LeRobot 生态系统同时保持可复现性。

有关流水线的下一步，请参阅 `部署反馈循环 <#9.5>`__，了解在线评估数据如何反馈到训练中以实现持续改进。

**来源**：cluster-README.md-7406cf73,
cluster-src/dataset_tools/README.md-03eaf360,
cluster-src/robot_config/config/robots/so101_single_arm.yaml-a9ae727a

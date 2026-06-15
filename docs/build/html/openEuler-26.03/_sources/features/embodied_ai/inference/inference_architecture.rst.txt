推理架构
========

.. raw:: html

   <details>

相关源文件

以下文件用于生成此文档页面：

-  `src/inference_service/README.en.md <src/inference_service/README.en.md>`__
-  `src/inference_service/README.md <src/inference_service/README.md>`__
-  `src/inference_service/inference_service/pure_inference_node.py <src/inference_service/inference_service/pure_inference_node.py>`__
-  `src/tensormsg/package.xml <src/tensormsg/package.xml>`__

.. raw:: html

   </details>

目的与范围
----------

本文档介绍 ``inference_service`` 包的三组件架构，该架构为在物理机器人上运行端到端机器学习策略提供核心 AI 执行框架。该架构将推理管道解耦为纯 Python、与 ROS 无关的组件，实现灵活的部署策略。

有关此架构启用的特定执行模式（单体与分布式）信息，请参阅 `单体执行模式 <#7.2>`__ 和 `分布式执行模式 <#7.3>`__。有关节点实现细节，请参阅 `策略节点 <#7.4>`__。有关为此管道提供数据的协议转换层，请参阅 `协议转换 (tensormsg) <#6>`__。

**源码：** `src/inference_service/README.en.md:1-13 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/README.en.md#L1-L13>`__,
`src/inference_service/README.md:1-15 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/README.md#L1-L15>`__

--------------

设计原则
--------

组合优于继承
~~~~~~~~~~~~

推理管道遵循 **基于组合的架构**，而非继承层次结构。系统被分解为三个独立、松耦合的组件，可根据部署需求以不同方式组合。每个组件有单一、明确定义的职责，可独立测试、优化和部署。

**源码：** `src/inference_service/README.en.md:5-6 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/README.en.md#L5-L6>`__,
`src/inference_service/README.md:7-8 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/README.md#L7-L8>`__

与 ROS 无关的核心
~~~~~~~~~~~~~~~~~

所有核心推理组件位于 ``inference_service.core`` 模块，**零 ROS 依赖**。它们仅操作 PyTorch 张量和标准 Python 数据结构。这种分离提供了几个关键优势：


.. list-table::
   :header-rows: 1

   * - 优势
     - 描述
   * - **离线测试**
     - 组件可在无任何 ROS 环境的情况下 通过 ``pytest`` 验证
   * - **部署灵活性**
     - 相同代码可在单体或分布式配置中运行
   * - **框架独立性**
     - 核心逻辑可移植到其他机器人框架 或独立应用程序
   * - **性能隔离**
     - 纯张量操作不受 ROS 通信开销影响

**源码：** `src/inference_service/README.en.md:7-12 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/README.en.md#L7-L12>`__,
`src/inference_service/README.md:9-14 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/README.md#L9-L14>`__

--------------

三组件架构
----------

组件概述
~~~~~~~~

.. mermaid::

   graph LR
       subgraph "ROS 层"
           SENSOR["ROS 传感器数据<br/>(图像, JointState)"]
           CTRL["ROS 控制命令<br/>(JointTrajectory)"]
       end
       
       subgraph "inference_service.core (纯 Python)"
           PREPROC["TensorPreprocessor"]
           ENGINE["PureInferenceEngine"]
           POSTPROC["TensorPostprocessor"]
       end
       
       SENSOR -->|"ROS → Python"| PREPROC
       PREPROC -->|"Dict[str, Tensor]"| ENGINE
       ENGINE -->|"InferenceResult"| POSTPROC
       POSTPROC -->|"Python → ROS"| CTRL
       
       PREPROC -.->|"裁剪、归一化"| PREPROC
       ENGINE -.->|"policy.select_action()"| ENGINE
       POSTPROC -.->|"反归一化"| POSTPROC

**图：三组件管道与 ROS 边界分离**

三个组件形成顺序处理管道：

1. **TensorPreprocessor** — 将原始 ROS 传感器数据转换为归一化的 PyTorch 张量
2. **PureInferenceEngine** — 执行策略网络以生成动作
3. **TensorPostprocessor** — 将网络输出反归一化为物理控制命令

**源码：** `src/inference_service/README.en.md:7-10 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/README.en.md#L7-L10>`__,
`src/inference_service/README.md:9-12 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/README.md#L9-L12>`__

--------------

组件 1：TensorPreprocessor
--------------------------

职责
~~~~

``TensorPreprocessor`` 组件处理将异构 ROS 传感器数据转换为适合策略网络输入的标准化张量批次。此组件是 CPU 密集型的，执行：


.. list-table::
   :header-rows: 1

   * - 操作
     - 描述
   * - **数据提取**
     - 从 ROS 消息缓冲区读取值 (图像、关节位置)
   * - **图像裁剪**
     - 应用外设配置中的裁剪参数
   * - **归一化**
     - 缩放像素值（0-255 → 0.0-1.0） 和关节位置到 [-1, 1]
   * - **批次组装**
     - 构建符合策略期望的命名张量字典

与契约系统集成
~~~~~~~~~~~~~~

预处理器根据 ``robot_config`` 中的 **契约定义**\ （`见契约系统 <#3.2>`__）运行。它：

-  仅订阅契约中声明的观测
-  应用为每种模态指定的归一化统计信息
-  构建与策略 ``input_features`` 匹配的张量键

数据流
~~~~~~

.. mermaid::

   graph TB
       subgraph "输入: ROS 消息缓冲区"
           IMG_TOP["StreamBuffer:<br/>images.top"]
           IMG_WRIST["StreamBuffer:<br/>images.wrist"]
           JOINTS["StreamBuffer:<br/>observation.state"]
       end
       
       subgraph "TensorPreprocessor 操作"
           READ["从缓冲区读取最新数据"]
           CROP["裁剪图像<br/>(外设配置)"]
           NORM_IMG["归一化像素<br/>[0,255] → [0.0,1.0]"]
           NORM_JOINT["归一化关节<br/>契约中的统计信息"]
           BATCH["组装批次字典"]
       end
       
       subgraph "输出: 张量批次"
           OUT["Dict[str, Tensor]:<br/>- observation.images.top<br/>- observation.images.wrist<br/>- observation.state"]
       end
       
       IMG_TOP --> READ
       IMG_WRIST --> READ
       JOINTS --> READ
       READ --> CROP
       CROP --> NORM_IMG
       READ --> NORM_JOINT
       NORM_IMG --> BATCH
       NORM_JOINT --> BATCH
       BATCH --> OUT

**图：TensorPreprocessor 数据转换管道**

**源码：** `src/inference_service/README.en.md:8 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/README.en.md#L8>`__,
`src/inference_service/README.md:10 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/README.md#L10>`__

--------------

组件 2：PureInferenceEngine
---------------------------

.. _responsibilities-1:

职责
~~~~

``PureInferenceEngine`` 是一个 **完全无状态、与 ROS 无关的 GPU 执行引擎**。它封装策略网络并实现纯函数接口：

::

   batch: Dict[str, Tensor] → InferenceResult(action: Tensor, ...)

无状态设计
~~~~~~~~~~

引擎在推理调用之间 **不维护任何内部状态**。每次调用独立：

-  无 episode 历史跟踪
-  无超出策略自身管理的时间依赖
-  无副作用

此设计支持：- 分布式模式下的并发推理请求 - 简单的错误恢复（失败的推理不会破坏状态） - 测试的确定性行为

策略加载
~~~~~~~~

引擎使用 LeRobot 库的标准格式加载预训练策略检查点。它从检查点元数据解析策略类型和配置。

.. mermaid::

   graph TB
       subgraph "PureInferenceEngine 初始化"
           PATH["policy_path:<br/>/path/to/checkpoint.pt"]
           RESOLVE["resolve_device()<br/>cuda/cpu 检测"]
           LOAD["torch.load()<br/>策略检查点"]
           EXTRACT["提取:<br/>- policy_type<br/>- chunk_size<br/>- input_features"]
       end
       
       subgraph "运行时: __call__ 方法"
           INPUT["batch:<br/>Dict[str, Tensor]"]
           SELECT["policy.select_action(batch)"]
           RESULT["InferenceResult:<br/>- action: Tensor<br/>- chunk_size: int"]
       end
       
       PATH --> RESOLVE
       RESOLVE --> LOAD
       LOAD --> EXTRACT
       
       INPUT --> SELECT
       SELECT --> RESULT

**图：PureInferenceEngine 生命周期与调用**

设备管理
~~~~~~~~

引擎包含自动选择适当计算设备的设备解析逻辑：

================ =========================================
设备参数         行为
================ =========================================
``"auto"``       优先使用 CUDA（如可用），回退到 CPU
``"cuda"``       强制 GPU，如不可用则抛出错误
``"cpu"``        强制 CPU 执行
================ =========================================

**源码：** `src/inference_service/README.en.md:9 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/README.en.md#L9>`__,
`src/inference_service/README.md:11 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/README.md#L11>`__,
`src/inference_service/inference_service/pure_inference_node.py:30 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/pure_inference_node.py#L30>`__

--------------

组件 3：TensorPostprocessor
---------------------------

.. _responsibilities-2:

职责
~~~~

``TensorPostprocessor`` 执行预处理器的逆变换，将策略网络的归一化动作张量转换回物理控制命令：


.. list-table::
   :header-rows: 1

   * - 操作
     - 描述
   * - **反归一化**
     - 将动作值从 [-1, 1] 缩放到 物理关节限制
   * - **动作块提取**
     - 提取完整动作块 (通常为 100 个时间步)
   * - **ROS 消息构建**
     - 构建适合动作分发的 ROS 消息

输出格式
~~~~~~~~

后处理器输出与 ``action_dispatcher_node`` 兼容的数据（`见动作分发 <#8>`__）：

-  **动作块**：用于时序平滑的多时间步动作序列
-  **物理单位**：以弧度或米为单位的关节位置
-  **契约对齐**：动作名称与契约的动作规格匹配

**源码：** `src/inference_service/README.en.md:10 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/README.en.md#L10>`__,
`src/inference_service/README.md:12 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/README.md#L12>`__

--------------

管道数据流
----------

张量传递语义
~~~~~~~~~~~~

三个组件通过定义良好的张量字典通信。在 **单体模式** 下，张量通过引用传递（零拷贝）。在 **分布式模式** 下，张量通过 ``tensormsg`` 协议序列化（`见协议转换 <#6>`__）。

.. mermaid::

   graph TB
       subgraph "各阶段数据结构"
           direction TB
           
           IN_DATA["输入: ROS 消息<br/>- sensor_msgs/Image<br/>- sensor_msgs/JointState"]
           
           PREP_OUT["预处理后<br/>Dict[str, Tensor]:<br/>- 'observation.images.top': [1,3,480,640]<br/>- 'observation.state': [1,7]"]
           
           ENG_OUT["推理后<br/>InferenceResult:<br/>- action: [chunk_size, action_dim]<br/>- chunk_size: int"]
           
           POST_OUT["后处理后<br/>- 物理关节位置<br/>- 准备用于 action_dispatcher"]
       end
       
       IN_DATA -->|"TensorPreprocessor"| PREP_OUT
       PREP_OUT -->|"PureInferenceEngine"| ENG_OUT
       ENG_OUT -->|"TensorPostprocessor"| POST_OUT

**图：管道中的数据结构转换**

请求-响应匹配
~~~~~~~~~~~~~

在分布式模式下，系统使用 ``_request_id`` 机制将异步推理响应与其原始请求匹配。``pure_inference_node`` 透传此标识符：

.. code:: python

   # 从输入批次提取请求 ID
   request_id = batch.pop("task.request_id", None)

   # ... 执行推理 ...

   # 在输出中包含请求 ID
   if request_id is not None:
       out_batch["action.request_id"] = [request_id]

**源码：**
`src/inference_service/inference_service/pure_inference_node.py:88-98 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/pure_inference_node.py#L88-L98>`__

--------------

与 TensorMsg 协议集成
---------------------

双向转换
~~~~~~~~

``tensormsg`` 包（`见协议转换 <#6>`__）提供启用分布式模式操作的序列化层。``TensorMsgConverter`` 类处理：


.. list-table::
   :header-rows: 1

   * - 方法
     - 用途
   * - ``to_variant(batch: Dict)``
     - 将 Python 张量字典转换为 ROS ``VariantsList`` 消息
   * - ``from_varian t(msg: VariantsList, device)``
     - 将 ROS 消息反序列化回 指定设备上的张量字典

在纯推理节点中的使用
~~~~~~~~~~~~~~~~~~~~

``pure_inference_node`` 演示了此集成：

.. code:: python

   # 反序列化输入批次
   batch = TensorMsgConverter.from_variant(msg, self._engine._device)

   # 运行推理
   result = self._engine(batch)

   # 序列化输出
   out_batch = {"action": result.action}
   out_msg = TensorMsgConverter.to_variant(out_batch)
   self._pub.publish(out_msg)

此抽象允许核心组件保持与 ROS 无关，同时启用网络透明的张量通信。

**源码：**
`src/inference_service/inference_service/pure_inference_node.py:86-103 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/pure_inference_node.py#L86-L103>`__,
`src/tensormsg/package.xml:1-26 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/tensormsg/package.xml#L1-L26>`__

--------------

总结
----

三组件架构实现了严格的关注点分离：


.. list-table::
   :header-rows: 1

   * - 组件
     - 依赖
     - 主要职责
   * - ` `TensorPreprocessor``
     - 无（纯 Python）
     - ROS 数据 → 归一化张量
   * - `` PureInferenceEngine``
     - 仅 PyTorch
     - 无状态策略执行
   * - `` TensorPostprocessor``
     - 无（纯 Python）
     - 反归一化张量 → ROS 命令

此设计使相同的核心逻辑能够通过不同的组合策略支持单体（单机）和分布式（设备-边缘-云端）部署，详见 `单体执行模式 <#7.2>`__ 和 `分布式执行模式 <#7.3>`__。

**源码：** `src/inference_service/README.en.md:1-74 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/README.en.md#L1-L74>`__,
`src/inference_service/README.md:1-76 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/README.md#L1-L76>`__

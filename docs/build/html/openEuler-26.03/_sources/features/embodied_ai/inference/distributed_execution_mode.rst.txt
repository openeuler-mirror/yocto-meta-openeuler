分布式执行模式
==============

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

本文档描述推理管道的 **分布式执行模式**，该模式支持将计算从轻量级机器人控制器卸载到局域网上的高性能 GPU 服务器。此模式专为具有低功耗 CPU（如 Raspberry Pi、工业 PC）但可访问网络计算节点的机器人设计，这些机器人无法在本地运行推理工作负载。

有关替代的单机模式信息，请参阅 `单体执行模式 <#7.2>`__。有关整体推理架构，请参阅 `推理架构 <#7.1>`__。

**源码**：`src/inference_service/README.en.md:26-36 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/README.en.md#L26-L36>`__

--------------

架构概述
--------

分布式模式将推理管道拆分到两个物理节点：


.. list-table::
   :header-rows: 1

   * - 组件
     - 位置
     - 角色
     - 硬件要求
   * - **设备节点**
     - 机器人 控制器
     - Ten sorPr eproc essor + Tens orPos tproc essor
     - 仅 CPU，轻量级
   * - **云端/边缘 节点**
     - GPU 服务器
     - Pure Infer enceE ngine
     - 支持 CUDA 的 GPU

关键的架构洞察是设备节点作为 **异步代理**，仅按需读取相机数据（以推理频率，通常为 20Hz），而不是流式传输连续视频（30fps+）。此设计可防止网络饱和，同时保持与基于拉取的 ``action_dispatch`` 系统的兼容性。

高层数据流
~~~~~~~~~~

.. mermaid::

   graph TB
       subgraph Device["设备节点 (机器人控制器)"]
           AD["action_dispatcher_node"]
           LPN["lerobot_policy_node<br/>(异步代理)"]
           PREPROC["TensorPreprocessor<br/>(CPU)"]
           POSTPROC["TensorPostprocessor<br/>(CPU)"]
           SENSORS["相机订阅<br/>关节状态缓冲区"]
       end
       
       subgraph Cloud["云端/边缘节点 (GPU 服务器)"]
           PIN["pure_inference_node"]
           ENGINE["PureInferenceEngine<br/>(GPU)"]
       end
       
       AD -->|"DispatchInfer Goal"| LPN
       LPN -->|"按需读取"| SENSORS
       SENSORS --> PREPROC
       PREPROC -->|"VariantsList"| PUB_BATCH["/preprocessed/batch"]
       
       PUB_BATCH -.->|"ROS2 topic<br/>over LAN"| SUB_BATCH["/preprocessed/batch"]
       
       SUB_BATCH --> PIN
       PIN --> ENGINE
       ENGINE --> PIN
       PIN -->|"VariantsList"| PUB_ACT["/inference/action"]
       
       PUB_ACT -.->|"ROS2 topic<br/>over LAN"| SUB_ACT["/inference/action"]
       
       SUB_ACT --> LPN
       LPN --> POSTPROC
       POSTPROC -->|"Result"| AD

**源码**：`src/inference_service/README.en.md:26-36 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/README.en.md#L26-L36>`__

--------------

异步代理模式
------------

设备节点的 ``lerobot_policy_node`` 实现异步挂起机制，以避免在等待云端推理结果时阻塞 ROS2 执行器。

执行序列
~~~~~~~~

.. mermaid::

   sequenceDiagram
       participant Dispatcher as action_dispatcher_node
       participant Device as lerobot_policy_node<br/>(设备)
       participant Cloud as pure_inference_node<br/>(云端)
       
       Dispatcher->>Device: DispatchInfer Goal
       activate Device
       Note over Device: 按需读取相机
       Device->>Device: TensorPreprocessor.preprocess()
       Device->>Cloud: 发布到 /preprocessed/batch
       Note over Device: threading.Event.wait()<br/>(挂起回调)
       deactivate Device
       
       activate Cloud
       Cloud->>Cloud: PureInferenceEngine.__call__()
       Cloud->>Device: 发布到 /inference/action
       deactivate Cloud
       
       activate Device
       Note over Device: threading.Event.set()<br/>(唤醒回调)
       Device->>Device: TensorPostprocessor.postprocess()
       Device->>Dispatcher: Result (action chunk)
       deactivate Device

此模式确保：- **按需捕获**：相机仅在 ``action_dispatcher`` 触发推理时读取 - **零阻塞**：挂起使用 ``threading.Event``，而非忙等待 - **网络效率**：仅传输推理关键帧（如 20Hz），而非连续流（30fps）

**源码**：`src/inference_service/README.en.md:29-36 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/README.en.md#L29-L36>`__

--------------

通信协议
--------

主题与消息类型
~~~~~~~~~~~~~~

分布式模式使用两个 ROS2 主题进行双向通信：


.. list-table::
   :header-rows: 1

   * - 主题
     - 方向
     - 消息类型
     - 内容
     - 频率
   * - ``/pr eproce ssed/b atch``
     - 设备 → 云端
     - ``VariantsList``
     - 预处理 张量 (图像、 状态)
     - ~20Hz (推理速率)
   * - ``/ infere nce/ac tion``
     - 云端 → 设备
     - ``VariantsList``
     - 原始动作 张量 + 元数据
     - ~20Hz (响应速率)

两个主题都使用 ``ibrobot_msgs`` 包中的 ``VariantsList`` 消息类型，使用 ``TensorMsgConverter`` 在 Python 字典之间进行转换。

消息结构
~~~~~~~~

``/preprocessed/batch`` (设备发布):

.. code:: python

   {
       "observation.images.top": torch.Tensor,      # 形状: [B, C, H, W]
       "observation.images.wrist": torch.Tensor,
       "observation.state": torch.Tensor,            # 形状: [B, state_dim]
       "task.request_id": [int],                     # 用于请求匹配
   }

``/inference/action`` (云端发布):

.. code:: python

   {
       "action": torch.Tensor,                       # 形状: [B, chunk_size, action_dim]
       "action.request_id": [int],                   # 从请求回显
       "_latency_ms": float,                         # 推理延迟
   }

**源码**：`src/inference_service/pure_inference_node.py:33-41 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/pure_inference_node.py#L33-L41>`__,
`src/inference_service/pure_inference_node.py:86-103 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/pure_inference_node.py#L86-L103>`__

--------------

纯推理节点
----------

云端节点（``pure_inference_node.py``）是围绕 ``PureInferenceEngine`` 的轻量级、无状态 ROS2 封装。它不感知传感器、相机或机器人配置——仅处理张量。

节点架构
~~~~~~~~

.. mermaid::

   graph LR
       subgraph PureInferenceNode["pure_inference_node.py"]
           SUB["订阅<br/>/preprocessed/batch"]
           CB["_inference_cb()"]
           ENGINE["PureInferenceEngine<br/>(GPU)"]
           CONV_IN["TensorMsgConverter.from_variant()"]
           CONV_OUT["TensorMsgConverter.to_variant()"]
           PUB["发布者<br/>/inference/action"]
       end
       
       SUB --> CB
       CB --> CONV_IN
       CONV_IN --> ENGINE
       ENGINE --> CONV_OUT
       CONV_OUT --> PUB

关键实现细节
~~~~~~~~~~~~

**初始化**
`src/inference_service/pure_inference_node.py:43-79 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/pure_inference_node.py#L43-L79>`__：- 声明参数：``policy_path``、``input_topic``、``output_topic``、``device`` - 使用加载的策略实例化 ``PureInferenceEngine`` - 创建对 ``/preprocessed/batch`` 的订阅，使用 ``ReentrantCallbackGroup`` - 创建对 ``/inference/action`` 的发布者

**推理回调**
`src/inference_service/pure_inference_node.py:81-119 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/pure_inference_node.py#L81-L119>`__：

.. code:: python

   def _inference_cb(self, msg: VariantsList):
       # 1. 将 ROS 消息转换为张量批次
       batch = TensorMsgConverter.from_variant(msg, self._engine._device)
       
       # 2. 提取 request_id 用于匹配
       request_id = batch.pop("task.request_id", None)
       
       # 3. 运行纯推理 (GPU)
       result = self._engine(batch)
       
       # 4. 打包输出并附带 request_id
       out_batch = {
           "action": result.action,
           "action.request_id": [request_id] if request_id else None,
           "_latency_ms": inference_latency_ms,
       }
       
       # 5. 发布结果
       out_msg = TensorMsgConverter.to_variant(out_batch)
       self._pub.publish(out_msg)

**源码**：`src/inference_service/pure_inference_node.py:33-120 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/pure_inference_node.py#L33-L120>`__

--------------

请求-响应匹配
-------------

为实现无消息丢失的异步操作，分布式模式使用 ``request_id`` 实现请求-响应关联系统。

匹配机制
~~~~~~~~

.. mermaid::

   graph TB
       subgraph Device["设备节点流程"]
           GEN["生成唯一<br/>request_id"]
           ATTACH["附加到批次:<br/>task.request_id"]
           WAIT["threading.Event.wait()"]
           VALIDATE["验证响应<br/>request_id"]
           PROCESS["处理动作"]
       end
       
       subgraph Cloud["云端节点流程"]
           EXTRACT["从批次提取<br/>request_id"]
           INFER["运行推理"]
           ECHO["在响应中<br/>回显 request_id"]
       end
       
       GEN --> ATTACH
       ATTACH --> PUB["/preprocessed/batch"]
       PUB -.-> EXTRACT
       EXTRACT --> INFER
       INFER --> ECHO
       ECHO --> PUB2["/inference/action"]
       PUB2 -.-> VALIDATE
       ATTACH --> WAIT
       VALIDATE --> WAIT
       WAIT --> PROCESS

实现
~~~~

**设备端**\ （未在提供的文件中显示，但在架构中引用）：- 生成唯一的 ``request_id``（如递增计数器）- 在预处理批次中包含 ``task.request_id: [id]`` - 存储与此请求关联的 ``threading.Event`` - 收到响应时，验证 ``action.request_id`` 匹配

**云端**
`src/inference_service/pure_inference_node.py:88-98 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/pure_inference_node.py#L88-L98>`__：- 从传入批次提取 ``task.request_id`` - 将其传递到输出作为 ``action.request_id`` - 无需存储或状态管理

此设计确保：- **乱序容忍**：如果响应乱序到达，可以匹配 - **超时处理**：设备可以检测缺失的响应 - **无状态云端**：云端节点无需请求跟踪

**源码**：`src/inference_service/pure_inference_node.py:12-15 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/pure_inference_node.py#L12-L15>`__,
`src/inference_service/pure_inference_node.py:88-98 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/pure_inference_node.py#L88-L98>`__

--------------

配置
----

分布式模式通过机器人配置 YAML 中的 ``execution_mode`` 参数启用。

YAML 配置
~~~~~~~~~

.. code:: yaml

   # src/robot_config/config/robots/so101_single_arm.yaml
   control_modes:
     model_inference:
       inference:
         enabled: true
         execution_mode: "distributed"  # 启用分布式模式
         model: so101_act

``execution_mode`` 参数接受两个值：- ``"monolithic"``：单进程、零拷贝推理（见 `单体执行模式 <#7.2>`__）- ``"distributed"``：设备-云端拆分，通过 ROS2 主题通信

**源码**：`src/inference_service/README.en.md:43-52 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/README.en.md#L43-L52>`__

--------------

启动与部署
----------

设备节点启动
~~~~~~~~~~~~

设备节点作为标准机器人启动系统的一部分启动。启动构建器根据 ``execution_mode`` 参数自动配置 ``lerobot_policy_node``：

.. code:: bash

   ros2 launch robot_config robot.launch.py \
       robot_config:=so101_single_arm \
       control_mode:=model_inference

节点将：- 加载机器人契约以确定观测源 - 仅初始化 ``TensorPreprocessor`` 和 ``TensorPostprocessor`` - 创建对 ``/preprocessed/batch`` 和 ``/inference/action`` 的订阅 - 为 ``action_dispatcher_node`` 注册 action server

**源码**：`src/inference_service/README.en.md:56-59 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/README.en.md#L56-L59>`__

云端节点启动
~~~~~~~~~~~~

云端节点必须在 GPU 服务器上单独启动。它被设计为独立节点，不依赖完整的机器人系统：

.. code:: bash

   ros2 launch inference_service cloud_inference.launch.py \
       policy_path:=/path/to/models/pretrained_model \
       device:=cuda

**启动参数**：


.. list-table::
   :header-rows: 1

   * - 参数
     - 类型
     - 默认值
     - 描述
   * - ``policy_path``
     - string
     - (必需)
     - LeRobot 策略检查点 的路径（.pt 文件）
   * - ``input_topic``
     - string
     - ``/preproc essed/batch``
     - 订阅预处理张量的主题
   * - ``output_topic``
     - string
     - ``/infer ence/action``
     - 发布推理结果的主题
   * - ``device``
     - string
     - ``auto``
     - PyTorch 设备 (cuda/cpu/auto)

**网络要求**：- 设备和云端节点必须在同一 ROS Domain ID 上 - 建议低延迟 LAN 连接（<10ms RTT）- 足够的带宽用于张量传输（典型视觉策略在 20Hz 时约 10MB/s）

**源码**：`src/inference_service/README.en.md:61-69 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/README.en.md#L61-L69>`__,
`src/inference_service/pure_inference_node.py:122-161 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/pure_inference_node.py#L122-L161>`__

--------------

性能特征
--------

延迟分解
~~~~~~~~

分布式模式下的总推理延迟包括：

=========================== =============== ==========
组件                        典型延迟        位置
=========================== =============== ==========
相机读取 + 预处理           5-15ms          设备 CPU
ROS2 序列化                 1-3ms           设备
网络传输                    2-10ms          LAN
GPU 推理                    20-100ms        云端 GPU
网络返回                    2-10ms          LAN
后处理                      1-2ms           设备 CPU
**总计**                    **31-140ms**    端到端
=========================== =============== ==========

云端节点每 100 次推理记录延迟统计
`src/inference_service/pure_inference_node.py:108-114 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/pure_inference_node.py#L108-L114>`__：

.. code:: python

   if self._inference_count % 100 == 0:
       avg_latency = self._total_latency_ms / self._inference_count
       self.get_logger().info(
           f"Inference stats: count={self._inference_count}, "
           f"avg_latency={avg_latency:.1f}ms, "
           f"last_latency={inference_latency_ms:.1f}ms"
       )

网络效率
~~~~~~~~

与流式传输原始相机流相比：


.. list-table::
   :header-rows: 1

   * - 方法
     - 数据速率
     - 帧/秒
   * - 连续流式传输（3 个相机 @ 640×480）
     - ~70 MB/s
     - 30 fps × 3 个相机
   * - 分布式模式 (预处理张量)
     - ~10 MB/s
     - 20 Hz（推理速率）
   * - **带宽节省**
     - **~86%**
     - 仅在需要时传输

**源码**：`src/inference_service/README.en.md:34-36 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/README.en.md#L34-L36>`__,
`src/inference_service/pure_inference_node.py:105-114 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/pure_inference_node.py#L105-L114>`__

--------------

代码实体参考
------------

关键类与文件
~~~~~~~~~~~~


.. list-table::
   :header-rows: 1

   * - 实体
     - 文件
     - 用途
   * - ``PureInferenceNode``
     - `src/inference_service/inference_service/pure_inference_node.py:33-120 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/pure_inference_node.py#L33-L120>`__
     - GPU 推理的云端节点封装 GPU 推理的云端节点封装
   * - ` `PureInferenceEngine``
     - `src/inference_s ervice/inferenc e_service/core/ pure_inference_ engine.py <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_s ervice/inferenc e_service/core/ pure_inference_ engine.py>`__
     - 无状态 GPU 推理引擎 （见 `推理架构 <#7.1>`__）
   * - ``TensorMsgConverter``
     - `src/tensorms g/tensormsg/con verter.py <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/tensorms g/tensormsg/con verter.py>`__
     - ROS↔张量序列化 （见 `协议转换 <#6>`__）
   * - ``VariantsList``
     - `src/ibrobot_m sgs/msg/Variant sList.msg <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/ibrobot_m sgs/msg/Variant sList.msg>`__
     - 异构张量的 ROS2 消息类型

启动文件
~~~~~~~~


.. list-table::
   :header-rows: 1

   * - 文件
     - 用途
   * - `src/infere nce_service/launch/cloud_ inference.launch.py <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/infere nce_service/launch/cloud_ inference.launch.py>`__
     - 独立云端节点启动器
   * - `src/robot_config/lau nch/robot.launch.py <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/lau nch/robot.launch.py>`__
     - 设备端机器人系统 （自动配置分布式模式）

**源码**：`src/inference_service/pure_inference_node.py:1-165 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/pure_inference_node.py#L1-L165>`__,
`src/tensormsg/package.xml:1-27 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/tensormsg/package.xml#L1-L27>`__

数据集转换 (bag_to_lerobot)
===========================

.. raw:: html

   <details>

相关源文件

以下文件用于生成此 wiki 页面的上下文：

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

本文档介绍 ``bag_to_lerobot`` 转换工具，该工具将 ROS2 bag 文件（录制的回合）转换为 LeRobot v3 数据集格式，用于训练机器学习策略。该工具通过使用与实时推理相同的契约驱动处理工具，确保训练与部署的一致性。

有关录制回合的信息，请参阅 `回合录制 <#9.2>`__。有关与 LeRobot 库的训练集成，请参阅 `训练集成 <#9.4>`__。

--------------

目的与范围
----------

``bag_to_lerobot`` 工具将一个或多个 ROS2 bag 目录转换为 LeRobot v3 数据集，具有以下保证：

-  **训练-服务一致性**：使用与 ``lerobot_policy_node`` 相同的 ``decode_value()`` 函数和重采样逻辑，消除训练-服务偏差
-  **单一事实来源**：直接从 ``robot_config.yaml`` 加载契约规范，确保观测和动作与机器人配置匹配
-  **特征对齐**：通过 ``feature_from_spec()`` 生成与模型输入要求完全匹配形状的数据集特征

该工具作为独立的 Python 脚本运行，不依赖 ROS2 运行时。

**来源**：
`src/dataset_tools/dataset_tools/bag_to_lerobot.py:1-73 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/dataset_tools/bag_to_lerobot.py#L1-L73>`__

--------------

转换流水线概述
--------------

.. mermaid::

   graph TB
       subgraph "Input"
           BAG1["ROS2 Bag<br/>Episode 1<br/>(MCAP)"]
           BAG2["ROS2 Bag<br/>Episode 2<br/>(MCAP)"]
           BAGN["ROS2 Bag<br/>Episode N<br/>(MCAP)"]
           RC["robot_config.yaml<br/>(Contract Spec)"]
       end
       
       subgraph "bag_to_lerobot.py"
           LOAD["_load_contract_from_robot_config()<br/>Load Contract"]
           PLAN["_plan_streams()<br/>Build topic→spec mapping"]
           
           subgraph "Per-Episode Processing"
               SCAN["Scan Bag<br/>deserialize_message()"]
               DECODE["decode_value()<br/>(shared with inference)"]
               SELECT["Timestamp Selection<br/>(contract/bag/header)"]
               RESAMPLE["resample()<br/>Align to rate_hz ticks"]
               COERCE["Image Coercion<br/>uint8, resize"]
               CONSOLIDATE["Consolidate Streams<br/>(observation.state, actions)"]
           end
           
           FEATURES["feature_from_spec()<br/>Generate dataset features"]
           WRITE["LeRobotDataset.add_frame()<br/>Write frames"]
       end
       
       subgraph "Output"
           DS["LeRobot v3 Dataset"]
           VID["videos/*.mp4"]
           DATA["data/*.parquet"]
           META["meta/info.json<br/>meta/stats.json"]
       end
       
       BAG1 --> SCAN
       BAG2 --> SCAN
       BAGN --> SCAN
       RC --> LOAD
       
       LOAD --> PLAN
       PLAN --> SCAN
       SCAN --> DECODE
       DECODE --> SELECT
       SELECT --> RESAMPLE
       RESAMPLE --> COERCE
       COERCE --> CONSOLIDATE
       
       LOAD --> FEATURES
       FEATURES --> DS
       CONSOLIDATE --> WRITE
       WRITE --> DS
       
       DS --> VID
       DS --> DATA
       DS --> META
       
       style LOAD fill:#fff3e0,stroke:#ff9800,stroke-width:2px
       style DECODE fill:#e8f5e9,stroke:#388e3c,stroke-width:2px
       style FEATURES fill:#e8f5e9,stroke:#388e3c,stroke-width:2px

**来源**：
`src/dataset_tools/dataset_tools/bag_to_lerobot.py:5-73 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/dataset_tools/bag_to_lerobot.py#L5-L73>`__,
`src/dataset_tools/dataset_tools/bag_to_lerobot.py:233-648 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/dataset_tools/bag_to_lerobot.py#L233-L648>`__

--------------

契约作为单一事实来源
--------------------

转换过程直接从 ``robot_config.yaml`` 加载契约，确保训练数据创建与部署之间的处理一致：

.. mermaid::

   graph LR
       subgraph "robot_config.yaml"
           YAML["contract:<br/>  observations:<br/>    - key: observation.images.top<br/>      topic: /camera/top/image_raw<br/>      image:<br/>        resize: [480, 640]<br/>  actions:<br/>    - key: action<br/>      publish:<br/>        topic: /arm_controller/commands"]
       end
       
       subgraph "bag_to_lerobot"
           LOAD["_load_contract_from_robot_config()"]
           SPECS["iter_specs(contract)<br/>→ SpecView objects"]
           FEAT["feature_from_spec(spec)<br/>→ LeRobot features"]
           DEC["decode_value(ros_type, msg, spec)"]
       end
       
       subgraph "lerobot_policy_node"
           LOAD2["_load_contract()"]
           SPECS2["iter_specs(contract)<br/>→ SpecView objects"]
           DEC2["decode_value(ros_type, msg, spec)"]
           PREP["TensorPreprocessor"]
       end
       
       YAML --> LOAD
       YAML --> LOAD2
       
       LOAD --> SPECS
       SPECS --> FEAT
       SPECS --> DEC
       
       LOAD2 --> SPECS2
       SPECS2 --> DEC2
       DEC2 --> PREP
       
       style YAML fill:#fff3e0,stroke:#ff9800,stroke-width:3px
       style DEC fill:#e8f5e9,stroke:#388e3c,stroke-width:2px
       style DEC2 fill:#e8f5e9,stroke:#388e3c,stroke-width:2px

``_load_contract_from_robot_config()`` 函数加载机器人配置并将其转换为 ``Contract`` 数据类：

**来源**：
`src/dataset_tools/dataset_tools/bag_to_lerobot.py:216-231 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/dataset_tools/bag_to_lerobot.py#L216-L231>`__,
`src/robot_config/robot_config/config.py:133-216 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/config.py#L133-L216>`__

--------------

流规划与话题分发
----------------

在扫描 bag 之前，``_plan_streams()`` 为每个契约规范创建 ``_Stream`` 缓冲区，并构建分发索引以实现高效的消息路由：

.. mermaid::

   graph TB
       subgraph "Contract Specs"
           OBS1["SpecView:<br/>key: observation.images.top<br/>topic: /camera/top/image_raw<br/>ros_type: sensor_msgs/msg/Image"]
           OBS2["SpecView:<br/>key: observation.state<br/>topic: /joint_states<br/>ros_type: sensor_msgs/msg/JointState"]
           ACT1["SpecView:<br/>key: action<br/>topic: /arm_controller/commands<br/>is_action: True"]
       end
       
       subgraph "_plan_streams()"
           BUILD["Build streams dict + by_topic index"]
       end
       
       subgraph "Output Data Structures"
           STREAMS["streams = {<br/>  'observation.images.top': _Stream(...),<br/>  'observation.state_joint_states': _Stream(...),<br/>  'action_arm_controller_commands': _Stream(...)<br/>}"]
           
           BYTOPIC["by_topic = {<br/>  '/camera/top/image_raw': ['observation.images.top'],<br/>  '/joint_states': ['observation.state_joint_states'],<br/>  '/arm_controller/commands': ['action_arm_controller_commands']<br/>}"]
       end
       
       OBS1 --> BUILD
       OBS2 --> BUILD
       ACT1 --> BUILD
       
       BUILD --> STREAMS
       BUILD --> BYTOPIC
       
       style BUILD fill:#e3f2fd,stroke:#1976d2,stroke-width:2px

**关键逻辑**
（`src/dataset_tools/dataset_tools/bag_to_lerobot.py:151-210 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/dataset_tools/bag_to_lerobot.py#L151-L210>`__）：

-  **唯一键生成**：对于具有多个话题的 ``observation.state`` 规范，通过附加经过处理的话题名称创建唯一键，如 ``observation.state_joint_states``
-  **动作合并**：具有相同 ``key`` 的多个动作规范在扫描期间分别跟踪，然后在帧组装时合并
-  **话题验证**：如果契约话题不在 bag 的话题列表中，则发出警告

**来源**：
`src/dataset_tools/dataset_tools/bag_to_lerobot.py:112-132 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/dataset_tools/bag_to_lerobot.py#L112-L132>`__,
`src/dataset_tools/dataset_tools/bag_to_lerobot.py:151-210 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/dataset_tools/bag_to_lerobot.py#L151-L210>`__

--------------

消息解码与时间戳选择
--------------------

每条消息使用来自 ``robot_config.contract_utils`` 的共享 ``decode_value()`` 函数解码，确保与实时推理的处理一致：

.. mermaid::

   graph TB
       subgraph "Bag Scanning Loop"
           READ["reader.read_next()<br/>(topic, data, bag_ns)"]
           DESER["deserialize_message(data,<br/>  get_message(ros_type))"]
       end
       
       subgraph "Timestamp Selection"
           POLICY{timestamp_source?}
           RECEIVE["ts_sel = bag_ns"]
           HEADER["ts_sel = stamp_from_header_ns(msg)<br/>fallback: bag_ns"]
           CONTRACT["if spec.stamp_src == 'header':<br/>  ts_sel = stamp_from_header_ns(msg)<br/>else:<br/>  ts_sel = bag_ns"]
       end
       
       subgraph "Decoding"
           DECODE["decode_value(ros_type, msg, spec)"]
           PUSH["st.ts.append(ts_sel)<br/>st.val.append(val)"]
       end
       
       READ --> DESER
       DESER --> POLICY
       
       POLICY -->|"'receive'"| RECEIVE
       POLICY -->|"'header'"| HEADER
       POLICY -->|"'contract'"| CONTRACT
       
       RECEIVE --> DECODE
       HEADER --> DECODE
       CONTRACT --> DECODE
       
       DECODE --> PUSH
       
       style DECODE fill:#e8f5e9,stroke:#388e3c,stroke-width:2px

**时间戳选择模式**
（`src/dataset_tools/dataset_tools/bag_to_lerobot.py:464-475 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/dataset_tools/bag_to_lerobot.py#L464-L475>`__）：


.. list-table::
   :header-rows: 1

   * - 模式
     - 行为
   * - ``contract``
     - 使用每个规范的 ``stamp_src`` 字段 （默认：接收时间，可覆盖为 header）
   * - ``receive``
     - 始终使用 bag 接收时间戳 （``bag_ns``）
   * - ``header``
     - 优先使用 ``msg.header.stamp``，如果缺失 则回退到 ``bag_ns``

**来源**：
`src/dataset_tools/dataset_tools/bag_to_lerobot.py:454-481 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/dataset_tools/bag_to_lerobot.py#L454-L481>`__,
`src/robot_config/robot_config/contract_utils.py:264-267 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/contract_utils.py#L264-L267>`__

--------------

重采样到契约频率
----------------

扫描后，工具将所有流重采样到契约的 ``rate_hz`` 的统一时间点：

.. mermaid::

   graph TB
       subgraph "Per-Stream Data"
           TS["ts = [t0, t1, t2, ..., tn]<br/>(nanoseconds, unsorted)"]
           VAL["vals = [v0, v1, v2, ..., vn]<br/>(decoded values)"]
       end
       
       subgraph "Tick Generation"
           START["start_ns = min(all stream timestamps)"]
           DUR["dur_ns = max(all) - start_ns"]
           TICKS["ticks_ns = start_ns + np.arange(n_ticks) * step_ns<br/>step_ns = int(1e9 / rate_hz)"]
       end
       
       subgraph "Resampling"
           POLICY{spec.resample_policy}
           HOLD["resample_hold()<br/>Forward-fill"]
           ASOF["resample_asof()<br/>Within tolerance only"]
           DROP["resample_drop()<br/>Require fresh data"]
           
           RESULT["resampled[key] = [val_at_tick0, val_at_tick1, ...]"]
       end
       
       TS --> START
       TS --> DUR
       START --> TICKS
       DUR --> TICKS
       
       TICKS --> POLICY
       VAL --> POLICY
       
       POLICY -->|"'hold'"| HOLD
       POLICY -->|"'asof'"| ASOF
       POLICY -->|"'drop'"| DROP
       
       HOLD --> RESULT
       ASOF --> RESULT
       DROP --> RESULT

**重采样策略**
（`src/robot_config/robot_config/contract_utils.py:273-326 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/contract_utils.py#L273-L326>`__）：

-  ``hold``：前向填充最后可用值（机器人状态最常用）
-  ``asof``：仅使用 ``asof_tol_ms`` 容差内的值；否则为 ``None``
-  ``drop``：要求数据在当前时间周期内接收；否则为 ``None``

**来源**：
`src/dataset_tools/dataset_tools/bag_to_lerobot.py:516-531 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/dataset_tools/bag_to_lerobot.py#L516-L531>`__,
`src/robot_config/robot_config/contract_utils.py:273-326 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/contract_utils.py#L273-L326>`__

--------------

流合并
------

转换器处理两种合并场景以支持灵活的契约配置：

多个 observation.state 规范
~~~~~~~~~~~~~~~~~~~~~~~~~~~

当多个 ``observation.state`` 规范引用不同话题（例如，``/joint_states`` 用于机械臂，``/gripper_states`` 用于夹爪）时，它们被连接为单个特征：

.. mermaid::

   graph LR
       subgraph "Contract"
           OBS1["observation.state<br/>topic: /joint_states<br/>names: [pos.1, pos.2, pos.3, pos.4, pos.5]"]
           OBS2["observation.state<br/>topic: /gripper_states<br/>names: [pos.6]"]
       end
       
       subgraph "During Scanning"
           STREAM1["observation.state_joint_states:<br/>[a1, a2, a3, a4, a5]"]
           STREAM2["observation.state_gripper_states:<br/>[g1]"]
       end
       
       subgraph "Consolidation"
           CONCAT["np.concatenate([<br/>  [a1, a2, a3, a4, a5],<br/>  [g1]<br/>])"]
           
           FRAME["frame['observation.state'] =<br/>[a1, a2, a3, a4, a5, g1]"]
       end
       
       OBS1 --> STREAM1
       OBS2 --> STREAM2
       
       STREAM1 --> CONCAT
       STREAM2 --> CONCAT
       
       CONCAT --> FRAME
       
       style CONCAT fill:#e3f2fd,stroke:#1976d2,stroke-width:2px

**来源**：
`src/dataset_tools/dataset_tools/bag_to_lerobot.py:329-341 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/dataset_tools/bag_to_lerobot.py#L329-L341>`__,
`src/dataset_tools/dataset_tools/bag_to_lerobot.py:537-555 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/dataset_tools/bag_to_lerobot.py#L537-L555>`__

具有相同键的多个动作规范
~~~~~~~~~~~~~~~~~~~~~~~~

当多个动作规范共享相同的 ``key: action``（例如，机械臂控制器 + 夹爪控制器）时，它们被连接：

.. mermaid::

   graph LR
       subgraph "Contract"
           ACT1["key: action<br/>topic: /arm_controller/commands<br/>names: [action.0, action.1, ..., action.4]"]
           ACT2["key: action<br/>topic: /gripper_controller/commands<br/>names: [action.5]"]
       end
       
       subgraph "During Scanning"
           STREAM1["action_arm_controller_commands:<br/>[0.1, 0.2, 0.3, 0.4, 0.5]"]
           STREAM2["action_gripper_controller_commands:<br/>[0.8]"]
       end
       
       subgraph "Consolidation"
           CONCAT["np.concatenate([<br/>  [0.1, 0.2, 0.3, 0.4, 0.5],<br/>  [0.8]<br/>])"]
           
           FRAME["frame['action'] =<br/>[0.1, 0.2, 0.3, 0.4, 0.5, 0.8]"]
       end
       
       ACT1 --> STREAM1
       ACT2 --> STREAM2
       
       STREAM1 --> CONCAT
       STREAM2 --> CONCAT
       
       CONCAT --> FRAME
       
       style CONCAT fill:#e3f2fd,stroke:#1976d2,stroke-width:2px

**来源**：
`src/dataset_tools/dataset_tools/bag_to_lerobot.py:344-362 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/dataset_tools/bag_to_lerobot.py#L344-L362>`__,
`src/dataset_tools/dataset_tools/bag_to_lerobot.py:558-584 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/dataset_tools/bag_to_lerobot.py#L558-L584>`__

--------------

LeRobot v3 数据集输出
--------------------

转换器使用 ``LeRobotDataset.create()`` 创建 LeRobot v3 数据集，特征从契约规范派生：

输出目录结构
~~~~~~~~~~~~

::

   output_dataset/
   ├── videos/
   │   ├── observation.images.top/
   │   │   └── chunk-000/
   │   │       └── file-000.mp4
   │   ├── observation.images.wrist/
   │   └── observation.images.front/
   ├── data/
   │   └── chunk-000/
   │       └── file-000.parquet
   └── meta/
       ├── info.json
       ├── tasks.parquet
       ├── stats.json
       └── episodes/
           └── episode_0.parquet

特征生成
~~~~~~~~

特征使用 ``feature_from_spec()`` 生成，确保与模型期望完全对齐：

.. mermaid::

   graph TB
       subgraph "SpecView"
           SPEC["key: observation.images.top<br/>image_resize: (480, 640)<br/>image_channels: 3"]
       end
       
       subgraph "feature_from_spec()"
           CHECK{image_resize?}
           IMG["dtype: 'video' or 'image'<br/>shape: (H, W, C)<br/>names: ['height', 'width', 'channel']"]
           VEC["dtype: 'float32'<br/>shape: (len(names),)<br/>names: spec.names"]
       end
       
       subgraph "LeRobotDataset"
           FEATURES["features = {<br/>  'observation.images.top': {<br/>    'dtype': 'video',<br/>    'shape': (480, 640, 3)<br/>  },<br/>  'observation.state': {<br/>    'dtype': 'float32',<br/>    'shape': (6,)<br/>  },<br/>  'action': {<br/>    'dtype': 'float32',<br/>    'shape': (6,)<br/>  }<br/>}"]
       end
       
       SPEC --> CHECK
       CHECK -->|Yes| IMG
       CHECK -->|No| VEC
       
       IMG --> FEATURES
       VEC --> FEATURES
       
       style FEATURES fill:#f3e5f5,stroke:#9c27b0,stroke-width:2px

**特殊处理**
（`src/dataset_tools/dataset_tools/bag_to_lerobot.py:288-394 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/dataset_tools/bag_to_lerobot.py#L288-L394>`__）：

-  **深度图像**：自动设置为 3 通道，并在特征元数据中标记 ``video.is_depth_map: True``
-  **任务字符串**：任务规范（例如，提示）归一化为 ``dtype: 'string', shape: [1]``
-  **契约指纹**：嵌入到 ``info.json`` 中作为 ``ibrobot_fingerprint``，用于训练期间验证

**来源**：
`src/dataset_tools/dataset_tools/bag_to_lerobot.py:288-394 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/dataset_tools/bag_to_lerobot.py#L288-L394>`__,
`src/robot_config/robot_config/contract_utils.py:214-235 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/contract_utils.py#L214-L235>`__

--------------

图像强制转换与视频编码
----------------------

图像被强制转换为 uint8 格式以实现确定性存储：

.. mermaid::

   graph TB
       subgraph "Decoded Image Value"
           ARR["np.ndarray<br/>dtype: float32 or uint8<br/>range: [0, 1] or [0, 255]"]
       end
       
       subgraph "Coercion"
           CHECK{arr.dtype == np.uint8?}
           CONVERT["arr = np.clip(arr * 255.0, 0, 255).astype(np.uint8)"]
           KEEP["arr (already uint8)"]
       end
       
       subgraph "LeRobot Storage"
           FRAME["frame[key] = arr"]
           ENCODE["LeRobotDataset encodes to MP4<br/>(if use_videos=True)"]
       end
       
       ARR --> CHECK
       CHECK -->|No| CONVERT
       CHECK -->|Yes| KEEP
       
       CONVERT --> FRAME
       KEEP --> FRAME
       
       FRAME --> ENCODE

**注意**：- LeRobot 加载器在训练期间自动将 uint8 转换回 float32 [0, 1] - 视频编码使用 H.264 编解码器，具有可配置的分块大小（``--video-mb``）

**来源**：
`src/dataset_tools/dataset_tools/bag_to_lerobot.py:603-608 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/dataset_tools/bag_to_lerobot.py#L603-L608>`__

--------------

命令行界面
----------

基本用法
~~~~~~~~

.. code:: bash

   # 单个回合
   ros2 run dataset_tools bag_to_lerobot \
       --bag /path/to/episode_dir \
       --robot-config src/robot_config/config/robots/so101_single_arm.yaml \
       --out /path/to/output_dataset

   # 多个回合
   ros2 run dataset_tools bag_to_lerobot \
       --bags /path/to/epi1 /path/to/epi2 /path/to/epi3 \
       --robot-config src/robot_config/config/robots/so101_single_arm.yaml \
       --out /path/to/output_dataset

参数
~~~~


.. list-table::
   :header-rows: 1

   * - 参数
     - 描述
     - 默认值
   * - ``--bag``
     - 单个 bag 目录路径
     - 必需 （与 ``--bags`` 互斥）
   * - ``--bags``
     - 多个 bag 目录路径
     - 必需 （与 ``--bag`` 互斥）
   * - ``--robot-config``
     - ``robot_config.yaml`` 的路径
     - 必需
   * - ``--out``
     - 输出数据集根目录
     - 必需
   * - ``--repo-id``
     - 数据集仓库 ID 元数据
     - ``rosbag_v30``
   * - ``--no-videos``
     - 存储 PNG 图像而非 MP4 视频
     - ``False``
   * - ``--timestamp``
     - 时间戳来源： ``contract``、``bag``、 ``header``
     - ``contract``
   * - ``--image-threads``
     - 每个进程的图像写入线程数
     - ``4``
   * - ``--image-processes``
     - 图像写入进程数
     - ``0``
   * - ``--chunk-size``
     - 每个 Parquet/视频分块的 最大帧数
     - ``1000``
   * - ``--data-mb``
     - 目标数据文件大小（MB）
     - ``100``
   * - ``--video-mb``
     - 目标视频文件大小（MB）
     - ``500``

**来源**：
`src/dataset_tools/dataset_tools/bag_to_lerobot.py:653-693 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/dataset_tools/bag_to_lerobot.py#L653-L693>`__

--------------

入口点与主函数
--------------

``main()`` 函数解析参数并调用 ``export_bags_to_lerobot()``：

.. code:: python

   # CLI invocation
   def main():
       args = parse_args()
       bag_dirs = [Path(args.bag)] if args.bag else [Path(p) for p in args.bags]
       
       export_bags_to_lerobot(
           bag_dirs=bag_dirs,
           robot_config_path=Path(args.robot_config),
           out_root=Path(args.out),
           repo_id=args.repo_id,
           use_videos=not args.no_videos,
           timestamp_source=args.timestamp,
           # ... other parameters
       )

**来源**：
`src/dataset_tools/dataset_tools/bag_to_lerobot.py:696-717 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/dataset_tools/bag_to_lerobot.py#L696-L717>`__

--------------

与数据流水线集成
----------------

转换工具融入更广泛的数据生命周期：

.. mermaid::

   graph LR
       subgraph "Phase 1: Collection"
           TELEOP["Teleoperation<br/>robot_teleop"]
           ROBOT["Physical Robot"]
       end
       
       subgraph "Phase 2: Recording"
           RECORDER["episode_recorder<br/>Action Server"]
           BAG["ROS2 Bag<br/>(MCAP)"]
       end
       
       subgraph "Phase 3: Conversion"
           B2L["bag_to_lerobot<br/>Contract-driven"]
           DS["LeRobot v3<br/>Dataset"]
       end
       
       subgraph "Phase 4: Training"
           TRAIN["lerobot library<br/>ACT/Diffusion/VLA"]
           CKPT["Policy Checkpoint<br/>(.pt file)"]
       end
       
       subgraph "Phase 5: Deployment"
           INF["lerobot_policy_node<br/>(same contract)"]
           DISP["action_dispatcher"]
       end
       
       TELEOP --> ROBOT
       ROBOT --> RECORDER
       RECORDER --> BAG
       BAG --> B2L
       B2L --> DS
       DS --> TRAIN
       TRAIN --> CKPT
       CKPT --> INF
       INF --> DISP
       DISP --> ROBOT
       
       style B2L fill:#e3f2fd,stroke:#1976d2,stroke-width:2px
       style DS fill:#f3e5f5,stroke:#9c27b0,stroke-width:2px

有关录制回合，请参阅 `回合录制 <#9.2>`__。有关使用转换后数据集进行部署，请参阅 `策略节点 <#7.4>`__ 和 `训练集成 <#9.4>`__。

**来源**：
`src/dataset_tools/dataset_tools/bag_to_lerobot.py:5-19 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/dataset_tools/bag_to_lerobot.py#L5-L19>`__,
`src/dataset_tools/README.md:121-144 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/dataset_tools/README.md#L121-L144>`__

--------------

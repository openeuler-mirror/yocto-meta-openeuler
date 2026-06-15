协议转换 (tensormsg)
====================

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
-  `src/robot_config/README.en.md <src/robot_config/README.en.md>`__
-  `src/robot_config/README.md <src/robot_config/README.md>`__
-  `src/robot_config/config/robots/so101_dual_arm.yaml <src/robot_config/config/robots/so101_dual_arm.yaml>`__
-  `src/robot_config/config/robots/so101_single_arm.yaml <src/robot_config/config/robots/so101_single_arm.yaml>`__
-  `src/robot_config/robot_config/loader.py <src/robot_config/robot_config/loader.py>`__
-  `src/tensormsg/tensormsg/converter.py <src/tensormsg/tensormsg/converter.py>`__

.. raw:: html

   </details>

``tensormsg`` 包作为 ROS 2 消息流与机器学习张量表示之间的**双向协议转换器**。它使 LeRobot 策略能够消费机器人观测并产生动作，无需手动编写序列化代码，使用契约驱动规范系统确保数据收集、训练和部署之间的一致性。

有关契约如何定义和加载的信息，请参阅 `契约定义 <#5.2>`__。有关使用 tensormsg 的推理管道详情，请参阅 `推理管道 <#7>`__。

**来源**: `README.md:30-31 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L30-L31>`__,
`docs/architecture.md:203-208 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/docs/architecture.md#L203-L208>`__,
`src/tensormsg/tensormsg/converter.py:1-262 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/tensormsg/tensormsg/converter.py#L1-L262>`__

--------------

系统角色与数据流
----------------

``tensormsg`` 包作为 IB-Robot 架构中的核心协议枢纽，实现以下数据转换：

.. mermaid::

   graph TB
       subgraph "ROS 2 World"
           CAM["/camera/top/image_raw<br/>(sensor_msgs/Image)"]
           JS["/joint_states<br/>(sensor_msgs/JointState)"]
           CMD["/arm_position_controller/commands<br/>(Float64MultiArray)"]
       end
       
       subgraph "tensormsg Package"
           CONV["TensorMsgConverter"]
           DECODE["decode()<br/>ROS → NumPy"]
           ENCODE["encode()<br/>Tensor → ROS"]
           VARIANT_TO["to_variant()<br/>Dict[Tensor] → VariantsList"]
           VARIANT_FROM["from_variant()<br/>VariantsList → Dict[Tensor]"]
           
           CONV --> DECODE
           CONV --> ENCODE
           CONV --> VARIANT_TO
           CONV --> VARIANT_FROM
       end
       
       subgraph "ML/LeRobot World"
           OBS["observation.images.top<br/>(480, 640, 3) float32"]
           STATE["observation.state<br/>(6,) float32"]
           ACTION["action<br/>(6,) float32"]
       end
       
       CAM -->|"subscribe"| DECODE
       JS -->|"subscribe"| DECODE
       DECODE --> OBS
       DECODE --> STATE
       
       ACTION --> ENCODE
       ENCODE -->|"publish"| CMD
       
       OBS -.->|"distributed mode"| VARIANT_TO
       STATE -.->|"distributed mode"| VARIANT_TO
       VARIANT_FROM -.->|"distributed mode"| ACTION
       
       style CONV fill:#e8f5e9,stroke:#388e3c,stroke-width:3px
       style DECODE fill:#fff3e0,stroke:#ff9800,stroke-width:2px
       style ENCODE fill:#fff3e0,stroke:#ff9800,stroke-width:2px

**关键转换路径：**

1. **观测路径 (ROS → 张量)**: 相机图像和关节状态从 ROS 消息解码为 NumPy 数组，按契约规范调整大小/归一化，并批处理为张量用于策略输入。

2. **动作路径 (张量 → ROS)**: 策略输出张量被编码回 ROS 消息（如 ``Float64MultiArray``、``JointState``）并发布到控制器话题。

3. **分布式推理路径**: 观测和动作被序列化为 ``ibrobot_msgs/msg/VariantsList``，用于边缘节点和云端节点之间的网络传输。

**来源**: `README.md:30-31 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L30-L31>`__,
`src/tensormsg/tensormsg/converter.py:11-72 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/tensormsg/tensormsg/converter.py#L11-L72>`__,
`src/robot_config/config/robots/so101_single_arm.yaml:203-301 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L203-L301>`__

--------------

TensorMsgConverter 类
---------------------

``TensorMsgConverter`` 类提供所有协议转换的核心 API。它作为无状态工具运行，使用静态方法委托给已注册的编码器/解码器函数。

.. mermaid::

   graph LR
       subgraph "TensorMsgConverter API"
           API["TensorMsgConverter"]
           
           subgraph "Core Methods"
               DEC["decode(msg, spec)<br/>→ np.ndarray"]
               ENC["encode(ros_type, data, names, clamp)<br/>→ ROS Message"]
               TO_VAR["to_variant(batch)<br/>→ VariantsList"]
               FROM_VAR["from_variant(msg, device)<br/>→ Dict[str, Tensor]"]
           end
           
           API --> DEC
           API --> ENC
           API --> TO_VAR
           API --> FROM_VAR
       end
       
       subgraph "Registry System"
           ENC_REG["ENCODER_REGISTRY"]
           DEC_REG["DECODER_REGISTRY"]
       end
       
       subgraph "Registered Handlers"
           IMG_DEC["_dec_image()<br/>sensor_msgs/Image"]
           JS_DEC["_dec_joint_state()<br/>sensor_msgs/JointState"]
           F32_DEC["_dec_f32()<br/>Float32MultiArray"]
           TWIST_ENC["_enc_twist()<br/>geometry_msgs/Twist"]
           JS_ENC["_enc_joint_state()"]
       end
       
       DEC -->|"lookup"| DEC_REG
       ENC -->|"lookup"| ENC_REG
       
       DEC_REG --> IMG_DEC
       DEC_REG --> JS_DEC
       DEC_REG --> F32_DEC
       ENC_REG --> TWIST_ENC
       ENC_REG --> JS_ENC

**来源**: `src/tensormsg/tensormsg/converter.py:11-72 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/tensormsg/tensormsg/converter.py#L11-L72>`__

--------------

注册表系统
----------

该包使用基于装饰器的注册表模式将 ROS 消息类型与转换函数关联。这允许轻松扩展自定义消息类型，无需修改核心逻辑。

编码器注册
~~~~~~~~~~

编码器将 Python 数据（张量、数组、序列）转换为 ROS 消息：

.. code:: python

   # From converter.py:162-170
   @register_encoder("geometry_msgs/msg/Twist")
   def _enc_twist(names, data, clamp):
       if names: return _encode_via_dotted_paths("geometry_msgs/msg/Twist", names, data, clamp)
       msg = get_message("geometry_msgs/msg/Twist")()
       arr = np.asarray(data, dtype=np.float32).reshape(-1)
       if clamp: arr = np.clip(arr, clamp[0], clamp[1])
       if len(arr) >= 1: msg.linear.x = float(arr[0])
       if len(arr) >= 2: msg.angular.z = float(arr[1])
       return msg

解码器注册
~~~~~~~~~~

解码器从 ROS 消息中提取 NumPy 数组，应用契约规范：

.. code:: python

   # From converter.py:172-232
   @register_decoder("sensor_msgs/msg/Image")
   def _dec_image(msg, spec):
       h, w = int(msg.height), int(msg.width)
       enc = getattr(msg, "encoding", "bgr8").lower()
       raw = np.frombuffer(msg.data, dtype=np.uint8)
       
       resize_hw = spec.image_resize if spec and hasattr(spec, 'image_resize') else None
       
       # Handle RGB/BGR/RGBA/BGRA
       if enc in ("rgb8", "bgr8"):
           ch = 3
           row = raw.reshape(h, step)[:, : w * ch]
           arr = row.reshape(h, w, ch)
           hwc_rgb = arr if enc == "rgb8" else arr[..., ::-1]
       
       if resize_hw:
           hwc_rgb = nearest_resize_rgb(hwc_rgb, int(resize_hw[0]), int(resize_hw[1]))
       
       return hwc_rgb.astype(np.float32) / 255.0

**converter.py 中的主要注册：**

================================== ======= ======= ==============
ROS 类型                           解码器  编码器  行范围
================================== ======= ======= ==============
``sensor_msgs/msg/Image``          ✅       ❌       `172-232 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/172-232>`__
``sensor_msgs/msg/JointState``     ✅       ✅       `234-249 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/234-249>`__
``std_msgs/msg/Float32MultiArray`` ✅       ❌       `251-253 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/251-253>`__
``std_msgs/msg/Float64MultiArray`` ✅       ❌       `255-257 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/255-257>`__
``geometry_msgs/msg/Twist``        ❌       ✅       `162-170 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/162-170>`__
================================== ======= ======= ==============

**来源**: `src/tensormsg/tensormsg/converter.py:11-262 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/tensormsg/tensormsg/converter.py#L11-L262>`__,
`src/tensormsg/tensormsg/registry.py <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/tensormsg/tensormsg/registry.py>`__

--------------

图像解码管道
------------

图像解码器支持多种 ROS 编码格式，并应用契约指定的转换：

.. mermaid::

   graph TB
       MSG["sensor_msgs/Image<br/>encoding, width, height, data"]
       
       subgraph "Encoding Detection"
           ENC_CHECK{encoding type?}
       end
       
       subgraph "RGB/BGR Path"
           RGB_DECODE["Extract HWC array<br/>reshape(h, w, 3)"]
           BGR_FLIP["BGR → RGB<br/>arr[..., ::-1]"]
       end
       
       subgraph "Depth Path"
           DEPTH_16["16UC1:<br/>uint16 → meters"]
           DEPTH_32["32FC1:<br/>float32 direct"]
           DEPTH_NORM["Normalize to [0,1]<br/>clip & divide"]
           DEPTH_REPEAT["Repeat to 3 channels"]
       end
       
       subgraph "Contract Transformations"
           RESIZE_CHECK{resize specified?}
           RESIZE_OP["nearest_resize_rgb()<br/>to target HW"]
           NORMALIZE["/ 255.0<br/>→ float32 [0,1]"]
       end
       
       OUT["np.ndarray<br/>(H, W, 3) float32"]
       
       MSG --> ENC_CHECK
       ENC_CHECK -->|"rgb8/bgr8"| RGB_DECODE
       ENC_CHECK -->|"16uc1/mono16"| DEPTH_16
       ENC_CHECK -->|"32fc1"| DEPTH_32
       
       RGB_DECODE --> BGR_FLIP
       BGR_FLIP --> RESIZE_CHECK
       
       DEPTH_16 --> DEPTH_NORM
       DEPTH_32 --> DEPTH_NORM
       DEPTH_NORM --> DEPTH_REPEAT
       DEPTH_REPEAT --> RESIZE_CHECK
       
       RESIZE_CHECK -->|"yes"| RESIZE_OP
       RESIZE_CHECK -->|"no"| NORMALIZE
       RESIZE_OP --> NORMALIZE
       NORMALIZE --> OUT

**支持的编码格式:** - **RGB/BGR**: ``rgb8``、``bgr8``、``rgba8``、``bgra8`` (移除 alpha 通道) - **灰度**: ``mono8``、``8uc1`` (复制到 3 通道) - **深度**: ``16uc1``、``mono16`` (转换为米, 归一化)、``32fc1`` (直接使用 float32)

**契约驱动转换:** - **调整大小**: 如果 ``spec.image_resize`` 为 ``[480, 640]``, 应用最近邻调整大小 - **归一化**: 始终转换为 ``float32``, 范围 ``[0, 1]``

**来源**: `src/tensormsg/tensormsg/converter.py:172-232 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/tensormsg/tensormsg/converter.py#L172-L232>`__,
`src/robot_config/config/robots/so101_single_arm.yaml:208-209 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L208-L209>`__

--------------

带名称选择的关节状态解码
------------------------

``JointState`` 解码器支持使用点分路径表示法的契约驱动字段选择：

.. mermaid::

   graph TB
       JS_MSG["sensor_msgs/JointState<br/>name: ['1','2','3','4','5','6']<br/>position: [0.1, 0.2, ..., 0.6]<br/>velocity: [...]<br/>effort: [...]"]
       
       SPEC["Contract Spec<br/>names: ['position.1', 'position.2', ..., 'position.6']"]
       
       subgraph "Decoding Logic"
           HAS_NAMES{spec.names<br/>provided?}
           
           DOTTED["_decode_via_names()"]
           DEFAULT["Return msg.position<br/>as np.array"]
           
           LOOP["For each name in spec.names"]
           DOT_GET["dot_get(msg, 'position.1')<br/>→ Extract by index"]
           BUILD["Accumulate values"]
       end
       
       OUT["np.ndarray<br/>(6,) float32"]
       
       JS_MSG --> HAS_NAMES
       SPEC --> HAS_NAMES
       
       HAS_NAMES -->|"yes"| DOTTED
       HAS_NAMES -->|"no"| DEFAULT
       
       DOTTED --> LOOP
       LOOP --> DOT_GET
       DOT_GET --> BUILD
       BUILD --> OUT
       DEFAULT --> OUT

**契约规范示例：**

.. code:: yaml

   # From so101_single_arm.yaml:249-260
   - key: observation.state
     topic: /joint_states
     type: sensor_msgs/msg/JointState
     selector: 
       names: 
         - "position.1"
         - "position.2"
         - "position.3"
         - "position.4"
         - "position.5"
         - "position.6"

点分表示法 ``position.1`` 由 ``dot_get()`` 辅助函数解析，该函数导航消息结构并从 ``position`` 数组中提取索引 1 处的值。

**来源**: `src/tensormsg/tensormsg/converter.py:234-238 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/tensormsg/tensormsg/converter.py#L234-L238>`__,
`src/robot_config/config/robots/so101_single_arm.yaml:249-260 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L249-L260>`__

--------------

动作编码管道
------------

动作从张量编码回 ROS 消息供控制器使用：

.. mermaid::

   graph TB
       TENSOR["Tensor or np.ndarray<br/>(6,) float32<br/>[j1, j2, j3, j4, j5, gripper]"]
       
       CONTRACT["Contract Action Spec<br/>topic: /arm_position_controller/commands<br/>type: std_msgs/msg/Float64MultiArray<br/>names: ['action.0', ..., 'action.4']<br/>clamp: [-3.14, 3.14]"]
       
       subgraph "Encoding Logic"
           LOOKUP["Lookup encoder for<br/>std_msgs/msg/Float64MultiArray"]
           
           FOUND{encoder<br/>registered?}
           
           FALLBACK["_encode_via_dotted_paths()<br/>Manual field assignment"]
           REGISTERED["Registered encoder function"]
           
           FLATTEN["Flatten to 1D array"]
           CLAMP["Apply joint limits<br/>np.clip(arr, min, max)"]
           ASSIGN["Assign to msg fields<br/>via names or direct"]
       end
       
       MSG["std_msgs/Float64MultiArray<br/>data: [0.1, 0.2, 0.3, 0.4, 0.5]"]
       
       TENSOR --> FLATTEN
       CONTRACT --> LOOKUP
       FLATTEN --> CLAMP
       
       LOOKUP --> FOUND
       FOUND -->|"no"| FALLBACK
       FOUND -->|"yes"| REGISTERED
       
       FALLBACK --> CLAMP
       REGISTERED --> CLAMP
       CLAMP --> ASSIGN
       ASSIGN --> MSG

**使用点分路径编码：**

.. code:: python

   # From converter.py:75-84
   def _encode_via_dotted_paths(ros_type: str, names: List[str], data: Any, clamp: Optional[Tuple[float, float]] = None) -> Any:
       msg_cls = get_message(ros_type)
       msg = msg_cls()
       arr = np.asarray(data, dtype=np.float32).reshape(-1)
       if clamp:
           arr = np.clip(arr, clamp[0], clamp[1])
       for i, path in enumerate(names):
           if i < arr.size:
               dot_set(msg, path, float(arr[i]))
       return msg

**来源**: `src/tensormsg/tensormsg/converter.py:14-22 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/tensormsg/tensormsg/converter.py#L14-L22>`__,
`src/tensormsg/tensormsg/converter.py:75-84 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/tensormsg/tensormsg/converter.py#L75-L84>`__,
`src/robot_config/config/robots/so101_single_arm.yaml:264-283 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L264-L283>`__

--------------

分布式推理的变体序列化
----------------------

对于分布式推理模式，tensormsg 提供 ``to_variant()`` 和 ``from_variant()`` 方法，通过 ROS 话题序列化批次数据：

.. mermaid::

   graph TB
       subgraph "Edge Node (Device)"
           BATCH_EDGE["Dict[str, Tensor]<br/>observation.images.top: (1,3,480,640)<br/>observation.state: (1,6)"]
           TO_VAR["to_variant(batch)"]
           PUB["/preprocessed/batch<br/>publisher"]
       end
       
       subgraph "VariantsList Message"
           VLIST["ibrobot_msgs/msg/VariantsList<br/>variants: [Variant, Variant, ...]"]
           
           V1["Variant<br/>key: 'observation.images.top'<br/>type: 'float_32_array'<br/>float_32_array.data: [...]<br/>float_32_array.layout.dim: [(1), (3), (480), (640)]"]
           
           V2["Variant<br/>key: 'observation.state'<br/>type: 'float_32_array'<br/>float_32_array.data: [...]<br/>float_32_array.layout.dim: [(1), (6)]"]
           
           VLIST --> V1
           VLIST --> V2
       end
       
       subgraph "Cloud Node (GPU)"
           SUB["/preprocessed/batch<br/>subscriber"]
           FROM_VAR["from_variant(msg, device)"]
           BATCH_CLOUD["Dict[str, Tensor]<br/>on GPU"]
       end
       
       BATCH_EDGE --> TO_VAR
       TO_VAR --> VLIST
       VLIST --> PUB
       PUB -.->|"ROS 2 DDS"| SUB
       SUB --> FROM_VAR
       FROM_VAR --> BATCH_CLOUD
       
       style VLIST fill:#fff3e0,stroke:#ff9800,stroke-width:2px

to_variant() 实现
~~~~~~~~~~~~~~~~~

将张量字典转换为 ``VariantsList`` 消息：

.. code:: python

   # From converter.py:42-63
   @staticmethod
   def to_variant(batch: Dict[str, Any]) -> Any:
       msg_cls = get_message("ibrobot_msgs/msg/VariantsList")
       msg = msg_cls()
       msg.variants = []
       
       for key, value in batch.items():
           if not any(key.startswith(p) for p in ['task', 'observation', 'action']):
               continue
               
           variant_msg = get_message("ibrobot_msgs/msg/Variant")()
           variant_msg.key = key
           
           if isinstance(value, Tensor):
               _fill_variant_from_tensor(variant_msg, value)
           elif isinstance(value, list) and all(isinstance(x, str) for x in value):
               variant_msg.type = "string_array"
               variant_msg.string_array = value
           else:
               continue
           msg.variants.append(variant_msg)
       return msg

支持的张量类型
~~~~~~~~~~~~~~

================= ==================== =====================
Torch dtype       Variant 类型         MultiArray 消息
================= ==================== =====================
``torch.bool``    ``"bool_array"``     直接列表
``torch.int32``   ``"int_32_array"``   ``Int32MultiArray``
``torch.int64``   ``"int_64_array"``   ``Int64MultiArray``
``torch.float32`` ``"float_32_array"`` ``Float32MultiArray``
``torch.float64`` ``"float_64_array"`` ``Float64MultiArray``
================= ==================== =====================

每个 ``MultiArray`` 消息包含： - ``data``: 扁平化的 1D 值数组 - ``layout.dim``: ``MultiArrayDimension`` 消息列表，保留张量形状

**来源**: `src/tensormsg/tensormsg/converter.py:42-158 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/tensormsg/tensormsg/converter.py#L42-L158>`__,
`src/inference_service/README.en.md:46-79 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/README.en.md#L46-L79>`__

--------------

契约驱动转换
------------

契约系统确保观测和动作在录制、训练和推理期间以相同方式处理：

.. mermaid::

   graph TB
       subgraph "robot_config YAML (Single Source of Truth)"
           CONTRACT["contract:<br/>  rate_hz: 20<br/>  observations: [...]<br/>  actions: [...]"]
       end
       
       subgraph "Observation Specification"
           OBS_SPEC["- key: observation.images.top<br/>  topic: /camera/top/image_raw<br/>  type: sensor_msgs/msg/Image<br/>  peripheral: top<br/>  image:<br/>    resize: [480, 640]<br/>  align:<br/>    strategy: hold<br/>    stamp: header<br/>    tol_ms: 1500"]
       end
       
       subgraph "Action Specification"
           ACT_SPEC["- key: action<br/>  selector:<br/>    names: ['action.0', ..., 'action.4']<br/>  publish:<br/>    topic: /arm_position_controller/commands<br/>    type: std_msgs/msg/Float64MultiArray<br/>    strategy:<br/>      mode: nearest<br/>      tolerance_ms: 500"]
       end
       
       subgraph "tensormsg Usage"
           DECODE_CALL["decode(img_msg, spec)<br/>→ (480, 640, 3) float32"]
           ENCODE_CALL["encode('std_msgs/msg/Float64MultiArray',<br/>       action_tensor, names, clamp)"]
       end
       
       CONTRACT --> OBS_SPEC
       CONTRACT --> ACT_SPEC
       
       OBS_SPEC -.->|"spec.image_resize"| DECODE_CALL
       OBS_SPEC -.->|"spec.peripheral.width/height"| DECODE_CALL
       
       ACT_SPEC -.->|"spec.selector.names"| ENCODE_CALL
       ACT_SPEC -.->|"spec.publish.type"| ENCODE_CALL

**契约确保：** - **调整大小一致性**: 训练数据和实时推理使用相同的图像尺寸 - **字段映射**: 录制和推理中提取相同的关节索引/名称 - **QoS 设置**: 相同的可靠性/历史设置防止数据丢失 - **对齐策略**: 相同的时间戳容差防止同步漂移

**来源**:
`src/robot_config/config/robots/so101_single_arm.yaml:198-301 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L198-L301>`__,
`src/tensormsg/tensormsg/converter.py:24-39 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/tensormsg/tensormsg/converter.py#L24-L39>`__

--------------

使用示例
--------

推理节点中解码观测
~~~~~~~~~~~~~~~~~~

.. code:: python

   # Simplified from lerobot_policy_node
   from tensormsg.converter import TensorMsgConverter
   from robot_config.loader import load_robot_config

   config = load_robot_config("so101_single_arm.yaml")

   # Find observation spec by key
   obs_spec = next(o for o in config.contract.observations if o.key == "observation.images.top")

   # Callback receives ROS message
   def image_callback(msg):
       # Decode with contract spec
       img_array = TensorMsgConverter.decode(msg, obs_spec)
       # img_array is now (480, 640, 3) float32 in [0, 1]
       
       # Convert to torch tensor
       img_tensor = torch.from_numpy(img_array).permute(2, 0, 1)  # CHW
       # Ready for policy input

编码动作用于分发
~~~~~~~~~~~~~~~~

.. code:: python

   # Simplified from action_dispatcher_node
   from tensormsg.converter import TensorMsgConverter

   # Policy outputs action tensor
   action_tensor = policy.predict(observations)  # (6,) float32

   # Find action spec
   action_spec = config.contract.actions[0]
   ros_type = action_spec.publish['type']
   names = action_spec.selector['names']

   # Encode to ROS message
   msg = TensorMsgConverter.encode(
       ros_type=ros_type,
       data=action_tensor,
       names=names,
       clamp=(-3.14, 3.14)  # Joint limits
   )

   # Publish to controller
   publisher.publish(msg)

分布式模式的变体序列化
~~~~~~~~~~~~~~~~~~~~~~

.. code:: python

   # Edge node: serialize batch for network transmission
   from tensormsg.converter import TensorMsgConverter

   batch = {
       "observation.images.top": torch.randn(1, 3, 480, 640),
       "observation.state": torch.randn(1, 6)
   }

   variants_msg = TensorMsgConverter.to_variant(batch)
   preprocessed_pub.publish(variants_msg)

   # Cloud node: deserialize and move to GPU
   def batch_callback(variants_msg):
       batch = TensorMsgConverter.from_variant(variants_msg, device=torch.device("cuda"))
       # batch tensors are now on GPU, ready for inference
       output = model(batch)

**来源**: `src/tensormsg/tensormsg/converter.py:11-158 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/tensormsg/tensormsg/converter.py#L11-L158>`__,
`src/inference_service/inference_service/nodes/lerobot_policy_node.py <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/inference_service/inference_service/nodes/lerobot_policy_node.py>`__

--------------

关键设计原则
------------

1. **无状态转换**: 所有方法都是静态的；没有内部状态允许跨线程并行使用。

2. **契约驱动一致性**: 来自 ``robot_config`` 的规范确保录制、训练和推理中的处理完全相同。

3. **通过注册表扩展**: 通过使用 ``@register_encoder`` 或 ``@register_decoder`` 装饰函数来添加新消息类型。

4. **回退机制**: 当没有注册的处理程序时，点分路径表示法允许通用字段访问。

5. **尽可能零拷贝**: NumPy 数组直接从 ROS 消息缓冲区创建（如 ``np.frombuffer(msg.data)``），以最小化分配开销。

**来源**: `src/tensormsg/tensormsg/converter.py:11-262 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/tensormsg/tensormsg/converter.py#L11-L262>`__,
`README.md:30-31 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/README.md#L30-L31>`__

外设配置
========

.. raw:: html

   <details>

相关源文件

以下文件用于生成此文档页面：

-  `src/robot_config/README.en.md <src/robot_config/README.en.md>`__
-  `src/robot_config/README.md <src/robot_config/README.md>`__
-  `src/robot_config/config/robots/so101_dual_arm.yaml <src/robot_config/config/robots/so101_dual_arm.yaml>`__
-  `src/robot_config/config/robots/so101_single_arm.yaml <src/robot_config/config/robots/so101_single_arm.yaml>`__
-  `src/robot_config/robot_config/loader.py <src/robot_config/robot_config/loader.py>`__
-  `src/tensormsg/tensormsg/converter.py <src/tensormsg/tensormsg/converter.py>`__

.. raw:: html

   </details>

目的与范围
----------

本文档介绍 robot_config 中的外设配置系统，该系统定义了连接到机器人的相机和传感器硬件。外设在机器人 YAML 文件的 ``peripherals`` 部分定义，主要有两个用途：

1. **硬件配置**：使用适当的参数启动 ROS2 相机驱动节点
2. **元数据注入**：为契约观测提供分辨率、FPS 和帧信息

有关通用机器人配置结构，请参阅 `机器人配置文件 <#5.1>`__。有关契约观测如何引用外设，请参阅 `契约定义 <#5.2>`__。有关 TF 帧发布和启动集成，请参阅 `启动系统 <#5.4>`__。

**来源**：`src/robot_config/README.en.md:1-86 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/README.en.md#L1-L86>`__，
`src/robot_config/config/robots/so101_single_arm.yaml:130-196 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L130-L196>`__

--------------

外设配置结构
------------

外设定义在机器人配置 YAML 的 ``robot.peripherals`` 下作为一个列表。每个外设条目指定其类型、驱动和硬件特定参数。

.. mermaid::

   graph TB
       YAML["robot_config YAML<br/>so101_single_arm.yaml"]
       
       subgraph "peripherals 部分"
           PERIPH_LIST["peripherals: [list]"]
           
           CAM1["相机 1<br/>type: camera<br/>name: top<br/>driver: opencv"]
           CAM2["相机 2<br/>name: wrist<br/>driver: opencv"]
           CAM3["相机 3<br/>name: front<br/>driver: realsense"]
           
           PERIPH_LIST --> CAM1
           PERIPH_LIST --> CAM2
           PERIPH_LIST --> CAM3
       end
       
       subgraph "外设属性"
           HARDWARE["硬件配置<br/>index/serial_number<br/>width/height/fps"]
           FRAMES["帧 ID<br/>frame_id<br/>optical_frame_id"]
           TRANSFORM["变换<br/>parent_frame<br/>x,y,z,roll,pitch,yaw"]
           CALIB["标定<br/>camera_info_url"]
           
           CAM1 --> HARDWARE
           CAM1 --> FRAMES
           CAM1 --> TRANSFORM
           CAM1 --> CALIB
       end
       
       subgraph "消费者系统"
           LOADER["loader.py<br/>load_camera_config()"]
           CONTRACT["契约观测<br/>peripheral: reference"]
           LAUNCH["启动系统<br/>相机驱动节点"]
           
           YAML --> LOADER
           LOADER --> CONTRACT
           LOADER --> LAUNCH
       end

**图表**：外设配置数据从 YAML 定义流向消费者系统

**来源**：
`src/robot_config/config/robots/so101_single_arm.yaml:130-196 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L130-L196>`__，
`src/robot_config/robot_config/loader.py:25-63 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/loader.py#L25-L63>`__

--------------

相机外设类型
------------

系统目前支持两种相机驱动类型，每种都封装了现有的 ROS2 相机包。

驱动类型：opencv (usb_cam)
~~~~~~~~~~~~~~~~~~~~~~~~~~~

使用 ``usb_cam`` ROS2 包支持 USB 相机（网络摄像头、USB3 工业相机）。基于 OpenCV 的后端。

**配置示例**：

.. code:: yaml

   - type: camera
     name: top
     driver: opencv
     index: 0                    # /dev/video0
     width: 640
     height: 480
     fps: 30
     pixel_format: mjpeg2rgb     # mjpeg2rgb | bgr8 | rgb8 | yuyv
     frame_id: camera_top_frame
     optical_frame_id: camera_top_optical_frame


.. list-table::
   :header-rows: 1

   * - 参数
     - 类型
     - 必需
     - 描述
   * - ``index``
     - int
     - 是
     - USB 视频设备索引 (``/dev/video<N>``)
   * - ``width``
     - int
     - 是
     - 图像宽度（像素）
   * - ``height``
     - int
     - 是
     - 图像高度（像素）
   * - ``fps``
     - int
     - 是
     - 每秒帧数
   * - ``pixel_format``
     - string
     - 否
     - 编码格式 (默认: ``bgr8``)
   * - ``frame_id``
     - string
     - 是
     - 相机安装点的 TF 帧
   * - ``optical_frame_id``
     - string
     - 是
     - TF 光学帧（ROS 约定）

**来源**：
`src/robot_config/config/robots/so101_single_arm.yaml:132-152 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L132-L152>`__，
`src/robot_config/README.en.md:432-451 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/README.en.md#L432-L451>`__

驱动类型：realsense (realsense2_camera)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

使用 ``realsense2_camera`` ROS2 包支持 Intel RealSense D400 系列深度相机。

**配置示例**：

.. code:: yaml

   - type: camera
     name: front
     driver: realsense
     serial_number: ""           # 可选：指定设备序列号
     width: 640
     height: 480
     fps: 30
     pixel_format: bgr8
     enable_pointcloud: false
     align_depth: true
     frame_id: camera_front_link
     optical_frame_id: camera_front_optical_frame


.. list-table::
   :header-rows: 1

   * - 参数
     - 类型
     - 必需
     - 描述
   * - ``serial_number``
     - string
     - 否
     - 设备序列号 (空 = 第一个设备)
   * - ``width``
     - int
     - 是
     - 彩色图像宽度
   * - ``height``
     - int
     - 是
     - 彩色图像高度
   * - ``fps``
     - int
     - 是
     - 彩色流帧率
   * - ``enable_pointcloud``
     - bool
     - 否
     - 发布点云 (默认: false)
   * - ``align_depth``
     - bool
     - 否
     - 将深度对齐到彩色帧 (默认: true)

**来源**：
`src/robot_config/config/robots/so101_single_arm.yaml:175-196 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L175-L196>`__，
`src/robot_config/README.en.md:453-476 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/README.en.md#L453-L476>`__

--------------

变换配置
--------

每个外设通过 ``transform`` 部分定义其与机器人的空间关系，指定父帧和 6DOF 位姿。

.. code:: yaml

   transform:
     parent_frame: base          # 父 TF 帧
     x: 0.0                      # 平移（米）
     y: 0.0
     z: 0.5
     roll: 0.0                   # 旋转（弧度）
     pitch: 0.0
     yaw: 0.0

帧层次结构
~~~~~~~~~~

.. mermaid::

   graph TB
       BASE["base<br/>(机器人根节点)"]
       
       WRIST["wrist<br/>(末端执行器)"]
       
       CAM_TOP_FRAME["camera_top_frame<br/>(安装点)"]
       CAM_TOP_OPT["camera_top_optical_frame<br/>(光学中心)"]
       
       CAM_WRIST_FRAME["camera_wrist_frame"]
       CAM_WRIST_OPT["camera_wrist_optical_frame"]
       
       BASE --> CAM_TOP_FRAME
       CAM_TOP_FRAME --> CAM_TOP_OPT
       
       BASE --> WRIST
       WRIST --> CAM_WRIST_FRAME
       CAM_WRIST_FRAME --> CAM_WRIST_OPT
       
       style CAM_TOP_FRAME fill:#f9f9f9
       style CAM_WRIST_FRAME fill:#f9f9f9

**图表**：相机外设的 TF 帧层次结构

启动系统自动发布从 ``parent_frame`` 到 ``frame_id`` 的静态变换，以及从 ``frame_id`` 到 ``optical_frame_id`` 的变换（ROS 光学帧约定：Z 向前，Y 向下，X 向右）。

**来源**：
`src/robot_config/config/robots/so101_single_arm.yaml:143-151 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L143-L151>`__，
`src/robot_config/config/robots/so101_single_arm.yaml:165-173 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L165-L173>`__

--------------

相机标定集成
------------

相机内参（焦距、畸变系数）可以通过标准 ROS2 ``camera_info_manager`` 加载。

.. code:: yaml

   - type: camera
     name: top
     driver: opencv
     index: 0
     width: 640
     height: 480
     camera_info_url: file://$(env HOME)/.ros/camera_info/top_camera.yaml

标定文件路径必须使用 ``file://`` 协议。支持通过 ``$(env VAR)`` 语法进行环境变量扩展。

创建标定文件
~~~~~~~~~~~~

.. code:: bash

   # 运行 ROS2 相机标定工具
   ros2 run camera_calibration cameracalibrator \
     --size 8x6 \
     --square 0.024 \
     image:=/camera/top/image_raw

   # 保存到 ~/.ros/camera_info/top_camera.yaml

**来源**：`src/robot_config/README.en.md:478-499 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/README.en.md#L478-L499>`__，
`src/robot_config/robot_config/loader.py:248-252 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/loader.py#L248-L252>`__

--------------

与契约系统集成
--------------

外设通过 ``peripheral`` 字段在契约观测中按名称引用。这种链接实现了自动元数据传播。

.. mermaid::

   graph LR
       subgraph "robot_config YAML"
           PERIPH_DEF["peripherals:<br/>- name: top<br/>  width: 640<br/>  height: 480<br/>  fps: 30"]
           
           CONTRACT_OBS["contract.observations:<br/>- key: observation.images.top<br/>  peripheral: top<br/>  image:<br/>    resize: [480, 640]"]
       end
       
       subgraph "已加载配置"
           PERIPH_OBJ["PeripheralConfig<br/>name='top'<br/>width=640<br/>height=480"]
           
           OBS_OBJ["ContractObservation<br/>key='observation.images.top'<br/>peripheral='top'"]
       end
       
       subgraph "运行时系统"
           RECORDER["episode_recorder<br/>订阅 /camera/top/image_raw"]
           
           BAG2LR["bag_to_lerobot<br/>使用元数据解码:<br/>width=640, height=480<br/>调整大小到 480x640"]
           
           INFERENCE["lerobot_policy_node<br/>创建 StreamBuffer:<br/>width=640, height=480"]
       end
       
       PERIPH_DEF --> PERIPH_OBJ
       CONTRACT_OBS --> OBS_OBJ
       
       PERIPH_OBJ -.->|"元数据查找"| OBS_OBJ
       
       OBS_OBJ --> RECORDER
       OBS_OBJ --> BAG2LR
       OBS_OBJ --> INFERENCE

**图表**：外设元数据传播到契约消费者

元数据查找机制
~~~~~~~~~~~~~~

当契约观测指定 ``peripheral: top`` 时，系统：

1. **加载阶段**：
   `src/robot_config/robot_config/loader.py:94-144 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/loader.py#L94-L144>`__ 将外设定义加载到 ``PeripheralConfig`` 对象
2. **契约解析**：带有 ``peripheral`` 字段的观测按名称查找元数据
3. **消费者系统**：``episode_recorder``、``bag_to_lerobot`` 和 ``lerobot_policy_node`` 访问外设元数据用于：

   -  图像解码（分辨率、像素格式）
   -  重采样（从原始 FPS 到 ``rate_hz``）
   -  张量形状验证

**来源**：
`src/robot_config/config/robots/so101_single_arm.yaml:203-247 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L203-L247>`__，
`src/robot_config/robot_config/loader.py:256-260 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/loader.py#L256-L260>`__

--------------

外设加载器实现
--------------

`src/robot_config/robot_config/loader.py:25-63 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/loader.py#L25-L63>`__ 中的 ``load_camera_config()`` 函数将 YAML 字典转换为 ``CameraConfig`` 数据类实例。

.. mermaid::

   graph TB
       YAML_DICT["YAML dict<br/>{type: camera, name: top, driver: opencv, ...}"]
       
       LOADER["load_camera_config(data)"]
       
       subgraph "处理步骤"
           DRIVER_SELECT["确定驱动类型<br/>opencv | realsense"]
           INDEX_SELECT["选择索引字段<br/>index | port | serial_number"]
           DEFAULTS["应用默认值<br/>width=640, height=480, fps=30"]
           FRAME_IDS["生成帧 ID<br/>camera_{name}_frame"]
       end
       
       CAM_OBJ["CameraConfig 对象<br/>name, driver, width, height,<br/>frame_id, optical_frame_id, ..."]
       
       YAML_DICT --> LOADER
       LOADER --> DRIVER_SELECT
       DRIVER_SELECT --> INDEX_SELECT
       INDEX_SELECT --> DEFAULTS
       DEFAULTS --> FRAME_IDS
       FRAME_IDS --> CAM_OBJ

**图表**：相机配置加载流程

索引/端口处理
~~~~~~~~~~~~~~

不同的相机驱动使用不同的参数名称来识别设备：

- **opencv**：``index`` （``/dev/video<N>`` 的整数）
- **realsense**：``serial_number`` （特定设备的字符串）

加载器将这些标准化为 ``index_or_port``：

`src/robot_config/robot_config/loader.py:44-47 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/loader.py#L44-L47>`__

.. code:: python

   index_or_port = data.get("index", data.get("port", data.get("serial_number", 0)))
   if driver == "realsense" and "serial_number" in data:
       index_or_port = data["serial_number"]

**来源**：`src/robot_config/robot_config/loader.py:25-63 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/loader.py#L25-L63>`__

--------------

验证
----

外设配置在 ``validate_config()`` 期间于
`src/robot_config/robot_config/loader.py:217-262 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/loader.py#L217-L262>`__ 进行验证：

相机特定验证
~~~~~~~~~~~~


.. list-table::
   :header-rows: 1

   * - 检查
     - 错误条件
   * - 名称重复
     - 相同相机名称出现多次
   * - 无效尺寸
     - ``width <= 0`` 或 ``height <= 0``
   * - 无效 FPS
     - ``fps <= 0``
   * - 标定文件
     - ``camera_info_url`` 指向不存在的文件
   * - 外设引用
     - 契约观测引用未定义的外设

**验证示例**：

.. code:: python

   # 验证相机尺寸
   if cam.width <= 0 or cam.height <= 0:
       errors.append(f"Invalid camera dimensions for {cam.name}: {cam.width}x{cam.height}")

   # 验证契约-外设链接
   for obs in config.contract.observations:
       if obs.peripheral:
           if obs.peripheral not in camera_names:
               errors.append(
                   f"Observation '{obs.key}' references undefined peripheral: {obs.peripheral}"
               )

**来源**：`src/robot_config/robot_config/loader.py:236-260 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/loader.py#L236-L260>`__

--------------

双臂外设配置
------------

对于双臂机器人，外设遵循区分左/右或主/从的命名约定。

**示例来自**
`src/robot_config/config/robots/so101_dual_arm.yaml:42-101 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_dual_arm.yaml#L42-L101>`__：

.. code:: yaml

   peripherals:
     # 共享俯视图
     - type: camera
       name: top
       driver: opencv
       index: 0
       transform:
         parent_frame: base_link
         z: 0.5

     # 左手腕相机
     - type: camera
       name: left_wrist
       driver: opencv
       index: 2
       transform:
         parent_frame: left_wrist_link

     # 右手腕相机
     - type: camera
       name: right_wrist
       driver: opencv
       index: 4
       transform:
         parent_frame: right_wrist_link

每条手臂的腕部相机：

- 使用不同的 USB 索引（``index: 2`` vs ``index: 4``）
- 引用特定手臂的 TF 帧（``left_wrist_link`` vs ``right_wrist_link``）
- 可以在契约观测中独立引用

**来源**：
`src/robot_config/config/robots/so101_dual_arm.yaml:42-101 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_dual_arm.yaml#L42-L101>`__

--------------

图像编码与解码
--------------

虽然外设配置指定了 ``pixel_format`` 参数，但实际的图像解码发生在 ``tensormsg`` 中，使用外设元数据。

支持的像素格式
~~~~~~~~~~~~~~

============= =============== ======== ==========================
格式          描述            通道数   用例
============= =============== ======== ==========================
``bgr8``      8 位 BGR        3        默认 OpenCV 格式
``rgb8``      8 位 RGB        3        标准 RGB
``rgba8``     8 位 RGBA       4        RGB + 透明通道
``bgra8``     8 位 BGRA       4        BGR + 透明通道
``mono8``     8 位灰度        1        单色相机
``mjpeg2rgb`` MJPEG→RGB       3        压缩 USB 相机
``32fc1``     32 位浮点       1        深度图像
``16uc1``     16 位无符号     1        深度图像（毫米）
============= =============== ======== ==========================

`src/tensormsg/tensormsg/converter.py:172-232 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/tensormsg/tensormsg/converter.py#L172-L232>`__ 中的解码器处理这些编码，根据需要应用归一化和通道转换。

**来源**：`src/tensormsg/tensormsg/converter.py:172-232 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/tensormsg/tensormsg/converter.py#L172-L232>`__，
`src/robot_config/config/robots/so101_single_arm.yaml:139 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/config/robots/so101_single_arm.yaml#L139>`__

--------------

扩展到非相机外设
----------------

虽然相机是主要的外设类型，但配置系统通过通用 ``PeripheralConfig`` 支持任意传感器类型：

.. code:: yaml

   peripherals:
     - type: microphone
       name: desk_mic
       driver: audio_ros
       params:
         device_id: "hw:1,0"
         sample_rate: 44100
         channels: 2
       frame_id: microphone_frame

`src/robot_config/robot_config/loader.py:193-201 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/loader.py#L193-L201>`__ 加载非相机外设：

.. code:: python

   else:
       # 通用外设
       peripherals.append(
           PeripheralConfig(
               type=periph_data["type"],
               name=periph_data["name"],
               driver=periph_data.get("driver", "generic"),
               params=periph_data.get("params", {}),
               frame_id=periph_data.get("frame_id"),
           )
       )

**来源**：`src/robot_config/robot_config/loader.py:193-201 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/loader.py#L193-L201>`__

--------------

总结
----

外设配置系统提供：

1. **统一的硬件定义**：所有相机和传感器使用单一 YAML 部分
2. **驱动抽象**：支持多种 ROS2 相机包（usb_cam、realsense2_camera）
3. **空间注册**：用于 3D 传感器放置的 TF 帧变换
4. **元数据传播**：分辨率、FPS 和编码信息流向契约系统
5. **标定集成**：标准 ROS2 camera_info_manager 支持
6. **验证**：配置一致性的编译时检查

这种架构消除了相机驱动配置、契约定义和数据集转换工具之间的重复，实现了 `核心概念 <#3>`__ 中描述的单一数据源模式。

**来源**：`src/robot_config/README.en.md:1-86 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/README.en.md#L1-L86>`__，
`src/robot_config/robot_config/loader.py:25-287 <https://gitcode.com/openeuler/IB_Robot/blob/9e382ea2320c3260b03e9c838696f8ac89eb8944/src/robot_config/robot_config/loader.py#L25-L287>`__

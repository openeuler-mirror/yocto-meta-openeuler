.. _hieulerpi_heterogeneous_compute:

海鸥派异构算力（NPU/DSP）使用指南
##########################################

.. contents::
   :local:

海鸥派主控 SS928（SD3403V100/Hi3403V100）除四核 Cortex-A55 外，还集成
NNN、SVP_NPU、双核 Vision Q6 DSP、SVP 视频加速引擎和 RISC-V MCU。
这些单元使用不同的驱动、用户态库和工具链，不能互相替代。本文给出
各单元的用途、核心参数、内存/驱动位置和基本开发流程。

一、异构算力概览
================

.. list-table::
   :header-rows: 1
   :widths: 14 22 24 40

   * - 单元
     - 用途
     - 软件接口
     - 说明
   * - Cortex-A55 x4
     - 通用控制、MPP 媒体流水线、后处理
     - Linux 用户态
     - 主 CPU，负责调度和 CPU 后处理
   * - NNN（dlite）
     - 通用神经网络推理
     - AscendCL ``acl*`` + ``.om``
     - 支持 INT4/INT8/FP16，适合 ONNX/Caffe/TensorFlow 模型
   * - SVP_NPU（dpico）
     - 视觉神经网络推理
     - ``svp_acl*`` + ``.om``
     - 只支持 INT8/INT16，开销低，适合检测/分类
   * - Vision Q6 DSP x2
     - 传统 CV、信号处理、几何/深度计算
     - ``ss_mpi_svp_dsp_*`` + DSP 固件
     - Cadence Tensilica IP；定制算法需要 DSP 工具链
   * - SVP 引擎
     - IVE 图像预处理、KCF 跟踪、DPU 深度/匹配、MAU 矩阵
     - MPP MPI（``ot_ive``/``ot_dpu_*``/``ot_mau``）
     - 硬件加速模块，不需要单独模型
   * - RISC-V MCU
     - 实时控制、LiteOS
     - ``/dev/ipcm``、``virt-tty``
     - 与 Linux 通过 IPCM 共享内存通信

二、核心参数
============

.. list-table::
   :header-rows: 1
   :widths: 22 22 56

   * - 参数
     - 数值
     - 说明
   * - NPU 总算力
     - 10.4 TOPS INT8
     - 板卡口径为 NNN 4.8T + SVP_NNN 5.6T；部分公开资料只写 NN 4T
   * - NNN
     - 4.8 TOPS INT8
     - 支持 INT4/INT8/FP16；使用 AscendCL
   * - SVP_NPU
     - 5.6 TOPS INT8
     - 仅支持 INT8/INT16；使用 svp_acl
   * - DSP
     - 2 x Vision Q6
     - 每核 32KB I-Cache、32KB D-Cache、32KB IRAM、320KB DRAM
   * - DSP 预留内存
     - 62 MiB @ ``0x40200000``
     - ``load_ss928v100`` 中 ``dsp_mem_size=62``
   * - MCU
     - 32bit RISC-V @500MHz
     - 192 MiB @ ``0x44000000``，运行 LiteOS
   * - MMZ
     - 约 1792 MiB（8GB 板）
     - NPU/媒体内存池，起始 ``0x1d0000000``

NPU、DSP 和 MCU 使用独立 carveout，Linux 通过 ``mem=6144M`` 使用其余
内存。完整内存布局和 eMMC/启动流程见 :ref:`hieulerpi_system`。

三、驱动与设备节点
==================

kernel5 的 ``S90AutoRun`` 执行 ``/ko/load_ss928v100 -i``，与异构算力
相关的加载项如下：

.. code-block:: console

   # NNN
   insmod npu/ot_npu_device.ko
   insmod npu/ot_npu_aicpu.ko
   insmod npu/ot_npu_dfx.ko
   insmod npu/ot_npu_tsfw.ko

   # SVP_NPU
   insmod svp_npu/ot_svp_npu.ko

   # DSP
   insmod ot_dsp.ko

设备节点和用户态库：

.. list-table::
   :header-rows: 1
   :widths: 18 26 56

   * - 单元
     - 设备节点/库
     - 说明
   * - NNN
     - ``/usr/lib64/npu/libascendcl.so``
     - 驱动为 4 个 ``ot_npu_*.ko``，通过 AscendCL runtime 访问
   * - SVP_NPU
     - ``/dev/svp_npu``、``/usr/lib64/svp_npu/libsvp_acl.so``
     - ``ot_svp_npu.ko``\ 与 ``ot_pqp.ko`` 共用中断，不能同时加载
   * - DSP
     - ``/dev/dsp``、``/usr/lib64/libss_dsp.so``
     - 使用 ``ss_mpi_svp_dsp_*`` 接口

自检命令：

.. code-block:: console

   lsmod | grep -E 'npu|svp|dsp'
   ls -l /dev/svp_npu /dev/dsp
   ls /usr/lib64/npu /usr/lib64/svp_npu
   dmesg | grep -Ei 'npu|svp|dsp'

设备节点默认只有 root 可访问。kernel6 的
``bsp/meta-hisilicon/recipes-bsp/ss928/files/load_sdk_driver`` 目前只加载
``ot_svp_npu.ko``，NNN 和 DSP 模块不会自动加载，使用前需要确认或补充
加载脚本。

对应设备树节点位于
``bsp/meta-hisilicon/recipes-kernel/linux/files/dtbs/ss928-pi.dts``：

- ``npu@0x14000000``：NNN 的 NPU top/HTWS/AICore 和 CRG。
- ``svp_npu@0x15000000``：SVP_NPU，与 PQP 共用中断。
- ``dsp@0x16110000``：DSP0/DSP1。
- ``smmu_npu@14040000``、``svm_npu@14020000``：NNN 使用的 SMMU/SVM。

这些 carveout 在 Linux 启动前已经预留，用户态不要按普通内存直接读写。
如果 SVP_NPU 样例报 ``open /dev/svp_npu err``\ ，先确认
``ot_svp_npu.ko`` 已加载、``/dev/svp_npu`` 存在。

四、NNN（dlite）开发流程
========================

NNN 使用 AscendCL 接口，模型格式为 ``.om``，适合通用 ONNX/Caffe/
TensorFlow 模型。

4.1 模型转换
------------

在 x86 主机安装厂商 SDK 中的 NNN/CANN 工具链（例如
``Ascend-cann-toolkit_5.20.t6.2.b060_linux-x86_64.run``\ ），然后使用
``atc`` 将模型转换为 ``.om``：

.. code-block:: console

   source /usr/local/Ascend/ascend-toolkit/latest/.../bin/setenv.bash
   atc --model=yolov8n.onnx --framework=5 --output=yolov8n ...

INT8 量化通常配合 AMCT 做校准。具体 ``--soc_version``、``--input_shape``
和 ``--precision_mode`` 以 SDK 中对应版本的 NNN 文档为准。

4.2 交叉编译
------------

头文件来自 ``hieulerpi1-user-driver-dev`` 或 SDK sysroot：

.. code-block:: console

   aarch64-openeuler-linux-gnu-g++ app.cpp \
     -I<sysroot>/usr/include/npu \
     -L<sysroot>/usr/lib64/npu \
     -lascendcl -lstdc++ -lpthread -ldl -lrt -lm

4.3 运行时流程
--------------

.. code-block:: c

   #include "npu/acl.h"
   #include "npu/acl_mdl.h"

   aclInit(NULL);
   aclrtSetDevice(0);

   uint32_t model_id;
   aclmdlLoadFromFile("/root/model.om", &model_id);

   aclmdlDesc *desc = aclmdlCreateDesc();
   aclmdlGetDesc(desc, model_id);

   size_t in_size = aclmdlGetInputSizeByIndex(desc, 0);
   size_t out_size = aclmdlGetOutputSizeByIndex(desc, 0);

   void *in_dev = NULL;
   void *out_dev = NULL;
   aclrtMalloc(&in_dev, in_size, ACL_MEM_MALLOC_HUGE_FIRST);
   aclrtMalloc(&out_dev, out_size, ACL_MEM_MALLOC_HUGE_FIRST);

   aclmdlDataset *input = aclmdlCreateDataset();
   aclmdlDataset *output = aclmdlCreateDataset();
   aclmdlAddDatasetBuffer(input, aclCreateDataBuffer(in_dev, in_size));
   aclmdlAddDatasetBuffer(output, aclCreateDataBuffer(out_dev, out_size));

   aclrtMemcpy(in_dev, in_size, host_in, in_size,
               ACL_MEMCPY_HOST_TO_DEVICE);
   aclmdlExecute(model_id, input, output);
   aclrtMemcpy(host_out, out_size, out_dev, out_size,
               ACL_MEMCPY_DEVICE_TO_HOST);

   aclmdlDestroyDataset(input);
   aclmdlDestroyDataset(output);
   aclmdlUnload(model_id);
   aclFinalize();

运行前设置库路径：

.. code-block:: console

   export LD_LIBRARY_PATH=/usr/lib64/npu:$LD_LIBRARY_PATH
   export LD_PRELOAD=/usr/lib64/npu/libascend_protobuf.so

``LD_PRELOAD`` 是当前镜像的规避项，原因见“八、已上板验证与已知问题”。

4.4 样例与限制
--------------

NNN 样例和模型转换工具位于厂商 SDK 的 NNN_PC/CANN 包中，当前镜像
默认只安装运行库，不包含 NNN 样例、头文件和 ``.om`` 模型。NNN 支持
INT4/INT8/FP16，但模型必须由与板上 runtime 匹配的工具链转换。

五、SVP_NPU（dpico）开发流程
============================

SVP_NPU 使用 ``svp_acl`` 接口，模型同样为 ``.om``，但只支持
INT8/INT16，适合视觉检测/分类等定点模型。

5.1 模型转换
------------

使用厂商 SDK 中的 SVP_NNN 工具链/ATC 将 ONNX/Caffe 模型转换为
INT8/INT16 的 ``.om``。SVP_NPU 不支持 NNN 的 INT4/FP16 路径。

5.2 交叉编译
------------

.. code-block:: console

   aarch64-openeuler-linux-gnu-g++ app.cpp \
     -I<sysroot>/usr/include \
     -L<sysroot>/usr/lib64/svp_npu \
     -lsvp_acl -lprotobuf-c -lsecurec \
     -lpthread -ldl -lrt -lm

5.3 运行时流程
--------------

.. code-block:: c

   #include "svp_npu/svp_acl.h"
   #include "svp_npu/svp_acl_rt.h"
   #include "svp_npu/svp_acl_mdl.h"

   svp_acl_init(NULL);
   svp_acl_rt_set_device(0);
   svp_acl_rt_create_context(&ctx, 0);
   svp_acl_rt_create_stream(&stream);

   void *model_mem = NULL;
   svp_acl_rt_malloc_cached(&model_mem, model_size,
                            SVP_ACL_MEM_MALLOC_NORMAL_ONLY);
   /* 读取 .om 到 model_mem 后刷新 cache */
   svp_acl_rt_mem_flush(model_mem, model_size);

   uint32_t model_id;
   svp_acl_mdl_load_from_mem(model_mem, model_size, &model_id);

   svp_acl_mdl_desc *desc = svp_acl_mdl_create_desc();
   svp_acl_mdl_get_desc(desc, model_id);

   svp_acl_mdl_dataset *input = svp_acl_mdl_create_dataset();
   svp_acl_mdl_dataset *output = svp_acl_mdl_create_dataset();

   /*
    * 对每路输入/输出：
    * 1. svp_acl_mdl_get_input/output_size_by_index() 获取 size
    * 2. svp_acl_rt_malloc_cached() 申请 buffer
    * 3. svp_acl_create_data_buffer() 创建 data buffer
    * 4. svp_acl_mdl_add_dataset_buffer() 加入 dataset
    */

   /* 拷贝图像到输入 buffer 后刷新 cache */
   svp_acl_mdl_execute(model_id, input, output);

   /* 读取输出前刷新输出 buffer cache，再做后处理 */

运行环境：

.. code-block:: console

   export LD_LIBRARY_PATH=/usr/lib64/svp_npu:/usr/lib64:$LD_LIBRARY_PATH

5.4 输入输出注意事项
--------------------

- 用 ``svp_acl_mdl_get_input_dims``\ 、\ ``svp_acl_mdl_get_input_size_by_index``
  和 ``svp_acl_mdl_get_input_default_stride`` 确认尺寸、类型和 stride。
- 视觉模型的第一路输入通常是 YUV420SP 或 NCHW UINT8 图像，由
  VPSS/VGS 等 MPP 模块产出。
- 检测模型可能带有额外的运行时/工作缓冲区输入，不能只按“一路图像
  输入”处理；应遍历 ``svp_acl_mdl_get_num_inputs`` 返回的所有输入。
- 输出格式常见为 ND/NCHW，需要按模型后处理逻辑解析 stride 和维度。

5.5 样例
--------

SDK 自带 SVP_NPU 样例：

.. code-block:: text

   smp/a55_linux/mpp/sample/svp/svp_npu/
   ├── data/model/{resnet50,yolov5,yolov7,yolov8,lstm,rfcn}.om
   ├── sample_svp_npu/sample_svp_npu_process.c
   └── sample_svp_npu_main.c

编译后运行：

.. code-block:: console

   ./sample_svp_npu_main 0   # resnet50
   ./sample_svp_npu_main 1   # resnet50 多线程
   ./sample_svp_npu_main 3   # lstm
   ./sample_svp_npu_main 4   # rfcn

海鸥派 ``hieuler_component_ai`` 的
``component/common/model_impl.cpp`` 也使用同一套接口加载并执行
``.om``，可作为实际工程参考。

六、DSP（Vision Q6）开发流程
============================

DSP 是双核 Cadence Tensilica Vision Q6，适合深度转激光、滤波、几何
变换、光流等传统 CV/信号处理算法，不用于神经网络推理。

6.1 固件
--------

每个 DSP 核需要加载 4 个固件文件：

.. code-block:: text

   /root/dsp_bin/dsp0/ot_sram.bin
   /root/dsp_bin/dsp0/ot_iram0.bin
   /root/dsp_bin/dsp0/ot_dram0.bin
   /root/dsp_bin/dsp0/ot_dram1.bin

``dsp1`` 目录结构相同。DSP 固件由 Cadence Xtensa 工具链编译，公开
样例只提供 ``.bin``，不包含 DSP 源码；自定义 DSP 算子需要厂商 DSP
开发包。

6.2 ARM 侧加载与 RPC
--------------------

.. code-block:: c

   #include "ss_mpi_dsp.h"
   #include "ot_common_dsp.h"

   ss_mpi_svp_dsp_power_on(OT_SVP_DSP_ID_0);

   ss_mpi_svp_dsp_load_bin("/root/dsp_bin/dsp0/ot_iram0.bin",
                           OT_SVP_DSP_MEM_TYPE_IRAM_DSP_0);
   ss_mpi_svp_dsp_load_bin("/root/dsp_bin/dsp0/ot_sram.bin",
                           OT_SVP_DSP_MEM_TYPE_SYS_DDR_DSP_0);
   ss_mpi_svp_dsp_load_bin("/root/dsp_bin/dsp0/ot_dram0.bin",
                           OT_SVP_DSP_MEM_TYPE_DRAM_0_DSP_0);
   ss_mpi_svp_dsp_load_bin("/root/dsp_bin/dsp0/ot_dram1.bin",
                           OT_SVP_DSP_MEM_TYPE_DRAM_1_DSP_0);

   ss_mpi_svp_dsp_enable_core(OT_SVP_DSP_ID_0);

   ot_svp_dsp_msg msg = {0};
   msg.cmd      = OT_SVP_DSP_CMD_DEPTH_TO_LASER;
   msg.body     = msg_phy_addr;
   msg.body_len = msg_size;

   ot_svp_dsp_handle handle;
   ss_mpi_svp_dsp_rpc(&handle, &msg, OT_SVP_DSP_ID_0,
                      OT_SVP_DSP_PRI_0);

   td_bool finish = TD_FALSE;
   while (ss_mpi_svp_dsp_query(OT_SVP_DSP_ID_0, handle,
                               &finish, TD_TRUE)
          == OT_ERR_SVP_DSP_QUERY_TIMEOUT) {
       usleep(100);
   }

消息体通过 MMZ 物理地址传递。ARM 写入后、DSP 读取前需要
``ss_mpi_sys_flush_cache``\ ；DSP 写完后、ARM 读取前同样需要刷新
cache。

6.3 样例
--------

``hieuler_dsp_sample`` 提供深度图转激光扫描样例：

.. code-block:: text

   hieuler_dsp_sample/depth_to_laser_without_ground/
   ├── dsp_bin/dsp0/{ot_sram,ot_iram0,ot_dram0,ot_dram1}.bin
   ├── dsp_bin/dsp1/...
   └── arm_code/ros2_astra_camera/.../point_cloud_xyz.cpp

该样例加载 DSP0 固件后，通过
``OT_SVP_DSP_CMD_DEPTH_TO_LASER`` 命令完成深度图到激光数据的转换。

七、SVP 视频加速引擎
====================

SVP 引擎中的 IVE、KCF、DPU、MAU 等模块通过 MPP MPI 使用，不需要
单独的模型或固件：

- IVE：图像预处理、滤波、CSC、跟踪等。
- KCF：目标跟踪。
- DPU：双目深度/匹配。
- MAU：矩阵计算加速。

对应内核模块为 ``ot_ive.ko``\ 、\ ``ot_dpu_rect.ko``\ 、
``ot_dpu_match.ko``\ 、\ ``ot_mau.ko``\ 等，由 ``load_ss928v100`` 加载。

八、选型建议
============

.. list-table::
   :header-rows: 1
   :widths: 34 66

   * - 需求
     - 建议
   * - PyTorch/ONNX 通用模型，需要 FP16/INT4
     - NNN + AscendCL
   * - 视觉检测/分类，只要 INT8/INT16，希望低开销
     - SVP_NPU + svp_acl
   * - 深度转激光、滤波、几何/传统 CV
     - DSP
   * - 图像缩放/色彩转换/跟踪/双目深度
     - SVP 引擎（IVE/KCF/DPU）
   * - 实时控制、低功耗协处理
     - RISC-V MCU + LiteOS

九、已上板验证与已知问题
========================

在运行 5.10 内核的海鸥派上已完成以下验证：

.. list-table::
   :header-rows: 1
   :widths: 28 18 54

   * - 项目
     - 结果
     - 说明
   * - NNN 驱动/设备
     - 通过
     - ``ot_npu_*`` 四个模块加载正常
   * - NNN AscendCL 初始化
     - 通过
     - 需预加载旧版 protobuf，见下文
   * - SVP_NPU 驱动/设备
     - 通过
     - ``/dev/svp_npu`` 正常
   * - SVP_NPU 模型推理
     - 通过
     - ``barcode_yolov8.om``\ ，3 输入/3 输出，``execute=0``
   * - DSP 电源控制
     - 通过
     - ``power_on``/``power_off`` 均返回 0
   * - DSP 算法级 RPC
     - 未验证
     - 板上未部署 ``dsp_bin``
   * - NNN 模型推理
     - 未验证
     - 本地没有 NNN 格式 ``.om``

SVP_NPU 实测模型信息：

.. code-block:: text

   inputs=3 outputs=3
   in[0] 1,3,384,640  UINT8 NCHW  size=368640
   in[1] 1,1,1,52     FLOAT       size=208
   in[2] 1,1,1,835584 FLOAT       size=3342336
   out[0] 1,240,5     FLOAT
   out[1] 1,960,5     FLOAT
   out[2] 1,3840,5    FLOAT
   execute=0

已知问题：

1. **NNN protobuf ABI 不一致**：当前镜像的 ``libgraph.so`` 需要旧 ABI
   符号，但 ``libascend_protobuf.so.3.13.0.0`` 只导出 C++11 ABI 符号，
   直接运行 NNN 程序会报 ``undefined symbol``\ 。规避方式：

   .. code-block:: console

      export LD_PRELOAD=/usr/lib64/npu/libascend_protobuf.so
      export LD_LIBRARY_PATH=/usr/lib64/npu:$LD_LIBRARY_PATH

   长期修复需要调整 ``hieulerpi1-user-driver`` 中 protobuf 库的打包/
   链接关系。

2. **``/tmp`` 为 noexec**：测试程序放到 ``/tmp`` 会报
   ``Permission denied``\ ，应放在 ``/root`` 等可执行分区。

3. **NNN 初始化时的 CMA 告警**：dmesg 可能出现
   ``cma: cma_alloc: alloc failed``\ ，当前不影响初始化；跑大模型时
   如果出现内存错误，需要检查 CMA/MMZ 预留。

4. **当前镜像不含样例和头文件**：默认只安装运行库，SVP_NPU/NNN 样例、
   ``.om`` 模型和 ``/usr/include/npu``\ 、\ ``/usr/include/svp_npu``
   需要从 SDK 或 ``-dev`` 包获取。

5. **kernel6 加载差异**：kernel6 的 ``load_sdk_driver`` 目前只加载
   ``ot_svp_npu.ko``\ ；NNN 和 DSP 需要额外确认模块并补充加载。

十、快速自检
============

.. code-block:: console

   # 驱动与设备
   lsmod | grep -E 'npu|svp|dsp'
   ls -l /dev/svp_npu /dev/dsp

   # SVP_NPU 运行库
   ls /usr/lib64/svp_npu

   # NNN 运行库
   ls /usr/lib64/npu

   # DSP 运行库
   ls -l /usr/lib64/libss_dsp.so

   # 重新加载 BSP 模块（会中断摄像头/显示，空闲时执行）
   cd /ko && ./load_ss928v100 -a
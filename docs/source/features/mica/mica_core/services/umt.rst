用户消息传递服务
################

简介
----

在多 OS 混合部署场景下，Linux 与实时操作系统（RTOS）通过 RPMsg 协议进行跨核通信。默认配置下，RPMsg 使用 512 字节固定大小的消息缓冲区进行数据传输。当传输较大数据时，会触发以下问题：

- 需要将数据分片为多个512字节的消息包
- 每个消息包的传输都会产生IPI（处理器间中断）
- 频繁的IPI导致系统吞吐量下降和通信延迟增加

因此，当前 MICA 提供了 rpmsg-umt (user message transfer)服务，实现了高效通信服务：

1. 预先分配物理连续的共享内存区域
2. 用户数据写入到共享内存区域
3. 通过 RPMsg 单次传输共享内存的元数据（起始地址+大小）

对比如下：

传统方式：
[Data] -> RPMsg Buffer -> IPI -> RPMsg Buffer -> [Data]

rpmsg-umt：
[Data] -> Shared Memory -> (IPI + Metadata) -> Shared Memory -> [Data]

UMT 服务支持 baremetal 和 hetero 两种部署底座，通过 ``ped_type`` 参数进行区分。

使用方法
--------

UMT 提供了两类接口：上下文接口和一次性接口。

上下文接口
~~~~~~~~~~

上下文接口适用于需要多次通信的场景，创建一次上下文后可以重复使用，减少资源分配开销。

创建上下文
^^^^^^^^^^

.. code-block:: c

   /**
    * @brief Create UMT communication context
    *
    * Allocates and initializes resources.
    *
    * @param target_instance Target instance ID (only 0 supported)
    * @param ped_type Pedestal type: MCS_KM_PED_BAREMETAL or MCS_KM_PED_RISCV
    * @return Context handle on success, NULL on failure
    * @note Call umt_context_destroy when done
    */
   extern umt_context_t* umt_context_create(int target_instance, enum mcs_km_pedestal_type ped_type);

销毁上下文
^^^^^^^^^^

.. code-block:: c

   /**
    * @brief Destroy UMT communication context
    *
    * @param ctx Context handle
    * @note Safe if ctx is NULL; releases any held lock before destroy
    */
   extern void umt_context_destroy(umt_context_t *ctx);

发送数据
^^^^^^^^

.. code-block:: c

   /**
    * @brief Send data using context (no reply wait)
    *
    * @param ctx Context handle
    * @param offset Offset in umt shared memory (bytes), 0 ~ (OPENAMP_SHM_COPY_SIZE - data_len)
    * @param data Data to send
    * @param data_len Data length
    * @return 0 on success, negative errno on failure (e.g. -EINVAL for invalid ctx, offset or data_len)
    * @note Lock is acquired/released internally
    */
   extern int send_data_with_umt_context(umt_context_t *ctx, int offset, void *data, int data_len);

接收数据（阻塞）
%%%%%%%%%%%%%%%%

.. code-block:: c

   /**
    * @brief Receive data using context (block until data arrives or timeout)
    *
    * @param ctx Context handle
    * @param rcv_data Receive buffer
    * @param rcv_data_len Output: received length
    * @param timeout_ms Timeout in ms; 0 = wait forever
    * @return 0 on success, negative errno on failure (e.g. -EINVAL invalid ctx, -ETIMEDOUT on timeout,
    *         -ENODATA, -ENODEV, -EFAULT from read path)
    * @note Lock released during wait, re-acquired after
    * @note Do not use the same context for both blocking receive and callback; use one mode per context.
    */
   extern int receive_data_with_umt_context(umt_context_t *ctx, void *rcv_data, int *rcv_data_len, int timeout_ms);

注册接收回调
^^^^^^^^^^^^

.. code-block:: c

   /**
    * @brief Register receive callback (library runs an internal thread that waits for data and calls callback)
    *
    * One callback per context. Callback and blocking receive_data_with_umt_context must not be used on the same context.
    *
    * @param ctx Context handle
    * @param callback  Called with (data, data_len, priv); data is valid only during the call
    * @param priv  Opaque pointer passed to callback (e.g. application context)
    * @return 0 on success, negative errno on failure (e.g. -EINVAL if ctx/callback NULL or already registered,
    *         -ENOMEM, -EAGAIN if thread create fails)
    */
   extern int umt_register_rcv_cb(umt_context_t *ctx, umt_rcv_cb_t callback, void *priv);

   /**
    * @brief Unregister receive callback and stop the internal receive thread
    *
    * @param ctx Context handle
    * @return 0 on success, negative errno on failure (e.g. -EINVAL if ctx is NULL, or no callback registered)
    */
   extern int umt_unregister_rcv_cb(umt_context_t *ctx);

一次性接口
~~~~~~~~~~

一次性接口适用于简单的单次通信场景，内部会自动创建和销毁上下文。

发送数据
^^^^^^^^

.. code-block:: c

   /**
    * @brief One-shot send to RTOS (creates/destroys context internally; offset 0)
    *
    * @param data Data to send
    * @param data_len Data length
    * @param target_instance Target instance ID (must be 0)
    * @param ped_type MCS_KM_PED_BAREMETAL or MCS_KM_PED_RISCV
    * @return 0 on success, negative errno on failure (e.g. -EINVAL if ctx or offset invalid)
    */
   extern int send_data_to_rtos(void *data, int data_len, int target_instance, enum mcs_km_pedestal_type ped_type);

接收数据
^^^^^^^^

.. code-block:: c

   /**
    * @brief One-shot receive from RTOS (creates/destroys context internally)
    *
    * @param rcv_data Receive buffer
    * @param rcv_data_len Output: received length
    * @param target_instance Target instance ID (must be 0)
    * @param timeout_ms Timeout in ms; 0 = wait forever
    * @param ped_type MCS_KM_PED_BAREMETAL or MCS_KM_PED_RISCV
    * @return 0 on success, negative errno on failure (e.g. -ENOMEM, -ETIMEDOUT, -EINVAL, -ENODATA, -EFAULT)
    */
   int receive_data_from_rtos(void *rcv_data, int *rcv_data_len, int target_instance, int timeout_ms, enum mcs_km_pedestal_type ped_type);

发送并等待回复（旧接口）
%%%%%%%%%%%%%%%%%%%%%%%%%%

.. code-block:: c

   /**
    * @brief One-shot send and wait for reply (legacy API; uses BAREMETAL)
    *
    * Use send_data_to_rtos_and_wait_rcv_ped to specify pedestal.
    *
    * @param data Data to send
    * @param data_len Data length
    * @param target_instance Target instance ID (must be 0)
    * @param rcv_data Receive buffer
    * @param rcv_data_len Output: received length
    * @return 0 on success, negative errno on failure (e.g. -ENOMEM, -EINVAL, -ETIMEDOUT)
    */
   extern int send_data_to_rtos_and_wait_rcv(void *data, int data_len, int target_instance, void *rcv_data, int *rcv_data_len);

   /**
    * @brief One-shot send and wait for reply with specified pedestal type
    *
    * @param data Data to send
    * @param data_len Data length
    * @param target_instance Target instance ID (must be 0)
    * @param rcv_data Receive buffer
    * @param rcv_data_len Output: received length
    * @param ped_type MCS_KM_PED_BAREMETAL or MCS_KM_PED_RISCV
    * @return 0 on success, negative errno on failure (e.g. -ENOMEM, -EINVAL, -ETIMEDOUT)
    */
   extern int send_data_to_rtos_and_wait_rcv_ped(void *data, int data_len, int target_instance, void *rcv_data, int *rcv_data_len, enum mcs_km_pedestal_type ped_type);

.. note::

   - 对于 baremetal 底座，使用 ``MCS_KM_PED_BAREMETAL`` 作为 ped_type 参数
   - 对于 hetero 底座（RISC-V），使用 ``MCS_KM_PED_RISCV`` 作为 ped_type 参数

Linux 端示例可以参考 `test_umt <https://atomgit.com/openeuler/mcs/tree/master/test/test_umt#>`_ 。

RTOS 端实现可以参考 UniProton `PR454 <https://gitee.com/openeuler/UniProton/pulls/454>`_，`PR457 <https://gitee.com/openeuler/UniProton/pulls/457>`_ 。

性能指标
--------

测试环境：

- KunPeng 920
- openEuler Embedded 25.03
- UniProton

测试结果：

======== ================
 数据量    rpmsg-umt耗时
======== ================
  1MB         5.14ms
======== ================

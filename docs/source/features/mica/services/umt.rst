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

使用方法
--------

rpmsg-umt 提供了以下接口进行数据发送：

   .. code-block:: c

      /**
      * @brief 发送数据到指定实例的RTOS并等待接收返回结果。
      *
      * 该函数用于将数据发送到指定实例的RTOS（实时操作系统），并等待接收返回结果。
      *
      * @param data 指向要发送的数据内容的指针。调用者应确保该缓冲区包含正确的数据内容。
      * @param data_len 要发送的数据长度。调用者应提供实际要发送的数据长度。
      * @param target_instance 要发送的目标实例ID, uniproton 启动配置文件中"InstanceID"值。
      *               注：     当前不支持多实例，target_instance赋值为0；支持多实例以后修改成具体实例号
      * @param rcv_data 指向接收数据缓冲区的指针。调用者应确保缓冲区已分配足够的内存来存储接收到的数据。
      * @param rcv_data_len 指向接收数据长度的指针。调用者应提供一个整型变量的地址，用于存储接收到的数据长度。
      *
      * @return int 返回值表示函数执行结果。
      *             - 0 表示成功发送数据并接收返回结果。
      *             - -1 表示发送失败。
      */
      int send_data_to_rtos_and_wait_rcv(void *data, int data_len, int target_instance, void *rcv_data, int *rcv_data_len);

Linux 端示例可以参考 `send-data.c <https://gitee.com/openeuler/mcs/blob/master/test/send-data/send-data.c#>`_ 。

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

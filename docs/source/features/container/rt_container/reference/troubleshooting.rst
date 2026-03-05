.. _micrun_troubleshooting:

MicRun 故障排查指南
###################

本文档提供 MicRun 常见问题的排查步骤和解决方案。

诊断工具
========

基础命令
--------

.. list-table::
   :widths: 50 50
   :header-rows: 1

   * - 命令
     - 说明
   * - ``ctr task ls``
     - 列出所有任务
   * - ``ctr task status <id>``
     - 查看任务状态
   * - ``ctr container ls``
     - 列出所有容器
   * - ``ps aux | grep containerd-shim-mica-v2``
     - 查看 shim 进程
   * - ``journalctl -u containerd -f``
     - 查看 containerd 日志
   * - ``cat /var/log/mica/mica-runtime.log``
     - 查看 MicRun 日志（debug 构建）
   * - ``xl list``
     - 查看 Xen 域列表
   * - ``xl dmesg``
     - 查看 Xen 日志

查看 Sandbox 状态
-----------------

.. note::

   以下命令使用 ``jq`` 格式化 JSON 输出。如果未安装，可使用 ``sudo apt install jq`` 或 ``sudo yum install jq`` 安装，或者删除 ``| jq`` 直接查看原始 JSON。

.. code-block:: bash

   # 列出所有 Sandbox
   ls -la /run/micrun/sandbox/

   # 查看特定 Sandbox 状态
   cat /run/micrun/sandbox/<sandbox-id>/state.json | jq

查看 FIFO 状态
--------------

.. code-block:: bash

   # 查看 FIFO 路径
   ls -la /run/containerd/io.containerd.runtime.v2.task/default/<container-id>/

   # 检查 FIFO 是否存在
   stat /run/containerd/io.containerd.runtime.v2.task/default/<container-id>/stdin

常见问题
========

1. 容器启动失败
---------------

**症状**：

.. code-block:: bash

   ctr run --runtime io.containerd.mica.v2 localhost:5000/rtos:latest test
   # 错误: context deadline exceeded

**排查步骤**：

1. **检查 shim 进程是否存在**

   .. code-block:: bash

      ps aux | grep containerd-shim-mica-v2

2. **检查 containerd 日志**

   .. code-block:: bash

      journalctl -u containerd -n 100 | grep <container-id>

3. **检查 micad 是否运行**

   .. code-block:: bash

      systemctl status micad
      journalctl -u micad -n 100

4. **检查 Xen 状态**

   .. code-block:: bash

      xl list
      xl dmesg | tail -50

**常见原因**：

.. list-table::
   :widths: 40 60
   :header-rows: 1

   * - 原因
     - 解决方案
   * - micad 未运行
     - ``systemctl start micad``
   * - 固件文件不存在
     - 检查 ``firmware_path`` 注解
   * - Xen 配置错误
     - 检查 ``ped.conf`` 注解
   * - 内存不足
     - 检查 ``memory.limit``

2. Shim 进程退出
----------------

**症状**：

.. code-block:: bash

   # 容器创建后立即退出
   ctr run --runtime io.containerd.mica.v2 localhost:5000/rtos:latest test
   # 命令返回，容器无法运行

**排查步骤**：

1. **查看 shim 退出日志**

   .. code-block:: bash

      journalctl -u containerd -f | grep shim

2. **检查是否有残留资源**

   .. code-block:: bash

      xl list | grep <container-id>

3. **检查状态文件**

   .. code-block:: bash

      cat /run/micrun/sandbox/<container-id>/state.json

**解决方案**：

.. list-table::
   :widths: 40 60
   :header-rows: 1

   * - 问题
     - 解决方案
   * - 固件路径错误
     - 修正 ``firmware_path`` 注解
   * - 缺少权限
     - 确保有访问 ``/dev/ttyRPMSG*`` 的权限
   * - Sandbox 状态不一致
     - 删除 ``/run/micrun/sandbox/<id>/`` 后重试

3. IO 无响应
------------

**症状**：

.. code-block:: bash

   ctr attach <container-id>
   # 无输出，或输入无响应

**排查步骤**：

1. **检查 FIFO 状态**

   .. code-block:: bash

      ls -la /run/containerd/io.containerd.runtime.v2.task/default/<container-id>/

2. **检查 TTY 设备**

   .. code-block:: bash

      ls -la /dev/ttyRPMSG*

3. **查看 shim 日志**

   .. code-block:: bash

      cat /var/log/mica/mica-runtime.log | grep <container-id>

**常见原因**：

.. list-table::
   :widths: 40 60
   :header-rows: 1

   * - 原因
     - 解决方案
   * - FIFO 未创建
     - 检查 ``Terminal`` 配置
   * - TTY 设备未打开
     - 检查 micad 日志
   * - Copier 未启动
     - 重启 shim
   * - 客户端断开
     - 使用 ``ctr attach`` 重新连接

4. 容器状态显示 UNKNOWN
-----------------------

**症状**：

.. code-block:: bash

   ctr task status <container-id>
   # UNKNOWN

**排查步骤**：

1. **检查 shim 进程**

   .. code-block:: bash

      ps aux | grep containerd-shim-mica-v2 | grep <container-id>

2. **检查状态文件**

   .. code-block:: bash

      cat /run/micrun/sandbox/<container-id>/state.json | jq '.state'

3. **检查 containerd 连接**

   .. code-block:: bash

      journalctl -u containerd -f | grep "ttrpc"

**解决方案**：

.. list-table::
   :widths: 40 60
   :header-rows: 1

   * - 问题
     - 解决方案
   * - shim 崩溃
     - 查找 shim 日志中的错误
   * - 状态文件损坏
     - 删除并重新创建容器
   * - ttrpc 连接断开
     - 重启 containerd

5. 多余的空行输出
------------------

**症状**：

.. code-block:: bash

   ctr run -t --runtime io.containerd.mica.v2 localhost:5000/rtos:latest test
   # 输出中有多余的空行
   Hello, UniProton!


   openEuler UniProton #

**原因**：

TTY 输出处理导致 ``\r\n`` 转换为 ``\r\r\n``。

**解决方案**：

确保使用正确版本的 MicRun：

* 检查 ``pkg/micantainer/rpmsg_tty.go`` 中禁用了 ``OPOST|ONLCR``
* 检查 ``pkg/io/copier.go`` 中调用了 ``compressLineEndings()``

6. Attach 后没有输出
--------------------

**症状**：

.. code-block:: bash

   ctr attach <container-id>
   # 连接成功，但没有输出

**排查步骤**：

1. **检查容器是否正在运行**

   .. code-block:: bash

      ctr task status <container-id>

2. **检查 FIFO 是否被其他进程占用**

   .. code-block:: bash

      lsof /run/containerd/io.containerd.runtime.v2.task/default/<container-id>/stdout

3. **检查 Session.Restart() 是否被调用**

   .. code-block:: bash

      grep "Restart" /var/log/mica/mica-runtime.log | grep <container-id>

**解决方案**：

.. list-table::
   :widths: 40 60
   :header-rows: 1

   * - 问题
     - 解决方案
   * - 容器未运行
     - 先启动容器
   * - FIFO 被占用
     - 断开其他 attach 连接
   * - Session 未重启
     - 重新启动 shim

7. 状态不一致导致无法删除
-------------------------

**症状**：

.. code-block:: bash

   ctr container delete <container-id>
   # 错误: sandbox is not ready, paused, or stopped, cannot delete

**排查步骤**：

1. **检查当前状态**

   .. code-block:: bash

      cat /run/micrun/sandbox/<container-id>/state.json | jq '.state.state'

2. **检查 shim 是否仍在运行**

   .. code-block:: bash

      ps aux | grep containerd-shim-mica-v2 | grep <container-id>

**解决方案**：

.. code-block:: bash

   # 方法 1: 先停止容器
   ctr task kill <container-id>
   # 等待停止完成

   # 方法 2: 如果 shim 已崩溃，手动清理
   xl destroy <container-id>
   rm -rf /run/micrun/sandbox/<container-id>/
   rm -rf /run/micrun/containers/<container-id>/
   ctr task delete -f <container-id>
   ctr container delete <container-id>

8. 内存不足错误
----------------

**症状**：

.. code-block:: bash

   # 日志显示
   memory allocation failed

**排查步骤**：

1. **检查容器内存限制**

   .. code-block:: bash

      ctr task metrics <container-id>

2. **检查系统内存**

   .. code-block:: bash

      free -h
      xl info | grep memory

**解决方案**：

.. code-block:: yaml

   # 增加 memory limit
   apiVersion: v1
   kind: Pod
   spec:
     containers:
     - name: rtos-app
       resources:
         limits:
           memory: "128Mi"  # 增加内存限制
         requests:
           memory: "64Mi"

或通过注解：

.. code-block:: yaml

   metadata:
     annotations:
       org.openeuler.micrun.container.min_memory_mb: "64"

9. CPU 绑定失败
---------------

**症状**：

.. code-block:: bash

   # 日志显示
   failed to pin vcpu: invalid argument

**排查步骤**：

1. **检查 cpuset 配置**

   .. code-block:: bash

      cat /run/micrun/sandbox/<container-id>/state.json | jq '.config.container_configs'

2. **检查主机 CPU 数量**

   .. code-block:: bash

      lscpu
      xl info

**解决方案**：

确保 cpuset 有效：

* cpus 编号必须在有效范围内
* SharedCPUPool 模式下，CPU 数量必须等于 vCPU 数量

10. auto_close 不生效
---------------------

**症状**：

客户端断开后容器继续运行。

**排查步骤**：

1. **检查注解配置**

   .. code-block:: bash

      ctr container info <container-id> | grep annotations

2. **检查超时设置**

   .. code-block:: bash

      grep "auto_close" /var/log/mica/mica-runtime.log

**解决方案**：

.. code-block:: yaml

   metadata:
     annotations:
       # 方法 1: 禁用自动关闭
       org.openeuler.micrun.container.auto_close: "false"

       # 方法 2: 设置超时（优先级更高）
       org.openeuler.micrun.container.auto_close_timeout: "0"  # 禁用
       org.openeuler.micrun.container.auto_close_timeout: "60s"  # 60秒后关闭

调试技巧
========

启用 Debug 日志
---------------

使用 debug 构建的 MicRun：

.. code-block:: bash

   # 查看 debug 日志
   cat /var/log/mica/mica-runtime.log

   # 或实时跟踪
   tail -f /var/log/mica/mica-runtime.log

使用 Mock Micad
---------------

.. code-block:: bash

   cd micrun/tests/mock_micad
   make run

检查状态文件
------------

.. code-block:: bash

   # 查看完整状态
   cat /run/micrun/sandbox/<id>/state.json | jq '.'

   # 查看状态
   cat /run/micrun/sandbox/<id>/state.json | jq '.state'

   # 查看配置
   cat /run/micrun/sandbox/<id>/state.json | jq '.config'

清理残留资源
------------

.. code-block:: bash

   #!/bin/bash
   CONTAINER_ID=$1

   # 1. 销毁 Xen 域
   xl destroy $CONTAINER_ID 2>/dev/null

   # 2. 删除 containerd 任务
   ctr task delete -f $CONTAINER_ID 2>/dev/null

   # 3. 删除 containerd 容器
   ctr container delete $CONTAINER_ID 2>/dev/null

   # 4. 删除 Sandbox 状态
   rm -rf /run/micrun/sandbox/$CONTAINER_ID

   # 5. 删除容器状态
   rm -rf /run/micrun/containers/$CONTAINER_ID

   echo "Cleanup complete for $CONTAINER_ID"

日志标识
========

.. list-table::
   :widths: 25 35 40
   :header-rows: 1

   * - 标识
     - 来源
     - 说明
   * - ``[SESSION]``
     - ``session.go``
     - 会话管理日志
   * - ``[IO]``
     - ``copier.go``
     - 数据复制日志
   * - ``[EVENT]``
     - ``events.go``
     - 事件总线日志
   * - ``[TTY]``
     - ``rpmsg_tty.go``
     - TTY 配置日志
   * - ``[SANDBOX]``
     - ``sandbox.go``
     - Sandbox 操作日志
   * - ``[CONTAINER]``
     - ``container.go``
     - 容器操作日志
   * - ``[RESTORE]``
     - ``sandbox.go``
     - 状态恢复日志
   * - ``[StoreSandbox]``
     - ``sandbox.go``
     - 状态保存日志

错误码对照表
============

.. list-table::
   :widths: 25 40 35
   :header-rows: 1

   * - 错误
     - 说明
     - 解决方案
   * - ``ERRO[0001]``
     - 容器 ID 为空
     - 检查容器 ID 参数
   * - ``ERRO[0002]``
     - Sandbox 未找到
     - 检查 Sandbox 是否存在
   * - ``ERRO[0003]``
     - 容器未找到
     - 检查容器是否在 Sandbox 中
   * - ``ERRO[0004]``
     - 无效状态
     - 检查当前状态是否允许该操作
   * - ``ERRO[0005]``
     - 固件文件未找到
     - 检查 ``firmware_path`` 注解
   * - ``ERRO[0006]``
     - Pedestal 配置错误
     - 检查 ``ped.conf`` 注解
   * - ``ERRO[0007]``
     - 状态转换无效
     - 检查状态转换规则
   * - ``ERRO[0008]``
     - IO 错误
     - 检查 FIFO 和 TTY 状态

相关文档
========

* :doc:`annotations` - 注解参考手册
* :doc:`../quick-start` - 快速入门指南
* :doc:`../kubernetes/index` - Kubernetes 集成指南

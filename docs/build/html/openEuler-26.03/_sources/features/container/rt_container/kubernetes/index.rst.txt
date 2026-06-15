.. _micrun_kubernetes:

MicRun Kubernetes 云边协同指南
##############################

本文档介绍如何在 K3s 环境中配置 MicRun，实现 RTOS 容器的云边协同部署。

.. note::

   **约定**：云侧运行 K3s Server，边侧运行 K3s Agent 和 RTOS 容器。

架构概览
========

::

    ┌───────────────────────────────┐
    │      Cloud - K3s Server       │
    │  Kubernetes API / Scheduler   │
    └───────────────┬───────────────┘
                    │
                    ▼
    ┌───────────────────────────────┐
    │      Edge - K3s Agent         │
    │  kubelet / containerd / MicRun│
    │                │              │
    │                ▼              │
    │       RTOS Container          │
    └───────────────────────────────┘

前置准备
========

.. list-table::
   :widths: 25 35 40
   :header-rows: 1

   * - 组件
     - 云侧
     - 边侧
   * - 操作系统
     - Linux
     - openEuler Embedded（含 micrun, micad, xen）
   * - K3s
     - v1.28+ server
     - v1.28+ agent
   * - containerd
     - K3s 自带
     - 1.7.27+
   * - MicRun
     - 不需要
     - 已安装并注册

边侧需完成 :doc:`../quick-start` 前 5 步。

云侧部署
========

安装 K3s Server
---------------

.. code-block:: bash

   # 安装（替换 <cloud-ip> 为云侧 IP）
   curl -sfL https://get.k3s.io | \
     INSTALL_K3S_EXEC="--write-kubeconfig-mode=644 --tls-san <cloud-ip>" \
     sh -

   # 获取 token（边侧加入需要）
   sudo cat /var/lib/rancher/k3s/server/node-token

   # 验证
   kubectl get nodes

边侧部署
========

配置 K3s 使用系统 containerd
-----------------------------

.. code-block:: bash

   sudo mkdir -p /etc/systemd/system/k3s-agent.service.env
   sudo tee /etc/systemd/system/k3s-agent.service.env/10-containerd.conf <<EOF
   K3S_SUPERVISOR_CONTAINERD=false
   CONTAINERD_SOCK=/run/containerd/containerd.sock
   EOF

安装 K3s Agent
--------------

.. code-block:: bash

   # 替换 <cloud-ip> 和 <node-token>
   export K3S_URL="https://<cloud-ip>:6443"
   export K3S_TOKEN="<node-token>"

   curl -sfL https://get.k3s.io | K3S_URL=${K3S_URL} K3S_TOKEN=${K3S_TOKEN} sh -

   # 验证
   sudo systemctl status k3s-agent

注册 RuntimeClass
-----------------

在云侧执行：

.. code-block:: bash

   kubectl apply -f - <<EOF
   apiVersion: node.k8s.io/v1
   kind: RuntimeClass
   metadata:
     name: micrun
   handler: micrun
   EOF

运行 RTOS Pod
=============

创建 Pod
--------

.. code-block:: bash

   kubectl apply -f - <<EOF
   apiVersion: v1
   kind: Pod
   metadata:
     name: rtos-demo
   spec:
     runtimeClassName: micrun
     containers:
     - name: rtos-app
       image: localhost:5000/mica-uniproton-app:xen-0.1
       tty: true
       stdin: true
   EOF

**配置说明**：

.. list-table::
   :widths: 30 70
   :header-rows: 1

   * - 字段
     - 说明
   * - ``runtimeClassName``
     - 指定使用 MicRun 运行时
   * - ``image``
     - RTOS 镜像名称（必须是边缘已导入的镜像）
   * - ``tty: true``
     - 分配伪终端（RTOS 容器通常需要）
   * - ``stdin: true``
     - 保持标准输入打开（支持交互式操作）

使用注解配置
------------

MicRun 通过 Pod 的 ``metadata.annotations`` 字段接收配置：

.. code-block:: yaml

   apiVersion: v1
   kind: Pod
   metadata:
     name: rtos-demo
     annotations:
       # 容器配置
       org.openeuler.micrun.container.os: "zephyr"
       org.openeuler.micrun.container.firmware_path: "images/zephyr.elf"
       org.openeuler.micrun.container.min_memory_mb: "32"
       org.openeuler.micrun.container.auto_close_timeout: "60s"

       # Hypervisor 配置
       org.openeuler.micrun.ped.pedestal: "xen"
   spec:
     runtimeClassName: micrun
     containers:
     - name: rtos-app
       image: localhost:5000/zephyr-app:latest
       resources:
         limits:
           memory: "64Mi"
           cpu: "2"
         requests:
           memory: "32Mi"

常用注解：

.. list-table::
   :widths: 50 30 20
   :header-rows: 1

   * - 注解
     - 说明
     - 示例
   * - ``org.openeuler.micrun.container.os``
     - RTOS 类型
     - ``zephyr``
   * - ``org.openeuler.micrun.container.firmware_path``
     - 固件文件路径
     - ``images/zephyr.elf``
   * - ``org.openeuler.micrun.container.auto_close``
     - IO 关闭时自动停止
     - ``true``/``false``
   * - ``org.openeuler.micrun.container.auto_close_timeout``
     - 自动关闭超时
     - ``30s``
   * - ``org.openeuler.micrun.ped.pedestal``
     - Hypervisor 类型
     - ``xen``

.. note::

   详细的注解参考请参见 :doc:`../reference/annotations`。

验证
----

.. code-block:: bash

   # 云侧查看 Pod
   kubectl get pods -o wide

   # 边侧验证
   ctr task ls | grep rtos
   sudo xl list

故障排查
========

快速诊断
--------

.. list-table::
   :widths: 35 30 35
   :header-rows: 1

   * - 问题
     - 可能原因
     - 解决方法
   * - Pod ContainerCreating 超时
     - 镜像不存在
     - 边侧执行 ``ctr image import`` 导入镜像
   * - 边侧节点 NotReady
     - K3s Agent 未运行或网络问题
     - 检查 ``systemctl status k3s-agent``
   * - runtime 'micrun' not found
     - containerd 未加载 MicRun
     - 检查 ``/etc/containerd/config.toml`` 配置

通用排查命令
------------

.. code-block:: bash

   # 查看 Pod 状态
   kubectl get pods -o wide

   # 查看 Pod 详细信息
   kubectl describe pod <pod_name>

   # 查看 Pod 日志
   kubectl logs <pod_name>

   # 在边缘查看 MicRun 日志
   tail -f /var/log/mica/mica-runtime.log

参考资源
========

.. seealso::

   - `K3s 官方文档 <https://docs.k3s.io/>`_
   - :doc:`../quick-start` - MicRun 快速入门
   - `Mica-Xen 指导 <https://embedded.pages.openeuler.org/master/features/mica/instruction.html>`_
   - `问题反馈 <https://atomgit.com/openeuler/mcs/issues>`_

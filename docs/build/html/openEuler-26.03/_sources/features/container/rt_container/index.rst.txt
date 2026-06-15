.. _rt_container:

实时容器
########

MicRun 是一个基于 containerd shimv2 的容器运行时，用于在异构计算平台上以容器方式管理 RTOS（实时操作系统）。

**核心能力**：

* 用 Kubernetes 管理 RTOS 工作负载
* 用容器镜像分发 RTOS 固件
* 同一设备上同时运行 Linux 和 RTOS
* 复用云原生工具链（ctr、nerdctl 等）

**支持的 RTOS**：Zephyr、UniProton

**支持的 Hypervisor**：Xen（完整功能）、Baremetal（基础功能）

.. toctree::
   :maxdepth: 1

   intro.rst
   quick-start.rst
   kubernetes/index.rst
   reference/index.rst

.. _micrun_kubernetes:

MicRun Kubernetes 云边协同指南
##############################

本文档介绍如何在 K3s 环境中配置 MicRun，实现 RTOS 容器的云边协同部署。

.. note::

   **约定**：优先推荐"云侧 K3s Server + 边侧 K3s Agent"模式；资源受限或离线调试场景也可使用单节点 K3s Server 进行验证。

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
     - 与边侧版本匹配的 server
     - rootfs 内置 agent
   * - containerd
     - K3s 自带或容器内置
     - rootfs 内置系统 containerd
   * - MicRun
     - 不需要
     - 已安装并注册

边侧需完成 :doc:`../quick-start` 前 5 步。

部署前检查
==========

在 openEuler Embedded 边侧机上，下面几个前置条件会直接影响 K3s 能否跑起来：

1. **系统时间必须正确**

   如果系统时间仍停留在 ``1970-01-01``，K3s 会直接报 ``server time isn't set properly`` 并退出。

   .. code-block:: bash

      date -u
      date -u -s "2026-03-12 12:00:00"

2. **内存必须留有余量**

   本机实测在 ``1.5GiB`` 左右可用内存下，未清理旧 Xen 域时，K3s 初始化可能被 OOM kill。
   建议先清理残留 RTOS 域：

   .. code-block:: bash

      xl list
      xl destroy <old-domain>
      free -m

   如果内存仍不足，建议先配置 swap。对于 initrd/内存盘环境，不要在恢复网络的同一步骤里无条件创建 swapfile，建议在确认根文件系统可承载后再单独执行：

   .. code-block:: bash

      dd if=/dev/zero of=/swapfile bs=1M count=1024 status=progress
      chmod 600 /swapfile
      mkswap /swapfile
      swapon /swapfile
      grep -q '^/swapfile ' /etc/fstab || echo '/swapfile none swap sw 0 0' >> /etc/fstab
      swapon --show

3. **oEE/QEMU 的 cgroup 能力需要按运行态配置处理**

   在当前 QEMU/oEE guest 中，kubelet 的 Pod QoS cgroup 可能无法完整创建。
   如果保持默认 ``cgroupsPerQOS=true``，Pod 进入 Running 后下一次同步会因为
   Pod cgroup 不存在而触发 ``killPod``，表现为 kubelet 立即记录
   ``Stopping container <name>``。测试环境推荐给 kubelet 增加：

   .. code-block:: bash

      --kubelet-arg=cgroups-per-qos=false \
        --kubelet-arg=enforce-node-allocatable= \
        --kubelet-arg=fail-cgroupv1=false

   这是 K3s/kubelet 运行态参数，不需要修改或重新打包 QEMU rootfs。

   较新的 kubelet 在 cgroup v1 环境中可能需要 ``fail-cgroupv1=false``。
   旧版本 kubelet 可能不支持该参数；遇到 ``unknown flag:
   --fail-cgroupv1`` 时，通过 ``K3S_KUBELET_ARGS`` 移除它。已验证的 oEE
   K3s v1.27（边侧 v1.27.15、云侧 ``rancher/k3s:v1.27.15-k3s1``）云边
   测试只保留 ``cgroups-per-qos=false`` 和空
   ``enforce-node-allocatable``；kubelet 版本不得新于 apiserver
   （K8s skew 约束），其他版本组合未验证。

4. **当前平台不支持 Flannel VXLAN**

   如果日志里出现 ``failed to create vxlan device: operation not supported``，需要改用：

   .. code-block:: bash

      --flannel-backend=none

   这会让节点在没有额外 CNI 时保持 ``NotReady``，但可用 ``hostNetwork: true`` + ``not-ready`` toleration 做 MicRun/runtime 验证。

5. **边侧必须能拿到 Pod sandbox 镜像**

   K3s/CRI 在创建 Pod sandbox 时会先使用 ``rancher/mirrored-pause:3.6``。如果边侧无法访问默认镜像仓库，需要提前把 pause 镜像导入到运行中的 containerd。

6. **用于自动化部署/测试的账号不要处于密码过期状态**

   如果远程 SSH 会话一登录就要求改密，自动化脚本会直接失败。可按需关闭账号过期限制：

   .. code-block:: bash

      chage -I -1 -m 0 -M 99999 -E -1 root
      passwd -x -1 root

7. **RTOS 镜像在 K3s 中需要显式提供 ``command``**

   当前 ``localhost:5000/mica-uniproton-app:xen-0.1`` 这类 RTOS 镜像没有标准 Linux 容器入口点。
   Kubelet/CRI 在生成 OCI spec 时若没有 ``command``，会报：

   .. code-block:: text

      failed to generate spec: no command specified

   运行时实际不会执行这个占位命令，但 Pod YAML 必须写一个占位值，例如：

   .. code-block:: yaml

      command: ["/micrun-placeholder"]

8. **边侧 IP 必须固定，避免 DHCP/链路本地地址漂移**

   在 QEMU/openEuler Embedded 场景中，如果 ``systemd-networkd`` 和 ``dhcpcd`` 同时管理 ``enp0s1``，容易出现：

   - 同时持有实验网段静态地址和 ``169.254.x.y/16``
   - 默认路由被切到链路本地地址
   - SSH 间歇性可达，甚至完全失联

   以下命令使用仓库默认 QEMU/K3s 示例网段。若你的环境不同，先改
   ``EDGE_IFACE``、``EDGE_IP`` 和 ``HOST_TAP_IP``：

   .. code-block:: bash

      EDGE_IFACE="${EDGE_IFACE:-enp0s1}"
      EDGE_IP="${EDGE_IP:-192.168.7.2}"
      HOST_TAP_IP="${HOST_TAP_IP:-192.168.7.1}"

      cat >/etc/systemd/network/10-eth-static.network <<'EOF'
      [Match]
      Name=__EDGE_IFACE__

      [Network]
      Address=__EDGE_IP__/24
      Gateway=__HOST_TAP_IP__
      DNS=__HOST_TAP_IP__
      DHCP=no
      LinkLocalAddressing=no
      LLMNR=no
      MulticastDNS=no
      IPv6AcceptRA=no
      EOF
      sed -i \
        -e "s/__EDGE_IFACE__/${EDGE_IFACE}/g" \
        -e "s/__EDGE_IP__/${EDGE_IP}/g" \
        -e "s/__HOST_TAP_IP__/${HOST_TAP_IP}/g" \
        /etc/systemd/network/10-eth-static.network

      systemctl disable --now dhcpcd
      systemctl enable --now systemd-networkd
      systemctl restart systemd-networkd

      ip -br addr show dev "$EDGE_IFACE"
      ip route

   如果你是通过串口终端恢复环境，也可以直接执行仓库里的脚本：

   .. code-block:: bash

      sh <path-to-mcs-repo>/micrun/tests/k3s/prepare_edge_node.sh

   可选环境变量：

   .. code-block:: bash

      IFACE="${EDGE_IFACE:-enp0s1}" \
      IP_ADDR="${EDGE_IP:-192.168.7.2}/24" \
      GATEWAY="${HOST_TAP_IP:-192.168.7.1}" \
      DNS_SERVER="${HOST_TAP_IP:-192.168.7.1}" \
      ENABLE_SWAP=false \
      DISABLE_ROOT_EXPIRY=true \
      sh <path-to-mcs-repo>/micrun/tests/k3s/prepare_edge_node.sh

   ``ENABLE_SWAP=true`` 只适合确认 guest 有足够可写空间的调试场景。ramfs
   rootfs 上创建大 swap 文件可能触发内存压力，标准 QEMU/K3s 测试不要依赖
   这一步。

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

当前推荐模式：构建内置 K3s Agent + 系统 containerd
---------------------------------------------------

标准 QEMU 云边测试必须使用 rootfs 构建产物中已经存在的 K3s。oEE 镜像中
K3s 默认路径是 ``/usr/bin/k3s``；如果该文件不存在，应回到构建配置补齐
``packagegroup-k3s-agent`` 后重新构建，不要在 QEMU guest 里安装或复制 K3s。

当前已验证的云边路径使用系统 ``containerd``，K3s agent 通过
``--container-runtime-endpoint=unix:///run/containerd/containerd.sock`` 接入。
这样可以复用 rootfs 中的 ``containerd``、``ctr`` 和 ``containerd-shim-mica-v2``。

配置系统 containerd 和 CNI
---------------------------

.. code-block:: bash

   sudo mkdir -p /etc/containerd /etc/cni/net.d /opt/cni
   sudo tee /etc/containerd/config.toml <<'EOF'
   version = 2

   [plugins."io.containerd.grpc.v1.cri"]
     sandbox_image = "docker.io/rancher/mirrored-pause:3.6"

   [plugins."io.containerd.grpc.v1.cri".cni]
     bin_dir = "/opt/cni/bin"
     conf_dir = "/etc/cni/net.d"

   [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
     runtime_type = "io.containerd.runc.v2"

   [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.micrun]
     runtime_type = "io.containerd.mica.v2"
     pod_annotations = ["org.openeuler.micrun.*"]
     container_annotations = ["org.openeuler.micrun.*"]

   [plugins."io.containerd.cri.v1.runtime".containerd.runtimes.micrun]
     runtime_type = "io.containerd.mica.v2"
     pod_annotations = ["org.openeuler.micrun.*"]
     container_annotations = ["org.openeuler.micrun.*"]
   EOF

   sudo tee /etc/cni/net.d/10-micrun.conflist <<'EOF'
   {
     "cniVersion": "1.0.0",
     "name": "micrun-bridge",
     "plugins": [
       {
         "type": "bridge",
         "bridge": "cni0",
         "isGateway": true,
         "ipMasq": true,
         "promiscMode": true,
         "ipam": {
           "type": "host-local",
           "ranges": [[{ "subnet": "10.42.1.0/24" }]],
           "routes": [{ "dst": "0.0.0.0/0" }]
         }
       },
       {
         "type": "portmap",
         "capabilities": { "portMappings": true }
       }
     ]
   }
   EOF

   sudo ln -sfn /var/lib/rancher/k3s/data/current/bin /opt/cni/bin
   sudo systemctl restart containerd

.. note::

   - 系统 containerd 的 CRI 插件会按 ``sandbox_image`` 拉取 pause 镜像。离线测试必须让该值与已导入镜像一致。
   - CNI 二进制需要通过 ``/opt/cni/bin`` 可见；当前做法是链接到 K3s 数据目录中的 CNI 工具。

重启后检查生成结果：

.. code-block:: bash

   grep -A 8 runtimes.micrun /etc/containerd/config.toml
   ctr -a /run/containerd/containerd.sock plugins ls | grep cri

每次重跑前清理旧的 K3s state
-----------------------------

如果边侧之前跑过单节点 K3s、旧的 RTOS Pod 或残留 ``containerd-shim-mica-v2``，Agent 可能会一直卡在：

.. code-block:: text

   Waiting for containerd startup: rpc error: code = Unavailable desc = server is not initialized yet: unavailable

推荐在每次重新拉起边侧 Agent 前执行：

.. code-block:: bash

   sudo systemctl stop micrun-k3s-agent.service || true
   sudo pkill -9 -f '/usr/bin/k3s agent' || true
   sudo pkill -9 -f 'containerd-shim-mica-v2 -namespace k8s.io -address /run/k3s/containerd/containerd.sock' || true
   sudo pkill -9 -f 'containerd-shim-mica-v2 -namespace k8s.io -address /run/containerd/containerd.sock' || true
   sudo find /run/k3s -mindepth 1 \( -name rootfs -o -name shm \) -exec umount -l {} \; 2>/dev/null || true
   sudo rm -rf /var/lib/rancher/k3s/agent/containerd /run/k3s

.. warning::

   如果清理了系统 containerd state 或重启了 rootfs，后续必须重新导入 ``pause`` 和 RTOS 镜像。

启动 K3s Agent
--------------

当前已验证方式是显式写一个独立的 systemd 服务：

.. code-block:: bash

   # 替换 <cloud-ip> <node-token> <edge-ip>
   sudo tee /etc/systemd/system/micrun-k3s-agent.service <<EOF
   [Unit]
   Description=MicRun K3s Edge Agent
   After=network-online.target containerd.service
   Wants=network-online.target

   [Service]
   Type=simple
   Environment=K3S_URL=https://<cloud-ip>:6443
   Environment=K3S_TOKEN=<node-token>
   ExecStart=/usr/bin/k3s agent --container-runtime-endpoint=unix:///run/containerd/containerd.sock --node-ip <edge-ip> --pause-image docker.io/rancher/mirrored-pause:3.6 --kubelet-arg=cgroups-per-qos=false --kubelet-arg=enforce-node-allocatable=
   Restart=always
   RestartSec=5

   [Install]
   WantedBy=multi-user.target
   EOF

   sudo systemctl daemon-reload
   sudo systemctl enable --now micrun-k3s-agent.service
   sudo systemctl status micrun-k3s-agent.service

预置 pause 镜像与 RTOS 镜像
---------------------------

如果边侧不能直接从镜像仓库拉取镜像，需要在 Agent 运行后，把 pause 镜像和 RTOS 镜像重新导入到系统 containerd：

.. code-block:: bash

   K3S_IMAGE_TAR="${K3S_IMAGE_TAR:-/tmp/localhost_5000_mica-uniproton-app_xen-0.1.tar}"
   K3S_PAUSE_TAR="${K3S_PAUSE_TAR:-/tmp/pause-image-arm64.tar}"

   ctr -a /run/containerd/containerd.sock plugins ls | grep cri

   ctr -a /run/containerd/containerd.sock -n k8s.io images import "$K3S_PAUSE_TAR"
   ctr -a /run/containerd/containerd.sock -n k8s.io images ls | grep 'rancher/mirrored-pause:3.6'

   ctr -a /run/containerd/containerd.sock -n k8s.io images import "$K3S_IMAGE_TAR"
   ctr -a /run/containerd/containerd.sock -n k8s.io images ls | grep mica-uniproton-app

可重复的云边 e2e 脚本
---------------------

仓库已提供一条已验证的端到端脚本，会自动完成云侧 server 容器、边侧 agent、镜像导入和 RTOS Pod 验证：

.. code-block:: bash

   cd <path-to-mcs-repo>/micrun/tests/k3s
   export EDGE_SSH_USER="${EDGE_SSH_USER:-root}"
   export EDGE_IP="${EDGE_IP:-192.168.7.2}"
   export HOST_TAP_IP="${HOST_TAP_IP:-192.168.7.1}"
   export CLOUD_IP="${CLOUD_IP:-192.168.7.10}"
   export TEST_REMOTE_HOST="${EDGE_SSH_USER}@${EDGE_IP}"
   export K3S_CLOUD_NETWORK_PARENT="tap0"
   export K3S_CLOUD_NETWORK_GATEWAY="${HOST_TAP_IP}"
   export K3S_CLOUD_SERVER_IP="${CLOUD_IP}"
   export K3S_EDGE_NODE_IP="${EDGE_IP}"
   ./run_cloud_edge_e2e.sh

单节点调试模式
--------------

当没有云侧控制平面，或需要在一台边侧机上快速验证 MicRun + K3s，可直接启动单节点 K3s Server：

.. code-block:: bash

   k3s server \
     --write-kubeconfig-mode=644 \
     --disable traefik \
     --disable servicelb \
     --disable local-storage \
     --disable metrics-server \
     --disable coredns \
     --disable-network-policy \
     --flannel-backend=none \
     --kubelet-arg=cgroups-per-qos=false \
     --kubelet-arg=enforce-node-allocatable= \
     --kubelet-arg=fail-cgroupv1=false

.. note::

   - ``--flannel-backend=none`` 适合 MicRun/hostNetwork 验证，不适合通用 Pod 网络测试
   - 若节点保持 ``NotReady``，可以给验证 Pod 增加 ``hostNetwork: true`` 和 ``node.kubernetes.io/not-ready:NoSchedule`` toleration

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
     hostNetwork: true
     runtimeClassName: micrun
     nodeSelector:
       kubernetes.io/hostname: qemu-aarch64
     tolerations:
     - key: node.kubernetes.io/not-ready
       operator: Exists
       effect: NoSchedule
     containers:
     - name: rtos-app
       image: localhost:5000/mica-uniproton-app:xen-0.1
       imagePullPolicy: IfNotPresent
       command: ["/micrun-placeholder"]
       tty: false
       stdin: true
   EOF

**配置说明**：

.. list-table::
   :widths: 30 70
   :header-rows: 1

   * - 字段
     - 说明
   * - ``hostNetwork: true``
     - 复用边侧节点网络（Flannel VXLAN 不可用时的通用绕过手段）
   * - ``runtimeClassName``
     - 指定使用 MicRun 运行时
   * - ``nodeSelector``
     - 将 Pod 调度到指定边侧节点
   * - ``tolerations``
     - 容忍 ``not-ready`` 节点（无 CNI 时节点会保持 NotReady）
   * - ``image``
     - RTOS 镜像名称（必须是边缘已导入的镜像）
   * - ``imagePullPolicy: IfNotPresent``
     - 边侧已导入镜像时优先本地使用，避免触发仓库拉取
   * - ``command``
     - RTOS 镜像无标准入口点，必须显式提供占位命令
   * - ``tty: false``
     - 默认关闭 TTY（``tty=true`` 与 stderr 不兼容，会触发 CRI 拒绝 attach）
   * - ``stdin: true``
     - 保持标准输入打开（支持交互式操作，配合 ``kubectl attach -i``）

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
   ctr -a /run/containerd/containerd.sock -n k8s.io tasks ls
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
     - ``pause`` 镜像或 RTOS 镜像不存在，或系统 containerd 的 ``sandbox_image`` 仍指向默认仓库
     - 系统 containerd 用 ``ctr -a /run/containerd/containerd.sock -n k8s.io images import``；同时检查 ``/etc/containerd/config.toml``
   * - 边侧节点 NotReady
     - K3s Agent 未运行或网络问题
     - 检查 ``systemctl status micrun-k3s-agent.service`` 或你当前使用的 agent 服务
   * - ``Waiting for containerd startup: server is not initialized yet``
     - CNI 路径不完整，或旧 K3s state/shim 未清理
     - 同时检查 ``/etc/cni/net.d``、``/opt/cni/bin``，并清理旧 ``/run/k3s`` state 和残留 shim
   * - ``failed to load cni during init`` / ``no network config found in /etc/cni/net.d``
     - ``10-micrun.conflist`` 未写入系统 CNI 目录
     - 将 CNI 配置写入 ``/etc/cni/net.d``，并确认 ``/opt/cni/bin`` 可用
   * - runtime ``micrun`` not found
     - 目标 containerd 未加载 MicRun runtime
     - external 模式检查 ``/etc/containerd/config.toml``，bundled 模式检查 ``config.toml.tmpl`` 与生成后的 ``config.toml``
   * - Pod 刚 Running 后立刻被 kubelet ``Stopping container``
     - Pod QoS cgroup 未创建，kubelet 执行 ``killPod``
     - 增加 ``cgroups-per-qos=false``、空 ``enforce-node-allocatable`` 和必要的 ``fail-cgroupv1=false``
   * - K3s 日志出现 ``configured to not run on a host using cgroup v1``
     - 当前 kubelet 默认拒绝 cgroup v1
     - 增加 ``--kubelet-arg=fail-cgroupv1=false``
   * - ``kubectl attach`` 无输出
     - Pod 未开启 ``stdin``，``tty=true`` 与 stderr 不兼容，或 shim IO 未连上 RTOS shell
     - 使用 ``test-k3s-interaction`` 复现，并检查边侧 containerd task、``journalctl -u micad`` 和 ``/var/log/mica/mica-runtime.log``
   * - 删除 Pod 后 Xen domain 仍存在
     - CRI 删除链路或 shim 清理异常
     - 对照 Pod container ID 检查 ``ctr -a /run/containerd/containerd.sock -n k8s.io tasks ls`` 和 ``xl list``
   * - K3s 启动即退出
     - 系统时间错误
     - 校正时间，避免 ``1970-01-01``
   * - K3s 启动被杀
     - 宿主内存不足
     - 清理旧 Xen 域、释放缓存、减少附加组件
   * - K3s 日志出现 ``failed to create vxlan device``
     - 宿主不支持 VXLAN
     - 改用 ``--flannel-backend=none`` 或安装其他 CNI
   * - K3s 日志出现 ``unknown flag: --fail-cgroupv1``
     - kubelet 版本不支持该参数
     - 移除该参数；保留 ``cgroups-per-qos=false`` 组合
   * - SSH 自动化一登录就要求改密
     - 账号密码已过期
     - 对自动化账号执行 ``chage``/``passwd -x`` 关闭过期限制
   * - 找不到 ``/var/log/mica/mica-runtime.log``
     - 当前环境未开启 MicRun 文件日志或目录未创建
     - 检查 ``/etc/mica/micrun/config.json`` 的日志输出配置，再决定是否创建 ``/var/log/mica``

通用排查命令
------------

.. code-block:: bash

   # 查看 Pod 状态
   kubectl get pods -o wide

   # 查看 Pod 详细信息
   kubectl describe pod <pod_name>

   # 查看 Pod 日志
   kubectl logs <pod_name>

   # 在边缘查看 MicRun 日志（仅 debug 构建输出文件日志）
   tail -f /var/log/mica/mica-runtime.log

参考资源
========

.. seealso::

   - `K3s 官方文档 <https://docs.k3s.io/>`_
   - :doc:`../quick-start` - MicRun 快速入门
   - `Mica-Xen 指导 <https://embedded.pages.openeuler.org/master/features/mica/instruction.html>`_
   - `问题反馈 <https://atomgit.com/openeuler/mcs/issues>`_

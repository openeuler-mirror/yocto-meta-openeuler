.. _isula_engine:

iSula容器引擎及使用方法
###############################################

iSula简介
==========

iSula是openEuler社区开发的容器引擎，采用C/C++实现，具有轻量、启动快、
不依赖Go运行时等特点，适合嵌入式与资源受限场景。

openEuler Embedded在构建时集成了iSula容器引擎，用户可以通过iSula容器引擎
来管理容器。当前集成的版本为iSulad 2.1.6、lcr 2.1.5。

iSula采用标准的C/S架构：``isulad``是daemon服务端，``isula``是独立的客户端命令，
两者通过Unix socket（默认 ``/var/run/isulad.sock``）通信。

当前默认容器运行时为 **lcr** （基于liblxc，由isulad通过 ``dlopen`` 加载到同一进程），
也支持runc和kata-runtime，但默认镜像中只包含lcr，需要runc或kata-runtime时需自行集成。

支持的容器镜像格式为OCI镜像、Docker镜像和external rootfs。

iSula提供两种容器管理接口：

- **CLI**：``isula`` 命令行，适合本地调试和单机管理。
- **CRI**：供Kubernetes/KubeEdge等编排组件接入。默认提供 **CRI v1alpha2**；
  如需CRI v1，需要在 ``/etc/isulad/daemon.json`` 中设置 ``"enable-cri-v1": true``
  （软件的CRI v1能力已在构建时打开）。

默认配置下集成的功能
======================

当前 ``isulad_2.1.6.bb`` 的默认配置（未做额外裁剪）包含以下能力：

.. list-table::
   :widths: 22 18 60
   :header-rows: 1

   * - 能力
     - 默认状态
     - 说明
   * - 默认运行时
     - lcr
     - ``daemon.json`` 中 ``"default-runtime": "lcr"``，无需额外安装runc
   * - 存储驱动
     - overlay2
     - 依赖内核overlayfs；使能isulad特性时构建系统会自动加入overlay内核模块
   * - 镜像管理
     - 开启
     - ``isula pull/push/login/logout/search/images/tag/rmi/import/export/load/save/prune``
   * - 容器生命周期
     - 开启
     - ``isula run/create/start/stop/restart/kill/pause/resume/rm/rename/update/wait/ps``
   * - 运行时运维
     - 开启
     - ``isula exec/attach/cp/logs/port/top/stats/inspect/events``
   * - 网络
     - 开启
     - 原生网络与CNI；``isula network create/ls/inspect/rm``
   * - 本地卷
     - 开启
     - ``isula volume``
   * - 资源限制
     - 开启
     - cgroups v1/v2；CPU、内存、cpuset、blkio、hugetlb等；OOM事件监控
   * - 安全隔离
     - 开启
     - namespace、capabilities、seccomp；SELinux支持已编译（musl变体关闭）
   * - CRI
     - v1alpha2
     - CRI v1需在 ``daemon.json`` 中设置 ``"enable-cri-v1": true``
   * - shim v2
     - 开启
     - 使用预编译的lib-shim-v2，用于CRI pod sandbox
   * - CDI
     - 开启
     - 配合CRI v1使用，用于设备注入
   * - gRPC API
     - 开启（仅本地）
     - 通过Unix socket提供本地API；远程连接（``ENABLE_GRPC_REMOTE_CONNECT``）关闭
   * - systemd集成
     - 可选
     - 使用systemd的镜像启用systemd notify；否则由初始化脚本挂载cgroup

架构与裁剪说明：

- arm32 不支持iSula，构建时不安装 ``packagegroup-isulad``。
- riscv64 关闭gRPC和shim v2。
- musl变体关闭gRPC、shim v2和SELinux，并依赖gcompat。
- aarch64全功能形态的依赖增量约45–50 MB（strip后，未压缩）；若关闭gRPC、
  shim v2、SELinux、devmapper等功能，可裁剪到约20 MB。
- 默认镜像不包含isula-build，构建容器镜像需另外使用isula-build工具。

构建带有iSula的openEuler Embedded镜像
=========================================

openEuler Embedded标准镜像默认不集成iSula容器引擎。
如果需要集成isulad，可以在 ``local.conf`` 中添加：

.. code-block:: shell

    DISTRO_FEATURES:append = " isulad "

也可以通过oebuild在生成构建目录时选择 ``isulad`` 特性：

.. code-block:: console

    $ oebuild generate -p qemu-aarch64 -f isulad -d <build_dir>

之后进入构建目录构建标准镜像：

.. code-block:: console

    $ cd <build_dir>
    $ oebuild bitbake openeuler-image

构建openeuler-container-os的过程和标准镜像类似，区别在于构建目标：

.. code-block:: console

    $ oebuild bitbake openeuler-container-os

启动iSula daemon
======================================

标准openEuler Embedded镜像默认不会自动启动iSulad，需要手动启动。

如果镜像使用systemd：

.. code-block:: console

    # 启动iSula daemon服务端
    $ systemctl start isulad
    # 可选：设置为开机自启
    $ systemctl enable isulad

如果镜像不使用systemd，先确保cgroup已挂载（未使用systemd时，``config_cgroup``
初始化脚本会在启动阶段自动执行），然后以后台进程方式启动：

.. code-block:: console

    $ isulad &
    ...
    isulad 20240131074734.534 - iSulad successfully booted in 0.120 s

如果需要从公共镜像仓库拉取镜像，先配置镜像源。编辑 ``/etc/isulad/daemon.json``，
在 ``registry-mirrors`` 中添加镜像源地址，例如：

.. code-block:: json

    "registry-mirrors": [
        "docker.io"
    ]

修改后重启isulad服务。

快速使用
==========

本文档仅记录常用操作，更完整的命令说明请参见iSulad官方文档。

**拉取镜像**

.. code-block:: console

    $ isula pull busybox

**查看本地镜像**

.. code-block:: console

    $ isula images

**运行容器**

.. code-block:: console

    $ isula run -it busybox sh
    / #

输入 ``exit`` 退出交互界面。

**创建、启动与进入容器**

.. code-block:: console

    $ isula create -it busybox sh
    $ isula start <container_id>
    $ isula attach <container_id>

**在运行中的容器内执行命令**

.. code-block:: console

    $ isula exec -it <container_id> sh

**查看容器与日志**

.. code-block:: console

    $ isula ps -a
    $ isula logs <container_id>

快速验证
==========

完成构建并启动isulad后，可以按以下步骤确认默认配置工作正常。

**1. 确认版本与服务状态**

.. code-block:: console

    $ isula version
    $ isula info

``isula info`` 中应能看到 ``Server Version: 2.1.6`` 和
``Storage Driver: overlay2`` （具体字段以实际版本为准）。

**2. 确认默认运行时为lcr**

.. code-block:: console

    $ grep '\"default-runtime\"' /etc/isulad/daemon.json
        "default-runtime": "lcr",

也可以运行一个容器后查看其运行时：

.. code-block:: console

    $ isula run -itd --name demo busybox sh
    $ isula ps -a --format "{{.Runtime}}"

输出应为 ``lcr``。

**3. 验证基本生命周期**

.. code-block:: console

    $ isula run --rm busybox echo "hello isula"
    hello isula
    $ isula exec -it demo sh -c 'uname -a; echo inside-container'
    $ isula stats --no-stream demo
    $ isula inspect demo | head
    $ isula logs demo
    $ isula rm -f demo

**4. 验证离线镜像导入导出**

无网络环境可以先在别处导出镜像，再在目标机上导入：

.. code-block:: console

    # 有镜像的机器上
    $ isula save busybox -o busybox.tar
    # 目标机器上
    $ isula load -i busybox.tar
    $ isula images

**5. 验证卷和网络**

.. code-block:: console

    $ isula volume create testvol
    $ isula run --rm -v testvol:/data busybox sh -c 'echo data > /data/test; cat /data/test'
    $ isula volume ls
    $ isula network ls

如果上述命令均正常，说明默认配置下的iSula功能可用。

.. _isula_mcs:

与MCS特性的关系：为什么当前不能集成iSula
=============================================

openEuler Embedded的MCS（Mixed Criticality System）特性中，RTOS容器化能力
由 **micrun** 提供。micrun 是 **containerd shim-v2** 实现：

- 运行时类型为 ``io.containerd.mica.v2``，产物为 ``containerd-shim-mica-v2``；
- 依赖rootfs中的系统containerd（1.7.19及以上）；
- 当前推荐形态是“K3s Agent + 系统containerd”，K3s Agent 通过
  ``--container-runtime-endpoint=unix:///run/containerd/containerd.sock`` 接入。

因此，MCS特性当前不能把K3s的容器引擎替换为iSula，原因有三点：

1. **iSula不支持加载containerd shim-v2。** iSula的runtime只有两类：lcr
   （进程内 ``dlopen liblcr.so``）和isula（通过 ``isulad-shim`` 执行runc这类
   OCI runtime命令行）。iSula自身也有shim v2，但它面向pod sandbox的
   sandboxer协议，不是containerd的runtime-v2 task服务，不能直接挂载
   ``containerd-shim-mica-v2``。
2. **iSula的CRI RuntimeClass支持范围有限。** 当前仅支持kata和runc两类
   OCI runtime；micrun是shim而不是OCI runtime命令行，无法通过RuntimeClass接入。
3. **一个K3s节点只能配置一个CRI endpoint。** RuntimeClass只能在同一个CRI实现
   内部切换handler，不能把RTOS Pod交给containerd、普通Pod交给iSula。

可选方案：

- **需要RTOS容器**：保留containerd + micrun，K3s使用
  ``K3S_EXTERNAL_ENDPOINT="containerd"``。这是当前MCS的推荐方案。
- **不需要RTOS容器** （只使用Jailhouse/OpenAMP等核隔离能力）：可以把K3s引擎
  换成iSula，配置 ``K3S_EXTERNAL_ENDPOINT="isulad"``，并显式安装
  ``packagegroup-isulad``。注意该路径当前对应的K3s版本为v1.22.6，
  且需要验证pause镜像、CNI目录和离线镜像导入。
- **必须统一到iSula**：需要为micrun开发iSula sandboxer适配层，或把micrun
  包装成OCI runtime并扩展iSula的RuntimeClass支持，工作量较大。

更多MCS与micrun的说明，参见 :doc:`../rt_container/index`。

更多参考
==========

- iSulad官方文档（openEuler 24.03 LTS）：
  `iSula容器引擎 <https://docs.openeuler.openatom.cn/zh/docs/24.03_LTS/docs/Container/iSula容器引擎.html>`_
- 本仓库recipe：``meta-openeuler/recipes-core/isulad/isulad_2.1.6.bb``
- 默认运行时配置：``meta-openeuler/recipes-core/isulad/files/0001-configuration-use-lcr.patch``
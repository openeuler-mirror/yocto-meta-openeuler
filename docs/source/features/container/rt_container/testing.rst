.. _micrun_testing:

MicRun 测试指导
###############

本文档面向两类读者：

- **测试人员**：需要知道 MicRun 有哪些可验证的场景、每个场景该用哪个入口、怎么判断通过与否
- **开发者/使用者**：想在本地确认某条链路是否正常，但不清楚该从哪一级测试开始

阅读顺序建议：先看 :ref:`micrun_test_matrix` 确认"要验证的场景属于哪一级"，
再跳到对应章节。所有测试脚本都在 MicRun 源码仓（``mcs``）的 ``micrun/tests``
目录下，本文用 ``<path-to-mcs-repo>`` 表示该仓库在本地的路径。

.. note::

   本文只讲"怎么测"。环境怎么从零搭建（构建系统镜像、构建 RTOS 容器镜像、
   注册运行时）见 :doc:`quick-start`；云边集群怎么部署见
   :doc:`kubernetes/index`。

.. _micrun_spec_mapping:

规格验收牵引
============

MicRun 的交付规格（功能规格 8 项 + 验收标准 8 条）与测试入口一一对应。
下表是"验收什么 → 用什么测"的总索引；每条的具体操作见后续章节。

.. list-table::
   :widths: 6 40 34 20
   :header-rows: 1

   * - #
     - 验收标准（摘要）
     - 验证入口
     - 状态
   * - 1
     - 作为 containerd shim v2 插件注册，运行时类型可被识别
     - ``tests/bin/test-qemu-smoke``\ （逐项断言 containerd 活动、shim 二进制在 PATH、aarch64 架构与 Xen ``Domain-0``）；``test-qemu-lifecycle`` 用例 10 反向断言未知运行时名报运行时解析错误；全部用例经 MicRun 运行时创建，隐式验证注册
     - 已覆盖
   * - 2
     - ctr/nerdctl 创建、启动、停止、删除 RTOS 工作负载
     - ``tests/bin/test-qemu-lifecycle``\ （ctr，13 个边界用例）；``tests/bin/test-io-qemu``\ （nerdctl 用户路径）
     - 已覆盖
   * - 3
     - mica-image-builder 制作镜像，导入后可启动
     - 镜像制作随 oebuild 交付（``micrun-files/mica-image-builder.py``），builder 产出的注解键值与 shim 消费常量的一致性由契约测试看护；导入与启动由 ``test-io-qemu`` / ``test-qemu-features`` 的 ``QEMU_IMAGE_TAR`` 流程覆盖
     - 已覆盖（打包全流程为人工流程）
   * - 4
     - 控制台交互：输入 help/uname 并获得响应
     - ``tests/bin/test-io-qemu``\ （ctr/nerdctl attach）；``tests/bin/test-k3s-interaction``\ （kubectl attach）；``test-qemu-features`` 用例 15 与 ``test-qemu-lifecycle`` 用例 12（断言真实命令响应，排除输入回显与启动横幅）
     - 已覆盖
   * - 5
     - 按 RTOS 类型（UniProton/Zephyr）与固件路径选择启动
     - ``tests/bin/test-qemu-features`` 用例 7（``os`` + ``firmware_path`` 注解显式选择）；单测与 mock_micad 常驻看护 Zephyr 合法性与固件路径
     - UniProton 场景已覆盖；Zephyr 固件经构建侧自行提供后按下述路径验证
   * - 6
     - 创建时配置 CPU/内存资源并生效
     - ``tests/bin/test-qemu-features`` 用例 1（注解 ``min_memory_mb``/``max_vcpu_num``）、用例 2（运行中热更新，Task.Update / CRI 路径）、用例 8（OCI 规格资源，``containerd_client run`` 经 Go SDK 注入 LinuxResources——与 CRI/kubelet 等价）
     - 已覆盖
   * - 7
     - K3s RuntimeClass + Pod 方式启动 RTOS 工作负载
     - ``tests/bin/test-k3s-single-node`` / ``tests/bin/test-k3s-cloud-edge``
     - 已覆盖
   * - 8
     - kubectl attach 连接 RTOS 工作负载并发送 shell 命令
     - ``tests/bin/test-k3s-interaction``
     - 已覆盖

Zephyr 验证路径（固件由用户经 ``rtos/meta-zephyr`` layer 自行构建提供）：

.. code-block:: bash

   # 1. 构建 Zephyr 固件（启用 rtos/meta-zephyr：zephyr-kernel / zephyr_toolchain）
   # 2. 制作为容器镜像（交付的 mica-image-builder 支持 --os zephyr）
   python3 mica-image-builder.py --pedestal xen --os zephyr \
       --firmware <zephyr.elf> --xen-image <zephyr.bin> \
       --image-name local/mica-zephyr-app:xen-arm64-0.1 \
       --platform linux/arm64 --export ./exports
   # 3. 以该镜像跑类型选择场景（实例配置 /etc/mica/qemu-zephyr-xen.conf 已随镜像交付）
   QEMU_IMAGE_TAR=<zephyr-tar> TEST_IMAGE=docker.io/local/mica-zephyr-app:xen-arm64-0.1 \
       tests/bin/test-qemu-features --case 7

规格的约束说明同样约束测试环境：验证路径为 AArch64 + Xen 底座
（宿主经 Xen 启动）、RTOS 类型为 UniProton/Zephyr、K3s Pod 需显式占位
命令且 stdin 开启 / tty 关闭、RTOS 工作负载面向无网络配置场景。

.. _micrun_test_matrix:

测试能力总览
============

下表把 MicRun 当前支持的场景映射到验证入口。**环境成本**\ 一列决定了你至少需要
准备什么。

.. list-table::
   :widths: 26 30 20 24
   :header-rows: 1

   * - 场景
     - 验证入口
     - 环境成本
     - 级别
   * - 配置解析、注解覆盖、资源换算、状态机、IO 状态机
     - ``make ci``\ （fmt/vet/单元测试/race 检测）
     - 一台普通 Linux 开发机
     - L1
   * - QEMU + Xen 环境自身是否可用
     - ``tests/bin/test-qemu-smoke``
     - QEMU 构建产物
     - L2
   * - 容器生命周期边界（重复创建、幂等 kill、auto-close、pause/resume、资源泄漏）
     - ``tests/bin/test-qemu-lifecycle``
     - QEMU 构建产物
     - L2
   * - ``ctr`` / ``nerdctl`` 用户命令路径、TTY 交互、attach/detach、回声抑制
     - ``tests/bin/test-io-qemu``
     - QEMU + RTOS 镜像 tar
     - L3
   * - Kubernetes 调度 RTOS Pod（单节点）
     - ``tests/bin/test-k3s-single-node``
     - 边侧节点内置 K3s
     - L4
   * - Kubernetes 云边协同（云侧 server + 边侧 agent）
     - ``tests/bin/test-k3s-cloud-edge``
     - QEMU + 本机 Docker
     - L4
   * - ``kubectl attach`` 交互与删除清理
     - ``tests/bin/test-k3s-interaction``
     - 已就绪的 K3s 环境
     - L4
   * - Deployment 镜像 OTA 滚动升级
     - ``tests/bin/test-k3s-ota``
     - 云边环境 + v1/v2 镜像
     - L4

分级含义：

.. list-table::
   :widths: 10 30 60
   :header-rows: 1

   * - 级别
     - 名称
     - 说明
   * - L1
     - 本机单元测试
     - 不需要 QEMU、Xen、RTOS 镜像或任何硬件，改完代码就能跑
   * - L2
     - 环境冒烟与生命周期
     - 需要能启动的 QEMU 产物，验证运行时和 Xen 的基础协作
   * - L3
     - 用户命令路径回归
     - 在 L2 基础上验证真实用户会敲的 ``ctr``/``nerdctl`` 命令
   * - L4
     - Kubernetes 场景验证
     - 验证云原生入口，是最接近生产形态的一级

.. tip::

   排查问题时按 **L1 → L4** 的顺序定位：低级别失败就没必要跑高级别。
   做发布前回归时按 **L1 → L2 → L3 → L4** 全量执行。

统一入口
========

``tests/run_all_tests.sh`` 是纳入项目测试体系的类别入口：

.. code-block:: bash

   cd <path-to-mcs-repo>/micrun

   ./tests/run_all_tests.sh --help          # 查看用法
   ./tests/run_all_tests.sh                 # 全量（不含 performance）
   ./tests/run_all_tests.sh io              # IO 类别
   ./tests/run_all_tests.sh k3s             # K3s 类别
   ./tests/run_all_tests.sh k3s interaction # K3s 单个场景（语义名）
   ./tests/run_all_tests.sh lifecycle       # 生命周期单元测试
   ./tests/run_all_tests.sh performance     # 性能基准

除上述通用 K3s 用例集外，交付规格的验收 7/8 由 ``tests/k3s/`` 下的
场景套件背书：``run_cloud_edge_e2e.sh``\ （RuntimeClass + Pod 启动 +
产品路径删除清理）、``run_interaction_e2e.sh``\ （kubectl attach 交互 +
删除清理）、``run_ota_e2e.sh``\ （Deployment 镜像滚动升级 + v2 attach +
清理）、``run_single_node_e2e.sh``\ （单节点入口；镜像
dom0 内存低于其预检时按设计优雅跳过）。

四个类别与前面的分级对应关系：

.. list-table::
   :widths: 20 20 60
   :header-rows: 1

   * - 类别
     - 级别
     - 说明
   * - ``lifecycle``
     - L1
     - Go 单元测试，筛选生命周期相关用例
   * - ``performance``
     - L1
     - Go benchmark，**默认不随全量执行**
   * - ``io``
     - L3
     - 自适应 IO 套件，需要可达的 guest
   * - ``k3s``
     - L4
     - K3s 用例集，默认含 ``interaction``，不含 ``ota``

无参数执行时 ``performance`` 会被跳过，避免拉长常规回归；需要包含时设置
``RUN_PERFORMANCE_TESTS=1``。

L1：本机单元测试
================

这一级**不需要任何硬件、QEMU 或 RTOS 镜像**，是改完代码后的第一道关卡，
也是新人最容易上手的入口。

运行全部单元测试
----------------

提交代码前的第一道关卡是 ``make ci`` 本地验证门（gofmt 检查 + go vet + 构建 +
单元测试 + race 检测，一次跑齐）：

.. code-block:: bash

   cd <path-to-mcs-repo>/micrun
   make ci        # 提交前必跑：fmt/vet/build/test/race 全绿

细分目标：

.. code-block:: bash

   make test          # 单元测试（默认构建）
   make test-race     # 带 race 检测
   make test-debug    # debug 构建变体（-tags debug）
   make test-all      # test + test-race + test-debug
   make cover         # 覆盖率报告（builds/coverage.out）
   make lint          # gofmt 检查 + go vet

仓库使用 vendor 模式，无需联网拉取依赖。全部通过时每个包输出 ``ok``。
开发细节（红-绿回归测试手册、build tag 矩阵、覆盖基线）见 MicRun 仓
``docs/internals/testing.md``。

覆盖范围
--------

单元测试覆盖了 30 个以上的包，主要包括：

.. list-table::
   :widths: 42 58
   :header-rows: 1

   * - 包
     - 验证内容
   * - ``internal/adapters/config/oci``
     - 注解解析、运行时配置键、资源换算、路径类键过滤
   * - ``internal/adapters/config/runtimeconfig``
     - 配置来源优先级、解析失败回退、INI/TOML 解析
   * - ``internal/adapters/io``
     - FIFO 搬运、epoll 事件、非阻塞读写、输出规范化
   * - ``internal/adapters/state/file``
     - 状态文件读写、快照一致性
   * - ``internal/application/lifecycle``
     - 创建/启动/停止/删除状态迁移
   * - ``internal/application/recovery``
     - shim 重启后的状态恢复与对账
   * - ``internal/domain/console``
     - 输入语义、回声抑制、行结束符处理
   * - ``internal/domain/container``
     - 容器领域模型、资源规划
   * - ``internal/support/cpuset``
     - cpuset 解析、归一化、越界保护
   * - ``internal/transport/shimv2``
     - shim v2 RPC 适配、task 管理、事件

按主题筛选
----------

只跑生命周期相关用例：

.. code-block:: bash

   ./tests/run_all_tests.sh lifecycle

等价于对 ``lifecycle``、``task``、``domain/container``、``shimv2`` 四个包按
``Lifecycle|Create|Start|Stop|Delete|Kill|Wait|Pause|Resume|CloseIO|State``
筛选用例。第二个参数会作为 ``go test -run`` 的正则传入，可用来进一步收窄：

.. code-block:: bash

   ./tests/run_all_tests.sh lifecycle TestCreateContainer

性能基准
--------

.. code-block:: bash

   ./tests/run_all_tests.sh performance

对 ``internal/adapters/io`` 和 ``internal/support/parse`` 执行 Go benchmark，
默认 ``benchtime`` 为 ``100ms``，可用 ``PERF_BENCHTIME`` 调整：

.. code-block:: bash

   PERF_BENCHTIME=2s ./tests/run_all_tests.sh performance

端到端时延基线（Create→RUNNING、attach 首响应、删除收敛的实测中位数）与可复现的
测量/对比脚本见 MicRun 仓 ``docs/internals/testing.md`` 与 ``micrun/tests/perf/``；
性能敏感改动应据此复测对比。

不接硬件的交互调试
------------------

如果只想在开发机上观察 shim 与 micad 的交互，而不启动真实 RTOS，可以使用
mock micad：

.. code-block:: bash

   cd <path-to-mcs-repo>/micrun
   make mock-micad

它会在 ``/tmp/mica/mica-create.socket`` 上模拟 micad 的控制面，并用 PTY 模拟
RTOS 的 IO 行为。清理残留 socket 和 PTY 软链接：

.. code-block:: bash

   cd tests/mock_micad && make gc

L2：QEMU 环境冒烟与生命周期
===========================

这一级验证"QEMU 产物本身能不能用"，是所有 guest 内测试的前置条件。

准备工作
--------

先按 :doc:`quick-start` 构建出 QEMU 产物，然后声明产物位置：

.. code-block:: bash

   export QEMU_OUTPUT_DIR="<path-to-qemu-output-test-dir>"
   export QEMU_BIN="<path-to-qemu-system-aarch64>"
   export QEMU_LD_LIBRARY_PATH="<path-to-qemu-lib-dir>:<path-to-qemu-lib64-dir>"
   export QEMU_LOCAL_SUDO_PASSWORD="<host-sudo-password-if-needed>"

.. warning::

   提交文档、日志或问题单时，不要写入真实宿主机路径、sudo 密码或 guest 密码。
   一律保留为环境变量或 ``<...>`` 占位符。

环境冒烟
--------

.. code-block:: bash

   <path-to-mcs-repo>/micrun/tests/bin/test-qemu-smoke

依次验证：

#. QEMU 启动且 SSH 在 60 秒内可达
#. guest 架构为 aarch64（``uname -m``）
#. ``systemctl is-active containerd`` 为活动状态
#. shim 二进制 ``containerd-shim-mica-v2`` 在 PATH 上可解析
#. ``xl list`` 可执行且包含 ``Domain-0``\ （Xen 工具栈就绪）
#. ``xl cpupool-list`` 探针（失败只告警，不判失败——部分 Xen 构建缺
   cpupool 支持）
#. Xen 启动探针：用 guest 内已有的 Xen 配置执行一次 ``xl create`` 并
   ``xl destroy``，确认真的能起域（依赖 qemu-xen device model，失败只告警）

Xen 启动探针在只想快速确认 SSH/containerd 时可以跳过：

.. code-block:: bash

   export QEMU_SMOKE_SKIP_XEN_PROBE=true

网络模式
--------

.. list-table::
   :widths: 30 70
   :header-rows: 1

   * - 取值
     - 含义
   * - ``QEMU_NET_MODE=both``
     - 默认。保留 ``tap0``，同时增加 usernet SSH 转发
   * - ``QEMU_NET_MODE=tap``
     - 只用 tap 网络，适合手工串口或固定 guest IP 调试
   * - ``QEMU_NET_MODE=user``
     - 只用 usernet，适合不依赖固定 guest IP 的冒烟

``tap0`` 是本地 QEMU/K3s 的标准测试网络；usernet 只是让自动化脚本能稳定访问
``root@127.0.0.1:<QEMU_SSH_FWD_PORT>``\ （默认端口 ``10022``），**不是** tap 的
替代方案。K3s 云边测试依赖 ``tap0`` 上的 ``192.168.7.0/24`` 网络和 macvlan，
因此不能只用 usernet。

生命周期边界用例
----------------

.. code-block:: bash

   <path-to-mcs-repo>/micrun/tests/bin/test-qemu-lifecycle

这 13 个用例覆盖的是冒烟和 IO 测试都碰不到的异常路径：

.. list-table::
   :widths: 6 34 60
   :header-rows: 1

   * - #
     - 用例
     - 通过判据
   * - 1
     - 不存在的镜像
     - 返回 ``not found`` 类错误，shim 不 panic
   * - 2
     - 删除不存在的容器
     - 返回干净错误，不产生残留
   * - 3
     - 重复创建同名容器
     - 被拒绝并返回 ``already exists``
   * - 4
     - 对已停止 task 再次 kill
     - 幂等，不使 shim 崩溃
   * - 5
     - 创建-删除循环
     - fd 数量在容差内回到初始值（fd 计数参与判定），无残留 Xen domain 与僵尸 task
   * - 6
     - auto-close 超时
     - 分离态容器转为 ``STOPPED``，Xen domain 被清理
   * - 7
     - pause / resume
     - 两步都返回 0，最终状态回到 ``RUNNING``
   * - 8
     - 全删后同名重建
     - 重建成功并回到 ``RUNNING``
   * - 9
     - 运行中 task 的 Xen domain 生命周期
     - 运行中 ``xl list`` 可见，删除后消失
   * - 10
     - 未知运行时名
     - 干净报错（反向验证运行时分发真实生效）
   * - 11
     - SIGTERM 停止 task
     - task 终止且无残留 Xen domain
   * - 12
     - attach 交互 + EOF
     - 命令应答返回，EOF 后 task 与 domain 干净收口
   * - 13
     - 未映射 kill 信号
     - 返回错误而非假成功，task 保持 ``RUNNING``

用例 6 会注入 ``auto_close_timeout=10s`` 注解并在客户端断开后默认等待
15 秒，等待时长可用 ``AUTO_CLOSE_WAIT`` 调整。调试时想保留 guest 不
关机，设置 ``QEMU_KEEP_RUNNING=true``。

L3：IO 与用户命令路径回归
=========================

这一级验证真实用户会敲的命令，是 MicRun 交互体验的主要防线。

执行方式
--------

.. code-block:: bash

   export EDGE_SSH_USER="${EDGE_SSH_USER:-root}"
   export EDGE_IP="${EDGE_IP:-192.168.7.2}"
   export TEST_REMOTE_HOST="${EDGE_SSH_USER}@${EDGE_IP}"
   export TEST_REMOTE_PASSWORD="<guest-root-password-if-needed>"
   export TEST_IMAGE="localhost:5000/mica-uniproton-app:xen-0.1"
   export QEMU_SOURCE_IMAGE_REF="localhost:5000/mica-uniproton-app:xen-0.1"
   export QEMU_IMAGE_TAR="<path-to-stamped-output>/exports/local_mica-uniproton-app_xen-arm64-0.1.tar"

   <path-to-mcs-repo>/micrun/tests/bin/test-io-qemu

该入口会自动完成五步：

#. 校验 QEMU guest 可达
#. 重新构建当前工作区的 shim
#. 把 shim 部署到 guest
#. 导入 RTOS 镜像 tar
#. 运行自适应 IO 套件

因此它验证的是**你当前代码**\ 的行为，而不是 rootfs 里预置的那个 shim。

如果 ``TEST_REMOTE_HOST`` 设为 ``qemu-k3s``、``root@127.0.0.1`` 或
``127.0.0.1``，入口会先调用 ``test-qemu-smoke`` 自动启动 QEMU，并通过 usernet
SSH 转发访问 guest。只用 tap 时，需要先手动启动 QEMU 并把
``TEST_REMOTE_HOST`` 指向实际 guest 地址。

镜像 profile
------------

RTOS 镜像的行为差异很大，套件会先探测再决定跑哪些用例：

.. list-table::
   :widths: 20 80
   :header-rows: 1

   * - profile
     - 含义
   * - ``shell``
     - 镜像提供交互式 shell（如 UniProton shell），跑全量交互用例
   * - ``hello``
     - 镜像只有固定启动横幅（如 ``Hello, UniProton!``），只跑对该行为有意义的用例

``IMAGE_PROFILE=auto``\ （默认）自动探测，也可显式指定为 ``shell`` 或 ``hello``。

.. important::

   探测不出 profile 会被判定为**失败回归**，而不是静默跳过。这是刻意设计：
   探测失败通常意味着 shim 启动路径真的出了问题，不能当成"环境不支持"放过。

覆盖的用户工作流
----------------

``shell`` 类镜像：

- ``nerdctl run -it --rm``、``nerdctl run -dt --name``
- ``nerdctl create -i -t --name`` + ``nerdctl start``
- ``nerdctl stop`` + ``nerdctl rm``、``nerdctl rm -f``
- ``nerdctl attach``、detach 回到远端 shell
- 前台 ``nerdctl run -it`` 后反复 attach / detach
- 空输入、非法命令、粘贴式命令突发、断行后 detach 的恢复
- TTY ``Ctrl-C`` 中断及中断后的清理
- ``nerdctl ps``、``nerdctl inspect``\ （拿到 ``--name`` 背后真实的 containerd/Xen ID）
- ``ctr container create`` + ``ctr task start -d``
- ``ctr task ls``、``ctr containers info``、``xl list`` 与运行时日志诊断
- 超时、``exit``、``stop``、``kill``、``rm`` 之后的清理

``hello`` 类镜像：

- ``nerdctl run -i --rm``、``nerdctl run -d --name``
- ``nerdctl create --name`` + ``nerdctl start``
- ``nerdctl ps``、``nerdctl rm -f``

.. note::

   使用 ``nerdctl --name`` 时，先 ``nerdctl inspect <name>`` 拿到真实 ID，
   再去核对 ``ctr`` 或 ``xl``。containerd task 和 Xen domain 用的是这个 ID，
   不是 ``nerdctl ps`` 显示的名字。

QEMU 环境下建议保持 ``NERDCTL_NETWORK_MODE=none``\ （默认值）。

L4：Kubernetes 场景验证
=======================

这一级验证云原生入口，是最接近生产形态的一级。四种模式按依赖递增。

用例清单
--------

.. list-table::
   :widths: 16 34 50
   :header-rows: 1

   * - ID
     - 名称
     - 说明
   * - ``preflight``
     - 环境预检
     - kubectl 可用性、节点就绪状态
   * - ``runtimeclass``
     - RuntimeClass 创建
     - 创建或更新 ``RuntimeClass micrun``
   * - ``pod-lifecycle``
     - Pod 启动/停止
     - RTOS Pod 进入 ``Running`` 并可正常停止
   * - ``deployment``
     - Deployment 扩缩容
     - 副本数 2 → 3
   * - ``pod-logs``
     - Pod 日志获取
     - ``kubectl logs`` 有输出
   * - ``resource-limits``
     - 资源限制
     - resources 限制被正确应用
   * - ``cpu-pinning``
     - vCPU pinning 注解
     - Pod 不被 pin 下发毒化，边侧 ``xl vcpu-pin`` 记录亲和性
   * - ``multi-node``
     - 多节点部署
     - 云边协同调度
   * - ``self-healing``
     - 故障恢复
     - 异常后的状态恢复
   * - ``interaction``
     - RuntimeClass Pod 交互与清理
     - ``kubectl attach`` 交互 + 三层对账 + 删除清理
   * - ``ota``
     - Deployment OTA 滚动升级
     - v1 → v2 镜像滚动升级

``run_all_tests.sh k3s`` 无场景参数时默认包含 ``interaction``，不包含
``ota``。要把 OTA 纳入默认类别，设置 ``K3S_INCLUDE_OTA=true``；要默认
排除交互场景，设置 ``K3S_INCLUDE_INTERACTION=false``。旧的
``K3S-000`` 到 ``K3S-009`` 编号仍被接受为兼容别名。

云边形态下跑通用用例集的两个要点：

- **边侧 kubectl**：oEE 镜像内置的 K3s 是 agent 形态，没有 ``kubectl``
  子命令。此时导出 ``K3S_LOCAL_KUBECONFIG`` 指向集群 kubeconfig（例如
  从云侧 server 容器导出的 ``k3s.yaml``，server 地址改为云侧 IP），套件
  会自动回退为宿主 ``kubectl`` 直连同一集群。
- **无 CNI 网络**：云边集群不带 CNI（控制面节点 ``NotReady`` 属预期），
  Pod 类场景需要 ``K3S_HOST_NETWORK=true`` 与
  ``K3S_TOLERATE_NOTREADY=true``，否则 Pod sandbox 网络创建失败。

公共变量
--------

.. code-block:: bash

   export EDGE_SSH_USER="${EDGE_SSH_USER:-root}"
   export EDGE_IFACE="${EDGE_IFACE:-enp0s1}"
   export EDGE_IP="${EDGE_IP:-192.168.7.2}"
   export HOST_TAP_IP="${HOST_TAP_IP:-192.168.7.1}"
   export CLOUD_IP="${CLOUD_IP:-192.168.7.10}"
   export TEST_REMOTE_HOST="${EDGE_SSH_USER}@${EDGE_IP}"
   export TEST_REMOTE_PASSWORD="<guest-root-password-if-needed>"

边侧节点需要具备三个文件：

.. list-table::
   :widths: 24 40 36
   :header-rows: 1

   * - 文件
     - 边侧默认路径
     - 覆盖变量
   * - K3s 二进制
     - ``/usr/bin/k3s``
     - ``K3S_BIN``
   * - pause 镜像 tar
     - ``/tmp/pause-image-arm64.tar``
     - ``K3S_PAUSE_TAR``
   * - RTOS 镜像 tar
     - ``/tmp/localhost_5000_mica-uniproton-app_xen-0.1.tar``
     - ``K3S_IMAGE_TAR``

.. important::

   K3s 二进制必须来自 rootfs 构建产物，**不要**\ 在 guest 内临时安装、复制或
   替换 K3s 二进制——那样测的就不是发布形态了。

单节点模式
----------

边侧节点自己跑 ``k3s server``，适合快速确认 bundled containerd 能调用 MicRun：

.. code-block:: bash

   export TEST_IMAGE="localhost:5000/mica-uniproton-app:xen-0.1"
   <path-to-mcs-repo>/micrun/tests/bin/test-k3s-single-node

验证：K3s server 启动、``RuntimeClass micrun`` 可用、RTOS Pod 进入
``Running``、``k3s ctr task ls`` 能看到任务、``xl list`` 能看到 Xen domain。

若 rootfs 只构建了 K3s agent 子命令，跳过这个模式，直接用云边模式。若 Dom0
可用内存低于阈值且没有 swap，入口会干净跳过（此时仍应用云边模式覆盖主链路）。

云边模式
--------

本机 Docker 跑 K3s server，边侧节点跑 agent。这是 K3s 与 QEMU 联调的主要方式：

.. code-block:: bash

   export TEST_IMAGE="localhost:5000/mica-uniproton-app:xen-0.1"
   export K3S_CLOUD_NETWORK_PARENT="tap0"
   export K3S_CLOUD_SERVER_IP="${CLOUD_IP}"
   export K3S_EDGE_NODE_IP="${EDGE_IP}"
   export K3S_EDGE_NODE_NAME="qemu-aarch64"
   export K3S_CLOUD_SERVER_IMAGE="<k3s-server-image-matching-edge-version>"
   export K3S_EDGE_CONTAINERD_MODE="external"

   <path-to-mcs-repo>/micrun/tests/bin/test-k3s-cloud-edge

验证：Docker macvlan 网络与云侧 server 启动、边侧 agent 经 ``tap0`` 加入集群、
边侧 containerd 加载 MicRun runtime、Pod 调度到指定边侧节点并 ``Running``、
边侧 ``ctr -n k8s.io tasks ls`` 与 ``xl list`` 能找到**同一个容器 ID**、
删除后 task 与 Xen domain 都被清理。

调试时想保留 Pod：``K3S_E2E_KEEP_POD=true``。

.. note::

   云侧 K3s server 镜像版本应与边侧 K3s 版本匹配，否则 agent 可能无法加入集群。

交互模式
--------

单纯的 ``Running`` 不代表用户能用。交互模式验证的是真正的 Kubernetes 使用入口：

.. code-block:: bash

   export K3S_INTERACTION_MODE="auto"     # auto/cloud/local/edge
   export K3S_INTERACTION_EXPECT="auto"   # auto/shell/hello
   <path-to-mcs-repo>/micrun/tests/bin/test-k3s-interaction

验证链条：创建 ``RuntimeClass micrun`` → 创建带 ``stdin: true`` 的 RTOS Pod →
等待 ``Running`` → ``kubectl attach -i`` 逐行发送 ``help``、``uname`` →
匹配 UniProton shell 或 hello 输出标记 → 从 Pod status 解析 containerd ID →
在边侧 containerd 找到同一 task → 在 ``xl list`` 找到同一 Xen domain →
删除 Pod 后确认两者都被清理。

``K3S_INTERACTION_MODE`` 的四种取值：

.. list-table::
   :widths: 16 84
   :header-rows: 1

   * - 取值
     - 行为
   * - ``auto``
     - 优先检测本机运行中的云侧 server 容器；其次用 ``K3S_LOCAL_KUBECONFIG``；最后回退到边侧 ``k3s kubectl``
   * - ``cloud``
     - 强制通过云侧 ``kubectl`` 创建 Pod
   * - ``local``
     - 用本机 kubeconfig 访问已存在的控制面，适合 QEMU 资源有限、不想在 guest 内跑 server 的场景
   * - ``edge``
     - 在边侧节点上用 ``k3s kubectl`` 跑单节点交互测试

.. note::

   Pod 默认 ``tty: false``，这是为了兼容 K3s/containerd 的 attach 参数组合——
   CRI 同时设置 ``tty=true`` 和 ``stderr=true`` 时会返回
   ``tty and stderr cannot both be true``。需要验证交互式 TTY 时显式设置
   ``K3S_INTERACTION_TTY=true``。

OTA 模式
--------

验证云端 Deployment 镜像更新能驱动边侧 RTOS workload 滚动升级。它**不会**\ 启动
新的 K3s server/agent，要求云边模式已经就绪：

.. code-block:: bash

   # 前置：先跑一次云边模式
   <path-to-mcs-repo>/micrun/tests/bin/test-k3s-cloud-edge

   # 准备 v2 镜像 tar 并放到边侧
   export K3S_OTA_V1_IMAGE="localhost:5000/mica-uniproton-app:xen-0.1"
   export K3S_OTA_V2_IMAGE="localhost:5000/mica-uniproton-app:xen-0.2"
   export K3S_OTA_V2_IMAGE_TAR="/tmp/localhost_5000_mica-uniproton-app_xen-0.2.tar"

   <path-to-mcs-repo>/micrun/tests/bin/test-k3s-ota

验证：导入 v1/v2 镜像 → 创建 v1 Deployment 并确认边侧 task 与 Xen domain →
patch 镜像为 v2 并等待 rollout → 确认新旧 container ID 不同 → 确认旧 v1 Xen
domain 被清理、新 v2 domain 启动 → 对 v2 Pod 执行 ``kubectl attach -i`` 并匹配
输出 → 删除 Deployment 后确认清理完成。

kubelet cgroup 适配
-------------------

oEE/QEMU guest 的 cgroup 层级可能不足以支撑 kubelet 的 Pod QoS cgroup，
导致 RTOS domain 刚启动就被 ``StopContainer``。测试脚本默认追加：

.. code-block:: bash

   --kubelet-arg=cgroups-per-qos=false \
     --kubelet-arg=enforce-node-allocatable= \
     --kubelet-arg=fail-cgroupv1=false

当前已验证的 oEE K3s v1.27 组合是前两个参数：

.. code-block:: bash

   export K3S_KUBELET_ARGS="--kubelet-arg=cgroups-per-qos=false --kubelet-arg=enforce-node-allocatable="

较新的 kubelet 在 cgroup v1 guest 中可能还需要 ``fail-cgroupv1=false``；
较旧版本若提示 unknown flag，就通过 ``K3S_KUBELET_ARGS`` 覆盖为本版本支持的
参数。目标环境已具备完整 cgroup 能力时可显式置空：

.. code-block:: bash

   export K3S_KUBELET_ARGS=""

环境变量参考
============

通用
----

.. list-table::
   :widths: 34 30 36
   :header-rows: 1

   * - 变量
     - 默认值
     - 说明
   * - ``TEST_REMOTE_HOST``
     - ``root@192.168.7.2``
     - 边侧/guest SSH 目标
   * - ``TEST_REMOTE_PASSWORD``
     - 空
     - SSH 密码（免密时留空）
   * - ``TEST_IMAGE``
     - ``localhost:5000/mica-uniproton-app:xen-0.1``
     - 测试使用的 RTOS 镜像
   * - ``IMAGE_PROFILE``
     - ``auto``
     - 镜像能力类型：``auto``/``shell``/``hello``
   * - ``NERDCTL_NETWORK_MODE``
     - ``none``
     - QEMU 环境推荐保持 ``none``
   * - ``TEST_LOG_DIR``
     - ``/tmp/micrun-tests``
     - 测试日志目录
   * - ``TEST_TIMEOUT_POD``
     - ``120``
     - Pod 相关操作超时（秒）

QEMU
----

.. list-table::
   :widths: 34 30 36
   :header-rows: 1

   * - 变量
     - 默认值
     - 说明
   * - ``QEMU_OUTPUT_DIR``
     - 无
     - QEMU 构建产物目录（必填）
   * - ``QEMU_BIN``
     - 无
     - ``qemu-system-aarch64`` 路径
   * - ``QEMU_LD_LIBRARY_PATH``
     - 无
     - QEMU 依赖库路径
   * - ``QEMU_NET_MODE``
     - ``both``
     - ``both``/``tap``/``user``
   * - ``QEMU_SSH_FWD_PORT``
     - ``10022``
     - usernet SSH 转发端口
   * - ``QEMU_MACHINE_MEM_MB``
     - ``4096``
     - 虚拟机总内存
   * - ``QEMU_GUEST_MEM_MB``
     - ``3072``
     - Dom0 内存
   * - ``QEMU_SMP`` / ``QEMU_CPU``
     - ``4`` / ``cortex-a53``
     - vCPU 数与 CPU 型号
   * - ``QEMU_IMAGE_TAR``
     - 自动探测
     - RTOS 镜像 tar 路径
   * - ``QEMU_KEEP_RUNNING``
     - ``false``
     - 测试后是否保留 guest
   * - ``QEMU_SMOKE_SKIP_XEN_PROBE``
     - ``false``
     - 是否跳过 Xen 启动探针

K3s
---

.. list-table::
   :widths: 40 28 32
   :header-rows: 1

   * - 变量
     - 默认值
     - 说明
   * - ``K3S_BIN``
     - ``/usr/bin/k3s``
     - 边侧 K3s 二进制
   * - ``K3S_EDGE_CONTAINERD_MODE``
     - ``external``
     - ``external`` 用系统 containerd，``bundled`` 用 K3s 自带
   * - ``K3S_CONTAINERD_ADDRESS``
     - ``/run/containerd/containerd.sock``
     - external 模式的 socket
   * - ``K3S_EDGE_NODE_NAME``
     - ``qemu-aarch64``
     - Kubernetes 边侧节点名
   * - ``K3S_CLOUD_NETWORK_PARENT``
     - ``tap0``
     - Docker macvlan 父接口
   * - ``K3S_RUNTIME_CLASS_NAME``
     - ``micrun``
     - RuntimeClass 名称
   * - ``K3S_INCLUDE_INTERACTION``
     - ``true``
     - 无场景参数时是否含 ``interaction``
   * - ``K3S_INCLUDE_OTA``
     - ``false``
     - 无场景参数时是否含 ``ota``
   * - ``K3S_POD_WAIT_SECONDS``
     - ``120``
     - 等待 Pod ``Running`` 的超时
   * - ``K3S_ATTACH_TIMEOUT``
     - ``60``
     - ``kubectl attach`` 最大等待秒数
   * - ``K3S_INTERACTION_KEEP_POD``
     - ``false``
     - 交互测试后是否保留 Pod
   * - ``K3S_E2E_KEEP_POD``
     - ``false``
     - 云边测试后是否保留 Pod

完整变量清单见 mcs 仓的 ``micrun/tests/common/env.sh`` 与
``micrun/tests/k3s/README.md``。

测试边界与约束
==============

这些约束决定了一次测试结果是否可信，执行前请确认。

不修改构建产物
--------------

.. important::

   标准化测试**不得解包、修改或重新打包已构建好的 QEMU rootfs 产物**
   （如 ``openeuler-image-qemu-aarch64-*.rootfs.cpio.gz``）。

如果排障时确实需要在运行中的 guest 里临时补齐 ``/var/lib/xen``、
``/var/volatile/log``、``/var/log/xen`` 或 ``/run/xen``，只能把它记录为
**临时 guest 修复**，不能把修复后的 rootfs 当成测试基线。SSH 密钥、固定密码、
网络默认配置和 Xen 运行目录都应来自构建配置或明确的 guest 初始化步骤。

运行态修改范围
--------------

K3s 场景需要清理和重建运行中边侧节点的状态，这些属于**正常的运行态准备**，
不属于产物修改：

- 停止旧的 ``k3s``、``micrun-k3s-agent.service`` 和残留 shim
- 清理 bundled K3s state 或系统 containerd 中的旧 task
- 写入 bundled ``config.toml.tmpl`` 或系统 ``/etc/containerd/config.toml``
- 写入 K3s 和系统 CNI 配置
- 创建或更新边侧 agent systemd service
- 导入 pause 和 RTOS 镜像 tar

IO 回归同样会把当前工作区构建的 shim 部署进运行中的 guest 做验证。

敏感信息
--------

提交测试记录、日志或问题单前，确认没有写入真实宿主机绝对路径、sudo 密码、
guest 密码或访问密钥。用变量名和 ``<...>`` 占位符表达环境差异。

结果判读与失败定位
==================

按级别定位
----------

.. list-table::
   :widths: 24 76
   :header-rows: 1

   * - 失败级别
     - 首先怀疑
   * - L1 单元测试
     - 代码逻辑本身。与环境无关，可直接在开发机复现和调试
   * - L2 冒烟
     - QEMU 产物、Xen 工具栈、containerd 服务。此时不要去查 MicRun IO
   * - L2 生命周期
     - 状态机与资源清理路径。留意用例 5（fd/domain 泄漏）
   * - L3 IO
     - shim 的 IO 链路。先确认原生 ``mica`` 路径是否也能复现，以免把 micad 或 RTOS 固件问题误判成 MicRun 问题
   * - L4 K3s
     - 先看 ``preflight`` 环境预检是否通过；预检失败说明是集群环境问题，不是 MicRun 问题

常见现象
--------

.. list-table::
   :widths: 42 58
   :header-rows: 1

   * - 现象
     - 优先检查
   * - 边侧节点无法 SSH
     - ``tap0``、guest IP、``TEST_REMOTE_PASSWORD``、首次登录是否要求改密
   * - IO 套件报"未知 profile"
     - 这是真实回归，检查 shim 启动路径，不要当环境问题跳过
   * - Pod 卡在 ``ContainerCreating``
     - pause 镜像和 RTOS 镜像是否导入目标 containerd；external 模式还要检查 ``/etc/containerd/config.toml`` 的 ``sandbox_image``
   * - Pod 刚 ``Running`` 就被 ``Killing``
     - kubelet 因 Pod cgroup 不存在执行 ``killPod``，确认已设置 ``cgroups-per-qos=false`` 等参数
   * - ``kubectl attach`` 无输出
     - Pod 是否设置 ``stdin: true``；K3s 交互脚本默认 ``tty: false``
   * - Pod ``Running`` 但没有 Xen domain
     - 核对边侧 ``ctr`` 容器 ID 与 ``xl list``，以及 ``journalctl -u micad``
   * - 删除 Pod 后仍有 Xen domain
     - 核对 ``ctr -n k8s.io tasks ls`` 和 ``xl list`` 是否仍含同一 ID
   * - 下一轮测试出现旧 Pod 重建或 ``mica daemon reported failure``
     - 先停止旧 K3s agent/server，再清理 MicRun/micad 运行态

日志位置
--------

.. code-block:: bash

   # 测试脚本日志
   ls "${TEST_LOG_DIR:-/tmp/micrun-tests}"

   # QEMU 启动日志
   cat /tmp/micrun-qemu-lifecycle.log

   # guest 内的运行时日志（debug 构建）
   ssh "$TEST_REMOTE_HOST" 'cat /var/log/mica/mica-runtime.log'

   # guest 内的 micad 日志
   ssh "$TEST_REMOTE_HOST" 'journalctl -u micad -n 200'

更细的排查步骤见 :doc:`reference/troubleshooting`。

相关文档
========

- :doc:`quick-start` - 环境搭建与第一个容器
- :doc:`kubernetes/index` - 云边协同部署
- :doc:`reference/troubleshooting` - 故障排查
- :doc:`reference/annotations` - 注解参考
- :doc:`reference/configuration` - 配置参考
- `项目仓库 <https://atomgit.com/openeuler/mcs>`_ - 测试脚本源码位于 ``micrun/tests``

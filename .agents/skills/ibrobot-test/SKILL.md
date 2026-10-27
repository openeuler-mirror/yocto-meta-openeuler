---
name: ibrobot-test
description: 'IB-Robot 跨平台功能测试(qemu-aarch64 与真机昇腾)。覆盖：用 oebuild 构建带 oebridge/ibrobot/systemd 三特性的 qemu-aarch64 镜像、100G 大磁盘灌 rootfs、从盘启动 qemu、guest 内 setup.sh/build.sh/run_tests.sh(组件单测/colcon + inference 推理闭环冒烟,ACT 模型 zip)、qemu(无 NPU,AUTOLOAD=0)与真机(Ascend+CANN,torch_npu 加载)平台差异、torch_npu/ROS domain/跳过包互导/resnet18 等典型失败的诊断与修复。触发关键词：IB-Robot 测试、ibrobot test、qemu-aarch64 ibrobot、构建 ibrobot 镜像、oebridge ibrobot systemd、100G 磁盘、prep-disk、从盘启动、run_tests、inference、ACT 模型、torch_npu、ROS_DOMAIN_ID、真机测试。'
argument-hint: "描述任务，例如 '构建带 ibrobot 的 qemu-aarch64 镜像并测试' 或 '真机跑 ACT 推理闭环' 或 'IB-Robot 测试报 torch 错'"
---

# Skill: ibrobot-test — IB-Robot 跨平台测试(qemu-aarch64 / 真机昇腾)

本技能覆盖 IB-Robot 在 **qemu-aarch64**(无 NPU)与**真机**(Ascend NPU + CANN)上的功能测试：
从零构建带 IB-Robot 特性的 qemu 镜像、创建大容量磁盘、启动 qemu、并在 guest 内跑功能测试的完整闭环，以及真机上
跑 ACT 推理闭环（mock-sim + 策略），和调试中遇到的典型
失败（环境变量、torch_npu、ROS 域守卫、跳过包互导等）的诊断与修复。

> 关联文档：本技能目录附带 `TESTING_GUIDE.md`（完整测试指南）与
> `run_tests.sh`（测试脚本）；权威版本在 IB-Robot 仓库内。

---

## 0. 何时使用本技能

- 需要构建一个**自带 IB-Robot 运行环境**（ROS 2 Humble + LeRobot + oebridge）的 qemu-aarch64 镜像。
- 需要在 qemu-aarch64 上**测试 IB-Robot 各组件功能**（pytest + colcon gtest/gmock）。
- IB-Robot 测试报 `torch_npu`/`libhccl.so`/`ROS_DOMAIN_ID`/`ModuleNotFoundError`/`colcon test` 误报等。

---

## 1. 关键原理与约束

| 约束 | 说明 | 应对 |
|---|---|---|
| 默认 `-initrd rootfs.cpio.gz` 把 rootfs 解到**内存盘**(固定 ~7.2G,剩 ~2.9G) | 装不下 torch(~2G)+lerobot+构建产物(10G+) | **改用 100G 物理盘作根盘**(见 §3) |
| 镜像是**昇腾导向**(预装 torch_npu) | qemu 无 NPU、无 libhccl.so → torch 启动自动加载 torch_npu 失败 + SIGSEGV | 测试时 `export TORCH_DEVICE_BACKEND_AUTOLOAD=0` |
| 部分组件测试有** ROS 域隔离守卫** | 未设 domain env → 整批 setup 失败 | 强制 `ROS_DOMAIN_ID=42` 等(见 §5.1) |
| `build.sh --mixin dev` 用 `BUILD_TESTING=OFF` | C++ gtest/gmock 不编译 → colcon test "空通过" | 跑 C++ 测试前用 `-DBUILD_TESTING=ON` 重编(见 §4.3) |
| `colcon test` **即使 gtest 用例失败也 exit 0** | 凭退出码会误报 PASS | 解析 CTest 摘要 `X% tests passed, Y failed out of Z` |

---

## 2. 第 1 步：构建带 oebridge+ibrobot+systemd 三特性的 qemu-aarch64 镜像

镜像必须**主动带三个特性**：`oebridge`（包管理/host 环境）、`ibrobot`（IB-Robot ROS 集成）、
`systemd`（init 管理，IB-Robot 依赖）。三者通过 `INIT_MANAGER` + `DISTRO_FEATURES` 注入。

### 2.1 方式 A（推荐）：用 `oebridge-ibrobot` feature 生成

`oebridge-ibrobot` feature（`.oebuild/features/package_manager/oebridge-ibrobot.yaml`）已内置：
`INIT_MANAGER = "systemd"` + `DISTRO_FEATURES:append = " ibrobot oe-ros"`，且 `dependencies: [oebridge]`，
即一条命令带齐三特性。

```bash
# 在 oebuild 工作区（已 source .venv/bin/activate）
oebuild update                         # 刷新 layers（首次或更新后）
oebuild generate -p qemu-aarch64 -f oebridge-ibrobot
# → 生成 build/qemu-aarch64/compile.yaml
cd build/qemu-aarch64
oebuild bitbake openeuler-image        # 容器内构建（约 30-90 min）
```

### 2.2 方式 B：手写 compile.yaml（更可控）

参照 `3591rc-ibrobot.yaml` 改 `machine: qemu-aarch64`，落成 `build/qemu-aarch64/compile.yaml`：

```yaml
build_in: docker
machine: qemu-aarch64
toolchain_type: EXTERNAL_TOOLCHAIN:aarch64
no_layer: false
repos:
- yocto-poky
- yocto-meta-openembedded
- yocto-meta-ros                       # ROS 2 humble 源
local_conf: |+
  INIT_MANAGER = "systemd"             # 特性 1: systemd
  DISTRO_FEATURES:append = " oebridge oe-ros ibrobot "   # 特性 2+3: oebridge + ibrobot
  SERVER_MIRROR = "https://mirrors.tuna.tsinghua.edu.cn/openeuler"
  SERVER_VERSION = "openEuler-24.03-LTS"
  GLIBC_GENERATE_LOCALES:append = "en_US.UTF-8 zh_CN.UTF-8 "
  IMAGE_INSTALL:append = " glibc-binary-localedata-en-us glibc-binary-localedata-zh-cn "
layers:
- yocto-meta-openeuler/bsp/meta-hisilicon              # oebridge-ibrobot 镜像 bbappend 所在
- yocto-meta-openembedded/meta-multimedia              # ffmpeg（ibrobot 依赖）
docker_param:
  image: swr.cn-north-4.myhuaweicloud.com/openeuler-embedded/openeuler-container:latest
  parameters: -itd --network host --cap-add NET_ADMIN
  volumns:
  - /dev/net/tun:/dev/net/tun
  command: bash
bitbake_cmds:
- bitbake openeuler-image
```

```bash
cd build/qemu-aarch64 && oebuild bitbake openeuler-image
```

> 三特性对应关系：
> - `systemd` ← `INIT_MANAGER = "systemd"`
> - `oebridge` ← `DISTRO_FEATURES:append = " oebridge ..."`（packagegroup-oebridge）
> - `ibrobot` ← `DISTRO_FEATURES:append = " ... ibrobot "`（packagegroup-ibrobot.inc：opencv/ffmpeg/ros-humble-* /moveit 等）
>
> 镜像 bbappend `bsp/meta-hisilicon/recipes-core/images/openeuler-image.bbappend` 会按 `DISTRO_FEATURES ibrobot` 选择
> `oebridge-extra-command-ibrobot*.sh`（含 clone IB_Robot + setup.sh -y 的开机脚本，可选 `ibrobot-dev` 走开发态）。

### 2.3 产物

```
build/qemu-aarch64/output/<时间戳>/
├── zImage                                  # 内核（已内建 virtio_blk/ext4/virtio_net）
├── vmlinux                                 # 未压缩内核（可 grep 验证内建驱动）
├── Image
└── openeuler-image-qemu-aarch64-<ts>.rootfs.cpio.gz   # rootfs（含 ROS+oebridge+ibrobot 预装）
```

> 验证内核内建驱动（决定能否从盘启动）：
> ```bash
> grep -aoE 'virtio_blk|virtio_pci|virtio_mmio|ext4|virtio_net' vmlinux | sort | uniq -c
> ```
> 都有计数即可 `root=/dev/vda` 启动（openEuler aarch64 内核已内建）。

---

## 3. 第 2 步：创建大容量磁盘并灌入 rootfs

### 3.1 为什么必须用大磁盘

`-initrd rootfs.cpio.gz` 把 rootfs 解到内存盘（rootfs 类型，固定 ~7.2G），IB-Robot 的
torch/lerobot/构建产物动辄 10G+，必然爆盘。**用一块 100G 物理盘作根盘**，所有 apt/pip/build
都落盘且重启持久。

### 3.2 建盘 + 灌 rootfs（`prep-disk.sh`）

把 `prep-disk.sh` 放在镜像输出目录（与 zImage/rootfs.cpio.gz 同级），它**自动定位本目录的
`*.rootfs.cpio.gz`**、`losetup` 挂镜像、`mkfs.ext4`、解 cpio、改 root 密码、写 fstab、卸载：

```bash
cd build/qemu-aarch64/output/<ts>
qemu-img create -f raw ibrobot-disk.img 100G    # 稀疏盘，实际 0 字节起
sudo bash prep-disk.sh                           # 需 host sudo（losetup/mkfs/cpio）
```

`prep-disk.sh` 内容（自定位、可照抄）：

```bash
#!/bin/bash
set -euo pipefail
OUT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IMG="$OUT/ibrobot-disk.img"
CPIO="$(ls "$OUT"/openeuler-image-qemu-aarch64-*.rootfs.cpio.gz 2>/dev/null | head -1)"
MNT="/mnt/ibrobot-disk"; ROOTPW="Aarch64@Qemu"
[ "$(id -u)" = 0 ] || { echo "run with sudo"; exit 1; }
[ -n "$CPIO" ] || { echo "no rootfs cpio in $OUT"; exit 1; }
[ -f "$IMG" ] || qemu-img create -f raw "$IMG" 100G
DEV="$(losetup -fP --show "$IMG")"
mkfs.ext4 -F -m 1 "$DEV" >/dev/null 2>&1
mkdir -p "$MNT"; mount "$DEV" "$MNT"
cd "$MNT" && zcat "$CPIO" | cpio -idm >/dev/null 2>&1; cd - >/dev/null
# 设 root 密码 + 清掉强制改密（避免首登走 keyboard-interactive 改密流程）
chroot "$MNT" /bin/bash -c "echo 'root:$ROOTPW' | chpasswd && chage -m 0 -M 99999 -E -1 -W -1 -I -1 root && chage -d \"\$(date +%Y-%m-%d)\" root"
grep -q '^[^#].*[[:space:]]/[[:space:]]' "$MNT/etc/fstab" 2>/dev/null || echo '/dev/vda / ext4 defaults,rw 0 1' >> "$MNT/etc/fstab"
cd /; umount "$MNT"; losetup -d "$DEV"
echo "DONE: $IMG"
```

> 真实物理盘/分区：把 `IMG=...ibrobot-disk.img` 改成 `IMG=/dev/sdX`，启动命令 `-drive file=` 相应改 `/dev/sdX`。

---

## 4. 第 3 步：从盘启动 qemu（去 `-initrd`，`root=/dev/vda`）

```bash
cd build/qemu-aarch64/output/<ts>
sudo qemu-system-aarch64 -M virt-4.0 -m 20G -cpu cortex-a53 -smp 4 -kernel zImage \
  -append "root=/dev/vda rw rootfstype=ext4 rootwait init=/sbin/init console=ttyAMA0,115200" \
  -netdev bridge,br=br_qemu,id=net0 -device virtio-net-pci,netdev=net0 \
  -drive file=ibrobot-disk.img,format=raw,if=none,id=hd0 \
  -device virtio-blk-device,drive=hd0 -nographic
```

要点：
- **不再用 `-initrd`**；内核内建 virtio_blk+ext4，`root=/dev/vda` 直接挂盘为根。
- aarch64 virt 走 virtio-mmio，磁盘设备名是 `virtio-blk-device`（非 `virtio-blk-pci`）。
- 网络沿用 `bridge,br=br_qemu` + `virtio-net-pci`（与原命令一致），guest DHCP 得 192.168.122.20。
- console `ttyAMA0,115200` 配合 `-nographic`。
- 若启动报 `VFS: Unable to mount root fs`（理论上不会），把 `-initrd` 加回用 initramfs pivot。

> 备选（不改启动方式、最省事）：保留 `-initrd` + 加数据盘挂到 `/workspace`，clone/build 放盘上。
> 但系统 apt 仍落 rootfs（2.9G 紧张），**推荐用本节的根盘方案**。

---

## 5. 第 4 步：guest 内 IB-Robot 环境与构建

```bash
ssh root@192.168.122.20     # 密码 Aarch64@Qemu（prep-disk.sh 已设）
cd /IB_Robot                # 镜像若已预装（ibrobot 特性）则已在；否则：
# git clone -b master --single-branch --depth 1 https://atomgit.com/openeuler/IB_Robot.git && git config --global http.sslVerify false
./scripts/setup.sh -y        # venv(torch/lerobot)+rosdep+submodules+lerobot patches；20-60 min
source .shrc_local
./scripts/build.sh           # 默认 --mixin dev（BUILD_TESTING=OFF）；注意 build.sh 无 -y 参数！
```

> `build.sh` 在 openEuler 上会**跳过 6 个 CUDA/Gazebo-only 包**：`sim_models perception_service semantic_mapping vlm_task_planner manipulation_service embodied_bringup`。
> 若测试需它们的跨包导入，补建（见 §6.3）。

---

## 6. 第 5 步：跑测试（`run_tests.sh`）

> 本技能目录已附带 `run_tests.sh`（测试执行器）与 `TESTING_GUIDE.md`（完整测试指南）。
> 用法：把 `run_tests.sh` 拷到 IB-Robot 工作区根目录（它 `cd` 到自身目录、测 `src/`）再运行；
> 已构建的工作区直接 `./run_tests.sh ...`。详见 `TESTING_GUIDE.md`。

### 6.1 必设环境变量（决定能否跑通，缺一整批失败）

`run_tests.sh` 的 `setup_env()` 已内置；手动跑也须设：

```bash
export PYTEST_DISABLE_PLUGIN_AUTOLOAD=1       # 跳过 launch_testing 插件冲突
# TORCH_DEVICE_BACKEND_AUTOLOAD：仅 qemu（无昇腾 CANN）才设 0；真机有 CANN 不设。
# run_tests.sh 已内置 NPU 自适应（import torch_npu 探测）；手动跑才需：
export TORCH_DEVICE_BACKEND_AUTOLOAD=0         # ← 仅 qemu/无昇腾时；真机勿设
export ROS_DOMAIN_ID=42                        # 测试隔离域（强制，见下）
export IBROBOT_TEST_ROS_DOMAIN_ID=42
export ROS_LOCALHOST_ONLY=1                    # 强制！不能用 ${ROS_LOCALHOST_ONLY:-1}
source .shrc_local && source install/setup.sh  # 后者让生成消息 ibrobot_msgs 可 import
```

> ⚠️ `ROS_LOCALHOST_ONLY` 必须 `export =1` **强制覆盖**：`.shrc_local` 预设了 `0`，
> `${VAR:-1}` 在变量非空时不触发默认值，会沿用 0，导致 `safety_guard`/`skill_library`/
> `robot_skill_cli` 共 68 个用例在 setup 守卫处全挂。

### 6.2 命令

```bash
./run_tests.sh list                 # 列出 34 个组件及测试方法
./run_tests.sh <component> [args]   # 单组件
./run_tests.sh all [--no-build]     # 全量
./run_tests.sh build [pkgs...]     # 仅 colcon 构建
./run_tests.sh inference [--model <ACT.zip|dir>] [--platform qemu|real] [--no-inference]
                                    # mock-sim + ACT 推理闭环冒烟（见 §6.4）
```

### 6.3 C++ 组件跑 gtest（默认 dev 构建不编测试目标）

```bash
source .shrc_local
colcon build --packages-select so101_hardware lekiwi_hardware omni_wheel_controller \
  ibrobot_msgs lekiwi_description robot_description --merge-install --symlink-install \
  --cmake-args -Wno-dev -DCMAKE_BUILD_TYPE=Debug -DBUILD_TESTING=ON
./run_tests.sh all    # colcon test 跑 gtest/gmock/lint（lint 失败已忽略，只看功能）
```

补建跳过的 ament_python 包（解决跨包 `ModuleNotFoundError`）：

```bash
colcon build --packages-select vlm_task_planner manipulation_service semantic_mapping \
  perception_service embodied_bringup --merge-install --symlink-install
```

### 6.4 推理闭环测试（`inference` 子命令 + ACT 模型）

`run_tests.sh inference` 跑 mock-sim + ACT 策略闭环冒烟：契约 mock 发 mock 图像/关节 → ACT 策略推理 → 动作分发到 `/arm_position_controller/commands`，验证全链路。

> ⚠️ **前置：测试 ACT 推理前，请先自行下载 ACT 策略模型文件**（如 `ACT_1arm_2cam_banana_pick_v1_step_160000_distill_20260515.zip`），通过 `--model <path>` 传入（脚本自动解压到 `models/`、校验 `inference_manifest.json`）。
> **未提供模型时只能用 `--no-inference` 跑纯 mock**（组件测试 `list`/`all` 不需要模型）。模型 zip 通常由训练侧产出/发布，请向项目模型仓库或训练负责人获取。

```bash
# 真机（Ascend NPU + CANN）：完整推理闭环，ACT 模型 zip 自动解压到 models/
./run_tests.sh inference --model /path/to/ACT_1arm_2cam_banana_pick_v1_step_160000_distill_20260515.zip --platform real

# qemu（无 aarch64 CANN）：仅 mock（完整推理在 qemu 跑不了）
./run_tests.sh inference --no-inference --platform qemu
```

| 参数 | 说明 |
|---|---|
| `--model <ACT.zip\|dir>` | ACT 策略包；zip 自动解压到 `models/`、校验 `inference_manifest.json` |
| `--platform qemu\|real` | 显式平台（默认 auto/NPU 自适应） |
| `--no-inference` | 仅 mock（`with_inference:=false`），无需模型 |
| `--duration/--robot/--warmup` | 运行秒数（默认 60）/ robot_config（默认 so101_single_arm）/ 预热秒数（默认 20） |

**平台差异**：

| | qemu-aarch64 | 真机（Ascend+CANN） |
|---|---|---|
| 组件测试 | ✅ 大多过（torch CPU） | ✅ + Ascend 测试可跑 |
| 完整 ACT 推理闭环 | ❌ lerobot 策略工厂需 `libhccl.so`（aarch64 CANN），qemu 无 → 跑不了 | ✅ torch_npu 加载，~200ms/步 |

**真机离线前置（无外网）**：① **先下载 ACT 模型** zip，用 `--model` 传入（自动解压到 `models/`）；② ACT 的 resnet18 编码器需 `~/.cache/torch/hub/checkpoints/resnet18-f37072fd.pth`（torchvision 首次用会下载 → 离线机先缓存好）。

**真机实测基线**：`pipeline_policy_node` 加载 ACT（`deployment=cpu, backend=torch`）、`action_dispatcher` 收推理（100/chunk、~200ms/步）、`/arm_position_controller/commands` ~15-20Hz。

---

## 7. 故障根因分类与处置（核心调试经验）

失败按根因归 5 类，**前 3 类纯环境/脚本问题，后 2 类真实数据/版本依赖**。

### 7.1 类 A — torch_npu 后端在非昇腾 qemu 自动加载失败

- 症状：`RuntimeError: Failed to load backend extension: torch_npu` + `ImportError: libhccl.so` +
  `RuntimeError: Only a single TORCH_LIBRARY ... triton`；`inference_service` 还 `exit 139`(SIGSEGV)。
- 影响 9 组件：`robot_config/tensormsg/action_dispatch/inference_service/perception_service/attention_viz/dataset_tools/voice_asr_service/manipulation_service`。
- 修复：`export TORCH_DEVICE_BACKEND_AUTOLOAD=0`。

### 7.2 类 B — 测试隔离 ROS 域守卫未通过

- 症状：`safety_guard`(32)/`skill_library`(28)/`robot_skill_cli`(8) 全 `ERROR at setup`，
  `assert expected_domain is not None` / `assert ''.isdecimal()`。
- 根因：`ros_context` fixture 的 `_assert_test_ros_environment()` 要求显式声明隔离域。
- 修复：强制 `ROS_DOMAIN_ID=42 IBROBOT_TEST_ROS_DOMAIN_ID=42 ROS_LOCALHOST_ONLY=1`（注意 force）。

### 7.3 类 C — 跳过构建的包之间互相 import

- 症状：`No module named 'semantic_mapping'` / `'perception_service'`。
- 根因：6 个 CUDA/Gazebo-only 包被 build.sh 跳过（未进 install/），但测试互相 import。
- 修复：补建这 5 个 ament_python 包（§6.3）。

### 7.4 类 D — `run_tests.sh` 脚本 bug（已修复，需用最新版）

| bug | 修复 |
|---|---|
| 未 source `install/setup.sh` | setup_env 增 source |
| `run_colcon_test` 缺 `--merge-install` | 加 `--merge-install` |
| `colcon test` exit 0 误报 PASS | 解析 CTest 摘要行 |
| `colcon test-result` 跨包扫描误报 | 不用 test-result，按本次输出解析 |
| `${ROS_LOCALHOST_ONLY:-1}` 沿用 0 | 改 force `=1` |

### 7.5 类 E — 真实数据/硬件/版本依赖（qemu 上无法通过，**非代码 bug**）

| 组件 | 根因 | 处置 |
|---|---|---|
| `robot_config`(2/395) | 缺 `/IB_Robot/models/...` 模型 + 标定文件 | 提供数据或测试 skip |
| `inference_service` | 昇腾专用（需 ACL+Ascend FFmpeg） | 非 Ascend 测试已过；应加 skip 守卫 |
| `perception_service`/`dataset_tools` | `operator torchvision::nms does not exist` | torchvision/torch 版本不匹配，重装匹配版 |
| `robot_moveit` | `liburdfdom_sensor.so.4.0` 缺 | `dnf install urdfdom` 或加 `LD_LIBRARY_PATH=/opt/ros/humble/lib` |
| `robot_navigation`(1/133) | e2e 触发时序敏感 | 132/133 过，flaky/env 敏感 |
| `action_dispatch` | `No module named 'action_dispatch.base_executor'` | 过期测试导入，核对代码 |
| `omni_wheel_controller`(1/2) | vendored 测试夹具用旧插件名 `test_actuator`，已装 ros2_control 改名 `test_hardware_components/TestSingleJointActuator` | 控制器逻辑 gmock 过；可本地 patch 验证（子模块勿提交） |

---

## 8. 调试决策树

| 现象 | 判定 | 处置 |
|---|---|---|
| 报 `torch_npu`/`libhccl`/`triton TORCH_LIBRARY`/`exit 139` | 类 A | 确认 `TORCH_DEVICE_BACKEND_AUTOLOAD=0` |
| `safety_guard`/`skill_library`/`robot_skill_cli` 全 setup 失败 | 类 B | 强制设 ROS domain 三变量 |
| `No module named '<另一组件>'` | 类 C | 补建跳过包 |
| C++ 组件 `colcon test` 报 `merged layout` | 脚本 | `run_colcon_test` 加 `--merge-install` |
| C++ 组件 0 测试通过 | 构建 | `-DBUILD_TESTING=ON` 重编 |
| 组件报 PASS 但 gtest 实际失败 | 脚本 | 用 CTest 摘要解析（已含） |
| `operator torchvision::nms does not exist` | 版本 | 重装匹配版 torchvision |
| `liburdfdom_sensor.so.4.0 not found` | 系统库 | 装 urdfdom |
| `No module named 'ibrobot_msgs'` | 环境 | source `install/setup.sh` |
| pytest 收集报 `PluginValidationError` | 插件 | `PYTEST_DISABLE_PLUGIN_AUTOLOAD=1` |

---

## 9. 最终测试结果总账（参考基线）

`pass=21 / fail=8 / skip=5`（共 34 组件，约 1400+ 用例通过，lint 忽略）。

- **8 个 FAIL 全为环境/数据/版本类，无 IB-Robot 功能代码 bug**。
- C++ 6 组件全部功能正常（2 个仅 lint 失败、1 个仅 vendored 测试夹具版本错配，控制器逻辑 gmock 均过）。
- 详见本技能目录 `TESTING_GUIDE.md` 第 6 章。

---

## 10. Cheatsheet

```bash
# 宿主机：构建镜像（带 oebridge+ibrobot+systemd）
oebuild update && oebuild generate -p qemu-aarch64 -f oebridge-ibrobot
cd build/qemu-aarch64 && oebuild bitbake openeuler-image
# 产物：output/<ts>/{zImage, *.rootfs.cpio.gz}

# 宿主机：建大磁盘 + 灌 rootfs
cd output/<ts> && qemu-img create -f raw ibrobot-disk.img 100G && sudo bash prep-disk.sh

# 启动 qemu（从盘）
sudo qemu-system-aarch64 -M virt-4.0 -m 20G -cpu cortex-a53 -smp 4 -kernel zImage \
  -append "root=/dev/vda rw rootfstype=ext4 rootwait init=/sbin/init console=ttyAMA0,115200" \
  -netdev bridge,br=br_qemu,id=net0 -device virtio-net-pci,netdev=net0 \
  -drive file=ibrobot-disk.img,format=raw,if=none,id=hd0 \
  -device virtio-blk-device,drive=hd0 -nographic

# guest 内
ssh root@192.168.122.20   # Aarch64@Qemu
cd /IB_Robot && ./scripts/setup.sh -y && source .shrc_local && ./scripts/build.sh
# C++ 测试目标 + 补建跳过包
colcon build --packages-select so101_hardware lekiwi_hardware omni_wheel_controller ibrobot_msgs lekiwi_description robot_description --merge-install --symlink-install --cmake-args -Wno-dev -DBUILD_TESTING=ON
colcon build --packages-select vlm_task_planner manipulation_service semantic_mapping perception_service embodied_bringup --merge-install --symlink-install
# 测试（run_tests.sh 在本技能目录；拷到 IB-Robot 工作区根目录后运行）
cp .agents/skills/ibrobot-test/run_tests.sh /IB_Robot/ && chmod +x /IB_Robot/run_tests.sh
cd /IB_Robot && ./run_tests.sh list && ./run_tests.sh all
# 推理闭环：真机 ./run_tests.sh inference --model <ACT.zip> --platform real；qemu 用 --no-inference
./run_tests.sh inference --model /path/to/ACT.zip --platform real   # 真机
./run_tests.sh inference --no-inference --platform qemu             # qemu（仅 mock）
```

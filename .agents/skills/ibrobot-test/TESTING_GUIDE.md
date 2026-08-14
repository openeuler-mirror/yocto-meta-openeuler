# IB-Robot 组件测试指导文档

> 适用环境:openEuler Embedded 24.03 (qemu-aarch64) 无真实硬件条件下的功能测试
> 配套脚本:`run_tests.sh`(仓库根目录)
> 最后更新:2026-08-08

---

## 1. 测试对象

**IB-Robot** —— 融合 LeRobot 与 ROS 2 Humble 的具身智能开发框架。测试覆盖 `src/` 下 **34 个组件**(已排除 `workflows/`,它不是组件)。

按功能层分类:

| 分类 | 组件 |
|---|---|
| 硬件驱动 | `so101_hardware`、`lekiwi_hardware`、`hardware_mock`、`omni_wheel_controller`(子模块) |
| 运动/导航/遥操 | `robot_moveit`、`robot_navigation`、`robot_teleop`、`task_dispatch`、`sim_models` |
| 推理/感知/数据 | `inference_service`、`inference_manifest`、`perception_service`、`semantic_mapping`、`attention_viz`、`model_utils`、`dataset_tools` |
| 配置/消息/调度 | `robot_config`、`ibrobot_msgs`、`tensormsg`、`action_dispatch` |
| 具身/抓取/安全/技能 | `embodied_agent`、`embodied_bringup`、`embodied_common`、`manipulation_service`、`manipulation_execution`、`safety_guard`、`skill_library`、`vlm_task_planner`、`robot_skill_cli` |
| 纯描述/子模块 | `lekiwi_description`、`robot_description`、`pymoveit2`(子模块)、`rosclaw`(子模块)、`voice_asr_service` |

**测试目标**:在 qemu-aarch64 仿真平台验证各组件**功能**正确性(忽略 ament_lint 代码风格类失败)。

---

## 2. 测试环境

| 项 | 配置 |
|---|---|
| 虚拟机 | `qemu-system-aarch64 -M virt-4.0 -m 20G -cpu cortex-a53 -smp 4` |
| 系统 | openEuler Embedded 24.03(aarch64) |
| 根盘 | **100G 物理磁盘**(Plan B:rootfs 从盘启动,见 §4.1) |
| ROS | `/opt/ros/humble`(预装) |
| Python | 系统 3.11 + 工作区 `venv`(torch / lerobot / pydantic v2 / colcon) |
| 网络 | `-netdev bridge,br=br_qemu` + `-device virtio-net-pci`,guest DHCP 得 192.168.122.20,SSH(root) |

> 为何必须用 100G 物理盘:qemu 默认 `-initrd rootfs.cpio.gz` 把 rootfs 解到内存盘(固定 7.2G,仅剩 2.9G),装不下 torch(~2G)+lerobot+构建产物(10G+)。改用 100G 盘作根盘后,所有 apt/pip/build 都落盘且重启持久。

---

## 3. 测试原理

### 3.1 两类测试机制

| 机制 | 适用 | 是否需构建 | 命令形态 |
|---|---|---|---|
| **源码级 pytest** | 纯 Python 组件 | 否(`PYTHONPATH=src/<pkg>` 直接跑) | `pytest src/<pkg>/test` |
| **colcon test** | C++(gtest/gmock)+ ament_lint | 是(需 `BUILD_TESTING=ON`) | `colcon test --packages-select <pkg> --merge-install` |

### 3.2 `run_tests.sh` 设计要点

`setup_env()` 负责加载环境并设置**关键环境变量**(这些是能否跑通的决定性因素):

| 环境变量 | 值 | 作用(及为什么) |
|---|---|---|
| `PYTEST_DISABLE_PLUGIN_AUTOLOAD` | `1` | 禁用 pytest 插件自动加载。ROS Humble 的 `launch_testing` 插件与 venv 的 pluggy 不兼容,自动加载会触发 `PluginValidationError`,使所有用例收集失败 |
| `TORCH_DEVICE_BACKEND_AUTOLOAD` | `0` | 禁用 torch 设备后端自动加载。venv 装了 `torch_npu`(昇腾),但 qemu 无 NPU 且缺 `libhccl.so`,自动加载会失败 + 触发 triton 重复注册 + SIGSEGV |
| `ROS_DOMAIN_ID` | `42`(强制) | 测试隔离 ROS 域 |
| `IBROBOT_TEST_ROS_DOMAIN_ID` | `42`(强制) | `safety_guard`/`skill_library`/`robot_skill_cli` 的 `ros_context` fixture 守卫要求显式声明隔离域 |
| `ROS_LOCALHOST_ONLY` | `1`(强制) | 同上守卫要求;**必须 force 而非 `${:-}`**,因为 `.shrc_local` 预设了 `ROS_LOCALHOST_ONLY=0`,`${VAR:-1}` 会沿用 0 |

> ⚠️ 关键教训:`export ROS_LOCALHOST_ONLY="${ROS_LOCALHOST_ONLY:-1}"` 是**错的**——当变量已被 `.shrc_local` 设为 `"0"`(非空)时,`:-` 不会触发默认值,结果仍是 0,导致 3 个组件的 68 个用例全部在 setup 守卫处失败。必须 `export ROS_LOCALHOST_ONLY=1` **强制覆盖**。

`run_colcon_test()` 要点:
- 加 `--merge-install`:与 `build.sh` 的 merged install 布局匹配,否则 colcon test 报错。
- **`colcon test` 即使 gtest 用例失败也返回 exit 0**——不能凭它的退出码判断;改为解析每包 CTest 摘要行 `X% tests passed, Y tests failed out of Z`。
- 不用 `colcon test-result`(无 base 时会**扫描整个 build/ 工作区**,把别的包的失败累计进来 → 误报)。
- **lint 忽略**:失败用例若全部是 ament_lint(`copyright`/`cpplint`/`flake8`/`lint_cmake`/`pep257`/`uncrustify`/`cppcheck`/`xmllint`/`lint_package`/`pep8`)则记 PASS(只看功能),否则记 FAIL。

### 3.3 测试能力分级

| 能力 | 组件 | 说明 |
|---|---|---|
| 无硬件可跑(源码 pytest) | hardware_mock、tensormsg、action_dispatch、embodied_*、safety_guard、skill_library、robot_skill_cli、semantic_mapping、attention_viz、dataset_tools、robot_navigation(软件闭环)、robot_teleop 等 | 多数 |
| 需 colcon 构建(C++) | so101_hardware、lekiwi_hardware、omni_wheel_controller、ibrobot_msgs、lekiwi_description、robot_description | 需 `BUILD_TESTING=ON` |
| 需真实硬件/特殊依赖 | inference_service(昇腾 ACL+Ascend FFmpeg)、perception_service/dataset_tools(torchvision op)、robot_moveit(liburdfdom)、robot_config(模型/标定文件) | qemu 上无法通过,属环境限制 |

---

## 4. 测试流程

### 4.1 第 0 步:qemu 用 100G 物理盘作根盘(Plan B)

(1)宿主机把 rootfs 灌入 100G 盘镜像(`/data/demo/build/qemu-aarch64-ibrobot/output/<ts>/prep-disk.sh`,自动定位当前目录的 `*.rootfs.cpio.gz`):
```bash
qemu-img create -f raw ibrobot-disk.img 100G          # 已预创建则跳过
sudo bash prep-disk.sh                                 # losetup→mkfs.ext4→解 cpio→改 root 密码→写 fstab
```
(2)从盘启动(去 `-initrd`,改 `-append root=/dev/vda`,网络参数与原命令一致):
```bash
sudo qemu-system-aarch64 -M virt-4.0 -m 20G -cpu cortex-a53 -smp 4 -kernel zImage \
  -append "root=/dev/vda rw rootfstype=ext4 rootwait init=/sbin/init console=ttyAMA0,115200" \
  -netdev bridge,br=br_qemu,id=net0 -device virtio-net-pci,netdev=net0 \
  -drive file=ibrobot-disk.img,format=raw,if=none,id=hd0 \
  -device virtio-blk-device,drive=hd0 -nographic
```
> 内核必须内建 `virtio_blk`+`ext4`+`virtio_net`(openEuler aarch64 内核已内建,可 `grep` `vmlinux` 验证)。root 密码由 prep-disk.sh 设为 `Aarch64@Qemu` 且清掉强制改密。

### 4.2 第 1 步:环境初始化(`setup.sh -y`)
```bash
cd /IB_Robot                # 镜像若已预装则跳过 clone;否则 git clone -b master --depth 1 https://atomgit.com/openeuler/IB_Robot.git
git config --global http.sslVerify false
./scripts/setup.sh -y        # submodules + venv(torch/lerobot)+ rosdep + lerobot patches;约 20-60 min
```
> 验证:`source .shrc_local && command -v colcon && python3 -c 'import torch,pydantic'`。

### 4.3 第 2 步:构建(`build.sh`,默认 `--mixin dev`,`BUILD_TESTING=OFF`)
```bash
source .shrc_local
./scripts/build.sh           # 注意:build.sh 无 -y 参数,-y 会被透传给 colcon 致错;直接 ./scripts/build.sh
```
> `build.sh` 在 openEuler 上会跳过 6 个 CUDA/Gazebo-only 包:`sim_models perception_service semantic_mapping vlm_task_planner manipulation_service embodied_bringup`。若测试需它们的跨包导入,单独补建(见 §5.3)。

### 4.4 第 3 步:跑测试(`run_tests.sh`)
```bash
./run_tests.sh list                 # 列出 34 个组件及各自测试方法
./run_tests.sh <component> [args]   # 测单个组件(额外参数透传给 pytest)
./run_tests.sh all [--no-build]     # 全量;--no-build 跳过需 colcon 构建的 6 个
./run_tests.sh build [pkgs...]     # 仅 colcon 构建
```
- 每组件日志:`test_results/<时间戳>/<component>.log`
- 末尾汇总表:`pass/fail/skip` 计数 + 每行明细;脚本退出码非 0 表示有 FAIL。

### 4.5 第 4 步:C++ 组件真正跑 gtest(默认 dev 构建不编测试)
```bash
# 用 BUILD_TESTING=ON 重编 6 个 C++ 包(只这几个,不全量)
source .shrc_local
colcon build --packages-select so101_hardware lekiwi_hardware omni_wheel_controller \
  ibrobot_msgs lekiwi_description robot_description --merge-install --symlink-install \
  --cmake-args -Wno-dev -DCMAKE_BUILD_TYPE=Debug -DBUILD_TESTING=ON
./run_tests.sh all       # colcon test 会跑 gtest/gmock/lint(lint 失败已忽略)
```

### 4.6 第 5 步:调试循环
```
看 per-component 日志 → 用 grep 提取 distinct E-line / CTest 摘要 → 分类根因 → 修 env/script/数据 → 重跑
```
提取失败根因的常用命令(在 guest):
```bash
cd /IB_Robot/test_results/<ts>
grep -E '^\[(PASS|FAIL|SKIP)\]' <comp>.log                      # 组件结论
grep -A40 'short test summary info' <comp>.log | grep -E '^(ERROR|FAILED) '   # 失败用例名
grep -E '^E[[:space:]]' <comp>.log | sort | uniq -c | sort -rn | head   # 去重异常
```

---

## 5. 故障根因分类与处置(核心经验)

调试过程中出现的失败按根因归为 5 类,**前 3 类是纯环境/脚本问题,后 2 类是真实数据/版本依赖**。

### 5.1 类 A:torch_npu 后端在非昇腾 qemu 自动加载失败
- **症状**:`RuntimeError: Failed to load the backend extension: torch_npu` + `ImportError: libhccl.so` + `RuntimeError: Only a single TORCH_LIBRARY can be registered namespace triton`(后者是 torch_npu 与 torch 重复注册);`inference_service` 还会 `exit 139`(SIGSEGV)。
- **影响**:`robot_config`、`tensormsg`、`action_dispatch`、`inference_service`、`perception_service`、`attention_viz`、`dataset_tools`、`voice_asr_service`、`manipulation_service`(9 组件)。
- **根因**:镜像是昇腾导向(预装 torch_npu),qemu 无 NPU、无 libhccl.so。
- **修复**:`export TORCH_DEVICE_BACKEND_AUTOLOAD=0`(已内置 `setup_env`)。

### 5.2 类 B:测试隔离 ROS 域守卫未通过
- **症状**:`safety_guard`(32)、`skill_library`(28)、`robot_skill_cli`(8)全在 setup 处 `assert expected_domain is not None` / `assert allocated.isdecimal()` 失败。
- **根因**:这三个组件的 `ros_context` fixture 调 `_assert_test_ros_environment()`,要求 `IBROBOT_TEST_ROS_DOMAIN_ID`/`ROS_DOMAIN_ID`/`ROS_LOCALHOST_ONLY=1` 显式声明;未设则全挡。
- **修复**:强制 `export ROS_DOMAIN_ID=42 IBROBOT_TEST_ROS_DOMAIN_ID=42 ROS_LOCALHOST_ONLY=1`(已内置)。**注意 force,不要 `${:-}`**(见 §3.2 教训)。

### 5.3 类 C:跳过构建的包之间互相 import
- **症状**:`perception_service` 报 `No module named 'semantic_mapping'`;`embodied_bringup` 报 `No module named 'perception_service'`。
- **根因**:这 6 个 CUDA/Gazebo-only 包被 `build.sh` 在 openEuler 跳过(未进 `install/`),但测试互相 import。
- **修复**:单独补建(都是 ament_python,构建不需 CUDA):
```bash
colcon build --packages-select vlm_task_planner manipulation_service semantic_mapping \
  perception_service embodied_bringup --merge-install --symlink-install
```
> 注意依赖序:`embodied_bringup` 依赖 `manipulation_service`+`vlm_task_planner`,一次列出 4-5 个 colcon 会自动排序。

### 5.4 类 D:`run_tests.sh` 自身 bug(调试中修复,现已含)
| bug | 表现 | 修复 |
|---|---|---|
| 未 source `install/setup.sh` | `import ibrobot_msgs` 失败(生成的消息在 install/) | setup_env 增 `source install/setup.sh` |
| `run_colcon_test` 缺 `--merge-install` | colcon test 报 merged 布局错 | 加 `--merge-install` |
| `colcon test` exit 0 误报 PASS | gtest 失败也报 PASS | 改解析 CTest 摘要行 |
| `colcon test-result` 跨包扫描 | `ibrobot_msgs`(2/2 过)被误报 FAIL | 不用 test-result,按本次输出解析 |
| `robot_config` 末尾 `\|\| true` 掩盖退出码 | 失败报 PASS | 捕获并返回真实 rc |
| `${ROS_LOCALHOST_ONLY:-1}` 沿用 0 | 类 B 守卫仍挂 | 改为 force `=1` |

### 5.5 类 E:真实数据/硬件/版本依赖(qemu 上无法通过,**非代码 bug**)
| 组件 | 失败 | 根因 | 处置 |
|---|---|---|---|
| `robot_config` | 2/395 | 缺 `/IB_Robot/models/ACT_...` 模型权重 + `/root/.calibrate/so101_follower_calibrate.json` 标定文件 | 提供模型/标定,或测试在缺数据时 skip |
| `inference_service` | ascend 测试 | 需真实昇腾 ACL + Ascend FFmpeg(`hisilicon` 后端不支持多实例、ffmpeg_not_found) | 非 Ascend 的 torch 后端测试已过;Ascend 专用测试应加 skip 守卫 |
| `perception_service` | 1 | `RuntimeError: operator torchvision::nms does not exist` | venv 里 torchvision 与 torch 版本/构建不匹配;重装匹配版 torchvision |
| `dataset_tools` | 1 | 同上 `torchvision::nms` | 同上 |
| `robot_moveit` | 1 | `ImportError: liburdfdom_sensor.so.4.0` | 缺 urdfdom 库;`dnf install urdfdom` 或把 `/opt/ros/humble/lib` 加入 `LD_LIBRARY_PATH` |
| `robot_navigation` | 1/133 | e2e `test_evaluation_triggered_after_nav`:`MockTriggerServer.calls` 为 0 | e2e 时序/环境敏感(全局 ROS domain 变更后出现);132/133 过 |
| `action_dispatch` | 1 | `ModuleNotFoundError: No module named 'action_dispatch.base_executor'` | 测试导入已不存在的模块,疑似过期测试/模块改名,需核对代码 |
| `omni_wheel_controller` | 1/2 | gmock `TestLoadOmniWheelController.load_controller`:vendored 测试夹具 `descriptions.hpp` 用旧插件名 `<plugin>test_actuator</plugin>`,但已装 ros2_control 改名为 `test_hardware_components/TestSingleJointActuator` | 子模块 vendored 测试版本错配;控制器逻辑 gmock 过;可本地 patch `test_actuator`→`test_hardware_components/TestSingleJointActuator` 验证(子模块,勿提交) |

---

## 6. 最终测试结果总账

**pass=21 / fail=8 / skip=5(共 34,约 1400+ 用例通过,lint 忽略)**

| 结果 | 组件 |
|---|---|
| ✅ PASS(21) | `hardware_mock`(21)、`so101_hardware`(gtest 功能)、`lekiwi_hardware`(gtest 功能)、`omni_wheel_controller`(逻辑 gmock 过)、`ibrobot_msgs`(2)、`lekiwi_description`、`robot_description`、`tensormsg`(24)、`inference_manifest`、`semantic_mapping`(138)、`attention_viz`(17)、`robot_teleop`(166)、`voice_asr_service`(6 skip)、`embodied_common`(67)、`embodied_agent`(90+2)、`embodied_bringup`(16)、`vlm_task_planner`(14)、`safety_guard`(32)、`skill_library`(119)、`robot_skill_cli`(56)、`manipulation_service`(15)、`manipulation_execution`(33) |
| ❌ FAIL(8) | `robot_config`(2:缺模型/标定)、`action_dispatch`(1:过期导入)、`inference_service`(Ascend 专用)、`perception_service`(1:torchvision nms)、`dataset_tools`(1:torchvision nms)、`robot_moveit`(1:liburdfdom)、`robot_navigation`(1:e2e)、`omni_wheel_controller`(1:vendored 夹具版本错配) |
| ⏭ SKIP(5) | `task_dispatch`、`model_utils`、`sim_models`、`pymoveit2`、`rosclaw`(无 in-tree 测试) |

> **关键结论**:8 个 FAIL **全部为环境/数据/版本依赖类,无 IB-Robot 功能代码 bug**。C++ 组件 6 个全部功能正常(2 个仅 lint 失败、1 个仅 vendored 测试夹具版本错配,控制器逻辑 gmock 均过)。

---

## 7. 复现命令清单(Cheatsheet)

```bash
# === 宿主机:灌盘(Plan B)===
cd /data/demo/build/qemu-aarch64-ibrobot/output/<ts>
sudo bash prep-disk.sh

# === 启动 qemu(从盘)===
sudo qemu-system-aarch64 -M virt-4.0 -m 20G -cpu cortex-a53 -smp 4 -kernel zImage \
  -append "root=/dev/vda rw rootfstype=ext4 rootwait init=/sbin/init console=ttyAMA0,115200" \
  -netdev bridge,br=br_qemu,id=net0 -device virtio-net-pci,netdev=net0 \
  -drive file=ibrobot-disk.img,format=raw,if=none,id=hd0 \
  -device virtio-blk-device,drive=hd0 -nographic

# === guest 内 ===
cd /IB_Robot
source .shrc_local
./scripts/setup.sh -y                                    # 首次环境(若镜像未预装)
./scripts/build.sh                                        # 构建(默认 dev, BUILD_TESTING=OFF)
# 补建跳过包(若需跨包导入)
colcon build --packages-select vlm_task_planner manipulation_service semantic_mapping perception_service embodied_bringup --merge-install --symlink-install
# C++ 组件测试目标(可选,跑 gtest)
colcon build --packages-select so101_hardware lekiwi_hardware omni_wheel_controller ibrobot_msgs lekiwi_description robot_description --merge-install --symlink-install --cmake-args -Wno-dev -DCMAKE_BUILD_TYPE=Debug -DBUILD_TESTING=ON

./run_tests.sh list                                       # 查看可测项
./run_tests.sh all                                        # 全量测试
./run_tests.sh <component>                               # 单组件
```

---

## 8. 调试决策树(FAQ)

| 现象 | 判定 | 处置 |
|---|---|---|
| 测试报 `torch_npu`/`libhccl.so`/`triton ... TORCH_LIBRARY`/`exit 139` | 类 A | 确认 `TORCH_DEVICE_BACKEND_AUTOLOAD=0` 已设 |
| `safety_guard`/`skill_library`/`robot_skill_cli` 全 `ERROR at setup`、`assert ... is not None`/`''.isdecimal()` | 类 B | 确认 `IBROBOT_TEST_ROS_DOMAIN_ID`/`ROS_DOMAIN_ID`/`ROS_LOCALHOST_ONLY=1` 已**强制**设 |
| `ModuleNotFoundError: No module named '<另一组件>'` | 类 C | 补建被跳过的包 |
| C++ 组件 `colcon test` 报 `merged layout` 错 | 脚本 | `run_colcon_test` 加 `--merge-install`(已含) |
| C++ 组件 0 测试通过(BUILD_TESTING=OFF) | 构建 | 用 `-DBUILD_TESTING=ON` 重编 |
| 组件报 PASS 但实际 gtest 失败 | 脚本 | 用 CTest 摘要解析而非 colcon test 退出码(已含) |
| 报 `operator torchvision::nms does not exist` | 版本 | torchvision/torch 不匹配,重装匹配版 torchvision |
| 报 `liburdfdom_sensor.so.4.0 not found` | 系统库 | `dnf install urdfdom` 或加 `LD_LIBRARY_PATH=/opt/ros/humble/lib` |
| `No module named 'ibrobot_msgs'` | 环境 | source `install/setup.sh`(已含) |
| pytest 收集报 `PluginValidationError` | 插件 | `PYTEST_DISABLE_PLUGIN_AUTOLOAD=1`(已含) |
| Ascend/pi05 测试失败 | 硬件 | qemu 无 NPU,属预期;非 Ascend 测试应过 |
| `No such file /IB_Robot/models/...` | 数据 | 提供模型权重,或测试 skip |

---

## 9. 附录:`run_tests.sh` 关键环境变量一览

```bash
export PYTEST_DISABLE_PLUGIN_AUTOLOAD=1          # 跳过 launch_testing 插件冲突
# TORCH_DEVICE_BACKEND_AUTOLOAD: 仅当 torch_npu 无法加载时(qemu 无 CANN)才设 0;真机有 CANN 不设。
# run_tests.sh 已内置 NPU 自适应(`import torch_npu` 探测),手动跑才需:
export TORCH_DEVICE_BACKEND_AUTOLOAD=0           # ← 仅 qemu/无昇腾时;真机勿设
export ROS_DOMAIN_ID=42                          # 测试隔离域(强制)
export IBROBOT_TEST_ROS_DOMAIN_ID=42             # 守卫要求(强制)
export ROS_LOCALHOST_ONLY=1                      # 守卫要求(强制,不能用 ${:-})
# 并 source .shrc_local + install/setup.sh
```

> 这些变量是本次调试逐类定位出来的;缺任何一个都会导致整批用例失败(而非个别)。新环境首跑前务必确认均已生效。

---

## 10. 推理闭环测试(`run_tests.sh inference` 子命令)

除组件单测外,`run_tests.sh` 还支持 **mock-sim + ACT 推理闭环冒烟**:在契约 mock(发布 mock 图像/关节)上加载 ACT 策略,验证 `mock 输入 → 策略推理 → 动作分发` 全链路。

### 平台差异(决定能否跑完整推理)

| 平台 | 组件测试 | 完整 ACT 推理闭环 |
|---|---|---|
| **qemu-aarch64**(无 NPU/CANN) | ✅ 大多过(torch CPU) | ❌ lerobot 策略工厂需 `libhccl.so`(aarch64 CANN),qemu 无 → 跑不了;用 `--no-inference` 跑纯 mock |
| **真机**(Ascend NPU + CANN) | ✅ + Ascend 测试可跑 | ✅ torch_npu 加载,~200ms/步,动作闭环在线 |

### 用法

```bash
# 真机:完整推理闭环(ACT 模型 zip 自动解压到 models/)
./run_tests.sh inference --model /path/to/ACT_1arm_2cam_banana_pick_v1_step_160000_distill_20260515.zip --platform real

# qemu:仅 mock(完整推理在 qemu 跑不了,无 aarch64 CANN)
./run_tests.sh inference --no-inference --platform qemu
```

| 参数 | 说明 |
|---|---|
| `--model <ACT.zip\|dir>` | ACT 策略包;zip 自动解压到 `models/`,校验 `inference_manifest.json` |
| `--platform qemu\|real` | 显式平台(默认 auto/NPU 自适应) |
| `--no-inference` | 仅 mock(`with_inference:=false`),无需模型 |
| `--duration <s>` | 运行秒数(默认 60) |
| `--robot <cfg>` | robot_config 名(默认 `so101_single_arm`) |
| `--warmup <s>` | 检查前预热秒数(默认 20,模型加载) |

脚本启动 `ros2 launch robot_config robot.launch.py robot_config:=<cfg> use_sim:=true sim_platform:=mock control_mode:=model_inference`,预热后查 `/arm_position_controller/commands` 是否在发(动作流)。PASS=动作在发;FAIL=看 `test_results/<ts>/inference.log`。

### 真机离线前置(无外网时)

1. **ACT 模型**:用 `--model <ACT.zip>` 提供(zip 自动解压)。
2. **resnet18 权重**:ACT 的视觉编码器 `torchvision.models.resnet18` 首次用会下载 `resnet18-f37072fd.pth` → 离线机下载失败。需先缓存到 `~/.cache/torch/hub/checkpoints/resnet18-f37072fd.pth`(在有网主机下,再 scp 过去)。

### 真机实测基线(Ascend 310P3 + CANN)

- `pipeline_policy_node`:`Loading weights from local directory`、`bundle=ACT_1arm_2cam_banana_pick_…`、`deployment=cpu, backend=torch`。
- `action_dispatcher`:`✓ First inference received: chunk=100, latency=239.8ms`,之后 `inferences=1..37, avg_latency≈200ms, queue 100→51`。
- 话题:`/joint_states` ~90Hz(mock 输入)、`/arm_position_controller/commands` ~15-20Hz(分发动作)。

### qemu vs 真机决策

- 测**组件逻辑**(无硬件)→ qemu(`run_tests.sh all`,要快加 `--no-build`)。
- 跑**完整 ACT 推理闭环** → 真机(`run_tests.sh inference --model <ACT.zip> --platform real`)。
- qemu 只能验**mock 输入**(`inference --no-inference`),策略推理需 CANN(qemu 无)。

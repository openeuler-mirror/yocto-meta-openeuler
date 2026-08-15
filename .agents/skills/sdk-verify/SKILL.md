---
name: sdk-verify
description: 验证 openEuler Embedded SDK 安装包（do_populate_sdk 产物）是否支持内核驱动与用户态 C/C++ 应用开发。一键脚本自动完成 SDK 安装、交叉编译测试程序与内核模块、经 oebuild runqemu nographic 启动 qemu 镜像、scp 传输产物并 SSH 验证，覆盖 qemu-aarch64/qemu-arm/qemu-riscv64 全部 qemu 平台。使用时机：SDK 生成或改动（PACKAGECONFIG、TOOLCHAIN_HOST_TASK、OPENEULER_FULL_SDK_ENABLE 等）后的功能回归验证。触发关键词：SDK 验证、验证 SDK、sdk verify、内核模块编译、交叉编译测试、toolchain 验证、hello_mod、do_populate_sdk 验证。
---

# SDK 验证 (sdk-verify)

## 目标

以 qemu-<arch> 镜像为运行目标，端到端验证 SDK 三项能力：

1. 用户态 C 程序交叉编译并运行
2. 用户态 C++ 程序交叉编译并运行（libstdc++ 动态链接）
3. 内核驱动模块编译（依赖 sysroot 中 kernel-devsrc）并 insmod 加载

## 适用范围与假设

- 平台：qemu-aarch64 / qemu-arm / qemu-riscv64（openEuler Embedded 全部 qemu 平台）
- **镜像已预设 root 密码（默认 `openEuler@2021`）**：本技能不修改 /etc/shadow、
  不做 init=/bin/sh 等登录 hack；密码默认 `openEuler@2021`，可用 `-p` 覆盖
- **QEMU 由 `oebuild runqemu nographic` 启动**（Docker 容器内执行，tap 网络
  guest=192.168.7.2）：qemu 二进制来自构建产物的 qemu-helper-native
  recipe-sysroot，宿主无需安装 qemu-system-<arch> 包
- **测试产物经 scp 传输**（镜像含 openssh-sshd 与预设密码，网络可达），
  不解包 rootfs、不依赖 ext4 与 debugfs
- 宿主前置条件：`sshpass` 或 OpenSSH ≥ 8.4（SSH_ASKPASS 机制，无需额外包）、
  `oebuild`（workspace/.venv/bin/oebuild）、Docker、`/dev/net/tun`、`file`
- 构建产物前提：`build/<machine>/tmp/deploy/` 下已有 SDK 安装脚本
  `*toolchain*.sh` 与镜像产物 `*.qemuboot.conf` + `*.rootfs.*`
  （默认 cpio.gz，ext4 亦可）

## 一键验证

```bash
SKILL=.agents/skills/sdk-verify

# 基本用法（root 密码默认 openEuler@2021，SDK 未安装时自动安装到 ~/sdk-<machine>）
bash $SKILL/scripts/verify-sdk.sh -m qemu-aarch64

# 密码不同时用 -p 覆盖；指定已安装 SDK 目录与构建目录可跳过 SDK 安装与产物发现
bash $SKILL/scripts/verify-sdk.sh -m qemu-riscv64 -p '<root密码>' \
    -s ~/sdk-qemu-riscv64 -b ~/openeuler/openeuler/workspace/build/qemu-riscv64
```

### 参数

| 参数 | 默认 | 说明 |
|---|---|---|
| `-m` | qemu-aarch64 | 平台：qemu-aarch64 / qemu-arm / qemu-riscv64 |
| `-p` | openEuler@2021 | 镜像预设的 root 密码（可覆盖默认值） |
| `-s` | 自动发现 | SDK 安装脚本 `*.sh` 或已安装 SDK 目录 |
| `-b` | 自动发现 | `build/<machine>` 构建目录 |
| `-d` | `~/sdk-verify-<machine>` | 工作目录（产物与日志） |

### 通过判定（全部满足）

- `insmod` 输出 `MODULE_INSMOD_OK` 且 `/proc/modules` 显示 `hello_mod ... Live`
- C 程序输出 `Hello from SDK-built C program`
- C++ 程序输出 `Hello from SDK-built C++ program: SDK C++ works`
- 验证命令完整执行到 `====VERIFY_DONE====`

脚本输出 `==== SDK 验证 PASS ====` 且退出码 0 即通过；完整 SSH 会话输出保存于
工作目录 `verification.log`。

## 平台参数表（脚本内置，改动平台时按此扩展）

| 平台 | ARCH | sysroot |
|---|---|---|
| qemu-aarch64 | arm64 | aarch64-openeuler-linux |
| qemu-arm | arm | arm-openeuler-linux |
| qemu-riscv64 | riscv | riscv64-openeuler-linux |

- QEMU 启动参数（机器、串口、rootfs 等）全部由 `oebuild runqemu` 按镜像产物
  `*.qemuboot.conf` 自动处理，脚本无需维护；tap 网络 guest 固定 192.168.7.2
- 环境脚本：`environment-setup-<sysroot>`（如 `environment-setup-aarch64-openeuler-linux`）
- 内核模块 `ARCH`：arm64 / arm / riscv（`CROSS_COMPILE` 直接取环境变量）

## 脚本执行流程

1. **定位产物**：`tmp/deploy/sdk/*toolchain*.sh`、`tmp/deploy/images/<machine>/`
   `*.qemuboot.conf` 与 `*.rootfs.*`；oebuild 定位 workspace/.venv/bin/oebuild
   （fallback PATH）
2. **SDK 准备**：已安装目录直接复用；否则 `bash <sdk.sh> -y -d ~/sdk-<machine>`；
   **安装路径必须短**（ELF 重定位约束，约 ≤90 字符，如 `~/sdk-aarch64`，
   过长会报 relocation 失败）
3. **交叉编译**：`source environment-setup-<sysroot>` → `$CC` 编译 test-app.c、
   `$CXX` 编译 test-app.cpp；`test-kmod.c` 复制为 `hello_mod.c`（obj-m 需与
   源文件同名），按脚本生成的 Makefile 执行 `make`（注入 KERNELDIR/ARCH/CROSS_COMPILE）
4. **ELF 校验**：`file` 检查 hello / hello_cpp / hello_mod.ko 架构
5. **启动 QEMU**：`oebuild runqemu nographic` 在构建目录后台启动（容器内执行，
   tap 网络）；先清理残留 qemu 实例防 tap0/端口冲突
6. **等待就绪**：ping guest 192.168.7.2（最长约 4 分钟）→ 探测 22 端口
   （最长约 90s）确认 sshd 就绪
7. **scp 传输**：`sshpass` 将 hello / hello_cpp / hello_mod.ko 传到 guest `/root/`
8. **运行验证**：SSH 登录 → `insmod` → `cat /proc/modules` → 运行 C/C++ 程序
   → `poweroff -f`（guest 关机导致 ssh 断开属正常）
9. **判定**：关键字匹配 verification.log，输出 PASS/FAIL

## 手动验证（不跑脚本时）

```bash
# 1. 安装 SDK（短路径）并 source
bash tmp/deploy/sdk/*toolchain*.sh -y -d ~/sdk-riscv64
source ~/sdk-riscv64/environment-setup-riscv64-openeuler-linux

# 2. 交叉编译
$CC -O2 test-app.c -o hello && $CXX -O2 test-app.cpp -o hello_cpp
cp test-kmod.c hello_mod.c   # obj-m=hello_mod.o 需要同名源文件
cat > Makefile <<'EOF'
KERNELDIR := $SDKTARGETSYSROOT/usr/src/kernel
ARCH := riscv
CROSS_COMPILE := $CROSS_COMPILE
obj-m := hello_mod.o
all:
	$(MAKE) -C $(KERNELDIR) M=$(PWD) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) modules
EOF
make   # 生成 hello_mod.ko

# 3. 启动 QEMU（oebuild runqemu nographic，容器内 tap 网络 guest=192.168.7.2）
cd build/qemu-riscv64
nohup script -q -e -c "$HOME/openeuler/openeuler/workspace/.venv/bin/oebuild runqemu nographic" \
    qemu-pty.log > qemu.log &

# 4. 等待 guest 网络与 sshd 就绪（ping 192.168.7.2；探测 22 端口）

# 5. scp 传输 + SSH 验证（密码经环境变量传递；以下为 SSH_ASKPASS 方式，
#    无 sshpass 时亦可用；脚本会自动选择）
cat > askpass.sh <<'EOF'
#!/bin/sh
echo "$SDK_VERIFY_PASSWORD"
EOF
chmod 700 askpass.sh
SSH_ASKPASS=$PWD/askpass.sh SSH_ASKPASS_REQUIRE=force SDK_VERIFY_PASSWORD=openEuler@2021 \
    setsid -w scp -o StrictHostKeyChecking=no hello hello_cpp hello_mod.ko root@192.168.7.2:/root/
SSH_ASKPASS=$PWD/askpass.sh SSH_ASKPASS_REQUIRE=force SDK_VERIFY_PASSWORD=openEuler@2021 \
    setsid -w ssh -o StrictHostKeyChecking=no root@192.168.7.2 \
    'insmod /root/hello_mod.ko && echo MODULE_INSMOD_OK; cat /proc/modules | grep hello_mod; /root/hello; /root/hello_cpp; poweroff -f'
```

## 测试文件

| 文件 | 内容 |
|---|---|
| `scripts/test-app.c` | 用户态 C：printf 标识输出 |
| `scripts/test-app.cpp` | 用户态 C++：std::vector<std::string> 遍历输出（验证 libstdc++ 头与动态链接） |
| `scripts/test-kmod.c` | 内核模块：printk 加载/卸载日志（脚本复制为 hello_mod.c 参与编译） |
| Makefile 模板 | 由脚本生成，注入 KERNELDIR/ARCH/CROSS_COMPILE |

## 常见问题

| 问题 | 处理 |
|---|---|
| SDK 安装报 relocation / ELF interpreter 错误 | 安装路径过长，改短路径（`~/sdk-<machine>` 或 `/opt/sdk-<machine>`） |
| oebuild 报 `No module named 'oebuild'` | PATH 中 oebuild 指向系统 python3；脚本自动使用 workspace/.venv/bin/oebuild，手动执行前先 `source workspace/.venv/bin/activate` |
| guest 网络 / sshd 未就绪 | 首启较慢（riscv64 约 2~4 分钟）；查看工作目录 qemu.log；`docker ps` 检查 runqemu 容器状态 |
| scp / ssh 登录被拒 | 密码与默认 openEuler@2021 不符；本技能不做 shadow 修改，用 `-p` 传正确密码 |
| 缺 `sshpass` | 非必需：OpenSSH ≥ 8.4 时脚本自动使用 SSH_ASKPASS 机制（无额外依赖）；仅旧版 OpenSSH 才需要安装 sshpass |
| 内核模块编译报 No rule to make target | 缺 `hello_mod.c`（obj-m 需与源文件同名）；脚本已用 `cp test-kmod.c hello_mod.c` 处理 |
| runqemu 启动失败（PAM / tap 报错） | oebuild runqemu 容器应为非特权 + CAP_NET_ADMIN + host 网络；宿主需有 /dev/net/tun |
| 模块加载报 version magic 不匹配 | SDK 与镜像不是同一次构建产物，重新 `do_populate_sdk` |

## 已知约束

- 镜像默认 rootfs 格式为 cpio.gz（qemuboot.conf `qb_default_fstype`），本方案不
  解包也不依赖 ext4：产物经 scp 写入运行中的 guest
- poweroff 后 QEMU 自动退出；脚本结束时会清理残留 qemu 进程

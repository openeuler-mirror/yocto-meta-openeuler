#!/usr/bin/env bash
# verify-sdk.sh — 端到端验证 openEuler Embedded SDK
# 覆盖：用户态 C/C++ 交叉编译运行 + 内核驱动模块编译/加载
# 平台：qemu-aarch64 / qemu-arm / qemu-riscv64（可扩展）
# 假设：镜像已预设 root 密码（默认 openEuler@2021，可用 -p 覆盖）；宿主有 sshpass 与 oebuild（venv）；
# QEMU 由 oebuild runqemu nographic 在容器内启动（tap 网络 guest=192.168.7.2），测试产物经 scp 传输
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"

MACHINE="qemu-aarch64"
PASSWORD="openEuler@2021"
SDK_SRC=""          # SDK 安装脚本或已安装 SDK 目录
BUILD_DIR=""        # build/<machine>
WORK_DIR=""
GUEST_IP=192.168.7.2   # oebuild runqemu tap 网络 guest 地址

usage() {
    cat <<EOF
用法: $0 [-p <root密码>] [-m <machine>] [-s <SDK脚本|SDK目录>] [-b <build目录>] [-d <工作目录>]
  -m machine    qemu-aarch64 | qemu-arm | qemu-riscv64 (默认 qemu-aarch64)
  -p password   镜像预设的 root 密码（默认 openEuler@2021）
  -s sdk        SDK 安装脚本 .sh 或已安装 SDK 目录（默认从 build 产物自动发现）
  -b build      构建目录（默认 <workspace>/build/<machine>）
  -d workdir    工作目录（默认 ~/sdk-verify-<machine>）
EOF
    exit 1
}

while getopts "m:p:s:b:d:h" opt; do
    case "$opt" in
        m) MACHINE="$OPTARG" ;;
        p) PASSWORD="$OPTARG" ;;
        s) SDK_SRC="$OPTARG" ;;
        b) BUILD_DIR="$OPTARG" ;;
        d) WORK_DIR="$OPTARG" ;;
        *) usage ;;
    esac
done

# ---- 平台参数表（新增平台在此扩展；QEMU 启动参数由 oebuild runqemu 按 qemuboot.conf 处理）----
case "$MACHINE" in
    qemu-aarch64)  ARCH=arm64;  SYSROOT=aarch64-openeuler-linux ;;
    qemu-arm)      ARCH=arm;    SYSROOT=arm-openeuler-linux ;;
    qemu-riscv64)  ARCH=riscv;  SYSROOT=riscv64-openeuler-linux ;;
    *) echo "错误: 不支持的平台 $MACHINE（qemu-aarch64/qemu-arm/qemu-riscv64）"; exit 1 ;;
esac

# ---- 非交互密码认证通道：优先 OpenSSH SSH_ASKPASS（>=8.4），fallback sshpass ----
HAVE_SSHPASS=0
command -v sshpass >/dev/null 2>&1 && HAVE_SSHPASS=1
SSH_MAJOR="$(ssh -V 2>&1 | sed -n 's/.*OpenSSH_\([0-9][0-9]*\).*/\1/p')"
HAVE_ASKPASS=0
[ -n "$SSH_MAJOR" ] && [ "$SSH_MAJOR" -ge 8 ] && HAVE_ASKPASS=1
if [ "$HAVE_ASKPASS" -eq 0 ] && [ "$HAVE_SSHPASS" -eq 0 ]; then
    echo "错误: 需要 OpenSSH >= 8.4（SSH_ASKPASS 机制）或 sshpass"; exit 1
fi
command -v setsid >/dev/null 2>&1 || { echo "错误: 缺少 setsid（util-linux）"; exit 1; }

# ---- 定位构建目录与产物 ----
if [ -z "$BUILD_DIR" ]; then
    for cand in "$HOME/openeuler/openeuler/workspace/build/$MACHINE" \
                "$HOME/workspace/build/$MACHINE" \
                "$HOME/build/$MACHINE"; do
        [ -d "$cand/tmp/deploy" ] && BUILD_DIR="$cand" && break
    done
fi
[ -n "${BUILD_DIR:-}" ] && [ -d "$BUILD_DIR/tmp/deploy" ] || { echo "错误: 找不到构建目录，用 -b 指定"; exit 1; }

# oebuild 定位（workspace/.venv/bin/oebuild，fallback PATH）
VENV_DIR="$(dirname "$(dirname "$BUILD_DIR")")/.venv"
OEBUILD="$VENV_DIR/bin/oebuild"
[ -x "$OEBUILD" ] || OEBUILD="$(command -v oebuild 2>/dev/null || true)"
[ -n "$OEBUILD" ] || { echo "错误: 找不到 oebuild（需 source workspace/.venv/bin/activate）"; exit 1; }

echo "== 使用 oebuild: $OEBUILD =="

DEPLOY="$BUILD_DIR/tmp/deploy"
SDK_SH=""
for f in "$DEPLOY"/sdk/*toolchain*.sh; do
    [ -f "$f" ] && SDK_SH="$f" && break
done
# 校验镜像产物（runqemu 依赖 qemuboot.conf + rootfs）
ls "$DEPLOY/images/$MACHINE/"*.qemuboot.conf >/dev/null 2>&1 || { echo "错误: 缺少镜像产物（*.qemuboot.conf）"; exit 1; }
ls "$DEPLOY/images/$MACHINE/"*.rootfs.* >/dev/null 2>&1 || { echo "错误: 缺少镜像产物（*.rootfs.cpio.gz / *.rootfs.ext4）"; exit 1; }

[ -n "$WORK_DIR" ] || WORK_DIR="$HOME/sdk-verify-$MACHINE"
mkdir -p "$WORK_DIR"

# ---- SDK 准备（已安装目录 / 安装脚本 / 自动发现）----
ENV_SCRIPT="environment-setup-$SYSROOT"
SDK_DIR=""
if [ -n "$SDK_SRC" ] && [ -f "$SDK_SRC/$ENV_SCRIPT" ]; then
    SDK_DIR="$SDK_SRC"                       # 已安装的 SDK 目录
elif [ -n "$SDK_SRC" ] && [ -f "$SDK_SRC" ]; then
    SDK_DIR="$HOME/sdk-$MACHINE"             # 指定安装脚本
    [ -d "$SDK_DIR" ] || {
        echo "== 安装 SDK: $SDK_SRC -> $SDK_DIR =="
        bash "$SDK_SRC" -y -d "$SDK_DIR" 2>&1 | tail -3
        test ${PIPESTATUS[0]} -eq 0
    }
elif [ -n "$SDK_SH" ]; then
    SDK_DIR="$HOME/sdk-$MACHINE"             # 自动发现
    [ -d "$SDK_DIR" ] || {
        echo "== 安装 SDK: $SDK_SH -> $SDK_DIR =="
        bash "$SDK_SH" -y -d "$SDK_DIR" 2>&1 | tail -3
        test ${PIPESTATUS[0]} -eq 0
    }
else
    echo "错误: 未找到 SDK 安装脚本，用 -s 指定"; exit 1
fi
[ -f "$SDK_DIR/$ENV_SCRIPT" ] || { echo "错误: $SDK_DIR 中缺少 $ENV_SCRIPT"; exit 1; }

# ---- 交叉编译 ----
source "$SDK_DIR/$ENV_SCRIPT"

cp "$SCRIPT_DIR/test-app.c" "$SCRIPT_DIR/test-app.cpp" "$SCRIPT_DIR/test-kmod.c" "$WORK_DIR"/
cp "$WORK_DIR/test-kmod.c" "$WORK_DIR/hello_mod.c"   # obj-m=hello_mod.o 需要同名源文件
cat > "$WORK_DIR/Makefile" <<EOF
KERNELDIR := $SDKTARGETSYSROOT/usr/src/kernel
ARCH := $ARCH
CROSS_COMPILE := $CROSS_COMPILE
obj-m := hello_mod.o
all:
	\$(MAKE) -C \$(KERNELDIR) M=\$(PWD) ARCH=\$(ARCH) CROSS_COMPILE=\$(CROSS_COMPILE) modules
clean:
	\$(MAKE) -C \$(KERNELDIR) M=\$(PWD) ARCH=\$(ARCH) CROSS_COMPILE=\$(CROSS_COMPILE) clean
EOF

echo "== 编译用户态 C/C++ =="
(cd "$WORK_DIR" && $CC -O2 test-app.c -o hello && $CXX -O2 test-app.cpp -o hello_cpp)

echo "== 编译内核模块（kernel-devsrc）=="
(cd "$WORK_DIR" && make >/dev/null)

echo "== ELF 校验 =="
file "$WORK_DIR/hello" "$WORK_DIR/hello_cpp" "$WORK_DIR/hello_mod.ko" | tee "$WORK_DIR/file-check.log"

# ---- 启动 QEMU（oebuild runqemu nographic，容器内运行；script 提供伪 TTY）----
# 清理可能残留的 QEMU 实例（防 tap0/端口冲突）
pkill -f "qemu-system" 2>/dev/null || true
echo "== 启动 QEMU（oebuild runqemu nographic）=="
cd "$BUILD_DIR"
nohup script -q -e -c "$OEBUILD runqemu nographic" "$WORK_DIR/qemu-pty.log" > "$WORK_DIR/qemu.log" 2>&1 &
QPID=$!
echo "runqemu pid=$QPID（日志: $WORK_DIR/qemu.log）"

# ---- 等待 guest 网络与 sshd 就绪 ----
echo "== 等待 guest（$GUEST_IP）网络就绪 =="
READY=0
for i in $(seq 1 120); do
    if ping -c1 -W1 "$GUEST_IP" >/dev/null 2>&1; then READY=1; break; fi
    if ! kill -0 "$QPID" 2>/dev/null; then
        echo "错误: runqemu 已退出"; tail -25 "$WORK_DIR/qemu.log"; exit 1
    fi
    sleep 2
done
[ "$READY" -eq 1 ] || { echo "错误: guest 网络未就绪（超时）"; tail -25 "$WORK_DIR/qemu.log"; exit 1; }
for i in $(seq 1 45); do
    (echo > "/dev/tcp/$GUEST_IP/22") 2>/dev/null && break
    sleep 2
done

echo "== guest 网络与 sshd 就绪 =="

# ---- scp 传输测试产物 ----
echo "== scp 传输测试产物到 guest /root/ =="
SSH_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=10 -o ServerAliveInterval=5 -o ServerAliveCountMax=2 -o PubkeyAuthentication=no -o PreferredAuthentications=keyboard-interactive,password -o NumberOfPasswordPrompts=1"

# 密码通道：SSH_ASKPASS 脚本只回读环境变量，密码不落盘；旧版 OpenSSH 回退 sshpass
ASKPASS="$WORK_DIR/askpass.sh"
cat > "$ASKPASS" <<'EOF'
#!/bin/sh
echo "$SDK_VERIFY_PASSWORD"
EOF
chmod 700 "$ASKPASS"
if [ "$HAVE_ASKPASS" -eq 1 ]; then
    run_ssh() { SSH_ASKPASS="$ASKPASS" SSH_ASKPASS_REQUIRE=force SDK_VERIFY_PASSWORD="$PASSWORD" setsid -w "$@"; }
else
    run_ssh() { sshpass -p "$PASSWORD" "$@"; }
fi

if ! run_ssh scp $SSH_OPTS "$WORK_DIR/hello" "$WORK_DIR/hello_cpp" "$WORK_DIR/hello_mod.ko" "root@$GUEST_IP:/root/"; then
    echo "错误: scp 失败（检查密码/网络，详见 $WORK_DIR/qemu.log）"; kill "$QPID" 2>/dev/null || true; tail -15 "$WORK_DIR/qemu.log"; exit 1
fi
echo SCP_OK

# ---- SSH 运行验证（密码经环境变量传递，不落盘；poweroff 断开 ssh 属正常）----
echo "== SSH 登录验证 =="
run_ssh ssh $SSH_OPTS -T "root@$GUEST_IP" \
    'uname -m; ls -l /root/hello /root/hello_cpp /root/hello_mod.ko; insmod /root/hello_mod.ko && echo MODULE_INSMOD_OK; cat /proc/modules | grep hello_mod; /root/hello; /root/hello_cpp; echo ====VERIFY_DONE====; poweroff -f' \
    > "$WORK_DIR/verification.log" 2>&1 || true
cat "$WORK_DIR/verification.log"

# ---- 判定 ----
LOG="$WORK_DIR/verification.log"
PASS=1
grep -q "MODULE_INSMOD_OK" "$LOG" || { echo "FAIL: 内核模块未成功加载"; PASS=0; }
grep -q "hello_mod .*Live" "$LOG" || { echo "FAIL: /proc/modules 未见 hello_mod Live"; PASS=0; }
grep -q "Hello from SDK-built C program" "$LOG" || { echo "FAIL: C 程序输出缺失"; PASS=0; }
grep -q "Hello from SDK-built C++ program" "$LOG" || { echo "FAIL: C++ 程序输出缺失"; PASS=0; }
grep -q "VERIFY_DONE" "$LOG" || { echo "FAIL: 验证命令未完整执行"; PASS=0; }

# 等待 QEMU 退出（poweroff 后自动退出）
for i in $(seq 1 30); do
    kill -0 "$QPID" 2>/dev/null || break
    sleep 2
done
kill "$QPID" 2>/dev/null || true
if [ "$PASS" -eq 1 ]; then
    echo "==== SDK 验证 PASS ===="
else
    echo "==== SDK 验证 FAIL（详见 $LOG）===="
fi
exit $([ "$PASS" -eq 1 ] && echo 0 || echo 1)

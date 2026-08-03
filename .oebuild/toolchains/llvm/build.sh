#!/bin/bash
#
# build.sh — openEuler Embedded LLVM 主机工具链构建包装脚本
#
# 本脚本封装 llvm-project 自带的 build.sh，并可选地完成 aarch64 GCC 库集成
# 与产物打包，使用户无需手动执行多步命令。
#
# 流程：
#   1) 在 ${WORK_DIR}/open_source/llvm-project/ 下执行 llvm-project/build.sh；
#   2) 若提供 --gcc-dir，则将 aarch64 GCC 交叉链的头文件与库文件集成到
#      LLVM 工具链中，并创建 ld 软链接；
#   3) 若提供 --package，则将产物打包为 .tar.gz。
#
# 调用方式：
#   ./build.sh <work_dir> [--gcc-dir <path>] [--package]
#
# 示例：
#   ./build.sh /tmp/llvm-work                           # 仅构建
#   ./build.sh /tmp/llvm-work --gcc-dir /path/to/gcc    # 构建 + GCC 集成
#   ./build.sh /tmp/llvm-work --gcc-dir /path/to/gcc --package  # 全流程
#

set -e

# ---------------------------------------------------------------------------
# 路径自定位
# ---------------------------------------------------------------------------
resolve_script_dir() {
	local script="$1"
	case "$script" in
		/*) echo "${script}" ;;
		*)  echo "${PWD}/${script}" ;;
	esac
}

if [ -n "${BASH_SOURCE[0]:-}" ]; then
	THIS_SCRIPT="${BASH_SOURCE[0]}"
elif [ -n "${ZSH_NAME:-}" ]; then
	THIS_SCRIPT="${(%):-%x}"
else
	THIS_SCRIPT="${PWD}/build.sh"
fi
THIS_SCRIPT="$(resolve_script_dir "${THIS_SCRIPT}")"
SRC_DIR="$(cd "$(dirname "${THIS_SCRIPT}")" && pwd)"

# ---------------------------------------------------------------------------
# 公共函数
# ---------------------------------------------------------------------------
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
info()  { echo -e "${GREEN}[INFO]${NC} $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }
die()   { echo -e "${RED}[ERROR]${NC} $*" >&2; exit 1; }
header(){ echo -e "${CYAN}=== $* ===${NC}"; }

usage() {
	cat <<EOF
${CYAN}openEuler Embedded LLVM 工具链构建脚本${NC}

用法:
  $0 <work_dir> [options]

参数:
  work_dir           prepare.sh 的工作目录（含 open_source/llvm-project/）

选项:
  --gcc-dir <path>   aarch64 GCC 交叉链目录，用于集成头文件与库文件
  --package          构建完成后将产物打包为 .tar.gz
  -h, --help         显示此帮助信息

示例:
  $0 /tmp/llvm-work --gcc-dir /path/to/openeuler_gcc_arm64le --package
EOF
}

# ---------------------------------------------------------------------------
# 参数解析
# ---------------------------------------------------------------------------
WORK_DIR=""
GCC_DIR=""
DO_PACKAGE=false

while [ $# -gt 0 ]; do
	case "$1" in
		-h|--help) usage; exit 0 ;;
		--gcc-dir)
			shift
			[ $# -gt 0 ] || die "--gcc-dir requires an argument"
			GCC_DIR="$1"
			;;
		--package)
			DO_PACKAGE=true
			;;
		-*)
			die "unknown option: $1"
			;;
		*)
			[ -z "${WORK_DIR}" ] || die "work_dir already set to '${WORK_DIR}', unexpected argument: $1"
			WORK_DIR="$1"
			;;
	esac
	shift
done

[ -n "${WORK_DIR}" ] || { usage; exit 1; }
[ -e "${WORK_DIR}" ] || die "work_dir '${WORK_DIR}' does not exist"
WORK_DIR="$(cd "${WORK_DIR}" && pwd)"

# shellcheck disable=SC1091
source "${SRC_DIR}/configs/config.xml"
[ -n "${LLVM:-}" ] || die "config.xml: LLVM is empty"
[ -n "${LLVM_BRANCH:-}" ] || die "config.xml: LLVM_BRANCH is empty"

# 从 LLVM_BRANCH="dev_17.0.6" 提取版本号 "17.0.6"
LLVM_VERSION="${LLVM_BRANCH#dev_}"
INSTALL_DIR_NAME="clang-llvm-${LLVM_VERSION}"

LLVM_SRC="${WORK_DIR}/open_source/${LLVM}"
[ -d "${LLVM_SRC}" ] || die "LLVM source not found at '${LLVM_SRC}', please run prepare.sh first"

# ---------------------------------------------------------------------------
# 选择主机编译器：LLVM 17+ 要求 GCC >= 7.4
# 统一构建容器中 gcc-12 可用，优先使用；否则回退到系统默认 gcc
# ---------------------------------------------------------------------------
if command -v gcc-12 >/dev/null 2>&1; then
	export CC=gcc-12
	export CXX=g++-12
	info "Host compiler: gcc-12 ($(gcc-12 -dumpversion))"
else
	export CC="${CC:-gcc}"
	export CXX="${CXX:-g++}"
	warn "gcc-12 not found, using default: $(gcc -dumpversion)"
fi

# ---------------------------------------------------------------------------
# 构建
# ---------------------------------------------------------------------------
header "LLVM Toolchain Build"

info "LLVM source : ${LLVM_SRC}"
info "Install dir : ${INSTALL_DIR_NAME}"
info "GCC dir     : ${GCC_DIR:-（未指定，跳过集成）}"
echo

# 1) 运行 llvm-project 自带的 build.sh
#    llvm-project/build.sh 硬编码 C_COMPILER_PATH / CXX_COMPILER_PATH，
#    不读取 CC/CXX 环境变量，这里在调用前替换为已选定的编译器；
#    同时修复 install-cxx-strripped 拼写错误（应为 stripped）
info "Running llvm-project build.sh..."
if [ -f "${LLVM_SRC}/build.sh" ]; then
	sed -i "s|^C_COMPILER_PATH=.*|C_COMPILER_PATH=${CC}|" "${LLVM_SRC}/build.sh"
	sed -i "s|^CXX_COMPILER_PATH=.*|CXX_COMPILER_PATH=${CXX}|" "${LLVM_SRC}/build.sh"
	sed -i "s|strripped|stripped|g" "${LLVM_SRC}/build.sh"
	info "Patched llvm-project build.sh: C_COMPILER_PATH=${CC} CXX_COMPILER_PATH=${CXX}"
fi
( cd "${LLVM_SRC}" && ./build.sh -e -o -s -i -r -b release -I "${INSTALL_DIR_NAME}" )

INSTALL_PATH="${LLVM_SRC}/${INSTALL_DIR_NAME}"
[ -d "${INSTALL_PATH}" ] || die "install dir '${INSTALL_PATH}' not found after build"

# 2) GCC 集成（可选）
if [ -n "${GCC_DIR}" ]; then
	[ -d "${GCC_DIR}" ] || die "--gcc-dir '${GCC_DIR}' not found"
	header "GCC Integration"
	info "Integrating aarch64 GCC libs from ${GCC_DIR}..."

	( cd "${INSTALL_PATH}" && {
		mkdir -p lib64 aarch64-openeuler-linux-gnu

		cp -rf "${GCC_DIR}/lib64/gcc" lib64/
		cp -rf "${GCC_DIR}/aarch64-openeuler-linux-gnu/include" aarch64-openeuler-linux-gnu/
		cp -rf "${GCC_DIR}/aarch64-openeuler-linux-gnu/sysroot" aarch64-openeuler-linux-gnu/

		cd bin
		ln -sf ld.lld aarch64-openeuler-linux-gnu-ld
	} )

	info "GCC integration done."
fi

# 3) 打包（可选）
if [ "${DO_PACKAGE}" = true ]; then
	header "Packaging"
	info "Creating ${INSTALL_DIR_NAME}.tar.gz..."

	( cd "${LLVM_SRC}" && {
		mkdir -p output
		tar zcf "output/${INSTALL_DIR_NAME}.tar.gz" "${INSTALL_DIR_NAME}"
	} )

	info "Package created at ${LLVM_SRC}/output/${INSTALL_DIR_NAME}.tar.gz"
fi

echo
info "LLVM build done. 产物位于 ${INSTALL_PATH}"

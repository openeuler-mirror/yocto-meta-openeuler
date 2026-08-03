#!/bin/bash
#
# prepare.sh — openEuler Embedded LLVM 主机工具链源码准备脚本
#
# 流程：
#   1) 读取 configs/config.xml 获取 LLVM 仓库名与分支名；
#   2) 在 ${WORK_DIR}/open_source/ 下 git clone llvm-project 并 checkout 分支。
#
# 调用方式：
#   ./prepare.sh [work_dir]
#   work_dir 缺省为脚本所在目录。脚本通过 $BASH_SOURCE 自定位，因此也支持
#   从任意位置以绝对路径调用，调用方当前工作目录不影响结果。
#

set -e

# ---------------------------------------------------------------------------
# 路径自定位：尽量用 BASH_SOURCE 解析脚本所在目录，避免依赖调用方 CWD
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
	THIS_SCRIPT="${PWD}/prepare.sh"
	if [ ! -e "${THIS_SCRIPT}" ]; then
		echo "Error: cannot locate prepare.sh" >&2
		exit 1
	fi
fi
THIS_SCRIPT="$(resolve_script_dir "${THIS_SCRIPT}")"
SRC_DIR="$(cd "$(dirname "${THIS_SCRIPT}")" && pwd)"

# ---------------------------------------------------------------------------
# 公共函数
# ---------------------------------------------------------------------------
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
info()  { echo -e "${GREEN}[INFO]${NC} $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }
die()   { echo -e "${RED}[ERROR]${NC} $*" >&2; exit 1; }

usage() {
	cat <<EOF
Tip: ${THIS_SCRIPT##*/} <work_dir>

  work_dir  LLVM 工具链源码准备的工作目录，open_source/ 会创建在其中。
            缺省值为脚本所在目录（${SRC_DIR}）。

  常见用法：
    ./prepare.sh             # 在脚本所在目录下准备
    ./prepare.sh /path/to/wd # 在 /path/to/wd 下准备
EOF
}

check_use() {
	if [ -n "${BASH_SOURCE[0]:-}" ]; then
		local invoked="${0}"
		local script="${BASH_SOURCE[0]}"
		invoked="$(resolve_script_dir "${invoked}")"
		script="$(resolve_script_dir "${script}")"
		if [ "${invoked}" != "${script}" ]; then
			echo "Error: this script cannot be sourced. Please run as '${script}'" >&2
			return 1
		fi
	fi
	return 0
}

delete_dir() {
	local d
	for d in "$@"; do
		[ -n "${d}" ] || continue
		if [ -e "./${d}" ]; then
			rm -rf -- "./${d}"
		fi
	done
}

do_prepare() {
	local pkg
	[ -d "${LIB_PATH}" ] || mkdir -p "${LIB_PATH}"
	pushd "${LIB_PATH}" >/dev/null
	delete_dir "${LLVM}"
	info "Cloning ${LLVM} (branch: ${LLVM_BRANCH})..."
	git clone -b "${LLVM_BRANCH}" "https://gitee.com/openeuler/${LLVM}.git" --depth 1
	info "${LLVM} cloned to ${LIB_PATH}/${LLVM}"
	popd >/dev/null
}

# ---------------------------------------------------------------------------
# main
# ---------------------------------------------------------------------------
main() {
	local work_dir="$1"

	usage
	check_use || exit 1

	if [ -z "${work_dir}" ]; then
		work_dir="${SRC_DIR}"
		echo "use default work dir: ${work_dir}"
	fi
	[ -e "${work_dir}" ] || die "work_dir '${work_dir}' does not exist"
	work_dir="$(cd "${work_dir}" && pwd)"

	# shellcheck disable=SC1091
	source "${SRC_DIR}/configs/config.xml"
	[ -n "${LLVM:-}" ] || die "config.xml: LLVM is empty"
	[ -n "${LLVM_BRANCH:-}" ] || die "config.xml: LLVM_BRANCH is empty"

	readonly LIB_PATH="${work_dir}/open_source"

	info "Checking prerequisites..."
	command -v git >/dev/null 2>&1 || die "git not installed"

	do_prepare

	echo
	echo "Prepare done! Now you can run: (not as root please)"
	echo "    ${SRC_DIR}/build.sh ${work_dir}"
}

main "$@"

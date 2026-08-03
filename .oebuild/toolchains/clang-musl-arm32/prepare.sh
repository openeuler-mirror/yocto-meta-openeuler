#!/bin/bash
#
# prepare.sh — openEuler Embedded Clang+musl ARM32 编译链源码准备脚本
#
# 流程：
#   1) 读取 configs/config.xml 获取各依赖仓库名、版本、下载地址；
#   2) 下载 32 位 GCC+musl 交叉编译链（二进制，分块下载 + 合并解压）；
#   3) git clone LLVM 源码仓；
#   4) git fetch musl 源码仓指定 commit。
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

  work_dir  Clang+musl ARM32 工具链源码准备的工作目录，open_source/ 会创建在其中。
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

# ---------------------------------------------------------------------------
# 下载函数
# ---------------------------------------------------------------------------
download_gcc_musl() {
	local output_dir="$1"
	local gcc_dir="${output_dir}/${GCC_MUSL}"

	if [ -d "${gcc_dir}" ]; then
		info "${GCC_MUSL} already exists, skip download"
		return 0
	fi

	info "Downloading ${GCC_MUSL} (split into ${GCC_MUSL_SPLIT_COUNT} parts)..."

	local tmp_dir="${output_dir}/tmp_gcc_musl_download"
	mkdir -p "${tmp_dir}"

	local i url part_file
	for i in $(seq 1 "${GCC_MUSL_SPLIT_COUNT}"); do
		url="${DOWNLOAD_BASE_URL}/${GCC_MUSL_RELEASE_TAG}/${i}_${GCC_MUSL}.tar.gz"
		part_file="${tmp_dir}/${i}_${GCC_MUSL}.tar.gz"
		if [ -f "${part_file}" ]; then
			info "  Part ${i} already downloaded, skip"
		else
			info "  Downloading part ${i} from ${url}..."
			curl -sL "${url}" -o "${part_file}" || die "Failed to download part ${i}"
		fi
	done

	info "  Merging split files..."
	cat $(for i in $(seq 1 "${GCC_MUSL_SPLIT_COUNT}"); do echo "${tmp_dir}/${i}_${GCC_MUSL}.tar.gz"; done) \
		> "${tmp_dir}/${GCC_MUSL}.tar.gz"

	info "  Extracting..."
	tar xzf "${tmp_dir}/${GCC_MUSL}.tar.gz" -C "${output_dir}"

	rm -rf "${tmp_dir}"
	info "${GCC_MUSL} downloaded and extracted to ${gcc_dir}"
}

download_llvm_source() {
	local output_dir="$1"
	local llvm_dir="${output_dir}/${LLVM}"

	if [ -d "${llvm_dir}" ]; then
		info "${LLVM} already exists, skip download"
		return 0
	fi

	info "Downloading ${LLVM} (branch: ${LLVM_BRANCH})..."
	git clone -b "${LLVM_BRANCH}" "${LLVM_REPO_URL}" "${llvm_dir}" --depth 1
	info "${LLVM} downloaded to ${llvm_dir}"
}

download_musl_source() {
	local output_dir="$1"
	local musl_dir="${output_dir}/${MUSL}"

	if [ -d "${musl_dir}" ]; then
		info "${MUSL} already exists, skip download"
		return 0
	fi

	info "Downloading ${MUSL} (commit: ${MUSL_COMMIT})..."
	git init "${musl_dir}"
	(
		cd "${musl_dir}"
		git remote add origin "${MUSL_REPO_URL}"
		git fetch origin "${MUSL_COMMIT}" --depth 1
		git checkout FETCH_HEAD
	)
	info "${MUSL} downloaded to ${musl_dir}"
}

do_prepare() {
	local lib_path="$1"

	mkdir -p "${lib_path}"
	download_gcc_musl "${lib_path}"
	download_llvm_source "${lib_path}"
	download_musl_source "${lib_path}"
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
	[ -n "${GCC_MUSL:-}" ] || die "config.xml: GCC_MUSL is empty"
	[ -n "${LLVM:-}" ] || die "config.xml: LLVM is empty"
	[ -n "${MUSL:-}" ] || die "config.xml: MUSL is empty"

	readonly LIB_PATH="${work_dir}/open_source"

	info "Checking prerequisites..."
	command -v git >/dev/null 2>&1 || die "git not installed"
	command -v curl >/dev/null 2>&1 || die "curl not installed"
	command -v tar >/dev/null 2>&1 || die "tar not installed"

	do_prepare "${LIB_PATH}"

	echo
	echo "Prepare done! Now you can run:"
	echo "  ${SRC_DIR}/build-llvm-musl-arm32.sh all \\"
	echo "      --gcc-dir ${LIB_PATH}/${GCC_MUSL} \\"
	echo "      --llvm-src ${LIB_PATH}/${LLVM} \\"
	echo "      --musl-src ${LIB_PATH}/${MUSL}/ \\"
	echo "      --output-dir ${work_dir}/toolchain"
}

main "$@"

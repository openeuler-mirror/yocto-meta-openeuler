#!/bin/bash
#
# prepare.sh — openEuler Embedded 交叉编译链源码准备脚本
#
# 流程：
#   1) 读取 configs/config.xml 获取各组件名/目录名/MANIFEST 指针；
#   2) 读取 .oebuild/manifest.yaml 获取每个组件的 remote_url + version(commit)；
#   3) 在 ${WORK_DIR}/open_source/ 下逐个 git clone 对应仓库并 checkout；
#   4) 对每个组件解包 *.tar.*，先按 *.spec 中声明的 Patch* 顺序应用补丁，
#      再应用 patches/ 目录下匹配 <pkg>- 前缀的 OE 专有补丁；
#   5) kernel 不做 patch；libiconv/gettext 仅创建空目录占位（crosstool-NG
#      在 openEuler 环境下会跳过它们的实际编译）。
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

if [ -n "${BASH_SOURCE[0]}" ]; then
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
die() { echo "Error: $*" >&2; exit 1; }

usage() {
	cat <<EOF
Tip: ${THIS_SCRIPT##*/} <work_dir>

  work_dir  交叉编译链源码准备的工作目录，open_source/ 会创建在其中。
            缺省值为脚本所在目录（${SRC_DIR}）。

  常见用法：
    ./prepare.sh             # 在脚本所在目录下准备
    ./prepare.sh /path/to/wd # 在 /path/to/wd 下准备
EOF
}

check_use() {
	# 拒绝被 source，必须以独立进程运行
	if [ -n "${BASH_SOURCE[0]:-}" ]; then
		local invoked="${0}"
		local script="${BASH_SOURCE[0]}"
		# 都按 resolve_script_dir 规范化后再比，避免相对路径假阳性
		invoked="$(resolve_script_dir "${invoked}")"
		script="$(resolve_script_dir "${script}")"
		if [ "${invoked}" != "${script}" ]; then
			echo "Error: this script cannot be sourced. Please run as '${script}'" >&2
			return 1
		fi
	fi
	return 0
}

# 递归删除指定子目录，仅作用于当前工作目录
delete_dir() {
	local d
	for d in "$@"; do
		[ -n "${d}" ] || continue
		if [ -e "./${d}" ]; then
			rm -rf -- "./${d}"
		fi
	done
}

# 在 manifest 中查找 " <repo>:" 行，要求恰好 1 个匹配；返回其所在行号
get_repo_line_num() {
	local repo="$1" manifest="$2"
	# 注意 manifest 中存在 "kernel-5.10-tag-rpi:"、"src-kernel-5.10:" 等
	# 形似名，这里用 " <repo>:" 精确匹配 "<repo>" 节点，避免误命中
	local matches
	matches="$(grep -nE "^[[:space:]]+${repo}:[[:space:]]*\$" "${manifest}" | cut -d: -f1)"
	[ -n "${matches}" ] || die "manifest: '${repo}' not found"
	local n
	n=$(printf '%s\n' "${matches}" | wc -l)
	[ "${n}" -eq 1 ] || die "manifest: '${repo}' matched ${n} times (expected exactly 1), please fix manifest"
	printf '%s' "${matches}"
}

get_remote_from_manifest() {
	local repo="$1" manifest="$2"
	local line
	line=$(get_repo_line_num "${repo}" "${manifest}")
	line=$((line + 1))
	awk -v target="${line}" 'NR==target' "${manifest}" \
		| awk -F 'remote_url:[[:space:]]*' '{print $2}' \
		| sed -e 's#^[[:space:]]*##' -e 's#[[:space:]]*$##'
}

get_version_from_manifest() {
	local repo="$1" manifest="$2"
	local line
	line=$(get_repo_line_num "${repo}" "${manifest}")
	line=$((line + 2))
	awk -v target="${line}" 'NR==target' "${manifest}" \
		| awk -F 'version:[[:space:]]*' '{print $2}' \
		| sed -e 's#^[[:space:]]*##' -e 's#[[:space:]]*$##'
}

# 在当前目录下恰好选择一个 *.tar.* 压缩包，返回其文件名
pick_tarball() {
	local tbs
	tbs=$(ls -1 *.tar.* 2>/dev/null || true)
	[ -n "${tbs}" ] || die "no tarball '*.tar.*' found in ${PWD}"
	local n
	n=$(printf '%s\n' "${tbs}" | wc -l)
	if [ "${n}" -ne 1 ]; then
		echo "Error: multiple tarballs found in ${PWD}, refusing to pick one:" >&2
		printf '%s\n' "${tbs}" >&2
		exit 1
	fi
	printf '%s' "${tbs}"
}

# 对 $1 指定的组件解包 + 应用 spec 内补丁 + 应用 OE 专有补丁
# 调用前已经 pushd 进组件目录
do_patch() {
	local pkg="$1"
	local tarball unpack_dir patchlist oe_patchlist p

	if [ "${pkg}" = "isl" ] || [ "${pkg}" = "zlib" ]; then
		# isl 与 zlib 在 src-openeuler 仓库里没有需要应用的 patch
		tarball=$(pick_tarball)
		echo "${pkg}: do_unpack of ${tarball}..."
		tar xf "${tarball}"
		echo "------------do_patch for ${pkg} done!"
		return
	fi

	tarball=$(pick_tarball)
	echo "${pkg}: do_unpack of ${tarball}..."
	tar xf "${tarball}"

	# spec 中声明的补丁列表（RPM 风格 "PatchNNNN: foo.patch"）
	patchlist="$(pwd)/${pkg}-patchlist"
	# OE 自维护补丁列表，命名约定见 patches/README.md
	oe_patchlist="$(pwd)/${pkg}-patchlist-oe"

	echo "make patchlist of ${pkg}..."
	cat ./*.spec 2>/dev/null \
		| grep -E '^Patch[0-9]+' \
		| grep -v '^[[:space:]]*#' \
		| grep -E '\.patch([[:space:]]|$)' \
		| awk -F ':' '{ sub(/^[[:space:]]+/,"",$2); print $2 }' \
		> "${patchlist}"
	ls "${OE_PATCH_DIR}/" 2>/dev/null | grep -E "^${pkg}-" > "${oe_patchlist}" || true

	unpack_dir="${tarball%%.tar.*}"
	[ -d "${unpack_dir}" ] || die "expected unpacked dir '${unpack_dir}' not found in ${PWD}"
	pushd "${unpack_dir}" >/dev/null

	# 按行读取（避免文件名含空格或 CRLF 被错拆）
	while IFS= read -r p || [ -n "${p}" ]; do
		[ -n "${p}" ] || continue
		# 去掉可能的尾随 CR
		p="${p%$'\r'}"
		[ -e "../${p}" ] || { echo "warn: patch '${p}' not found in ${PWD}, skip" >&2; continue; }
		echo "----------------apply spec patch ${p}:"
		patch -p1 < "../${p}"
	done < "${patchlist}"

	while IFS= read -r p || [ -n "${p}" ]; do
		[ -n "${p}" ] || continue
		p="${p%$'\r'}"
		[ -e "${OE_PATCH_DIR}/${p}" ] || { echo "warn: OE patch '${p}' not found, skip" >&2; continue; }
		echo "----------------apply OE patch ${OE_PATCH_DIR}/${p}:"
		patch -p1 < "${OE_PATCH_DIR}/${p}"
	done < "${oe_patchlist}"

	popd >/dev/null
	echo "------------do_patch for ${pkg} done!"
}

# 逐个 git clone + checkout + （非 kernel 时）do_patch
download_and_patch() {
	local repo remote version
	for repo in "$@"; do
		echo "download ${repo} ..."
		if [ "${repo}" = "${KERNEL}" ]; then
			remote=$(get_remote_from_manifest "kernel-5.10" "${MANIFEST_PATH}")
			version=$(get_version_from_manifest "kernel-5.10" "${MANIFEST_PATH}")
		else
			remote=$(get_remote_from_manifest "${repo}" "${MANIFEST_PATH}")
			version=$(get_version_from_manifest "${repo}" "${MANIFEST_PATH}")
		fi
		[ -n "${remote}" ]  || die "no remote_url for '${repo}' in manifest"
		[ -n "${version}" ] || die "no version for '${repo}' in manifest"

		mkdir -p "${repo}"
		pushd "${repo}" >/dev/null
		git init
		git remote add upstream "${remote}"
		git fetch upstream "${version}" --depth=1
		git checkout "${version}"
		[ "${repo}" = "${KERNEL}" ] || do_patch "${repo}"
		popd >/dev/null
	done
}

do_prepare() {
	local pkg
	[ -d "${LIB_PATH}" ] || mkdir -p "${LIB_PATH}"
	pushd "${LIB_PATH}" >/dev/null
	delete_dir "${KERNEL}" "${GCC}" "${GLIBC}" "${MUSLC}" "${BINUTILS}" \
		"${GMP}" "${MPC}" "${MPFR}" "${ISL}" "${EXPAT}" "${GETTEXT}" \
		"${NCURSES}" "${ZLIB}" "${LIBICONV}" "${GDB}" "${ZSTD}"
	download_and_patch \
		"${KERNEL}" "${MUSLC}" "${GCC}" "${GLIBC}" "${BINUTILS}" \
		"${GMP}" "${MPC}" "${MPFR}" "${ISL}" "${EXPAT}" "${NCURSES}" \
		"${ZLIB}" "${GDB}" "${ZSTD}"
	# LIBICONV / GETTEXT 仅需占位目录（crosstool-NG 在 openEuler 环境下会跳过
	# 它们的实际编译），不下载源码、不打补丁
	mkdir -p "${LIB_PATH}/${LIBICONV}/${LIBICONV_DIR}"
	mkdir -p "${LIB_PATH}/${GETTEXT}/${GETTEXT_DIR}"
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
	# 允许传入相对路径，按调用方 CWD 解析；不存在则报错
	[ -e "${work_dir}" ] || die "work_dir '${work_dir}' does not exist"
	work_dir="$(cd "${work_dir}" && pwd)"

	# source 全局配置：config.xml 中 MANIFEST 是相对 SRC_DIR（cross-tools/）
	# 解析的（如 ../manifest.yaml），这里转成绝对路径
	# shellcheck disable=SC1091
	source "${SRC_DIR}/configs/config.xml"
	[ -n "${MANIFEST:-}" ] || die "config.xml: MANIFEST is empty"
	MANIFEST_PATH="$(cd "${SRC_DIR}" && realpath -m "${MANIFEST}")"
	[ -f "${MANIFEST_PATH}" ] || die "manifest not found at '${MANIFEST_PATH}' (resolved from '${MANIFEST}' relative to '${SRC_DIR}')"

	readonly OE_PATCH_DIR="${SRC_DIR}/patches"
	readonly LIB_PATH="${work_dir}/open_source"

	do_prepare

	echo
	echo "Prepare done! Now you can run: (not as root please)"
	echo "    ${SRC_DIR}/update.sh"
}

main "$@"

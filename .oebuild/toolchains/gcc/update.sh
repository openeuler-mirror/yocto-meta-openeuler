#!/bin/bash
#
# update.sh — openEuler Embedded 交叉编译链构建后处理脚本
#
# 在 prepare.sh 完成源码下载后执行：
#   1) update_feature：修改 GCC 源码以让 64 位架构（aarch64/riscv64）默认从
#      lib64 下寻找 dynamic linker，并给 libstdc++.so 默认加 relro/now/
#      noexecstack。对其他架构（x86_64/arm32）属无操作；
#   2) update_config：把 configs/config_<arch> 拷到工作目录，并把其中所有
#      CT_*_CUSTOM_LOCATION 字段统一替换为 ${LIB_PATH}/<pkg>/<pkg>-<ver>
#      的真实绝对路径（取自 configs/config.xml）。
#
# 该脚本对 GCC 源码与 config 文件均做幂等处理：多次运行不会重复修改同一行，
# 也不会引入重复内容，便于在 prepare 失败后修复问题再次执行。
#
# 调用方式：
#   ./update.sh
#   通过 $BASH_SOURCE 自定位，可从任意目录以绝对路径调用。
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

if [ -n "${BASH_SOURCE[0]}" ]; then
	THIS_SCRIPT="${BASH_SOURCE[0]}"
elif [ -n "${ZSH_NAME:-}" ]; then
	THIS_SCRIPT="${(%):-%x}"
else
	THIS_SCRIPT="${PWD}/update.sh"
	if [ ! -e "${THIS_SCRIPT}" ]; then
		echo "Error: cannot locate update.sh" >&2
		exit 1
	fi
fi
THIS_SCRIPT="$(resolve_script_dir "${THIS_SCRIPT}")"
SRC_DIR="$(cd "$(dirname "${THIS_SCRIPT}")" && pwd)"

die() { echo "Error: $*" >&2; exit 1; }

usage() {
	cat <<EOF
Tip: ${THIS_SCRIPT##*/} [work_dir]

  在 prepare.sh 之后执行，完成 GCC 头文件特性补丁与 config 路径刷新。
  work_dir 缺省为脚本所在目录（${SRC_DIR}）。

  常见用法：
    ./prepare.sh /path/to/work
    ./update.sh /path/to/work
EOF
}

# 仅当目标行尚未被本脚本改造过时才执行 sed，避免重复运行产生重复内容
# 用法：idempotent_sed <file> <pattern> <replacement>
# 注意：使用 | 作为 sed 分隔符，避免与 C 预处理指令中的 # 冲突
idempotent_sed() {
	local file="$1" pattern="$2" replacement="$3"
	[ -f "${file}" ] || die "idempotent_sed: file '${file}' not found"
	# 若已有 STANDARD_STARTFILE_PREFIX_2 或自定义安全链接器标志，
	# 说明 update_feature 已经跑过；跳过
	if grep -q 'STANDARD_STARTFILE_PREFIX_2' "${file}" 2>/dev/null \
		|| grep -q -- '-Wl,-z,relro,-z,now,-z,noexecstack' "${file}" 2>/dev/null; then
		echo "    skip (already patched): ${file}"
		return 0
	fi
	sed -i "s|${pattern}|${replacement}|g" "${file}"
}

update_feature() {
	local aarch64_linux_h riscv_linux_h libstdcpp_makefile_in

	aarch64_linux_h="${LIB_PATH}/${GCC}/${GCC_DIR}/gcc/config/aarch64/aarch64-linux.h"
	riscv_linux_h="${LIB_PATH}/${GCC}/${GCC_DIR}/gcc/config/riscv/linux.h"
	libstdcpp_makefile_in="${LIB_PATH}/${GCC}/${GCC_DIR}/libstdc++-v3/src/Makefile.in"

	echo "[update_feature] modify GCC source for 64-bit lib64 linker & libstdc++ security flags"

	# aarch64：让 GLIBC_DYNAMIC_LINKER 走 /lib/.../ld-linux-aarch64...；
	# 同时新增 STANDARD_STARTFILE_PREFIX_2="/usr/lib64/" 让 startfile 也从 lib64 找
	if [ -f "${aarch64_linux_h}" ]; then
		idempotent_sed "${aarch64_linux_h}" \
			'^#define GLIBC_DYNAMIC_LINKER.*' \
			'#undef STANDARD_STARTFILE_PREFIX_2\n#define STANDARD_STARTFILE_PREFIX_2 "/usr/lib64/"\n#define GLIBC_DYNAMIC_LINKER "/lib%{mabi=lp64:64}%{mabi=ilp32:ilp32}/ld-linux-aarch64%{mbig-endian:_be}%{mabi=ilp32:_ilp32}.so.1"'
		idempotent_sed "${aarch64_linux_h}" \
			'^#define MUSL_DYNAMIC_LINKER.*' \
			'#define MUSL_DYNAMIC_LINKER "/lib%{mabi=lp64:64}%{mabi=ilp32:ilp32}/ld-musl-aarch64%{mbig-endian:_be}%{mabi=ilp32:_ilp32}.so.1"'
	else
		echo "    skip (not found): ${aarch64_linux_h}"
	fi

	# riscv64：让 GLIBC/MUSL 动态链接器走 /lib64/lp64d/...
	if [ -f "${riscv_linux_h}" ]; then
		idempotent_sed "${riscv_linux_h}" \
			'^#define GLIBC_DYNAMIC_LINKER.*' \
			'#define GLIBC_DYNAMIC_LINKER "/lib64/lp64d/ld-linux-riscv" XLEN_SPEC "-" ABI_SPEC ".so.1"'
		idempotent_sed "${riscv_linux_h}" \
			'^#define MUSL_DYNAMIC_LINKER.*' \
			'#define MUSL_DYNAMIC_LINKER "/lib64/lp64d/ld-musl-riscv" XLEN_SPEC MUSL_ABI_SUFFIX ".so.1"'
	else
		echo "    skip (not found): ${riscv_linux_h}"
	fi

	# libstdc++.so 默认加 relro/now/noexecstack + -Wtrampolines
	if [ -f "${libstdcpp_makefile_in}" ]; then
		idempotent_sed "${libstdcpp_makefile_in}" \
			'^\t-o \$\@.*' \
			'\t-Wl,-z,relro,-z,now,-z,noexecstack -Wtrampolines -o $@'
	else
		echo "    skip (not found): ${libstdcpp_makefile_in}"
	fi
}

update_config() {
	local cfg

	echo "[update_config] sync CT_*_CUSTOM_LOCATION with config.xml paths"
	# shellcheck disable=SC2086
	cp -f "${SRC_DIR}/configs/config_"* "${WORK_DIR}/"

	# 用 config.xml 中定义的真实路径统一覆盖各 config 中的占位/陈旧路径
	for cfg in "${WORK_DIR}/config_"*; do
		[ -f "${cfg}" ] || continue
		sed -i "s|^CT_LINUX_CUSTOM_LOCATION.*|CT_LINUX_CUSTOM_LOCATION=\"${LIB_PATH}/${KERNEL}\"|g"            "${cfg}"
		sed -i "s|^CT_BINUTILS_CUSTOM_LOCATION.*|CT_BINUTILS_CUSTOM_LOCATION=\"${LIB_PATH}/${BINUTILS}/${BINUTILS_DIR}\"|g" "${cfg}"
		sed -i "s|^CT_GLIBC_CUSTOM_LOCATION.*|CT_GLIBC_CUSTOM_LOCATION=\"${LIB_PATH}/${GLIBC}/${GLIBC_DIR}\"|g"  "${cfg}"
		sed -i "s|^CT_MUSL_CUSTOM_LOCATION.*|CT_MUSL_CUSTOM_LOCATION=\"${LIB_PATH}/${MUSLC}/${MUSLC_DIR}\"|g"    "${cfg}"
		sed -i "s|^CT_GCC_CUSTOM_LOCATION.*|CT_GCC_CUSTOM_LOCATION=\"${LIB_PATH}/${GCC}/${GCC_DIR}\"|g"          "${cfg}"
		sed -i "s|^CT_GDB_CUSTOM_LOCATION.*|CT_GDB_CUSTOM_LOCATION=\"${LIB_PATH}/${GDB}/${GDB_DIR}\"|g"          "${cfg}"
		sed -i "s|^CT_GMP_CUSTOM_LOCATION.*|CT_GMP_CUSTOM_LOCATION=\"${LIB_PATH}/${GMP}/${GMP_DIR}\"|g"          "${cfg}"
		sed -i "s|^CT_ISL_CUSTOM_LOCATION.*|CT_ISL_CUSTOM_LOCATION=\"${LIB_PATH}/${ISL}/${ISL_DIR}\"|g"          "${cfg}"
		sed -i "s|^CT_MPC_CUSTOM_LOCATION.*|CT_MPC_CUSTOM_LOCATION=\"${LIB_PATH}/${MPC}/${MPC_DIR}\"|g"          "${cfg}"
		sed -i "s|^CT_MPFR_CUSTOM_LOCATION.*|CT_MPFR_CUSTOM_LOCATION=\"${LIB_PATH}/${MPFR}/${MPFR_DIR}\"|g"     "${cfg}"
		sed -i "s|^CT_EXPAT_CUSTOM_LOCATION.*|CT_EXPAT_CUSTOM_LOCATION=\"${LIB_PATH}/${EXPAT}/${EXPAT_DIR}\"|g" "${cfg}"
		sed -i "s|^CT_LIBICONV_CUSTOM_LOCATION.*|CT_LIBICONV_CUSTOM_LOCATION=\"${LIB_PATH}/${LIBICONV}/${LIBICONV_DIR}\"|g" "${cfg}"
		sed -i "s|^CT_GETTEXT_CUSTOM_LOCATION.*|CT_GETTEXT_CUSTOM_LOCATION=\"${LIB_PATH}/${GETTEXT}/${GETTEXT_DIR}\"|g" "${cfg}"
		sed -i "s|^CT_NCURSES_CUSTOM_LOCATION.*|CT_NCURSES_CUSTOM_LOCATION=\"${LIB_PATH}/${NCURSES}/${NCURSES_DIR}\"|g" "${cfg}"
		sed -i "s|^CT_ZLIB_CUSTOM_LOCATION.*|CT_ZLIB_CUSTOM_LOCATION=\"${LIB_PATH}/${ZLIB}/${ZLIB_DIR}\"|g"      "${cfg}"
		sed -i "s|^CT_ZSTD_CUSTOM_LOCATION.*|CT_ZSTD_CUSTOM_LOCATION=\"${LIB_PATH}/${ZSTD}/${ZSTD_DIR}\"|g"      "${cfg}"
	done
}

main() {
	local work_dir="$1"

	usage

	# shellcheck disable=SC1091
	source "${SRC_DIR}/configs/config.xml"

	if [ -z "${work_dir}" ]; then
		work_dir="${SRC_DIR}"
	fi
	[ -d "${work_dir}/open_source" ] || die "open_source/ not found under '${work_dir}'; please run prepare.sh first"
	work_dir="$(cd "${work_dir}" && pwd)"

	readonly LIB_PATH="${work_dir}/open_source"
	WORK_DIR="${work_dir}"

	update_feature
	update_config

	echo
	echo "Update done! Now you can run (not as root please):"
	echo "    'cp config_aarch64 .config && ct-ng build'      for aarch64 + glibc"
	echo "    'cp config_aarch64-musl .config && ct-ng build' for aarch64 + musl  (LEGACY)"
	echo "    'cp config_arm32 .config && ct-ng build'        for arm32 + glibc"
	echo "    'cp config_arm32-musl .config && ct-ng build'  for arm32 + musl"
	echo "    'cp config_x86_64 .config && ct-ng build'       for x86_64 + glibc"
	echo "    'cp config_riscv64 .config && ct-ng build'     for riscv64 + glibc"
	echo "    'cp config_riscv64-musl .config && ct-ng build' for riscv64 + musl"
}

main "$@"

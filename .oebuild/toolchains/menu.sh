#!/bin/bash
#
# menu.sh — openEuler Embedded 编译链统一构建入口
#
# 用户可通过本脚本一次性选择要构建的编译链（GCC 系列 / LLVM 主机工具链 /
# Clang+musl ARM32 专用），无需记三套分散的目录与命令。
#
# 默认自动启动 Docker 容器（openeuler-sdk:latest）进行构建，容器内 openeuler
# 用户的 UID/GID 会自动调整为与主机一致，避免挂载目录权限问题。
#
# 调用方式：
#   ./menu.sh                        # 交互式菜单
#   ./menu.sh <choice> [mode]       # 非交互调用
#
#   choice 取值：
#     gcc-aarch64, gcc-aarch64-musl, gcc-arm32, gcc-arm32-musl,
#     gcc-x86_64, gcc-riscv64, gcc-riscv64-musl,
#     llvm, clang-musl-arm32
#     （或别名 aarch64 / arm32 / x86_64 / riscv64 / clang-musl 等）
#
#   mode 取值：
#     auto（默认）           自动启动容器，跑完 prepare + build
#     interactive            容器内准备源码后进入交互 shell
#     raw                    全手动：只打印 docker 命令与构建步骤，不执行
#
# 环境变量：
#   DOCKER_IMAGE            容器镜像名（默认 openeuler-sdk:latest）
#   OUTPUT_DIR              统一产物输出目录（默认 menu.sh 同级 output/）
#   WORK_BASE               工作目录基址（默认 menu.sh 同级 work/）
#
# 详见 .oebuild/toolchains/README.md。
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
	THIS_SCRIPT="${PWD}/menu.sh"
fi
THIS_SCRIPT="$(resolve_script_dir "${THIS_SCRIPT}")"
TOOLCHAINS_DIR="$(cd "$(dirname "${THIS_SCRIPT}")" && pwd)"
OEBUILD_DIR="$(cd "${TOOLCHAINS_DIR}/.." && pwd)"
YOCTO_DIR="$(cd "${OEBUILD_DIR}/.." && pwd)"

# ---------------------------------------------------------------------------
# 容器配置
# ---------------------------------------------------------------------------
DOCKER_IMAGE="${DOCKER_IMAGE:-openeuler-sdk:latest}"
HOST_UID="$(id -u)"
HOST_GID="$(id -g)"

# MOUNT_ROOT: 挂载到容器中的根目录（repo 上两级，覆盖 repo + build/）
MOUNT_ROOT="$(cd "${YOCTO_DIR}/../.." && pwd)"

# 统一产物输出目录（menu.sh 所在目录下的 output/）
OUTPUT_DIR="${OUTPUT_DIR:-${TOOLCHAINS_DIR}/output}"

# 工作目录基址
# 默认工作目录基址（menu.sh 所在目录下的 work/）
WORK_BASE="${WORK_BASE:-${TOOLCHAINS_DIR}/work}"

# ---------------------------------------------------------------------------
# 公共函数
# ---------------------------------------------------------------------------
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
info()  { echo -e "${GREEN}[INFO]${NC} $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*" >&2; exit 1; }
header(){ echo -e "${CYAN}=== $* ===${NC}"; }

die() { echo "Error: $*" >&2; exit 1; }

usage() {
	cat <<EOF
openEuler Embedded 编译链统一构建入口

用法:
  $0                          # 交互式菜单
  $0 <choice> [mode] [work_dir]

可选 choice:
  gcc-aarch64         arm64 + glibc 2.38 + gcc 12.3.0
  gcc-aarch64-musl    arm64 + musl 1.2.3 + gcc 10.3.0  (LEGACY)
  gcc-arm32           arm32 + glibc 2.38 + gcc 12.3.0
  gcc-arm32-musl      arm32 + musl 1.2.4 + gcc 12.3.0
  gcc-x86_64          x86_64 + glibc 2.38 + gcc 12.3.0
  gcc-riscv64         riscv64 + glibc 2.38 + gcc 12.3.0
  gcc-riscv64-musl    riscv64 + musl 1.2.4 + gcc 12.3.0
  llvm                LLVM 17.0.6 主机工具链 + aarch64 GCC 库集成
  clang-musl-arm32    Clang 19.1.7 + musl 1.2.4 ARM32 专用

可选 mode:
  auto         (默认) 自动启动容器，跑完 prepare + build
  interactive  容器内准备源码后进入交互 shell
  raw          只打印 docker 命令与构建步骤，不执行

可选 work_dir:
  构建工作目录，缺省为 ${TOOLCHAINS_DIR}/work/<choice>

环境变量:
  DOCKER_IMAGE  容器镜像名（默认 openeuler-sdk:latest）
  OUTPUT_DIR    统一产物输出目录
  WORK_BASE     工作目录基址

示例:
  $0 gcc-aarch64                  # 默认 auto，构建 aarch64 gcc 工具链
  $0 llvm interactive             # 交互模式准备 LLVM 构建
  $0 clang-musl-arm32 raw /tmp/w  # 在 /tmp/w 下原始模式打印命令
EOF
}

# ---------------------------------------------------------------------------
# 容器管理
# ---------------------------------------------------------------------------
check_docker() {
	command -v docker >/dev/null 2>&1 || die "docker not found. Please install Docker first."
	if ! docker image inspect "${DOCKER_IMAGE}" >/dev/null 2>&1; then
		warn "Docker image '${DOCKER_IMAGE}' not found locally."
		local dockerfile_dir="${OEBUILD_DIR}/dockerfile/openeuler-sdk"
		if [ -d "${dockerfile_dir}" ]; then
			info "Building image from ${dockerfile_dir} ..."
			docker build -t "${DOCKER_IMAGE}" "${dockerfile_dir}"
		else
			die "Dockerfile not found at ${dockerfile_dir}. Please build the image manually."
		fi
	fi
}

# 生成容器入口脚本：UID 匹配 + 以 openeuler 用户执行
generate_container_entry() {
	local entry_script="$1" exec_cmd="$2" work_dir="$3"
	mkdir -p "$(dirname "${entry_script}")"

	cat > "${entry_script}" <<INNER
#!/bin/bash
set -e

# 将容器内 openeuler 用户的 UID/GID 改为与主机一致
if [ "${HOST_UID}" != "1000" ] || [ "${HOST_GID}" != "1000" ]; then
	usermod -u ${HOST_UID} -g ${HOST_GID} openeuler 2>/dev/null || true
	chown -R openeuler:openeuler /home/openeuler 2>/dev/null || true
fi

# 以 openeuler 用户执行
exec su -s /bin/bash openeuler -c "cd '${work_dir}' && ${exec_cmd}"
INNER
	chmod +x "${entry_script}"
}

# 在容器中执行构建脚本（auto 模式）
run_in_container() {
	local work_dir="$1" build_script="$2"
	local entry_script="${work_dir}/.container-entry.sh"
	generate_container_entry "${entry_script}" "bash '${build_script}'" "${work_dir}"

	info "启动容器 ${DOCKER_IMAGE} ..."
	info "  挂载: ${MOUNT_ROOT}"
	info "  UID:  ${HOST_UID}:${HOST_GID}"

	docker run --rm \
		-v "${MOUNT_ROOT}:${MOUNT_ROOT}" \
		-e CT_PREFIX="${OUTPUT_DIR}" \
		-e HOME=/home/openeuler \
		--user 0:0 \
		"${DOCKER_IMAGE}" \
		bash "${entry_script}"
}

# 启动交互式容器（interactive 模式，prepare 后用户手动操作）
run_interactive_container() {
	local work_dir="$1"
	local entry_script="${work_dir}/.container-entry.sh"

	cat > "${entry_script}" <<INNER
#!/bin/bash
set -e

if [ "${HOST_UID}" != "1000" ] || [ "${HOST_GID}" != "1000" ]; then
	usermod -u ${HOST_UID} -g ${HOST_GID} openeuler 2>/dev/null || true
	chown -R openeuler:openeuler /home/openeuler 2>/dev/null || true
fi

exec su -s /bin/bash openeuler
INNER
	chmod +x "${entry_script}"

	info "启动交互式容器 ${DOCKER_IMAGE}（退出请输入 exit）"

	docker run --rm -it \
		-v "${MOUNT_ROOT}:${MOUNT_ROOT}" \
		-e CT_PREFIX="${OUTPUT_DIR}" \
		-e HOME=/home/openeuler \
		-e WORK_DIR="${work_dir}" \
		--user 0:0 \
		"${DOCKER_IMAGE}" \
		bash "${entry_script}"
}

# 打印 raw 模式的 docker 命令
print_raw_docker_cmd() {
	echo "  docker run --rm -it \\"
	echo "    -v ${MOUNT_ROOT}:${MOUNT_ROOT} \\"
	echo "    -e CT_PREFIX=${OUTPUT_DIR} \\"
	echo "    -e HOME=/home/openeuler \\"
	echo "    --user 0:0 \\"
	echo "    ${DOCKER_IMAGE} bash"
}

# ---------------------------------------------------------------------------
# 编译链注册表：choice → 子目录 + 适配函数
# ---------------------------------------------------------------------------
# 字段顺序：choice|display_name|kind|subdir|extra_note
REGISTRY=(
	"gcc-aarch64|aarch64 + glibc 2.38 + gcc 12.3.0|gcc|gcc|"
	"gcc-aarch64-musl|aarch64 + musl 1.2.3 + gcc 10.3.0 (LEGACY)|gcc|gcc|LEGACY"
	"gcc-arm32|arm32 + glibc 2.38 + gcc 12.3.0|gcc|gcc|"
	"gcc-arm32-musl|arm32 + musl 1.2.4 + gcc 12.3.0|gcc|gcc|"
	"gcc-x86_64|x86_64 + glibc 2.38 + gcc 12.3.0|gcc|gcc|"
	"gcc-riscv64|riscv64 + glibc 2.38 + gcc 12.3.0|gcc|gcc|"
	"gcc-riscv64-musl|riscv64 + musl 1.2.4 + gcc 12.3.0|gcc|gcc|"
	"llvm|LLVM 17.0.6 主机工具链 + aarch64 GCC 集成|llvm|llvm|"
	"clang-musl-arm32|Clang 19.1.7 + musl 1.2.4 ARM32 专用|clang-musl-arm32|clang-musl-arm32|"
)

# 短别名映射
ALIAS=(
	"aarch64:gcc-aarch64"
	"aarch64-musl:gcc-aarch64-musl"
	"arm32:gcc-arm32"
	"arm32-musl:gcc-arm32-musl"
	"x86_64:gcc-x86_64"
	"riscv64:gcc-riscv64"
	"riscv64-musl:gcc-riscv64-musl"
)

resolve_choice() {
	local input="$1"
	# 直接匹配注册表
	for row in "${REGISTRY[@]}"; do
		local key="${row%%|*}"
		if [ "${key}" = "${input}" ]; then
			echo "${row}"
			return 0
		fi
	done
	# 别名
	for a in "${ALIAS[@]}"; do
		local k="${a%%:*}" v="${a##*:}"
		if [ "${k}" = "${input}" ]; then
			for row in "${REGISTRY[@]}"; do
				local key="${row%%|*}"
				[ "${key}" = "${v}" ] && { echo "${row}"; return 0; }
			done
		fi
	done
	return 1
}

# ---------------------------------------------------------------------------
# 交互式菜单
# ---------------------------------------------------------------------------
show_container_info() {
	info "容器镜像: ${DOCKER_IMAGE}"
	if ! docker image inspect "${DOCKER_IMAGE}" >/dev/null 2>&1; then
		warn "  镜像未找到，首次运行将自动构建"
	fi
	info "  挂载根: ${MOUNT_ROOT}"
	info "  产物目录: ${OUTPUT_DIR}"
	echo
}

interactive_menu() {
	while true; do
		echo
		header "openEuler Embedded 编译链构建菜单"
		show_container_info
		echo "请选择要构建的编译链："
		local idx=1
		local map=()
		for row in "${REGISTRY[@]}"; do
			local choice kind note
			choice="${row%%|*}"; row="${row#*|}"
			local name="${row%%|*}"; row="${row#*|}"
			kind="${row%%|*}"; row="${row#*|}"
			note="${row#*|}"
			printf "  [%d] %-22s %s%s\n" "${idx}" "${choice}" "${name}" "${note:+  (${note})}"
			map[idx]="${choice}"
			idx=$((idx+1))
		done
		echo
		echo "请选择构建模式："
		echo "  [a] Auto         (自动启动容器，跑完 prepare + build)"
		echo "  [i] Interactive  (容器内准备源码，进入交互 shell)"
		echo "  [r] Raw          (只打印 docker 命令与构建步骤，不执行)"
		echo
		read -r -p "选择编译链 [1-$((idx-1))] 或 q 退出: " sel
		[ "${sel}" = "q" ] || [ "${sel}" = "Q" ] && { info "退出"; exit 0; }
		if ! [[ "${sel}" =~ ^[0-9]+$ ]] || [ "${sel}" -lt 1 ] || [ "${sel}" -gt $((idx-1)) ]; then
			warn "无效选择：${sel}"; continue
		fi
		local choice="${map[sel]}"
		read -r -p "构建模式 [a/i/r] (默认 a): " mode_sel
		local mode="auto"
		case "${mode_sel}" in
			i|I) mode="interactive" ;;
			r|R) mode="raw" ;;
			*)  mode="auto" ;;
		esac
		read -r -p "work_dir (留空使用默认): " wd
		echo
		run_choice "${choice}" "${mode}" "${wd}"
		return 0
	done
}

# ---------------------------------------------------------------------------
# dispatch：根据 choice 调用对应子目录的 prepare/build 脚本
# ---------------------------------------------------------------------------
run_choice() {
	local choice="$1" mode="${2:-auto}" work_dir_arg="$3"
	local row name kind subdir note

	row=$(resolve_choice "${choice}") || die "unknown choice: ${choice}"
	choice="${row%%|*}"; row="${row#*|}"
	name="${row%%|*}"; row="${row#*|}"
	kind="${row%%|*}"; row="${row#*|}"
	subdir="${row%%|*}"; note="${row#*|}"

	local subdir_path="${TOOLCHAINS_DIR}/${subdir}"
	[ -d "${subdir_path}" ] || die "subdir '${subdir_path}' not found"

	local default_wd="${WORK_BASE}/${choice}"
	local work_dir
	if [ -n "${work_dir_arg}" ]; then
		mkdir -p "${work_dir_arg}"
		work_dir="$(cd "${work_dir_arg}" && pwd)"
	else
		mkdir -p "${default_wd}"
		work_dir="$(cd "${default_wd}" && pwd)"
	fi

	info "choice    = ${choice}"
	info "name      = ${name}"
	info "kind      = ${kind}"
	info "subdir    = ${subdir_path}"
	info "mode      = ${mode}"
	info "work_dir  = ${work_dir}"
	info "output    = ${OUTPUT_DIR}"
	echo

	case "${kind}" in
		gcc)              dispatch_gcc "${choice}" "${mode}" "${work_dir}" "${subdir_path}" ;;
		llvm)             dispatch_llvm "${choice}" "${mode}" "${work_dir}" "${subdir_path}" ;;
		clang-musl-arm32) dispatch_clang_musl_arm32 "${choice}" "${mode}" "${work_dir}" "${subdir_path}" ;;
		*) die "unknown kind: ${kind}" ;;
	esac
}

# ---------------------------------------------------------------------------
# GCC 系列 dispatch
#   gcc configs 中 config_aarch64 / config_arm32 / config_arm32-musl /
#   config_x86_64 / config_riscv64 / config_riscv64-musl / config_aarch64-musl
# ---------------------------------------------------------------------------
dispatch_gcc() {
	local choice="$1" mode="$2" work_dir="$3" subdir="$4"
	local config_name
	# 把 choice 转成 config 名（gcc-aarch64 → config_aarch64）
	config_name="config_${choice#gcc-}"

	local prepare="${subdir}/prepare.sh"
	local update="${subdir}/update.sh"
	local config_file="${subdir}/configs/${config_name}"
	[ -f "${config_file}" ] || die "config file '${config_file}' not found"

	case "${mode}" in
		auto)
			header "GCC Auto Build: ${choice}"
			check_docker
			mkdir -p "${work_dir}" "${OUTPUT_DIR}"

			local build_script="${work_dir}/.build-gcc.sh"
			cat > "${build_script}" <<BUILD
#!/bin/bash
set -e
export CT_NG_INSTALL_DIR_RO=n
cd "${work_dir}"

if [ ! -d "open_source" ]; then
	echo "=== [1/3] GCC Prepare ==="
	bash "${prepare}" "${work_dir}"
else
	echo "=== [1/3] GCC Prepare (already done, skipping) ==="
fi

echo ""
echo "=== [2/3] GCC Update ==="
bash "${update}" "${work_dir}"

echo ""
echo "=== [3/3] ct-ng Build: ${config_name} ==="
cp -f "${config_name}" .config
ct-ng build

echo ""
echo "GCC build done. 产物位于: \${CT_PREFIX}/"
chmod -R u+w "\${CT_PREFIX}/" 2>/dev/null || true
ls -la "\${CT_PREFIX}/" 2>/dev/null || true
BUILD
			chmod +x "${build_script}"

			run_in_container "${work_dir}" "${build_script}"
			info "GCC build complete. 产物位于 ${OUTPUT_DIR}/"
			;;
		interactive)
			header "GCC Interactive Build: ${choice}"
			check_docker
			mkdir -p "${work_dir}" "${OUTPUT_DIR}"

			local prepare_script="${work_dir}/.prepare-gcc.sh"
			cat > "${prepare_script}" <<PREP
#!/bin/bash
set -e
cd "${work_dir}"

if [ ! -d "open_source" ]; then
	bash "${prepare}" "${work_dir}"
else
	echo "Prepare (already done, skipping)"
fi

bash "${update}" "${work_dir}"
echo ""
echo "源码与配置已就绪。"
PREP
			chmod +x "${prepare_script}"

			run_in_container "${work_dir}" "${prepare_script}"
			info "进入交互式容器..."
			info "请在容器内执行："
			echo "  cd ${work_dir}"
			echo "  cp ${config_name} .config && ct-ng build"
			echo
			run_interactive_container "${work_dir}"
			;;
		raw)
			header "GCC Raw Build: ${choice}（仅打印命令，不执行）"
			echo "# 启动容器："
			print_raw_docker_cmd
			echo ""
			echo "# 容器内命令序列："
			echo "  cd ${work_dir}"
			echo "  bash ${prepare} ${work_dir}"
			echo "  bash ${update} ${work_dir}"
			echo "  cp ${config_name} .config && ct-ng build"
			;;
		*) die "unknown mode: ${mode}" ;;
	esac
}

# ---------------------------------------------------------------------------
# LLVM 主机工具链 dispatch
#   prepare: 子目录 llvm/prepare.sh
#   build:   子目录 llvm/build.sh（包装，封装 llvm-project/build.sh + 集成）
# ---------------------------------------------------------------------------
dispatch_llvm() {
	local choice="$1" mode="$2" work_dir="$3" subdir="$4"
	local prepare="${subdir}/prepare.sh"
	local build="${subdir}/build.sh"

	case "${mode}" in
		auto)
			header "LLVM Auto Build"
			check_docker
			mkdir -p "${work_dir}" "${OUTPUT_DIR}"

			local build_script="${work_dir}/.build-llvm.sh"
			cat > "${build_script}" <<BUILD
#!/bin/bash
set -e
cd "${work_dir}"

if [ ! -d "open_source/llvm-project/.git" ]; then
	echo "=== [1/2] LLVM Prepare ==="
	bash "${prepare}" "${work_dir}"
else
	echo "=== [1/2] LLVM Prepare (already done, skipping) ==="
fi

echo ""
echo "=== [2/2] LLVM Build ==="
bash "${build}" "${work_dir}"

echo ""
echo "LLVM build done."
LLVM_OUTPUT="${work_dir}/open_source/llvm-project/clang-llvm-17.0.6"
if [ -d "\${LLVM_OUTPUT}" ]; then
	chmod -R u+w "${OUTPUT_DIR}/clang-llvm-17.0.6" 2>/dev/null || true
	rm -rf "${OUTPUT_DIR}/clang-llvm-17.0.6"
	cp -rf "\${LLVM_OUTPUT}" "${OUTPUT_DIR}/"
	echo "Output copied to ${OUTPUT_DIR}/clang-llvm-17.0.6"
fi
BUILD
			chmod +x "${build_script}"

			run_in_container "${work_dir}" "${build_script}"
			info "LLVM build complete. 产物位于 ${OUTPUT_DIR}/clang-llvm-17.0.6/"
			;;
		interactive)
			header "LLVM Interactive Build"
			check_docker
			mkdir -p "${work_dir}" "${OUTPUT_DIR}"

			local prepare_script="${work_dir}/.prepare-llvm.sh"
			cat > "${prepare_script}" <<PREP
#!/bin/bash
set -e
cd "${work_dir}"

if [ ! -d "open_source/llvm-project/.git" ]; then
	bash "${prepare}" "${work_dir}"
else
	echo "Prepare (already done, skipping)"
fi
echo ""
echo "LLVM source ready."
PREP
			chmod +x "${prepare_script}"

			run_in_container "${work_dir}" "${prepare_script}"
			info "进入交互式容器..."
			info "请在容器内执行："
			echo "  cd ${work_dir}"
			echo "  bash ${build} ${work_dir}"
			echo
			run_interactive_container "${work_dir}"
			;;
		raw)
			header "LLVM Raw Build（仅打印命令，不执行）"
			echo "# 启动容器："
			print_raw_docker_cmd
			echo ""
			echo "# 容器内命令序列："
			echo "  cd ${work_dir}"
			echo "  bash ${prepare} ${work_dir}"
			echo "  bash ${build} ${work_dir}"
			;;
		*) die "unknown mode: ${mode}" ;;
	esac
}

# ---------------------------------------------------------------------------
# Clang+musl ARM32 dispatch
#   prepare: 子目录 clang-musl-arm32/prepare.sh
#   build:   子目录 clang-musl-arm32/build-llvm-musl-arm32.sh
# ---------------------------------------------------------------------------
dispatch_clang_musl_arm32() {
	local choice="$1" mode="$2" work_dir="$3" subdir="$4"
	local prepare="${subdir}/prepare.sh"
	local build="${subdir}/build-llvm-musl-arm32.sh"

	# 读 config.xml 拿到依赖目录名
	local cfg="${subdir}/configs/config.xml"
	# shellcheck disable=SC1091
	source "${cfg}"

	local gcc_musl_dir="${work_dir}/open_source/${GCC_MUSL}"
	local llvm_src="${work_dir}/open_source/${LLVM}"
	local musl_src="${work_dir}/open_source/${MUSL}/"
	local cm_output="${work_dir}/toolchain"

	case "${mode}" in
		auto)
			header "Clang+musl ARM32 Auto Build"
			check_docker
			mkdir -p "${work_dir}" "${OUTPUT_DIR}"

			local build_script="${work_dir}/.build-clang-musl.sh"
			cat > "${build_script}" <<BUILD
#!/bin/bash
set -e
cd "${work_dir}"

if [ ! -d "open_source/${GCC_MUSL}" ]; then
	echo "=== [1/2] Clang+musl Prepare ==="
	bash "${prepare}" "${work_dir}"
else
	echo "=== [1/2] Clang+musl Prepare (already done, skipping) ==="
fi

echo ""
echo "=== [2/2] Clang+musl Build ==="
bash "${build}" all \
	--gcc-dir   "${gcc_musl_dir}" \
	--llvm-src  "${llvm_src}" \
	--musl-src  "${musl_src}" \
	--output-dir "${cm_output}"

echo ""
echo "Clang+musl build done."
CM_OUT="${cm_output}/llvm-musl-arm"
if [ -d "\${CM_OUT}" ]; then
	chmod -R u+w "${OUTPUT_DIR}/llvm-musl-arm" 2>/dev/null || true
	rm -rf "${OUTPUT_DIR}/llvm-musl-arm"
	cp -rf "\${CM_OUT}" "${OUTPUT_DIR}/"
	echo "Output copied to ${OUTPUT_DIR}/llvm-musl-arm"
fi
BUILD
			chmod +x "${build_script}"

			run_in_container "${work_dir}" "${build_script}"
			info "Clang+musl ARM32 build complete. 产物位于 ${OUTPUT_DIR}/llvm-musl-arm/"
			;;
		interactive)
			header "Clang+musl ARM32 Interactive Build"
			check_docker
			mkdir -p "${work_dir}" "${OUTPUT_DIR}"

			local prepare_script="${work_dir}/.prepare-clang-musl.sh"
			cat > "${prepare_script}" <<PREP
#!/bin/bash
set -e
cd "${work_dir}"

if [ ! -d "open_source/${GCC_MUSL}" ]; then
	bash "${prepare}" "${work_dir}"
else
	echo "Prepare (already done, skipping)"
fi
echo ""
echo "Clang+musl source ready."
PREP
			chmod +x "${prepare_script}"

			run_in_container "${work_dir}" "${prepare_script}"
			info "进入交互式容器..."
			info "请在容器内执行："
			echo "  cd ${work_dir}"
			echo "  bash ${build} all \\"
			echo "    --gcc-dir ${gcc_musl_dir} \\"
			echo "    --llvm-src ${llvm_src} \\"
			echo "    --musl-src ${musl_src} \\"
			echo "    --output-dir ${cm_output}"
			echo
			run_interactive_container "${work_dir}"
			;;
		raw)
			header "Clang+musl ARM32 Raw Build（仅打印命令，不执行）"
			echo "# 启动容器："
			print_raw_docker_cmd
			echo ""
			echo "# 容器内命令序列："
			echo "  cd ${work_dir}"
			echo "  bash ${prepare} ${work_dir}"
			echo "  bash ${build} all \\"
			echo "    --gcc-dir ${gcc_musl_dir} \\"
			echo "    --llvm-src ${llvm_src} \\"
			echo "    --musl-src ${musl_src} \\"
			echo "    --output-dir ${cm_output}"
			;;
		*) die "unknown mode: ${mode}" ;;
	esac
}

# ---------------------------------------------------------------------------
# main
# ---------------------------------------------------------------------------
main() {
	if [ $# -ge 1 ]; then
		case "$1" in
			-h|--help) usage; exit 0 ;;
		esac
		local choice="$1" mode="${2:-auto}" wd="${3:-}"
		run_choice "${choice}" "${mode}" "${wd}"
	else
		interactive_menu
	fi
}

main "$@"

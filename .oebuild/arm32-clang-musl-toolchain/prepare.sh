#!/bin/bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info()  { echo -e "${GREEN}[INFO]${NC} $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }

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

    for i in $(seq 1 ${GCC_MUSL_SPLIT_COUNT}); do
        local url="${DOWNLOAD_BASE_URL}/${GCC_MUSL_RELEASE_TAG}/${i}_${GCC_MUSL}.tar.gz"
        local part_file="${tmp_dir}/${i}_${GCC_MUSL}.tar.gz"
        if [ -f "${part_file}" ]; then
            info "  Part ${i} already downloaded, skip"
        else
            info "  Downloading part ${i} from ${url}..."
            curl -sL "${url}" -o "${part_file}" || error "Failed to download part ${i}"
        fi
    done

    info "  Merging split files..."
    cat $(for i in $(seq 1 ${GCC_MUSL_SPLIT_COUNT}); do echo "${tmp_dir}/${i}_${GCC_MUSL}.tar.gz"; done) \
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
    cd "${musl_dir}"
    git remote add origin "${MUSL_REPO_URL}"
    git fetch origin "${MUSL_COMMIT}" --depth 1
    git checkout FETCH_HEAD
    cd -
    info "${MUSL} downloaded to ${musl_dir}"
}

do_prepare() {
    local lib_path="$1"

    mkdir -p "${lib_path}"
    download_gcc_musl "${lib_path}"
    download_llvm_source "${lib_path}"
    download_musl_source "${lib_path}"
}

usage() {
    echo -e "Tip: sh arm32-clang-musl-toolchain/prepare.sh [work_dir]\n"
    echo -e "  work_dir: working directory for downloads (default: script directory)\n"
}

check_use() {
	if [ -n "$BASH_SOURCE" ]; then
		THIS_SCRIPT="$BASH_SOURCE"
	elif [ -n "$ZSH_NAME" ]; then
		THIS_SCRIPT="$0"
	else
		THIS_SCRIPT="$0"
	fi

	if [ ! -e "$THIS_SCRIPT" ]; then
		echo "Error: $THIS_SCRIPT doesn't exist!" >&2
		return 1
	fi
}

main() {
    usage
    check_use || return 1

    WORK_DIR="$1"
    SRC_DIR="$(cd $(dirname $0)/;pwd)"
    SRC_DIR="$(realpath ${SRC_DIR})"
    if [ -z "${WORK_DIR}" ]; then
        WORK_DIR=$SRC_DIR
        echo "use default work dir: $WORK_DIR"
    fi
    WORK_DIR="$(realpath ${WORK_DIR})"

    . "${SRC_DIR}/configs/config.xml"
    readonly LIB_PATH="${WORK_DIR}/open_source"

    info "Checking prerequisites..."
    command -v git >/dev/null 2>&1 || error "git not installed"
    command -v curl >/dev/null 2>&1 || error "curl not installed"
    command -v tar >/dev/null 2>&1 || error "tar not installed"

    do_prepare "${LIB_PATH}"

    echo ""
    echo "Prepare done! Now you can run:"
    echo "  cd ${WORK_DIR}"
    echo "  ./arm32-clang-musl-toolchain/build-llvm-musl-arm32.sh all \\"
    echo "      --gcc-dir ./open_source/${GCC_MUSL} \\"
    echo "      --llvm-src ./open_source/${LLVM} \\"
    echo "      --musl-src ./open_source/${MUSL}/ \\"
    echo "      --output-dir ./toolchain"
}

main "$@"
#!/bin/bash
set -e

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

TARGET=arm-openeuler-linux-musleabi
TARGET_ARCH=arm
MUSL_VERSION=1.2.4
CLANG_VERSION=19

GCC_TOOLCHAIN_DIR=""
LLVM_SRC_DIR=""
MUSL_SRC_DIR=""
OUTPUT_DIR=""
TOOLCHAIN_DIR=""
SYSROOT=""
LLVM_PATCHED_SRC_DIR=""
MUSL_PATCHED_SRC_DIR=""

BUILD_DIR_LLVM=""
BUILD_DIR_COMPILER_RT=""
BUILD_DIR_LIBUNWIND=""
BUILD_DIR_MUSL=""

NPROC=$(nproc)

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info()  { echo -e "${GREEN}[INFO]${NC} $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }

check_prerequisites() {
    info "检查前置条件..."

    [ -d "${GCC_TOOLCHAIN_DIR}" ] || error "GCC交叉编译链目录不存在: ${GCC_TOOLCHAIN_DIR}"
    [ -d "${LLVM_SRC_DIR}" ] || error "LLVM源码目录不存在: ${LLVM_SRC_DIR}"
    [ -d "${MUSL_SRC_DIR}" ] || error "musl源码目录不存在: ${MUSL_SRC_DIR}"

    command -v cmake >/dev/null 2>&1 || error "cmake未安装"
    ninja --version >/dev/null 2>&1 || command -v make >/dev/null 2>&1 || error "ninja或make未安装"

    GCC_VERSION=$(ls "${GCC_TOOLCHAIN_DIR}/lib/gcc/${TARGET}/" 2>/dev/null | head -1)
    [ -n "${GCC_VERSION}" ] || error "无法确定GCC版本"
    info "GCC版本: ${GCC_VERSION}"
}

copy_and_patch_sources() {
    info "========================================="
    info "拷贝源码到输出目录并应用补丁..."
    info "========================================="
    
    LLVM_PATCHED_SRC_DIR="${OUTPUT_DIR}/llvm-project-src"
    MUSL_PATCHED_SRC_DIR="${OUTPUT_DIR}/musl-src"
    
    if [ -d "${LLVM_PATCHED_SRC_DIR}" ]; then
        info "  LLVM源码已存在，跳过拷贝"
    else
        info "  拷贝LLVM源码到 ${LLVM_PATCHED_SRC_DIR}..."
        cp -a "${LLVM_SRC_DIR}" "${LLVM_PATCHED_SRC_DIR}"
    fi
    
    if [ -d "${MUSL_PATCHED_SRC_DIR}/musl-${MUSL_VERSION}" ]; then
        info "  musl源码已存在，跳过拷贝和解压"
    else
        info "  拷贝musl源码到 ${MUSL_PATCHED_SRC_DIR}..."
        cp -a "${MUSL_SRC_DIR}" "${MUSL_PATCHED_SRC_DIR}"
        info "  解压musl源码tar包..."
        tar xzf "${MUSL_PATCHED_SRC_DIR}/musl-${MUSL_VERSION}.tar.gz" -C "${MUSL_PATCHED_SRC_DIR}"
    fi
    
    info "  应用compiler-rt补丁..."
    patch_compiler_rt_for_musl
    
    info "  应用libunwind补丁..."
    patch_libunwind_for_arm
    
    info "源码拷贝和补丁应用完成"
}

patch_compiler_rt_for_musl() {
    info "为compiler-rt应用musl兼容补丁..."

    local SANITIZER_LINUX="${LLVM_PATCHED_SRC_DIR}/compiler-rt/lib/sanitizer_common/sanitizer_linux.cpp"
    local SANITIZER_LIMITS="${LLVM_PATCHED_SRC_DIR}/compiler-rt/lib/sanitizer_common/sanitizer_platform_limits_posix.h"

    info "  修补 sanitizer_platform_limits_posix.h..."
    export SANITIZER_LIMITS_PATH="${SANITIZER_LIMITS}"
    python3 << 'PYEOF'
import os

filepath = os.environ["SANITIZER_LIMITS_PATH"]

with open(filepath, 'r') as f:
    content = f.read()

old = """#elif SANITIZER_GLIBC || SANITIZER_ANDROID
#define SANITIZER_HAS_STAT64 1
#define SANITIZER_HAS_STATFS64 1
#endif"""

new = """#elif SANITIZER_GLIBC || SANITIZER_ANDROID
#define SANITIZER_HAS_STAT64 1
#define SANITIZER_HAS_STATFS64 1
// SANITIZER_MUSL_STAT64_PATCHED
#else
#define SANITIZER_HAS_STAT64 0
#define SANITIZER_HAS_STATFS64 0
#endif"""

if old in content:
    content = content.replace(old, new)
    with open(filepath, 'w') as f:
        f.write(content)
    print("  已修补 sanitizer_platform_limits_posix.h")
else:
    print("  警告: 未找到需要修补的代码块，可能源码版本不同")
PYEOF
    
    info "  修补 sanitizer_linux.cpp..."
    export SANITIZER_LINUX_PATH="${SANITIZER_LINUX}"
    python3 << 'PYEOF'
import os
import re

filepath = os.environ["SANITIZER_LINUX_PATH"]

with open(filepath, 'r') as f:
    content = f.read()

patched = False

# 1. 删除 stat64_to_stat 函数定义
pattern0 = r'#    if !SANITIZER_LINUX_USES_64BIT_SYSCALLS && SANITIZER_LINUX\nstatic void stat64_to_stat\(struct stat64 \*in, struct stat \*out\) \{[^}]*\}\n#    endif\n'
if re.search(pattern0, content):
    content = re.sub(pattern0, '', content)
    patched = True
    print("  已删除 stat64_to_stat 函数定义")

# 2. 替换 internal_stat 的 fstatat64 调用
pattern1 = r'#      else\n  struct stat64 buf64;\n  int res = internal_syscall\(SYSCALL\(fstatat64\), AT_FDCWD, \(uptr\)path,\n                             \(uptr\)&buf64, 0\);\n  stat64_to_stat\(&buf64, \(struct stat \*\)buf\);\n  return res;\n#      endif'
replacement1 = '#      else\n  int res = internal_syscall(SYSCALL(stat), path, (uptr)buf);\n  return res;\n#      endif'
if re.search(pattern1, content):
    content = re.sub(pattern1, replacement1, content)
    patched = True
    print("  已替换 internal_stat 的 fstatat64 调用")

# 3. 替换 internal_lstat 的 fstatat64 调用
pattern2 = r'#      else\n  struct stat64 buf64;\n  int res = internal_syscall\(SYSCALL\(fstatat64\), AT_FDCWD, \(uptr\)path,\n                             \(uptr\)&buf64, AT_SYMLINK_NOFOLLOW\);\n  stat64_to_stat\(&buf64, \(struct stat \*\)buf\);\n  return res;\n#      endif'
replacement2 = '#      else\n  int res = internal_syscall(SYSCALL(lstat), path, (uptr)buf);\n  return res;\n#      endif'
if re.search(pattern2, content):
    content = re.sub(pattern2, replacement2, content)
    patched = True
    print("  已替换 internal_lstat 的 fstatat64 调用")

# 4. 替换 internal_fstat 的 fstat64 调用
pattern3 = r'#    else\n  struct stat64 buf64;\n  int res = internal_syscall\(SYSCALL\(fstat64\), fd, &buf64\);\n  stat64_to_stat\(&buf64, \(struct stat \*\)buf\);\n  return res;\n#    endif'
replacement3 = '#    else\n  int res = internal_syscall(SYSCALL(fstat), fd, (uptr)buf);\n  return res;\n#    endif'
if re.search(pattern3, content):
    content = re.sub(pattern3, replacement3, content)
    patched = True
    print("  已替换 internal_fstat 的 fstat64 调用")

if patched:
    content = "// SANITIZER_MUSL_STAT64_PATCHED\n" + content
    with open(filepath, 'w') as f:
        f.write(content)
    print("  已应用stat64->stat补丁")
else:
    print("  警告: 未找到需要修补的代码块，可能源码版本不同")
PYEOF

    info "  compiler-rt musl补丁处理完成"
}

patch_libunwind_for_arm() {
    info "为libunwind应用ARM汇编支持补丁..."

    local LIBUNWIND_CMAKELISTS="${LLVM_PATCHED_SRC_DIR}/libunwind/CMakeLists.txt"
    local LIBUNWIND_SRC_CMAKELISTS="${LLVM_PATCHED_SRC_DIR}/libunwind/src/CMakeLists.txt"

    info "  添加 LIBUNWIND_ENABLE_ASSEMBLY 选项..."
    sed -i '/option(LIBUNWIND_ENABLE_FRAME_APIS/a option(LIBUNWIND_ENABLE_ASSEMBLY "Enable assembly support" ON)' "${LIBUNWIND_CMAKELISTS}"

    info "  在libunwind/src/CMakeLists.txt中添加ASM支持..."
    sed -i '1i enable_language(ASM)\n' "${LIBUNWIND_SRC_CMAKELISTS}"

    info "  libunwind ARM补丁处理完成"
}

build_llvm() {
    info "========================================="
    info "第1步: 构建LLVM/Clang/LLD (主机工具链)"
    info "========================================="

    rm -rf "${BUILD_DIR_LLVM}"
    mkdir -p "${BUILD_DIR_LLVM}"
    cd "${BUILD_DIR_LLVM}"

    cmake -G Ninja "${LLVM_PATCHED_SRC_DIR}/llvm" \
        -DCMAKE_INSTALL_PREFIX="${TOOLCHAIN_DIR}" \
        -DCMAKE_BUILD_TYPE=Release \
        -DLLVM_TARGETS_TO_BUILD=ARM \
        -DLLVM_ENABLE_PROJECTS="clang;lld" \
        -DLLVM_ENABLE_RTTI=ON \
        -DLLVM_ENABLE_TERMINFO=OFF \
        -DLLVM_ENABLE_LIBXML2=OFF \
        -DLLVM_ENABLE_ZLIB=OFF \
        -DLLVM_ENABLE_ZSTD=OFF \
        -DLLVM_BUILD_UTILS=OFF \
        -DLLVM_BUILD_TESTS=OFF \
        -DLLVM_BUILD_BENCHMARKS=OFF \
        -DLLVM_BUILD_DOCS=OFF \
        -DLLVM_INCLUDE_TESTS=OFF \
        -DLLVM_INCLUDE_BENCHMARKS=OFF \
        -DLLVM_INCLUDE_DOCS=OFF \
        -DLLVM_INCLUDE_EXAMPLES=OFF \
        -DCLANG_ENABLE_ARCMT=OFF \
        -DCLANG_ENABLE_STATIC_ANALYZER=OFF \
        -DCLANG_INCLUDE_TESTS=OFF \
        -DLLVM_DEFAULT_TARGET_TRIPLE=${TARGET} \
        -DLLVM_ENABLE_PIC=ON

    cmake --build . -j${NPROC}
    cmake --install .

    info "LLVM/Clang/LLD构建安装完成"
}

build_compiler_rt() {
    info "========================================="
    info "第2步: 构建compiler-rt (目标平台运行时)"
    info "========================================="

    rm -rf "${BUILD_DIR_COMPILER_RT}"
    mkdir -p "${BUILD_DIR_COMPILER_RT}"
    cd "${BUILD_DIR_COMPILER_RT}"

    local CLANG_PATH="${TOOLCHAIN_DIR}/bin/clang"
    local GCC_INSTALL_DIR="${GCC_TOOLCHAIN_DIR}"

    cmake -G Ninja "${LLVM_PATCHED_SRC_DIR}/compiler-rt" \
        -DCMAKE_C_COMPILER="${CLANG_PATH}" \
        -DCMAKE_CXX_COMPILER="${TOOLCHAIN_DIR}/bin/clang++" \
        -DCMAKE_AR="${TOOLCHAIN_DIR}/bin/llvm-ar" \
        -DCMAKE_NM="${TOOLCHAIN_DIR}/bin/llvm-nm" \
        -DCMAKE_RANLIB="${TOOLCHAIN_DIR}/bin/llvm-ranlib" \
        -DCMAKE_LINKER="${TOOLCHAIN_DIR}/bin/ld.lld" \
        -DCMAKE_C_COMPILER_TARGET="${TARGET}" \
        -DCMAKE_C_FLAGS="--target=${TARGET} --sysroot=${GCC_INSTALL_DIR}/${TARGET}/sysroot --gcc-toolchain=${GCC_INSTALL_DIR} -march=armv7-a -mfpu=vfpv3-d16 -mfloat-abi=hard -fuse-ld=lld" \
        -DCMAKE_CXX_FLAGS="--target=${TARGET} --sysroot=${GCC_INSTALL_DIR}/${TARGET}/sysroot --gcc-toolchain=${GCC_INSTALL_DIR} -march=armv7-a -mfpu=vfpv3-d16 -mfloat-abi=hard -fuse-ld=lld" \
        -DCMAKE_ASM_FLAGS="--target=${TARGET} -march=armv7-a -mfpu=vfpv3-d16 -mfloat-abi=hard" \
        -DCMAKE_EXE_LINKER_FLAGS="-fuse-ld=lld" \
        -DCMAKE_INSTALL_PREFIX="${TOOLCHAIN_DIR}" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCOMPILER_RT_BUILD_SANITIZERS=OFF \
        -DCOMPILER_RT_BUILD_XRAY=OFF \
        -DCOMPILER_RT_BUILD_LIBFUZZER=OFF \
        -DCOMPILER_RT_BUILD_PROFILE=OFF \
        -DCOMPILER_RT_BUILD_MEMPROF=OFF \
        -DCOMPILER_RT_BUILD_ORC=ON \
        -DCOMPILER_RT_DEFAULT_TARGET_ONLY=ON \
        -DLLVM_CONFIG_PATH="${TOOLCHAIN_DIR}/bin/llvm-config"

    cmake --build . -j${NPROC}
    cmake --install .

    local CLANG_LIB_DIR="${TOOLCHAIN_DIR}/lib/clang/${CLANG_VERSION}/lib/${TARGET}"
    local LINUX_RT_DIR="${TOOLCHAIN_DIR}/lib/linux"

    mkdir -p "${CLANG_LIB_DIR}"
    if [ -f "${LINUX_RT_DIR}/libclang_rt.builtins-arm.a" ]; then
        cp "${LINUX_RT_DIR}/libclang_rt.builtins-arm.a" "${CLANG_LIB_DIR}/libclang_rt.builtins.a"
        info "已复制 libclang_rt.builtins-arm.a 到 ${CLANG_LIB_DIR}"
    fi

    info "compiler-rt构建安装完成"
}

build_libunwind() {
    info "========================================="
    info "第3步: 构建libunwind (ARM异常处理库)"
    info "========================================="

    rm -rf "${BUILD_DIR_LIBUNWIND}"
    mkdir -p "${BUILD_DIR_LIBUNWIND}"
    cd "${BUILD_DIR_LIBUNWIND}"

    local CLANG_PATH="${TOOLCHAIN_DIR}/bin/clang"
    local GCC_INSTALL_DIR="${GCC_TOOLCHAIN_DIR}"

    cmake -G Ninja "${LLVM_PATCHED_SRC_DIR}/libunwind" \
        -DCMAKE_C_COMPILER="${CLANG_PATH}" \
        -DCMAKE_CXX_COMPILER="${TOOLCHAIN_DIR}/bin/clang++" \
        -DCMAKE_AR="${TOOLCHAIN_DIR}/bin/llvm-ar" \
        -DCMAKE_NM="${TOOLCHAIN_DIR}/bin/llvm-nm" \
        -DCMAKE_RANLIB="${TOOLCHAIN_DIR}/bin/llvm-ranlib" \
        -DCMAKE_LINKER="${TOOLCHAIN_DIR}/bin/ld.lld" \
        -DCMAKE_C_FLAGS="--target=${TARGET} --sysroot=${GCC_INSTALL_DIR}/${TARGET}/sysroot --gcc-toolchain=${GCC_INSTALL_DIR} -march=armv7-a -mfpu=vfpv3-d16 -mfloat-abi=hard -D_LIBUNWIND_IS_BAREMETAL=1 -fuse-ld=lld" \
        -DCMAKE_CXX_FLAGS="--target=${TARGET} --sysroot=${GCC_INSTALL_DIR}/${TARGET}/sysroot --gcc-toolchain=${GCC_INSTALL_DIR} -march=armv7-a -mfpu=vfpv3-d16 -mfloat-abi=hard -D_LIBUNWIND_IS_BAREMETAL=1 -nostdinc++ -fuse-ld=lld" \
        -DCMAKE_EXE_LINKER_FLAGS="-fuse-ld=lld" \
        -DCMAKE_INSTALL_PREFIX="${TOOLCHAIN_DIR}" \
        -DCMAKE_BUILD_TYPE=Release \
        -DLIBUNWIND_ENABLE_SHARED=ON \
        -DLIBUNWIND_ENABLE_STATIC=ON \
        -DLIBUNWIND_ENABLE_CROSS_UNWINDING=ON \
        -DLIBUNWIND_ENABLE_ARM_WMMX=OFF \
        -DLIBUNWIND_ENABLE_ASSEMBLY=ON \
        -DLIBUNWIND_USE_COMPILER_RT=ON \
        -DLIBUNWIND_INSTALL_HEADERS=ON \
        -DLLVM_PATH="${LLVM_PATCHED_SRC_DIR}" \
        -DLLVM_ENABLE_RTTI=ON

    cmake --build . -j${NPROC}
    cmake --install .

    info "libunwind构建安装完成"
}

build_musl() {
    info "========================================="
    info "第4步: 构建musl C库 (使用新编译的clang)"
    info "========================================="

    local CLANG_PATH="${TOOLCHAIN_DIR}/bin/clang"

    create_symlinks

    rm -rf "${BUILD_DIR_MUSL}"
    mkdir -p "${BUILD_DIR_MUSL}"
    cd "${BUILD_DIR_MUSL}"

    export PATH="${TOOLCHAIN_DIR}/bin:${PATH}"

    CC="${CLANG_PATH} --target=${TARGET} -march=armv7-a -mfpu=vfpv3-d16 -mfloat-abi=hard -rtlib=compiler-rt -fuse-ld=lld" \
    "${MUSL_PATCHED_SRC_DIR}/musl-${MUSL_VERSION}/configure" \
        --target=${TARGET} \
        --prefix=/usr \
        --disable-wrapper \
        --enable-static \
        --enable-shared

    make -j${NPROC}

    make DESTDIR="${SYSROOT}" install

    info "musl C库构建安装完成"
}

setup_sysroot() {
    info "========================================="
    info "第5步: 设置sysroot (整合GCC运行时库)"
    info "========================================="

    local GCC_VERSION=$(ls "${GCC_TOOLCHAIN_DIR}/lib/gcc/${TARGET}/" | head -1)

    mkdir -p "${SYSROOT}/lib"
    cp -a "${GCC_TOOLCHAIN_DIR}/${TARGET}/sysroot/lib/"* "${SYSROOT}/lib/" 2>/dev/null || true

    mkdir -p "${TOOLCHAIN_DIR}/lib/gcc/${TARGET}/${GCC_VERSION}"
    cp -a "${GCC_TOOLCHAIN_DIR}/lib/gcc/${TARGET}/${GCC_VERSION}/"* "${TOOLCHAIN_DIR}/lib/gcc/${TARGET}/${GCC_VERSION}/" 2>/dev/null || true

    mkdir -p "${SYSROOT}/usr/include"
    cp -a "${GCC_TOOLCHAIN_DIR}/${TARGET}/include/"* "${SYSROOT}/usr/include/" 2>/dev/null || true

    local LINUX_RT_DIR="${SYSROOT}/lib/linux"
    mkdir -p "${LINUX_RT_DIR}"
    if [ -d "${BUILD_DIR_COMPILER_RT}/lib/linux" ]; then
        cp -a "${BUILD_DIR_COMPILER_RT}/lib/linux/"* "${LINUX_RT_DIR}/" 2>/dev/null || true
    fi

    info "sysroot设置完成"
}

create_symlinks() {
    info "========================================="
    info "第6步: 创建交叉编译器符号链接"
    info "========================================="

    cd "${TOOLCHAIN_DIR}/bin"

    ln -sf clang ${TARGET}-clang
    ln -sf clang++ ${TARGET}-clang++
    ln -sf clang-cpp ${TARGET}-clang-cpp
    ln -sf lld ${TARGET}-ld
    ln -sf lld ${TARGET}-ld.lld
    ln -sf llvm-ar ${TARGET}-ar
    ln -sf llvm-nm ${TARGET}-nm
    ln -sf llvm-objcopy ${TARGET}-objcopy
    ln -sf llvm-objdump ${TARGET}-objdump
    ln -sf llvm-ranlib ${TARGET}-ranlib
    ln -sf llvm-readelf ${TARGET}-readelf
    ln -sf llvm-strip ${TARGET}-strip
    ln -sf llvm-strings ${TARGET}-strings

    info "符号链接创建完成"
}

verify_toolchain() {
    info "========================================="
    info "第7步: 验证交叉编译链"
    info "========================================="

    local CLANG_PATH="${TOOLCHAIN_DIR}/bin/clang"

    info "  检查clang版本..."
    ${CLANG_PATH} --version | head -3

    info "  检查目标三元组..."
    ${CLANG_PATH} -print-target-triple

    info "  编译测试程序..."
    local TEST_DIR="${SCRIPT_DIR}/test-toolchain"
    mkdir -p "${TEST_DIR}"
    cat > "${TEST_DIR}/hello.c" << 'EOF'
#include <stdio.h>
int main() {
    printf("Hello from LLVM+musl ARM32 cross-compiler!\n");
    return 0;
}
EOF

    ${CLANG_PATH} --target=${TARGET} \
        --sysroot="${SYSROOT}" \
        --gcc-toolchain="${GCC_TOOLCHAIN_DIR}" \
        -march=armv7-a -mfpu=vfpv3-d16 -mfloat-abi=hard \
        -static \
        -fuse-ld=lld \
        -o "${TEST_DIR}/hello" "${TEST_DIR}/hello.c" && \
        info "  静态编译测试: 成功" || \
        warn "  静态编译测试: 失败"

    ${CLANG_PATH} --target=${TARGET} \
        --sysroot="${SYSROOT}" \
        --gcc-toolchain="${GCC_TOOLCHAIN_DIR}" \
        -march=armv7-a -mfpu=vfpv3-d16 -mfloat-abi=hard \
        -fuse-ld=lld \
        -o "${TEST_DIR}/hello-dyn" "${TEST_DIR}/hello.c" && \
        info "  动态编译测试: 成功" || \
        warn "  动态编译测试: 失败"

    if command -v file >/dev/null 2>&1 && [ -f "${TEST_DIR}/hello" ]; then
        info "  二进制文件信息:"
        file "${TEST_DIR}/hello"
    fi

    if [ -x "${TOOLCHAIN_DIR}/bin/llvm-readelf" ] && [ -f "${TEST_DIR}/hello" ]; then
        info "  ELF头信息:"
        "${TOOLCHAIN_DIR}/bin/llvm-readelf" -h "${TEST_DIR}/hello" 2>/dev/null | grep -E 'Machine|Class' || true
    fi

    info "验证完成"
}

clean_build_dirs() {
    info "清理构建目录..."
    rm -rf "${BUILD_DIR_LLVM}" "${BUILD_DIR_COMPILER_RT}" "${BUILD_DIR_LIBUNWIND}" "${BUILD_DIR_MUSL}"
    info "构建目录已清理"
}

usage() {
    echo "用法: $0 [选项] [构建步骤]"
    echo ""
    echo "构建LLVM+musl ARM32交叉编译链"
    echo ""
    echo "必选参数:"
    echo "  --gcc-dir <路径>      GCC交叉编译链目录"
    echo "  --llvm-src <路径>     LLVM源码目录"
    echo "  --musl-src <路径>     musl源码目录"
    echo "  --output-dir <路径>   输出工具链目录"
    echo ""
    echo "可选参数:"
    echo "  --help, -h            显示此帮助信息"
    echo ""
    echo "构建步骤:"
    echo "  all          构建全部 (默认)"
    echo "  llvm         仅构建LLVM/Clang/LLD"
    echo "  compiler-rt  仅构建compiler-rt"
    echo "  libunwind    仅构建libunwind"
    echo "  musl         仅构建musl"
    echo "  sysroot      仅设置sysroot"
    echo "  symlinks     仅创建符号链接"
    echo "  verify       仅验证编译链"
    echo "  clean        清理构建目录"
    echo ""
    echo "示例:"
    echo "  $0 --gcc-dir /path/to/gcc --llvm-src /path/to/llvm --musl-src /path/to/musl --output-dir /path/to/output all"
}

main() {
    local STEP="all"

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --gcc-dir)
                GCC_TOOLCHAIN_DIR="$2"
                shift 2
                ;;
            --llvm-src)
                LLVM_SRC_DIR="$2"
                shift 2
                ;;
            --musl-src)
                MUSL_SRC_DIR="$2"
                shift 2
                ;;
            --output-dir)
                OUTPUT_DIR="$2"
                shift 2
                ;;
            --help|-h)
                usage
                exit 0
                ;;
            all|llvm|compiler-rt|libunwind|musl|sysroot|symlinks|verify|clean)
                STEP="$1"
                shift
                ;;
            *)
                error "未知选项: $1"
                usage
                exit 1
                ;;
        esac
    done

    if [ -z "${GCC_TOOLCHAIN_DIR}" ] || [ -z "${LLVM_SRC_DIR}" ] || [ -z "${MUSL_SRC_DIR}" ] || [ -z "${OUTPUT_DIR}" ]; then
        error "必须指定所有目录参数: --gcc-dir, --llvm-src, --musl-src, --output-dir"
        usage
        exit 1
    fi

    GCC_TOOLCHAIN_DIR=$(cd "${GCC_TOOLCHAIN_DIR}" && pwd)
    LLVM_SRC_DIR=$(cd "${LLVM_SRC_DIR}" && pwd)
    MUSL_SRC_DIR=$(cd "${MUSL_SRC_DIR}" && pwd)
    mkdir -p "${OUTPUT_DIR}"
    OUTPUT_DIR=$(cd "${OUTPUT_DIR}" && pwd)
    
    TOOLCHAIN_DIR="${OUTPUT_DIR}/llvm-musl-arm"
    mkdir -p "${TOOLCHAIN_DIR}"
    TOOLCHAIN_DIR=$(cd "${TOOLCHAIN_DIR}" && pwd)

    BUILD_DIR_LLVM="${OUTPUT_DIR}/build-llvm"
    BUILD_DIR_COMPILER_RT="${OUTPUT_DIR}/build-compiler-rt"
    BUILD_DIR_LIBUNWIND="${OUTPUT_DIR}/build-libunwind"
    BUILD_DIR_MUSL="${OUTPUT_DIR}/build-musl"

    SYSROOT="${TOOLCHAIN_DIR}/${TARGET}/sysroot"

    info "LLVM+musl ARM32交叉编译链构建脚本"
    info "========================================="
    info "目标平台:     ${TARGET}"
    info "GCC工具链:    ${GCC_TOOLCHAIN_DIR}"
    info "LLVM源码:     ${LLVM_SRC_DIR}"
    info "musl源码:     ${MUSL_SRC_DIR}"
    info "输出目录:     ${OUTPUT_DIR}"
    info "工具链目录:   ${TOOLCHAIN_DIR}"
    info "并行度:       ${NPROC}"
    info "========================================="

    case "${STEP}" in
        all)
            check_prerequisites
            copy_and_patch_sources
            build_llvm
            build_compiler_rt
            build_libunwind
            build_musl
            setup_sysroot
            create_symlinks
            verify_toolchain
            info "全部构建完成! 工具链位于: ${TOOLCHAIN_DIR}"
            ;;
        llvm)
            check_prerequisites
            build_llvm
            ;;
        compiler-rt)
            check_prerequisites
            build_compiler_rt
            ;;
        libunwind)
            check_prerequisites
            build_libunwind
            ;;
        musl)
            check_prerequisites
            build_musl
            ;;
        sysroot)
            setup_sysroot
            ;;
        symlinks)
            create_symlinks
            ;;
        verify)
            verify_toolchain
            ;;
        clean)
            clean_build_dirs
            ;;
        *)
            error "未知选项: ${STEP}"
            usage
            exit 1
            ;;
    esac
}

main "$@"
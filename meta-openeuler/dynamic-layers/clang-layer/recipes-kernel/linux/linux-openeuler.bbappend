TOOLCHAIN = "clang"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI:append:aarch64 = " file://fix-link-error-unknown-argument.patch \
        file://fix-out-of-range-error.patch \
        "

DEPENDS:append = " clang-cross-${TARGET_ARCH}"
do_kernel_configme[depends] += "clang-cross-${TARGET_ARCH}:do_populate_sysroot"
DEPENDS:remove = "virtual/${TARGET_PREFIX}gcc"
KERNEL_CC = "${CCACHE}${HOST_PREFIX}clang ${HOST_CC_KERNEL_ARCH} ${DEBUG_PREFIX_MAP} -fdebug-prefix-map=${STAGING_KERNEL_DIR}=${KERNEL_SRC_PATH}"

# fix error:
# kconfiglib.KconfigError: scripts/Kocnfig.include:47: Sorry, this assembler is not supported.
# scripts/as-version.sh need check option `-fintegrated-as` when using clang.
# Makefile can pass it through CLANG_FLAGS when enable `LLVM_IAS=1`, but CLANG_FLAGS cannot
# be passed to do_kernel_configcheck stage. So I append it on KERNEL_CC.
KERNEL_CC:append:toolchain-clang = " -fintegrated-as"
KERNEL_LD:toolchain-clang = "${CCACHE}${HOST_PREFIX}ld.lld"
KERNEL_AR:toolchain-clang = "${CCACHE}${HOST_PREFIX}llvm-ar"

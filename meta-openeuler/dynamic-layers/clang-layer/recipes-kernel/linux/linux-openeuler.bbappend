TOOLCHAIN = "clang"
DEPENDS:append = " clang-external-cross-${TARGET_ARCH}"
DEPENDS:remove = " virtual/${TARGET_PREFIX}gcc "
KERNEL_CC = "${CCACHE}${HOST_PREFIX}clang ${HOST_CC_KERNEL_ARCH} ${DEBUG_PREFIX_MAP} -fdebug-prefix-map=${STAGING_KERNEL_DIR}=${KERNEL_SRC_PATH}"

# Additional definitions to use the cross-compile toolchain

ZEPHYR_SYSROOT="${STAGING_DIR_TARGET}"
# use the openeuler embedded's pre-built external toolchain
CROSS_COMPILE = "${STAGING_BINDIR_TOOLCHAIN}/${TARGET_PREFIX}"

EXTRA_OECMAKE:append = " \
    -DZEPHYR_GCC_VARIANT=${ZEPHYR_GCC_VARIANT} \
    -DCROSS_COMPILE=${CROSS_COMPILE} \
    "

OE_TERMINAL_EXPORTS += "CROSS_COMPILE"
OE_TERMINAL_EXPORTS += "ZEPHYR_GCC_VARIANT"

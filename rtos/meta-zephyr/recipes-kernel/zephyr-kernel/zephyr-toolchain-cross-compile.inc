# Additional definitions to use the cross-compile toolchain


INHIBIT_DEFAULT_DEPS = "1"
DEPENDS += "zephyr-toolchain-${TARGET_ARCH}-native"
ZEPHYR_SYSROOT="${STAGING_DIR_TARGET}"
# use the openeuler embedded's pre-built external toolchain
CROSS_COMPILE:aarch64 = "${STAGING_DIR_NATIVE}${bindir_native}/aarch64-zephyr-elf-"

EXTRA_OECMAKE:append = " \
    -DZEPHYR_GCC_VARIANT=${ZEPHYR_GCC_VARIANT} \
    -DCROSS_COMPILE=${CROSS_COMPILE} \
    "

OE_TERMINAL_EXPORTS += "CROSS_COMPILE"
OE_TERMINAL_EXPORTS += "ZEPHYR_GCC_VARIANT"

INHIBIT_PACKAGE_DEBUG_SPLIT = "1"
INHIBIT_PACKAGE_STRIP = "1"

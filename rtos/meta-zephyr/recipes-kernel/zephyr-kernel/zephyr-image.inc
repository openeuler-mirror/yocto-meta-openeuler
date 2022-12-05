require zephyr-kernel-src.inc
require zephyr-kernel-common.inc
inherit deploy

OECMAKE_SOURCEPATH = "${ZEPHYR_SRC_DIR}"

# need prepend host cmake (> 3.20)'s path
# zephyr needs cmake version > 3.20 which is higher than yocto provided.
# A workaround is to compile or install cmake separately, and add it into
# the path.
# When cmake >3.20 is provided, this workaround can be removed
ZEPHYR_CMAKE_PATH ?= "/opt/cmake/bin:"
PATH_prepend = "${ZEPHYR_CMAKE_PATH}"


do_install() {
    install -d ${D}/firmware

    install -D ${B}/zephyr/${ZEPHYR_MAKE_OUTPUT} ${D}/firmware/${PN}.elf

    if [ -f ${B}/zephyr/${ZEPHYR_MAKE_BIN_OUTPUT} ]
    then
      install -D ${B}/zephyr/${ZEPHYR_MAKE_BIN_OUTPUT} ${D}/firmware/${PN}.bin
    fi

    if [ -f ${B}/zephyr/${ZEPHYR_MAKE_EFI_OUTPUT} ]
    then
      install -D ${B}/zephyr/${ZEPHYR_MAKE_EFI_OUTPUT} ${D}/firmware/${PN}.efi
    fi
}
FILES:${PN} = "/firmware"
INSANE_SKIP += "ldflags buildpaths"
SYSROOT_DIRS += "/firmware"

do_deploy() {
    cp ${D}/firmware/${PN}.* ${DEPLOYDIR}/
}
addtask deploy after do_install

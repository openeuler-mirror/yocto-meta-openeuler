require zephyr-kernel-src.inc
require zephyr-kernel-common.inc
inherit deploy

OECMAKE_SOURCEPATH = "${ZEPHYR_SRC_DIR}"

# according Linux side's rule, e.g. remote proc, zephyr
# image should be in /lib/firmware
ZEPHYR_INSTALL_DIR = "${nonarch_base_libdir}/firmware"

do_install() {

    install -d ${D}/${ZEPHYR_INSTALL_DIR}
    install -D ${B}/zephyr/${ZEPHYR_MAKE_OUTPUT} ${D}/${ZEPHYR_INSTALL_DIR}

    if [ -f ${B}/zephyr/${ZEPHYR_MAKE_BIN_OUTPUT} ]
    then
      install -D ${B}/zephyr/${ZEPHYR_MAKE_BIN_OUTPUT} ${D}/${ZEPHYR_INSTALL_DIR}/${PN}.bin
    fi

    if [ -f ${B}/zephyr/${ZEPHYR_MAKE_EFI_OUTPUT} ]
    then
      install -D ${B}/zephyr/${ZEPHYR_MAKE_EFI_OUTPUT} ${D}/${ZEPHYR_INSTALL_DIR}/${PN}.efi
    fi
}
FILES:${PN} = "${ZEPHYR_INSTALL_DIR}"
INSANE_SKIP += "ldflags buildpaths"
SYSROOT_DIRS += "${ZEPHYR_INSTALL_DIR}"

do_deploy() {
    cp ${D}/${ZEPHYR_INSTALL_DIR}/${PN}.* ${DEPLOYDIR}/
}
addtask deploy after do_install

SUMMARY = "hi3093 image tools"
LICENSE = "CLOSED"

SRC_URI = " \
    file://mpu_solution/build/build_fs \
    file://mpu_solution/tools/coremsg \
"

S = "${WORKDIR}/mpu_solution/tools/coremsg"

EXTRA_OEMAKE="CROSS_COMPILE=${TARGET_PREFIX}"

do_configure() {
}

do_install() {
    install -d ${D}/tools-tmp
    install -d ${D}/tools-tmp/bin
    install -m 744 ${S}/coremsg ${D}/tools-tmp/bin
    install -m 744 ${WORKDIR}/mpu_solution/build/build_fs/init ${D}/tools-tmp
    install -m 644 ${WORKDIR}/mpu_solution/build/build_fs/hi3093_init.sh ${D}/tools-tmp
    install -m 644 ${WORKDIR}/mpu_solution/build/build_fs/hi3093_upgrade.sh ${D}/tools-tmp
    install -m 644 ${WORKDIR}/mpu_solution/build/build_fs/link_emmc_devs ${D}/tools-tmp
}

FILES:${PN} += "/tools-tmp"

INHIBIT_PACKAGE_STRIP = "1"
INHIBIT_SYSROOT_STRIP = "1"

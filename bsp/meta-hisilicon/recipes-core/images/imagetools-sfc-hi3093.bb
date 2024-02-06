SUMMARY = "hi3093 image tools"
LICENSE = "CLOSED"

SRC_URI = " \
    file://mpu_solution/tools/emmc_divide \
"

S = "${WORKDIR}/mpu_solution/tools/emmc_divide"

EXTRA_OEMAKE="CROSS_COMPILE=${TARGET_PREFIX}"

do_configure() {
}

do_install() {
    install -d ${D}/tools-tmp-sfc
    install -m 744 ${S}/emmc_divide ${D}/tools-tmp-sfc
}

FILES:${PN} += "/tools-tmp-sfc"

INHIBIT_PACKAGE_STRIP = "1"
INHIBIT_SYSROOT_STRIP = "1"

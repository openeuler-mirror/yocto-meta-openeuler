SUMMARY = "hi3093 sign tools"
LICENSE = "CLOSED"

SRC_URI = " \
    file://mpu_solution/build/build_sign \
    file://mpu_solution/build/version_5.10 \
"

S = "${WORKDIR}/mpu_solution/build"

do_install() {
    install -d ${D}/signtools
    cp -rf ${S}/* ${D}/signtools
}

# export /signtools dir
SYSROOT_DIRS += "/signtools"
SYSROOT_PREPROCESS_FUNCS += "additional_populate_sysroot"
additional_populate_sysroot() {                           
    sysroot_stage_dir ${D}/signtools ${SYSROOT_DESTDIR}/signtools
}                                                         

FILES:${PN} += "/signtools"

INHIBIT_PACKAGE_STRIP = "1"
INHIBIT_SYSROOT_STRIP = "1"

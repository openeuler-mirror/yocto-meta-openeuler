SUMMARY = "securec modules recipes"
LICENSE = "CLOSED"

SRC_URI = " \
    file://mpu_solution/platform/securec \
    file://mpu_solution/src/non_real_time/adapter_for_hi3093/securec_5.10_makefile \
    file://mpu_solution/src/non_real_time/drivers \
"

S = "${WORKDIR}/mpu_solution/platform/securec/src"

inherit module

export SDK_ROOT="${WORKDIR}/mpu_solution/src/non_real_time/drivers"
export KERNEL_PATH="${KERNEL_SRC}"
export SDK_VERSION="${PV}"
export SRC_DIR="${WORKDIR}/mpu_solution/src"
export SECUREC_PATH="${WORKDIR}/mpu_solution/platform/securec"

do_configure:prepend() {
    cp -f ${WORKDIR}/mpu_solution/src/non_real_time/adapter_for_hi3093/securec_5.10_makefile ${WORKDIR}/mpu_solution/platform/securec/src/Makefile
    sed -i 's#-Werror##g' ${WORKDIR}/mpu_solution/src/non_real_time/drivers/Makefile.cfg
}

do_compile() {
    oe_runmake
}

do_install() {
    install -d ${D}/lib/modules/hi3093
    install -m 644 ${S}/ksecurec.ko ${D}/lib/modules/hi3093
    if [ -d "${STAGING_KERNEL_DIR}" ];then
        cat ${S}/Module.symvers >> ${STAGING_KERNEL_DIR}/Module.symvers
        cat ${S}/Module.symvers >> ${STAGING_KERNEL_BUILDDIR}/Module.symvers
    fi
}

RPROVIDES:${PN} += "kernel-module-ksecurec"

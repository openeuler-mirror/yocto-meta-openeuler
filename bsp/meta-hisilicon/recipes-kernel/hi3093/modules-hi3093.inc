SUMMARY = "${KO_DIR_NAME}"
LICENSE = "CLOSED"

SRC_URI = " \
    file://mpu_solution/src \
"

DEPENDS += " ${PREV_DEPEND} "

S = "${WORKDIR}/mpu_solution/src/non_real_time/drivers/${KO_DIR_NAME}"

inherit module

export SDK_ROOT="${WORKDIR}/mpu_solution/src/non_real_time/drivers"
export KERNEL_PATH="${STAGING_KERNEL_DIR}"
export SDK_VERSION="${PV}"
export SRC_DIR="${WORKDIR}/mpu_solution/src"
export SECUREC_PATH="${WORKDIR}/mpu_solution/platform/securec"
export KERNEL_VERSION_MAIN="5.10"

do_configure:prepend() {
    sed -i "s#M='${KO_DIR_NAME}'#M=\$\{PWD\}#g" ${S}/Makefile
    sed -i 's#M="${KO_DIR_NAME}"#M=\$\{PWD\}#g' ${S}/Makefile
    sed -i 's#-Werror##g' ${S}/../Makefile.cfg
}

do_compile() {
    oe_runmake
}

do_install() {
    install -d ${D}/lib/modules/hi3093
    for KON in "${KO_NAME}"
    do
        install -m 644 ${S}/${KON} ${D}/lib/modules/hi3093
    done
    if [ -d "${STAGING_KERNEL_DIR}" ];then
        cat ${S}/Module.symvers >> ${STAGING_KERNEL_DIR}/Module.symvers
        cat ${S}/Module.symvers >> ${STAGING_KERNEL_BUILDDIR}/Module.symvers
    fi
}


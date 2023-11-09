SUMMARY = "hwmgr driver kernel module"
LICENSE = "CLOSED"

OPENEULER_LOCAL_NAME = "component_hibot"
SRC_URI = " \
    file://${OPENEULER_LOCAL_NAME}/src/hwmgr/driver/ \
    file://hwmgr-driver-makefile \
"

S = "${WORKDIR}/component_hibot/src/hwmgr/driver"

inherit module

do_configure:prepend() {
    cp -f ${WORKDIR}/hwmgr-driver-makefile ${WORKDIR}/component_hibot/src/hwmgr/driver/Makefile
}

do_compile() {
    oe_runmake
}

do_install() {
    install -d ${D}/lib/modules/${KERNEL_VERSION}/hwmgr
    install -m 644 ${S}/hwmgr_shm.ko ${D}/lib/modules/${KERNEL_VERSION}/hwmgr
}


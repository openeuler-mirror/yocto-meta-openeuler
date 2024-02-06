# ref: u-boot_2022.07.bb
require u-boot-common.inc
require u-boot.inc
DEPENDS += "bc-native dtc-native python3-setuptools-native"

OPENEULER_SRC_URI_REMOVE = "https git"

PV = "2022.07"

UBOOT_MACHINE = "hi3093_sfc_defconfig"
DEPENDS += "atf-hi3093"

SRC_URI = " \
    file://mpu_solution/open_source/u-boot/u-boot \
    file://mpu_solution/src/real_time/baremetal/common/hi309x_baremetal.h \
"

S = "${WORKDIR}/mpu_solution/open_source/u-boot/u-boot"

do_configure:prepend() {
    cp ${WORKDIR}/mpu_solution/src/real_time/baremetal/common/hi309x_baremetal.h ${S}/include/configs/hi309x_memmap.h
}

do_compile:append() {
    ${HOST_PREFIX}objdump -D u-boot > u-boot.dump
}

do_install() {
    install -d ${D}/boot
    install -m 644 ${B}/u-boot.bin ${D}/boot/u-boot-sfc.bin
}

do_deploy() {
    install -m 644 ${D}/boot/u-boot-sfc.bin ${DEPLOYDIR}/
}

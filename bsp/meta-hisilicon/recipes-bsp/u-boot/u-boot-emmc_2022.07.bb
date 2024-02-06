# ref: u-boot_2022.07.bb fomr meta-openembedded
require u-boot-common.inc
require u-boot.inc
DEPENDS += "bc-native dtc-native python3-setuptools-native"

OPENEULER_SRC_URI_REMOVE = "https git"

PV = "2022.07"

UBOOT_MACHINE = "hi3093_euler_defconfig"
DEPENDS += "atf-hi3093"

SRC_URI = " \
    file://mpu_solution/open_source/u-boot/u-boot \
    file://mpu_solution/src/real_time/baremetal/common/hi309x_baremetal.h \
    file://mpu_solution/build/build_sign \
    file://mpu_solution/build/version_5.10 \
"

S = "${WORKDIR}/mpu_solution/open_source/u-boot/u-boot"

do_configure:prepend() {
    cp ${WORKDIR}/mpu_solution/src/real_time/baremetal/common/hi309x_baremetal.h ${S}/include/configs/hi309x_memmap.h
}

do_compile:append() {
    ${HOST_PREFIX}objdump -D u-boot > u-boot.dump
    mkdir -p pack
    cp -f u-boot.bin u-boot.map u-boot.dump System.map pack
    cp -f ${WORKDIR}/recipe-sysroot/boot/bl31.bin pack
    pushd pack
    BLOCKSIZE=1024
    UBOOT_CNT=440
    ATF_CNT=64
    UBOOT_BIN=u-boot.bin
    ATF_BIN=bl31.bin
    dd if=$ATF_BIN of=$UBOOT_BIN bs=$BLOCKSIZE count=$ATF_CNT seek=$UBOOT_CNT
    cp -rf u-boot.bin ${WORKDIR}/mpu_solution/build/build_sign
    pushd ${WORKDIR}/mpu_solution/build/build_sign
    echo hi3093 > rsacert.cer
    export KERNEL_VERSION_MAIN="5.10"
    sh prepare_code_sign_data u-boot.bin
    sh generate_sign_image u-boot_rsa_4096.cfg
    popd
    cp -f ${WORKDIR}/mpu_solution/build/build_sign/u-boot_rsa_4096.bin ./
    popd
}

do_install() {
    install -d ${D}/boot
    install -m 644 ${B}/pack/u-boot.bin ${D}/boot
    install -m 644 ${B}/pack/System.map ${D}/boot
    install -m 644 ${B}/pack/u-boot.map ${D}/boot
    install -m 644 ${B}/pack/u-boot.dump ${D}/boot
    install -m 644 ${B}/pack/u-boot_rsa_4096.bin ${D}/boot
}

do_deploy:append() {
    install -m 644 ${D}/boot/u-boot_rsa_4096.bin ${DEPLOYDIR}/
}

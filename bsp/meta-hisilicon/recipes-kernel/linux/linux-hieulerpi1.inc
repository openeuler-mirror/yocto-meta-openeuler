# add recipes-kernel path to find patch and defconfig
FILESEXTRAPATHS:append := "${THISDIR}/files/:"

# for mkimage
DEPENDS += "u-boot-tools-native dtc-native"

OPENEULER_REPO_NAMES = "kernel-5.10-tag928 src-kernel-5.10-tag928 HiEuler-driver"

PV = "5.10-tag928"

SRC_URI:append = " \
    file://HiEuler-driver/linux/5.10.0-153.28.0.patch \
    file://dtbs/ss928-pi.dts \
    file://dtbs/ss928-pi_mcs.dts \
"

# remove default patch
SRC_URI:remove = " \
    file://patches/${ARCH}/0001-arm64-add-zImage-support-for-arm64.patch \
"

# add BL31
SRC_URI:append = " file://HiEuler-driver/firmware/trusted-firmware-a-2.2.tar.gz "

# no external defconfig
OPENEULER_KERNEL_CONFIG = ""
# use in-tree defconfig, the defconfig is in src tree
# after patches are unpatched
KBUILD_DEFCONFIG = "hieulerpi1_defconfig"

WORKDTS = "${@bb.utils.contains('MCS_FEATURES', 'openamp', 'ss928-pi_mcs.dts', 'ss928-pi.dts', d)}"
# add method to do_compile task to produce bootable Image
do_compile:append(){
    mkimage -A arm64 -O linux -T kernel -C none -a 0x080000 -e 0x080000 -n "Linux-5.10.0" -d ${KERNEL_OUTPUT_DIR}/Image uImage-tmp
    oe_runmake dtbs
    dtc -I dts -O dtb ${WORKDIR}/dtbs/${WORKDTS} -o ${WORKDIR}/ss928-pi.dtb
    cat uImage-tmp ${WORKDIR}/ss928-pi.dtb > ${KERNEL_OUTPUT_DIR}/uImage-pi
}

# uImage as bl33, we need to use it to build the fip.bin. So add uImage to SYSROOT_DIR
# Since sysroot_stage_all() is rewritten as empty in meta/classes/kernel.bbclass,
# we can't use "SYSROOT_DIRS" directly, here we write a SYSROOT_PREPROCESS_FUNCS to add uImage
SYSROOT_DIRS += "/linux-img"
FILES:${KERNEL_PACKAGE_NAME} += "/linux-img"
do_install:append() {
        install -d ${D}/linux-img
        install -m 0644 ${KERNEL_OUTPUT_DIR}/uImage-pi ${D}/linux-img/uImage-pi
}

SYSROOT_PREPROCESS_FUNCS += "additional_populate_sysroot"
additional_populate_sysroot() {
    sysroot_stage_dir ${D}/linux-img ${SYSROOT_DESTDIR}/linux-img
}

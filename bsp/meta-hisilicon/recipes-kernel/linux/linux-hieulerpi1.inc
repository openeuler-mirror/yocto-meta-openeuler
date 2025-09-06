# add recipes-kernel path to find patch and defconfig
FILESEXTRAPATHS:append := "${THISDIR}/files/:"

# for mkimage
DEPENDS += "u-boot-tools-native dtc-native"

KERNEL_VERSION_SANITY_SKIP = "1"

OPENEULER_REPO_NAMES = " \
    ${@bb.utils.contains('DISTRO_FEATURES', 'kernel6', ' \
        kernel-6.6-tag928 HiEuler-driver \
    ', ' \
        kernel-5.10-tag928 src-kernel-5.10-tag928 HiEuler-driver \
    ', d)} \
"

PV = "${@bb.utils.contains('DISTRO_FEATURES', 'kernel6', '6.6-tag928', '5.10-tag928', d)}"

SRC_URI:append = " \
    ${@bb.utils.contains('DISTRO_FEATURES', 'kernel6', ' \
        file://HiEuler-driver/linux/0001-oh_ss928-oee.patch \
        file://patch/0002-oee-mod-compat-for-6.6.86.patch \
	file://dtbs/ss928-pi-kernel6.dts \
	file://dtbs/ss928-pi-kernel6_mcs.dts \
    ', ' \
        file://HiEuler-driver/linux/5.10.0-153.28.0.patch \
	file://dtbs/ss928-pi.dts \
	file://dtbs/ss928-pi_mcs.dts \
    ', d)} \
"

# remove default patch
SRC_URI:remove = " \
    ${@bb.utils.contains('DISTRO_FEATURES', 'kernel6', ' \
        file://patches/${ARCH}/0001-kernel6.6-arm64-add-zImage-support-for-arm64.patch \
    ', ' \
        file://patches/${ARCH}/0001-arm64-add-zImage-support-for-arm64.patch \
    ', d)} \
"

KN_SUFFIX = "${@bb.utils.contains('DISTRO_FEATURES', 'kernel6', '-kernel6', '', d)}"
TARGET_FILES = "${@bb.utils.contains('DISTRO_FEATURES', 'kernel6', 'uImage', 'dtbs', d)}"

# add BL31
SRC_URI:append = " file://HiEuler-driver/firmware/trusted-firmware-a-2.2.tar.gz "

# for kernel6, use yocto's hieulerpi1_kernel6_defconfig
OPENEULER_KERNEL_CONFIG = "${@bb.utils.contains('DISTRO_FEATURES', 'kernel6', 'file://config/hieulerpi1/hieulerpi1_kernel6_defconfig', 'file://config/hieulerpi1/hieulerpi1_kernel5_defconfig', d)}"

# for old kernels(5.10), keep use in-tree hieulerpi1_defconfig
# KBUILD_DEFCONFIG = "${@bb.utils.contains('DISTRO_FEATURES', 'kernel6', '', 'hieulerpi1_defconfig', d)}"
KBUILD_DEFCONFIG = ""

do_compile:prepend(){
    # avoid issue of '+' vermagic of module in-tree of yocto 
    sed -i '/echo "+"/d' ${STAGING_KERNEL_DIR}/scripts/setlocalversion
}


MCS_SUFFIX = "${@bb.utils.contains('MCS_FEATURES', 'openamp', '_mcs', '', d)}"
# add method to do_compile task to produce bootable Image
do_compile:append(){
    mkimage -A arm64 -O linux -T kernel -C none -a 0x080000 -e 0x080000 -n "Linux" -d ${KERNEL_OUTPUT_DIR}/Image uImage-tmp
    oe_runmake ${TARGET_FILES}
    dtc -I dts -O dtb ${WORKDIR}/dtbs/ss928-pi${KN_SUFFIX}${MCS_SUFFIX}.dts -o ${WORKDIR}/ss928-pi.dtb
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

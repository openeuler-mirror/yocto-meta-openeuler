# add recipes-kernel path to find patch and defconfig
FILESEXTRAPATHS:append := "${THISDIR}/files/:"

# for mkimage
DEPENDS += "u-boot-tools-native dtc-native"

OPENEULER_REPO_NAMES = "kernel-5.10-tag626 src-kernel-5.10-tag626"

OPENEULER_KERNEL_CONFIG = "file://config/hipico/${@bb.utils.contains('DISTRO_FEATURES', 'mini-img', 'hipico_mini_defconfig', 'hipico_debug_defconfig', d)}"

PV = "5.10-tag626"

SRC_URI:append = " \
    file://patch/0001-hipico-kernel-510-patch-d8e3bcbbe.patch \
    file://config/hipico/${@bb.utils.contains('DISTRO_FEATURES', 'mini-img', 'hipico_mini_defconfig', 'hipico_debug_defconfig', d)} \
    file://dtbs/hipico.dts \
    file://its/linux_image.its \
"

# add method to do_compile task to produce bootable Image
do_compile:append(){
    cp ${KERNEL_OUTPUT_DIR}/zImage ${WORKDIR}/its/zImage
    dtc -I dts -O dtb ${WORKDIR}/dtbs/hipico.dts -o ${WORKDIR}/its/devicetree.dtb
    mkimage -f ${WORKDIR}/its/linux_image.its uImage
    cp uImage ${KERNEL_OUTPUT_DIR}/uImage
}

# uImage as bl33, we need to use it to build the fip.bin. So add uImage to SYSROOT_DIR
# Since sysroot_stage_all() is rewritten as empty in meta/classes/kernel.bbclass,
# we can't use "SYSROOT_DIRS" directly, here we write a SYSROOT_PREPROCESS_FUNCS to add uImage
SYSROOT_DIRS += "/linux-img"
FILES:${KERNEL_PACKAGE_NAME} += "/linux-img"
do_install:append() {
        install -d ${D}/linux-img
	install -m 0644 ${KERNEL_OUTPUT_DIR}/uImage ${D}/linux-img/uImage
}

SYSROOT_PREPROCESS_FUNCS += "additional_populate_sysroot"
additional_populate_sysroot() {
    sysroot_stage_dir ${D}/linux-img ${SYSROOT_DESTDIR}/linux-img
}

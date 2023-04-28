FILESEXTRAPATHS_append := "${THISDIR}/files/:"

SRC_URI_append = " \
    file://config \
    file://patch/0001-support-jh7110-starfive.patch \
"

INITRAMFS_IMAGE = "openeuler-image-live"

OPENEULER_KERNEL_CONFIG = "../config/visionfive2-jh7110_defconfig"

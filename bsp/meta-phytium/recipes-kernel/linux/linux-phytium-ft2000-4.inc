FILESEXTRAPATHS:append := "${THISDIR}/files/:"

SRC_URI:append = " \
    file://patches/0001-support-phytium-ft2000-4.patch \
"

OPENEULER_KERNEL_CONFIG = "file://config/phytium-ft2000-4_defconfig"

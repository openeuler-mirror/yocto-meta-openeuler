FILESEXTRAPATHS:append := "${THISDIR}/files/:"

SRC_URI:append = " \
    file://config \
    file://patch/0001-support-jh7110-starfive.patch \
    file://patch/0002-fix-timer-starfive-error.patch \
    ${@bb.utils.contains('DISTRO_FEATURES', 'obmc', 'file://config/virtio-pci.cfg ', '', d)} \
"

OPENEULER_KERNEL_CONFIG = "file://config/visionfive2-jh7110_defconfig"

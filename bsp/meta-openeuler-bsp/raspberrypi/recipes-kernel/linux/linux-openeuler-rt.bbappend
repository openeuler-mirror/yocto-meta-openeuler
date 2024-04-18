# For the Raspberry Pi, we don't need to apply the aarch64 patches
SRC_URI:remove:raspberrypi4 = " \
    file://src-kernel-${PV}/0001-modify-openeuler_defconfig-for-rt62.patch \
"

SRC_URI += "\
    file://src-kernel-${PV}/0000-raspberrypi-kernel.patch \
    ${@bb.utils.contains('DISTRO_FEATURES', 'kernel6', '' ,' \
        file://src-kernel-${PV}/0002-modify-bcm2711_defconfig-for-rt-rpi-kernel.patch \
    ', d)} \
"

require linux-openeuler-rpi.inc

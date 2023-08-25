# For the Raspberry Pi, we don't need to apply the aarch64 patches
SRC_URI:remove:raspberrypi4 = " \
    file://src-kernel-5.10/0001-modify-openeuler_defconfig-for-rt62.patch \
"

SRC_URI += "\
    file://src-kernel-5.10/0000-raspberrypi-kernel.patch \
    file://src-kernel-5.10/0002-modify-bcm2711_defconfig-for-rt-rpi-kernel.patch \
"

require linux-openeuler-rpi.inc

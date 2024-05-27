# For the Raspberry Pi, we don't need to apply the aarch64 patches
SRC_URI:remove:raspberrypi4 = " \
    file://src-kernel-${PV}/0001-modify-openeuler_defconfig-for-rt62.patch \
    file://src-kernel-${PV}/patch-6.6.0-6.0.0-rt20.patch \
    file://src-kernel-${PV}/patch-6.6.0-6.0.0-rt20.patch-openeuler_defconfig.patch \
"

# 0002-modify-bcm2711_defconfig-for-rt-rpi-kernel.patch not need 
# for we have kernel meta data feature to enable it
# in kernel 6.6, this patch will patch failed, it is for 5.10
SRC_URI:append:raspberrypi4 = "\
    ${@bb.utils.contains('DISTRO_FEATURES', 'kernel6', ' \
        file://src-kernel-${PV}/0000-raspberrypi-kernel.patch \
        file://src-kernel-${PV}/0001-raspberrypi-kernel-RT.patch \
    ' ,' \
        file://src-kernel-${PV}-tag-rpi/0000-raspberrypi-kernel.patch \
        file://src-kernel-${PV}-tag-rpi/0002-modify-bcm2711_defconfig-for-rt-rpi-kernel.patch \
        file://src-kernel-${PV}-tag-rpi/0003-rpi4-extern.patch \
    ', d)} \
"

require linux-openeuler-rpi.inc

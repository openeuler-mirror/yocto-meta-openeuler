# For the Raspberry Pi, we don't need to apply the aarch64 patches
# (the rt20 entries were dropped from the base recipe together with
# the 6.6.0-172.0.0 baseline switch)
SRC_URI:remove:raspberrypi4-64 = " \
    file://src-kernel-${PV}/0001-modify-openeuler_defconfig-for-rt62.patch \
    file://src-kernel-${PV}/0001-apply-preempt-RT-patch.patch \
    file://src-kernel-${PV}/patch-6.6.0-6.0.0-rt79.patch \
    file://patches/${ARCH}/0001-kernel6.6-arm64-add-zImage-support-for-arm64.patch \
"

# same for the kernel6 zImage patch as in the non-rt recipe: the
# mainline variant is refreshed per the 174.0.0 baseline, while the
# tag-rpi tree keeps the old Kconfig layout, so take the tag-matching
# variant
SRC_URI:append:raspberrypi4-64 = " \
    ${@bb.utils.contains('DISTRO_FEATURES', 'kernel6', ' \
        file://patches/${ARCH}/0001-kernel6.6-arm64-add-zImage-support-for-arm64-tag-rpi.patch \
    ', '', d)} \
"

# 0002-modify-bcm2711_defconfig-for-rt-rpi-kernel.patch not need 
# for we have kernel meta data feature to enable it
# in kernel 6.6, this patch will patch failed, it is for 5.10
# kernel6: the RPi patches come from the matching packaging tag
# (src-kernel-${PV}-tag-rpi) like the non-rt recipe; the 26.09
# packaging no longer carries 0001-raspberrypi-kernel-RT.patch
SRC_URI:append:raspberrypi4-64 = "\
    ${@bb.utils.contains('DISTRO_FEATURES', 'kernel6', ' \
        file://src-kernel-${PV}-tag-rpi/0000-raspberrypi-kernel.patch \
        file://src-kernel-${PV}-tag-rpi/0001-raspberrypi-kernel-RT.patch \
    ' ,' \
        file://src-kernel-${PV}-tag-rpi/0000-raspberrypi-kernel.patch \
        file://src-kernel-${PV}-tag-rpi/0002-modify-bcm2711_defconfig-for-rt-rpi-kernel.patch \
        file://src-kernel-${PV}-tag-rpi/0003-rpi4-extern.patch \
        file://src-kernel-${PV}-tag-rpi/0001-apply-preempt-RT-patch.patch \
    ', d)} \
"

require linux-openeuler-rpi.inc

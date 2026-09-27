# For the Raspberry Pi, we don't need to apply the aarch64 patches
# from the base recipe (the rt62 patches are for the 5.10 flow and the
# base kernel6 rt79 patch is replaced by the RPi-specific RT patchset
# from the tag-rpi packaging below)
SRC_URI:remove:raspberrypi4-64 = " \
    file://src-kernel-${PV}/0001-modify-openeuler_defconfig-for-rt62.patch \
    file://src-kernel-${PV}/0001-apply-preempt-RT-patch.patch \
    file://src-kernel-${PV}/patch-6.6.0-6.0.0-rt79.patch \
"

# kernel6: the RPi patches come from the matching packaging tag
# (src-kernel-${PV}-tag-rpi) like the non-rt recipe. Since the 175.0.0
# packaging the tag-rpi pins follow the mainline kernel-6.6 baseline,
# and the packaging restores the RPi-specific RT flow of the upstream
# raspberrypi-kernel-rt.spec: the 0000 RPi kernel patch, the
# 0001-raspberrypi-kernel-RT patchset (which brings back the
# ARCH_SUPPORTS_RT selects) and the 0002 defconfig companion that
# enables CONFIG_PREEMPT_RT in the in-tree bcm2711_defconfig. The
# whole chain is verified to apply cleanly in SRC_URI order on the
# 6.6.0-175.0.0 tree.
SRC_URI:append:raspberrypi4-64 = "\
    ${@bb.utils.contains('DISTRO_FEATURES', 'kernel6', ' \
        file://src-kernel-${PV}-tag-rpi/0000-raspberrypi-kernel.patch \
        file://src-kernel-${PV}-tag-rpi/0001-raspberrypi-kernel-RT.patch \
        file://src-kernel-${PV}-tag-rpi/0002-modify-bcm_defconfig-for-rt-rpi-kernel.patch.patch \
    ' ,' \
        file://src-kernel-${PV}-tag-rpi/0000-raspberrypi-kernel.patch \
        file://src-kernel-${PV}-tag-rpi/0002-modify-bcm2711_defconfig-for-rt-rpi-kernel.patch \
        file://src-kernel-${PV}-tag-rpi/0003-rpi4-extern.patch \
        file://src-kernel-${PV}-tag-rpi/0001-apply-preempt-RT-patch.patch \
    ', d)} \
"

require linux-openeuler-rpi.inc

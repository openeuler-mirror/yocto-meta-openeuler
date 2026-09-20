# For the Raspberry Pi, we don't need to apply the aarch64 patches
# from the base recipe (the rt62 patches are for the 5.10 flow and the
# base kernel6 rt79 patch is taken from the tag-rpi packaging below,
# so the mainline copy must not be applied twice)
SRC_URI:remove:raspberrypi4-64 = " \
    file://src-kernel-${PV}/0001-modify-openeuler_defconfig-for-rt62.patch \
    file://src-kernel-${PV}/0001-apply-preempt-RT-patch.patch \
    file://src-kernel-${PV}/patch-6.6.0-6.0.0-rt79.patch \
"

# 0002-modify-bcm2711_defconfig-for-rt-rpi-kernel.patch not need
# for we have kernel meta data feature to enable it
# in kernel 6.6, this patch will patch failed, it is for 5.10
# kernel6: the RPi patches come from the matching packaging tag
# (src-kernel-${PV}-tag-rpi) like the non-rt recipe; since the
# 26.09 packaging no longer carries 0001-raspberrypi-kernel-RT.patch,
# the generic PREEMPT_RT rebase (rt79) shipped in the same packaging
# is applied on top of the RPi kernel patch instead (verified to
# apply cleanly on the 6.6.0-174.0.0 tag-rpi tree and to bring back
# the ARCH_SUPPORTS_RT selects)
SRC_URI:append:raspberrypi4-64 = "\
    ${@bb.utils.contains('DISTRO_FEATURES', 'kernel6', ' \
        file://src-kernel-${PV}-tag-rpi/0000-raspberrypi-kernel.patch \
        file://src-kernel-${PV}-tag-rpi/patch-6.6.0-6.0.0-rt79.patch \
    ' ,' \
        file://src-kernel-${PV}-tag-rpi/0000-raspberrypi-kernel.patch \
        file://src-kernel-${PV}-tag-rpi/0002-modify-bcm2711_defconfig-for-rt-rpi-kernel.patch \
        file://src-kernel-${PV}-tag-rpi/0003-rpi4-extern.patch \
        file://src-kernel-${PV}-tag-rpi/0001-apply-preempt-RT-patch.patch \
    ', d)} \
"

require linux-openeuler-rpi.inc

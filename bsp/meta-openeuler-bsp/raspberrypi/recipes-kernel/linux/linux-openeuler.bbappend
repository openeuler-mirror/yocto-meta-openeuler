# the RPi kernel tree (kernel-${PV}-tag-rpi) is pinned to its own tag,
# so the RPi kernel patch must come from the matching src-openeuler
# packaging tag (src-kernel-${PV}-tag-rpi) instead of src-kernel-${PV},
# which follows the mainline kernel6 packaging rebased per baseline
SRC_URI:append:raspberrypi4-64 = " \
    file://src-kernel-${PV}-tag-rpi/0000-raspberrypi-kernel.patch \
"
# same for the kernel6 zImage patch: the mainline variant is refreshed
# per the kernel-6.6 baseline (arch/arm64/Kconfig gained more trailing
# sources), while the tag-rpi tree still ends right after the kvm
# source, so take a tag-matching variant
SRC_URI:remove:raspberrypi4-64 = "file://patches/${ARCH}/0001-kernel6.6-arm64-add-zImage-support-for-arm64.patch"
SRC_URI:append:raspberrypi4-64 = " \
    ${@bb.utils.contains('DISTRO_FEATURES', 'kernel6', ' \
        file://patches/${ARCH}/0001-kernel6.6-arm64-add-zImage-support-for-arm64-tag-rpi.patch \
    ', '', d)} \
"
require linux-openeuler-rpi.inc

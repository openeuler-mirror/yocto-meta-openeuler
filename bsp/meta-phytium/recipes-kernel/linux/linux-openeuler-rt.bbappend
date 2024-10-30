require recipes-kernel/linux/linux-phytium.inc

SRC_URI:remove = " \
    ${@bb.utils.contains('DISTRO_FEATURES', 'kernel6', ' \
        file://src-kernel-${PV}/patch-6.6.0-6.0.0-rt20.patch \
        file://src-kernel-${PV}/patch-6.6.0-6.0.0-rt20.patch-openeuler_defconfig.patch \
    ' ,' \
        file://src-kernel-${PV}/0001-apply-preempt-RT-patch.patch \
        file://src-kernel-${PV}/0001-modify-openeuler_defconfig-for-rt62.patch \
    ', d)} \
"

SRC_URI:append = " \
    ${@bb.utils.contains('DISTRO_FEATURES', 'kernel6', ' \
        file://src-kernel-${PV}-tag-phytium/patch-6.6.0-6.0.0-rt20.patch \
        file://src-kernel-${PV}-tag-phytium/patch-6.6.0-6.0.0-rt20.patch-openeuler_defconfig.patch \
    ' ,' \
        file://src-kernel-${PV}-tag-phytium/0001-apply-preempt-RT-patch.patch \
        file://src-kernel-${PV}-tag-phytium/0001-modify-openeuler_defconfig-for-rt62.patch \
    ', d)} \
"

# add COMPATIBLE_MACHINE
COMPATIBLE_MACHINE = "ft2000-4|d2000|phytiumpi"

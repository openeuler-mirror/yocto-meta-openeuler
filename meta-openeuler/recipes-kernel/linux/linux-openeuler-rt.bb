require recipes-kernel/linux/linux-openeuler.inc

SRC_URI:append:aarch64 = " \
    ${@bb.utils.contains('DISTRO_FEATURES', 'kernel6', ' \
        file://src-kernel-${PV}/patch-6.6.0-6.0.0-rt20.patch \
        file://src-kernel-${PV}/patch-6.6.0-6.0.0-rt20.patch-openeuler_defconfig.patch \
    ' ,' \
        file://src-kernel-${PV}/0001-apply-preempt-RT-patch.patch \
        file://src-kernel-${PV}/0001-modify-openeuler_defconfig-for-rt62.patch \
    ', d)} \
"

SRC_URI:append:x86-64 = " \
    ${@bb.utils.contains('DISTRO_FEATURES', 'kernel6', ' \
        file://src-kernel-${PV}/patch-6.6.0-6.0.0-rt20.patch \
        file://src-kernel-${PV}/patch-6.6.0-6.0.0-rt20.patch-openeuler_defconfig.patch \
    ' ,' \
        file://src-kernel-${PV}/0001-apply-preempt-RT-patch.patch \
        file://src-kernel-${PV}/0001-modify-openeuler_defconfig-for-rt62.patch \
    ', d)} \
"

COMPATIBLE_MACHINE = "qemu-aarch64|generic-x86-64"

## Preempt-RT
KERNEL_FEATURES:append =  "features/preempt-rt/preempt-rt.scc"

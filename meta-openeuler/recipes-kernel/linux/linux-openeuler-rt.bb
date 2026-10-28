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

# The rss/percpu reverts were needed at the old rt20 rebases: the RT
# patchset conflicted with the openEuler "rss stats in atomic mode"
# feature. The 6.6.0-180.0.0.1 rt20 (src-kernel-6.6 @956b13b) applies
# cleanly without them -- the new baseline carries the reworked
# percpu/atomic dual-mode rss implementation and the upstream
# kernel-rt.spec drops the reverts as well.

COMPATIBLE_MACHINE = "qemu-aarch64|generic-x86-64"

## Preempt-RT
KERNEL_FEATURES:append =  " features/preempt-rt/preempt-rt.scc"

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

# The -Next-era mm rss-stats and percpu_counter reverts are not used on
# the 145.0.13 kernel6 baseline: neither matches the state of the
# openEuler-24.03-LTS tree (the rss-stats atomic-mode commit never landed
# there, and the percpu_counter revert removes helpers that mm.h on this
# baseline depends on). The kernel-rt rebase to 6.6.0-145.0.13.7
# reconciles the tree as is.

COMPATIBLE_MACHINE = "qemu-aarch64|generic-x86-64"

## Preempt-RT
KERNEL_FEATURES:append =  " features/preempt-rt/preempt-rt.scc"

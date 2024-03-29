require recipes-kernel/linux/linux-openeuler.inc

SRC_URI:append:aarch64 = " \
    file://src-kernel-5.10/0001-apply-preempt-RT-patch.patch \
    file://src-kernel-5.10/0001-modify-openeuler_defconfig-for-rt62.patch \
"

SRC_URI:append:x86-64 = " \
    file://src-kernel-5.10/0001-apply-preempt-RT-patch.patch \
    file://src-kernel-5.10/0001-modify-openeuler_defconfig-for-rt62.patch \
"

COMPATIBLE_MACHINE = "qemu-aarch64|generic-x86-64"

## Preempt-RT
KERNEL_FEATURES:append =  "features/preempt-rt/preempt-rt.scc"

require recipes-kernel/linux/linux-phytium.inc

SRC_URI:remove = " \
    file://src-kernel-5.10/0001-apply-preempt-RT-patch.patch \
    file://src-kernel-5.10/0001-modify-openeuler_defconfig-for-rt62.patch \
"

SRC_URI:append = " \
    file://src-kernel-5.10-tag-phytium/0001-apply-preempt-RT-patch.patch \
    file://src-kernel-5.10-tag-phytium/0001-modify-openeuler_defconfig-for-rt62.patch \
"

# add COMPATIBLE_MACHINE
COMPATIBLE_MACHINE = "ft2000-4|d2000"

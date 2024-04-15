# add COMPATIBLE_MACHINE
COMPATIBLE_MACHINE = "hi3093|hieulerpi1"

require recipes-kernel/linux/${@bb.utils.contains('DISTRO_FEATURES', 'mpu_solution', 'linux-hi3093-mpu.inc', 'linux-${MACHINE}.inc', d)}

SRC_URI:remove = " \
    file://src-kernel-5.10/0001-apply-preempt-RT-patch.patch \
    file://src-kernel-5.10/0001-modify-openeuler_defconfig-for-rt62.patch \
"

SRC_URI:append:hieulerpi1 = " \
    file://patch/0001-apply-preempt-RT-patch-b88a0de01.patch \
    file://src-kernel-5.10-tag928/0001-modify-openeuler_defconfig-for-rt62.patch \
"

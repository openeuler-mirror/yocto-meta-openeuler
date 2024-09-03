# add COMPATIBLE_MACHINE
COMPATIBLE_MACHINE = "hi3093|hieulerpi1"

require recipes-kernel/linux/${@bb.utils.contains('DISTRO_FEATURES', 'mpu_solution', 'linux-hi3093-mpu.inc', 'linux-${MACHINE}.inc', d)}

SRC_URI:remove:hieulerpi1 = " \
    file://src-kernel-${PV}/0001-apply-preempt-RT-patch.patch \
"
SRC_URI:prepend:hieulerpi1 = " \
    file://patch/0001-apply-preempt-RT-patch-b88a0de01.patch \
"

# add COMPATIBLE_MACHINE
COMPATIBLE_MACHINE = "hi3093|hieulerpi1|hiedge1"

require recipes-kernel/linux/${@bb.utils.contains('DISTRO_FEATURES', 'mpu_solution', 'linux-hi3093-mpu.inc', 'linux-${MACHINE}.inc', d)}

SRC_URI:prepend:hi3093 = " \
    file://patch/0001-kernel-22.03-lts-sp3-mmc.patch \
    file://patch/0001-kernel-support-pfp.patch \
"
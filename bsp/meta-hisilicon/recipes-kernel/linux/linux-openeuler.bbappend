# add COMPATIBLE_MACHINE
COMPATIBLE_MACHINE = "hi3093|hieulerpi1"

require recipes-kernel/linux/${@bb.utils.contains('DISTRO_FEATURES', 'mpu_solution', 'linux-hi3093-mpu.inc', 'linux-${MACHINE}.inc', d)}

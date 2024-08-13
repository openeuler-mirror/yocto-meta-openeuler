# add recipes-kernel path to find patch and defconfig
FILESEXTRAPATHS:append := "${THISDIR}/files/:"

OPENEULER_KERNEL_CONFIG = "file://config/kp920/defconfig"

# add COMPATIBLE_MACHINE
COMPATIBLE_MACHINE = "kp920"

# add recipes-kernel path to find patch and defconfig
FILESEXTRAPATHS:append := "${THISDIR}/files/:"

CONFIGVERSION="${@bb.utils.contains('DISTRO_FEATURES', 'kernel6', 'kernel6-', '', d)}"
OPENEULER_KERNEL_CONFIG = "file://${CONFIGVERSION}config/kp920/defconfig"

# add COMPATIBLE_MACHINE
COMPATIBLE_MACHINE = "kp920"

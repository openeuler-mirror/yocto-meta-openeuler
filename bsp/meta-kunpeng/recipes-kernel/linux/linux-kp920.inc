# add recipes-kernel path to find patch and defconfig
FILESEXTRAPATHS:append := "${THISDIR}/files/:"

SRC_URI:remove:aarch64 = " \
    ${@bb.utils.contains('DISTRO_FEATURES', 'kernel6', ' \
    file://patches/${ARCH}/0001-kernel6.6-arm64-add-zImage-support-for-arm64.patch \
    ', ' \
    file://patches/${ARCH}/0001-arm64-add-zImage-support-for-arm64.patch \
    ', d)} \
"

CONFIGVERSION="${@bb.utils.contains('DISTRO_FEATURES', 'kernel6', 'kernel6-', '', d)}"
OPENEULER_KERNEL_CONFIG = "file://${CONFIGVERSION}config/kp920/defconfig"

# add COMPATIBLE_MACHINE
COMPATIBLE_MACHINE = "kp920"

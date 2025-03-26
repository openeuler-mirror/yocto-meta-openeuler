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

SRC_URI:append = " \
    file://config/cfg-fragments/embedded-build.cfg \
    file://config/cfg-fragments/common-pc-drivers.cfg \
"

OPENEULER_KERNEL_CONFIG = ""
KBUILD_DEFCONFIG = "openeuler_defconfig"

# add COMPATIBLE_MACHINE
COMPATIBLE_MACHINE = "kp920"

# strip modules for kp920 image
EXTRA_OEMAKE += "INSTALL_MOD_STRIP=1"
INSANE_SKIP:${PN} += "already-stripped"

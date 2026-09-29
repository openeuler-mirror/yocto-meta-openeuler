# add recipes-kernel path to find patch and defconfig
FILESEXTRAPATHS:append := "${THISDIR}/files/:"

# CONFIG_DEBUG_INFO_BTF is set by the in-tree openeuler_defconfig and
# needs pahole to generate the vmlinux BTF plus libelf for the
# resolve_btfids host tool (discovered via pkg-config). The build
# container ships neither, so provide both from the native recipes
# (pahole is pinned to 1.28 through the meta-openeuler bbappend). This
# is wired for the kernel6 flow only: the 6.6.0-175.0.0 kernel carries
# the BTF_KFUNCS_START/END conversion for the arch kfunc sets, which
# is what made BTF generation fail on the 174.0.0 baseline.
DEPENDS:append = '${@bb.utils.contains("DISTRO_FEATURES", "kernel6", " pahole-native elfutils-native", "", d)}'

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
    file://config/cfg-fragments/no-hisi-pmu.cfg \
    ${@bb.utils.contains('DISTRO_FEATURES', 'kernel6', 'file://config/cfg-fragments/btf-kernel6.cfg', '', d)} \
"

OPENEULER_KERNEL_CONFIG = ""
KBUILD_DEFCONFIG = "openeuler_defconfig"

# add COMPATIBLE_MACHINE
COMPATIBLE_MACHINE = "kp920"

# strip modules for kp920 image
EXTRA_OEMAKE += "INSTALL_MOD_STRIP=1"
INSANE_SKIP:${PN} += "already-stripped"

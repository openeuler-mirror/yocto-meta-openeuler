# For the Raspberry Pi, we don't need to apply the aarch64 patches
SRC_URI_remove_raspberrypi4 += " \
    file://src-kernel-5.10/0000-kernel-rt62.patch \
    file://src-kernel-5.10/0001-kernel-rt62-modify-defconfig.patch \
"

SRC_URI += "\
    file://src-kernel-5.10/0000-raspberrypi-kernel.patch \
    file://src-kernel-5.10/0001-raspberrypi-kernel-rt62.patch \
    file://src-kernel-5.10/0002-raspberrypi-kernel-rt62-modify-defconfig.patch \
"

COMPATIBLE_MACHINE = "raspberrypi4-64"

OPENEULER_KERNEL_CONFIG = "${S}/arch/${ARCH}/configs/bcm2711_defconfig"
do_configure_prepend() {
    sed -i '$a CONFIG_ACPI=y' ${OPENEULER_KERNEL_CONFIG}
    cp -f "${OPENEULER_KERNEL_CONFIG}" .config
}

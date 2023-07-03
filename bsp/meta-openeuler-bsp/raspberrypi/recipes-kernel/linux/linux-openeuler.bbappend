SRC_URI += "\
    file://src-kernel-5.10/0000-raspberrypi-kernel.patch \
"
require linux-openeuler-rpi.inc

OPENEULER_KERNEL_CONFIG = "${S}/arch/${ARCH}/configs/bcm2711_defconfig"
do_configure:prepend() {
    sed -i '$a CONFIG_ACPI=y' ${OPENEULER_KERNEL_CONFIG}
    cp -f "${OPENEULER_KERNEL_CONFIG}" .config
}

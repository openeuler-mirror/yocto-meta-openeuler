SRC_URI += "\
    file://src-kernel-5.10/0000-raspberrypi-kernel.patch \
"
OPENEULER_KERNEL_CONFIG = "${S}/arch/${ARCH}/configs/bcm2711_defconfig"

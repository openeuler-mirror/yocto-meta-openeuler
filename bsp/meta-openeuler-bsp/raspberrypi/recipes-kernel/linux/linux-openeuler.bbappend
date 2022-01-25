SRC_URI += "\
    file://src-kernel-5.10/0000-raspberrypi-kernel.patch \
"
OPENEULER_KERNEL_CONFIG = "${S}/arch/${ARCH}/configs/bcm2711_defconfig"
#delete v8 in kernel module name, such as kernel-module-xxx-5.10.0-v8
KERNEL_MODULE_PACKAGE_SUFFIX = ""

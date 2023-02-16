require recipes-kernel/linux/linux-rockchip.inc

#define and use defconfig
do_configure_prepend() {
    cp -f "${OPENEULER_KERNEL_CONFIG}" .config
}

#add COMPATIBLE_MACHINE
COMPATIBLE_MACHINE = "ok3568"

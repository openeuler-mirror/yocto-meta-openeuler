require recipes-kernel/linux/linux-rockchip.inc

SRC_URI:append:rk3568 = " \
    file://patches/0002-fix-fiq_debugger.patch \
"
#define and use defconfig
do_configure:prepend() {
    sed -i 's/CONFIG_PREEMPT=y/CONFIG_PREEMPT_RT=y/g' ${OPENEULER_KERNEL_CONFIG}
    cp -f "${OPENEULER_KERNEL_CONFIG}" .config
}

#add COMPATIBLE_MACHINE
COMPATIBLE_MACHINE = "ok3568|ryd-3568"

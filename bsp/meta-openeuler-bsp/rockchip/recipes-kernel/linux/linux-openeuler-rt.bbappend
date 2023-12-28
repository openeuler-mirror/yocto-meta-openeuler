require recipes-kernel/linux/linux-rockchip.inc

SRC_URI_append_rockchip = " \
    file://patches/0002-fix-fiq_debugger.patch \
    file://patches/0002-fix_fpsimd_sched_panic.patch \
"
#define and use defconfig
do_configure_prepend() {
    sed -i 's/CONFIG_PREEMPT=y/CONFIG_PREEMPT_RT=y/g' .config
}

#add COMPATIBLE_MACHINE
COMPATIBLE_MACHINE = "ok3568|ryd-3568|ok3588|ok3399"

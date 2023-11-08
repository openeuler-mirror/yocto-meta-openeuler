require recipes-kernel/linux/linux-rockchip.inc

SRC_URI:append:rockchip = " \
    file://patches/0002-fix-fiq_debugger.patch \
    file://patches/0002-fix_fpsimd_sched_panic.patch \
"

#add COMPATIBLE_MACHINE
COMPATIBLE_MACHINE = "ok3568|ryd-3568|ok3588|ok3399"

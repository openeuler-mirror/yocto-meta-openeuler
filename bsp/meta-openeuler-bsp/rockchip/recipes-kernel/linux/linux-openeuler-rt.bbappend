require recipes-kernel/linux/linux-rockchip.inc

SRC_URI:append:rockchip = " \
    file://patches/0002-fix-fiq_debugger.patch \
    file://patches/0002-fix_fpsimd_sched_panic.patch \
"

OPENEULER_MULTI_REPOS += "src-kernel-5.10-tag928"

#add COMPATIBLE_MACHINE
COMPATIBLE_MACHINE = "ok3568|ryd-3568|ok3588|ok3399|roc-rk3588s-pc|orangepi4-lts|orangepi5"

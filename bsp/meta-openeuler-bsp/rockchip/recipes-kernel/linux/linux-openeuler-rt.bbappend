require recipes-kernel/linux/linux-rockchip.inc

SRC_URI:remove = " \
    file://src-kernel-5.10/0001-apply-preempt-RT-patch.patch \
    file://src-kernel-5.10/0001-modify-openeuler_defconfig-for-rt62.patch \
"

SRC_URI:append = " \
    file://src-kernel-5.10-tag-rockchip/0001-apply-preempt-RT-patch.patch \
    file://patches/0001-fix-IRQ_WORK_INIT_HARD-panic.patch \
    file://patches/0002-fix-fiq_debugger.patch \
    file://patches/0002-fix_fpsimd_sched_panic.patch \
"

OPENEULER_MULTI_REPOS += "src-kernel-5.10-tag-rockchip"

#add COMPATIBLE_MACHINE
COMPATIBLE_MACHINE = "ok3568|ryd-3568|ok3588|ok3399|roc-rk3588s-pc|orangepi4-lts|orangepi5"

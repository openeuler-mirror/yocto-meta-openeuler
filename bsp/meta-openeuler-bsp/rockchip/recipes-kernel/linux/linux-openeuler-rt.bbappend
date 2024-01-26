require recipes-kernel/linux/linux-rockchip.inc

SRC_URI_append_rockchip = " \
    file://src-rockchip-kernel/0001-apply-preempt-RT-patch.patch \
    file://patches/0002-fix-fiq_debugger.patch \
    file://patches/0002-fix_fpsimd_sched_panic.patch \
"

SRC_URI_remove_rockchip = " \
    file://src-kernel-5.10/0001-apply-preempt-RT-patch.patch \
    file://src-kernel-5.10/0001-modify-openeuler_defconfig-for-rt62.patch \
"

#add COMPATIBLE_MACHINE
COMPATIBLE_MACHINE = "ok3568|ryd-3568|ok3588|ok3399"

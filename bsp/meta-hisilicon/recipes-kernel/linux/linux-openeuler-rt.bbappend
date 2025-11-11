# add COMPATIBLE_MACHINE
COMPATIBLE_MACHINE = "hi3093|hieulerpi1"

require recipes-kernel/linux/${@bb.utils.contains('DISTRO_FEATURES', 'mpu_solution', 'linux-hi3093-mpu.inc', 'linux-${MACHINE}.inc', d)}

SRC_URI:remove:hieulerpi1 = " \
    file://src-kernel-${PV}/0001-apply-preempt-RT-patch.patch \
    file://src-kernel-${PV}/patch-6.6.0-6.0.0-rt20.patch \
    file://src-kernel-${PV}/patch-6.6.0-6.0.0-rt20.patch-openeuler_defconfig.patch \
    file://patches/rt/0001-Revert-mm-convert-mm-s-rss-stats-to-use-atomic-mode.patch \
    file://patches/rt/0002-Revert-percpu_counter-introduce-atomic-mode-for-perc.patch \
"
SRC_URI:prepend:hieulerpi1 = " \
    ${@bb.utils.contains('DISTRO_FEATURES', 'kernel6', ' \
    ', ' \
        file://patch/0001-apply-preempt-RT-patch-b88a0de01.patch \
    ', d)} \
"

SRC_URI:append:hieulerpi1 = " \
    ${@bb.utils.contains('DISTRO_FEATURES', 'kernel6', ' \
        file://patch/0001-hieulerpi-preempt-rt-for-6.6.patch \
    ', ' \
    ', d)} \
"

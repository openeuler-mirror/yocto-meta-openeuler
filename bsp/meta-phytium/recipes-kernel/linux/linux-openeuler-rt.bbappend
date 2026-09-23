require recipes-kernel/linux/linux-phytium.inc

SRC_URI:remove = " \
    ${@bb.utils.contains('DISTRO_FEATURES', 'kernel6', ' \
        file://src-kernel-${PV}/patch-6.6.0-6.0.0-rt79.patch \
    ', '', d)} \
"

SRC_URI:append = " \
    ${@bb.utils.contains('DISTRO_FEATURES', 'kernel6', ' \
        file://patches/patch-6.6.0-6.0.0-rt20.patch \
    ', '', d)} \
"

SRC_URI:append:phytium = "\
        ${@bb.utils.contains('DISTRO_FEATURES', 'kernel6', ' ' \
        , ' \
       file://patches/fix_rt_kernel_warning_on_calltrace.patch \
       ', d)} \
"

# add COMPATIBLE_MACHINE
COMPATIBLE_MACHINE = "phytium"

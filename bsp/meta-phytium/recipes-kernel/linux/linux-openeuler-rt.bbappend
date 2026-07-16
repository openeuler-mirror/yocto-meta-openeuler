require recipes-kernel/linux/linux-phytium.inc

SRC_URI:append:phytium = "\
        ${@bb.utils.contains('DISTRO_FEATURES', 'kernel6', ' ' \
        , ' \
       file://patches/fix_rt_kernel_warning_on_calltrace.patch \
       ', d)} \
"

# add COMPATIBLE_MACHINE
COMPATIBLE_MACHINE = "phytium"

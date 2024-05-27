SRC_URI:append:raspberrypi4 = " \
    ${@bb.utils.contains('DISTRO_FEATURES', 'kernel6', ' \
        file://src-kernel-${PV}/0000-raspberrypi-kernel.patch \
    ' ,' \
        file://src-kernel-${PV}-tag-rpi/0000-raspberrypi-kernel.patch \
    ', d)} \
"
require linux-openeuler-rpi.inc

FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

SRC_URI:append = " \
    ${@bb.utils.contains('DISTRO_FEATURES', 'kernel6', ' \
    file://busybox-kernel6.cfg \
', ' \
', d)} \
"
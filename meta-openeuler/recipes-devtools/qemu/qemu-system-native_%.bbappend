
SRC_URI:prepend = " file://${BP}.tar.xz "

PACKAGECONFIG:remove = " virglrenderer epoxy "

FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

SRC_URI:append = " \
    ${@bb.utils.contains('DISTRO_FEATURES', 'mcs', ' \
        file://add_extra_uart_for_mcs_feature.patch \
    ' ,'', d)} \
"

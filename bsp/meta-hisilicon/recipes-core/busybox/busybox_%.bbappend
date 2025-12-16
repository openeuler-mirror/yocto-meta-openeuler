FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

SRC_URI:append = " \
        file://devmem.cfg \
"

SRC_URI:append:hipico = " \
        file://udhcpd.cfg \
        file://wget.cfg \
"

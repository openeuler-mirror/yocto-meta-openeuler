FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

COMPATIBLE_MACHINE:zedboard = "zedboard"

SRC_URI:append:zedboard = " \
    file://zedboard.cfg \
    file://0001-ARM-dts-zynq-zed-add-PL-design-nodes.patch \
"
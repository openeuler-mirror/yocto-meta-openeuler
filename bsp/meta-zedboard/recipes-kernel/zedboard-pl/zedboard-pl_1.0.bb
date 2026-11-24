SUMMARY = "ZedBoard PL bitstream loader"
DESCRIPTION = "Platform driver that programs the ZedBoard PL from \
/lib/firmware/system.bit.bin through the exported FPGA manager API \
(Linux 5.10 has no sysfs firmware interface)."
LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/GPL-2.0-only;md5=801f80980d171dd6425610833a22dbe6"

inherit module

COMPATIBLE_MACHINE = "zedboard"

SRC_URI = " \
    file://Makefile \
    file://zedboard-pl.c \
"

S = "${WORKDIR}"
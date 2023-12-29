SUMMARY  = "add wifi firmware to /lib"
DESCRIPTION = "wifi_firmware"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"
PR = "r0"
SRC_URI = "file://firmware/nxp"

FILES_${PN} += "/lib/firmware/nxp"
inherit allarch

do_install() {
        install -d ${D}/lib/firmware/nxp
        install -m 0755 ${WORKDIR}/firmware/nxp/* ${D}/lib/firmware/nxp/
}

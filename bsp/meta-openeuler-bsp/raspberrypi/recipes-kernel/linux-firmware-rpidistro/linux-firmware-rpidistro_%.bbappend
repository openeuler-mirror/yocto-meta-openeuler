# apply openeuler source package

OPENEULER_REPO_NAME = "raspberrypi-firmware"

PV = "20230315"

SRC_URI = "file://raspberrypi-firmware-${PV}.tar.gz \
"

S = "${WORKDIR}/raspberrypi-firmware-${PV}"

LICENSE = "\
    Firmware-broadcom_bcm43xx-rpidistro \
"

# openeuler source package directory tree is difference
LIC_FILES_CHKSUM = "\
    file://License/LICENCE.broadcom_bcm43xx;md5=3160c14df7228891b868060e1951dfbc \
"

NO_GENERIC_LICENSE[Firmware-broadcom_bcm43xx-rpidistro] = "License/LICENCE.broadcom_bcm43xx"

# in do_install function, it will exec:
# cp ./LICENCE.broadcom_bcm43xx ${D}${nonarch_base_libdir}/firmware/LICENCE.broadcom_bcm43xx-rpidistro
# but this license file is at ${S}/License in openeuler source package
# so copy it to ${S} in do_compile function
do_compile_append() {
    cp ./License/LICENCE.broadcom_bcm43xx ./LICENCE.broadcom_bcm43xx
}

# regulatory.db is needed when firmware load
# this files is packed together in raspberrypi-firmware, just copy it.
# update from upstream
do_install_append() {
    cp ./regulatory* ${D}${nonarch_base_libdir}/firmware
}

PACKAGES += "\
    ${PN}-bcm43436 \
    ${PN}-bcm43436s \
"

FILES_${PN}-bcm43455 += " \
    ${nonarch_base_libdir}/firmware/regulatory* \
    ${nonarch_base_libdir}/firmware/cypress/cyfmac43455-sdio* \
"

FILES:${PN}-bcm43430 += " \
    ${nonarch_base_libdir}/firmware/cypress/cyfmac43430-sdio.bin \
    ${nonarch_base_libdir}/firmware/cypress/cyfmac43430-sdio.clm_blob \
"

FILES:${PN}-bcm43436 = "${nonarch_base_libdir}/firmware/brcm/brcmfmac43436-*"

FILES:${PN}-bcm43436s = "${nonarch_base_libdir}/firmware/brcm/brcmfmac43436s*"

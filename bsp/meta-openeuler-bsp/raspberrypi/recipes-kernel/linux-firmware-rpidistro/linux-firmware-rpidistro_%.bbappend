# apply openeuler source package

OPENEULER_REPO_NAME = "raspberrypi-firmware"

PV = "20230316"

SRC_URI = "file://raspberrypi-firmware-${PV}.tar.gz \
"

S = "${WORKDIR}/raspberrypi-firmware-${PV}"

LICENSE = "\
    Firmware-broadcom_bcm43xx-rpidistro \
"

# openeuler source package directory tree is difference
LIC_FILES_CHKSUM = "\
    file://License/LICENCE.broadcom_brcm80211;md5=a59d187f4143e4acd4e8dc4dc626f591 \
"

NO_GENERIC_LICENSE[Firmware-broadcom_bcm43xx-rpidistro] = "License/LICENCE.broadcom_brcm80211"

# in do_install function, it will exec:
# cp ./LICENCE.broadcom_bcm43xx ${D}${nonarch_base_libdir}/firmware/LICENCE.broadcom_bcm43xx-rpidistro
# but this license file is at ${S}/License in openeuler source package
# so copy it to ${S} in do_compile function
do_compile:append() {
    cp ./License/LICENCE.broadcom_brcm80211 ./LICENCE.broadcom_bcm43xx
}

# regulatory.db is needed when firmware load
# this files is packed together in raspberrypi-firmware, just copy it.
# update from upstream
do_install() {
    install -d ${D}${nonarch_base_libdir}/firmware/brcm ${D}${nonarch_base_libdir}/firmware/cypress

    cp ./LICENCE.broadcom_bcm43xx ${D}${nonarch_base_libdir}/firmware/LICENSE.broadcom_bcm43xx-rpidistro

    for fw in \
            brcmfmac43430-sdio \
            brcmfmac43436-sdio \
            brcmfmac43436s-sdio \
            brcmfmac43455-sdio \
            brcmfmac43456-sdio; do
        cp -R --no-dereference --preserve=mode,links -v brcm/${fw}.* ${D}${nonarch_base_libdir}/firmware/brcm/
    done

    cp -R --no-dereference --preserve=mode,links -v cypress/* ${D}${nonarch_base_libdir}/firmware/cypress/

    rm ${D}${nonarch_base_libdir}/firmware/cypress/README.txt
    rm ${D}${nonarch_base_libdir}/firmware/cypress/43439A0-7.95.49.00.combined
    
    rm ${D}${nonarch_base_libdir}/firmware/brcm/brcmfmac43455-sdio.bin
    ln -s ../cypress/cyfmac43455-sdio-standard.bin ${D}/${nonarch_base_libdir}/firmware/brcm/brcmfmac43455-sdio.bin

    # add compat links. Fixes errors like
    # brcmfmac mmc1:0001:1: Direct firmware load for brcm/brcmfmac43455-sdio.raspberrypi,4-model-compute-module.txt failed with error -2
    ln -sf brcmfmac43455-sdio.txt ${D}${nonarch_base_libdir}/firmware/brcm/brcmfmac43455-sdio.raspberrypi,4-compute-module.txt
    # brcmfmac mmc1:0001:1: Direct firmware load for brcm/brcmfmac43455-sdio.raspberrypi,4-model-b.bin failed with error -2
    ln -sf brcmfmac43455-sdio.bin ${D}${nonarch_base_libdir}/firmware/brcm/brcmfmac43455-sdio.raspberrypi,4-model-b.bin
    # brcmfmac mmc1:0001:1: Direct firmware load for brcm/brcmfmac43430-sdio.raspberrypi,model-zero-w.bin failed with error -2
    ln -sf brcmfmac43430-sdio.bin ${D}${nonarch_base_libdir}/firmware/brcm/brcmfmac43430-sdio.raspberrypi,model-zero-w.bin
    # brcmfmac mmc1:0001:1: Direct firmware load for brcm/brcmfmac43430-sdio.raspberrypi,3-model-b.bin failed with error -2
    ln -sf brcmfmac43430-sdio.bin ${D}${nonarch_base_libdir}/firmware/brcm/brcmfmac43430-sdio.raspberrypi,3-model-b.bin

    cp ./regulatory* ${D}${nonarch_base_libdir}/firmware
}

FILES:${PN}-bcm43455 += " \
    ${nonarch_base_libdir}/firmware/regulatory* \
    ${nonarch_base_libdir}/firmware/cypress/cyfmac43455-sdio* \
"

FILES:${PN}-bcm43430 += " \
    ${nonarch_base_libdir}/firmware/cypress/cyfmac43430-sdio.bin \
    ${nonarch_base_libdir}/firmware/cypress/cyfmac43430-sdio.clm_blob \
"

FILES:${PN}-bcm43436 = "${nonarch_base_libdir}/firmware/brcm/brcmfmac43436-*"

FILES:${PN}-bcm43436s = "${nonarch_base_libdir}/firmware/brcm/brcmfmac43436s*"

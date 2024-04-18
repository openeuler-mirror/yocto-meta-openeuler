# apply openeuler source package
OPENEULER_REPO_NAME = "raspberrypi-firmware"

PV = "20231219"

# openeuler source package directory tree is difference
LIC_FILES_CHKSUM = "\
    file://License/LICENCE.broadcom_bcm43xx;md5=3160c14df7228891b868060e1951dfbc \
"

NO_GENERIC_LICENSE[Firmware-broadcom_bcm43xx-rpidistro] = "License/LICENCE.broadcom_bcm43xx"

SRC_URI = "file://raspberrypi-firmware-${PV}.tar.gz \
"

S = "${WORKDIR}/raspberrypi-firmware-${PV}"


do_configure[noexec] = "1"
do_compile[noexec] = "1"

do_install() {
    install -d ${D}${nonarch_base_libdir}/firmware/brcm

    cp License/LICENCE.broadcom_bcm43xx ${D}${nonarch_base_libdir}/firmware/LICENSE.broadcom_bcm43xx-rpidistro

    for fw in \
            brcmfmac43430-sdio \
            brcmfmac43436-sdio \
            brcmfmac43436s-sdio \
            brcmfmac43455-sdio \
            brcmfmac43456-sdio; do
        cp -R --no-dereference --preserve=mode,links -v brcm/${fw}.* ${D}${nonarch_base_libdir}/firmware/brcm/
    done
}

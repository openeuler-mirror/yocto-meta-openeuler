# apply openeuler source package
OPENEULER_REPO_NAME = "raspberrypi-firmware"

PV = "20240419"

SRC_URI = "file://raspberrypi-firmware-${PV}.tar.gz \
"

S = "${WORKDIR}/raspberrypi-firmware-${PV}"

LIC_FILES_CHKSUM = "\
    file://LICENCE.cypress-rpidistro;md5=eb723b61539feef013de476e68b5c50a \
"

# copy license
do_extract_lic() {
    cp ${S}/License/LICENCE.bluez-firmware ${S}/LICENCE.cypress-rpidistro
}

# openeuler source package directory tree is difference
do_install() {
    install -d ${D}${nonarch_base_libdir}/firmware/brcm

    cp LICENCE.cypress-rpidistro ${D}${nonarch_base_libdir}/firmware
    install -m 0644 BCM434*.hcd ${D}${nonarch_base_libdir}/firmware/brcm/
}

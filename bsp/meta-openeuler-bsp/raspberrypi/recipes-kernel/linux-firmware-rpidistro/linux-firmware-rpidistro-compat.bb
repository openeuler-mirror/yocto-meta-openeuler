SUMMARY = "Linux kernel firmware files from Raspbian distribution"
DESCRIPTION = "Updated firmware files for RaspberryPi hardware. \
RPi-Distro obtains these directly from Cypress; they are not submitted \
to linux-firmware for general use."
HOMEPAGE = "https://github.com/RPi-Distro/firmware-nonfree"
SECTION = "kernel"

# In maintained upstream linux-firmware:
# * brcmfmac43430-sdio falls under LICENSE.cypress
# * brcmfmac43455-sdio falls under LICENSE.broadcom_bcm43xx
# * brcmfmac43456-sdio falls under LICENSE.broadcom_bcm43xx
#
# It is likely[^1] that both of these should be under LICENSE.cypress.
# Further, at this time the text of LICENSE.broadcom_bcm43xx is the same
# in linux-firmware and RPi-Distro/firmware-nonfree, but this may
# change.
#
# Rather than make assumptions about what's supposed to be what, we'll
# use the license implied by the source of these files, named to avoid
# conflicts with linux-firmware.
#
# [^1]: https://github.com/RPi-Distro/bluez-firmware/issues/1
LICENSE = "\
    Firmware-broadcom_bcm43xx-rpidistro \
"

# apply openeuler source package
OPENEULER_REPO_NAME = "raspberrypi-firmware"

inherit allarch

PV = "20240419"

# openeuler source package directory tree is difference
LIC_FILES_CHKSUM = "\
    file://License/LICENCE.broadcom_bcm43xx;md5=3160c14df7228891b868060e1951dfbc \
"

# These are not common licenses, set NO_GENERIC_LICENSE for them
# so that the license files will be copied from fetched source
NO_GENERIC_LICENSE[Firmware-broadcom_bcm43xx-rpidistro] = "License/LICENCE.broadcom_bcm43xx"

SRC_URI = "file://raspberrypi-firmware-${PV}.tar.gz \
"

S = "${WORKDIR}/raspberrypi-firmware-${PV}"


CLEANBROKEN = "1"

do_compile() {
    :
}
do_configure[noexec] = "1"
do_compile[noexec] = "1"

do_install() {
    install -d ${D}${nonarch_base_libdir}/firmware/brcm

    cp License/LICENCE.broadcom_bcm43xx ${D}${nonarch_base_libdir}/firmware/LICENSE.broadcom_bcm43xx-rpidistro

    cp -R --no-dereference --preserve=mode,links -v brcm/* ${D}${nonarch_base_libdir}/firmware/brcm/
}

PACKAGES = "\
    ${PN}-broadcom-license \
    ${PN}-bcm43xx \
"

LICENSE:${PN}-bcm43xx = "Firmware-broadcom_bcm43xx-rpidistro"
LICENSE:${PN}-broadcom-license = "Firmware-broadcom_bcm43xx-rpidistro"

FILES:${PN}-broadcom-license = "${nonarch_base_libdir}/firmware/LICENSE.broadcom_bcm43xx-rpidistro"
FILES:${PN}-bcm43xx = "${nonarch_base_libdir}/firmware/brcm/*"
RDEPENDS:${PN}-bcm43xx += "${PN}-broadcom-license"

# Firmware files are generally not run on the CPU, so they can be
# allarch despite being architecture specific
INSANE_SKIP = "arch"

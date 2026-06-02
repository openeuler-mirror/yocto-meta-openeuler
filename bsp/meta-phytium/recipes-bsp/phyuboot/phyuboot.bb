SUMMARY = "phytium uboot"
DESCRIPTION = "phytium uboot"
LICENSE = "PPL-1.0"
LIC_FILES_CHKSUM = "file://COPYING;md5=9dd6301488f42abb6e3196ef96b8daa9"

inherit deploy

SRC_URI = "git://git@gitee.com/phytium_embedded/phytium-rogue-umlibs.git;branch=${BRANCH};protocol=https"
BRANCH = "develop"
SRCREV = "291d906e69389fcb7acb04733b50ea9a12c9c886"

S = "${WORKDIR}/git"

do_configure[noexec] = "1"
do_compile[noexec] = "1"

# option size is "2GB" and "4GB"
RAMSIZE = "4GB"

do_install () {
    install -d ${D}
    cp -r ${S}/phyuboot/fip-all-optee-${RAMSIZE}.bin  ${D}/fip-all.bin
}

do_deploy () {
    install -d ${DEPLOYDIR}/
    cp -r ${D}/* ${DEPLOYDIR}/
}
addtask deploy after do_install

PACKAGES += "${PN}-image"
FILES:${PN}-image += "/"
PACKAGE_ARCH = "${MACHINE_ARCH}"

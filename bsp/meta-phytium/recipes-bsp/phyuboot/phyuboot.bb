SUMMARY = "phytium uboot"
DESCRIPTION = "phytium uboot"
LICENSE = "PPL-1.0"
LIC_FILES_CHKSUM = "file://PPL-1.0;md5=9dd6301488f42abb6e3196ef96b8daa9"

inherit deploy

OPENEULER_LOCAL_NAME = "oee_archive"

SRC_URI = " \
    file://${OPENEULER_LOCAL_NAME}/${BPN}/${BPN}.tar.gz \
"

S = "${WORKDIR}/phyuboot"

do_configure[noexec] = "1"
do_compile[noexec] = "1"

OPTEE_ENABLED = "1"

# option size is "2GB" and "4GB"
RAMSIZE = "4GB"

do_install () {
    install -d ${D}
    
    if [ "${OPTEE_ENABLED}" = "1" ]; then
        cp -r ${S}/fip-all-optee-${RAMSIZE}.bin  ${D}/fip-all.bin
    else
        cp -r ${S}/fip-all-${RAMSIZE}.bin  ${D}/fip-all.bin
    fi
}

do_deploy () {
    install -d ${DEPLOYDIR}/
    cp -r ${D}/* ${DEPLOYDIR}/
}
addtask deploy after do_install

PACKAGES += "${PN}-image"
FILES:${PN}-image += "/"
PACKAGE_ARCH = "${MACHINE_ARCH}"

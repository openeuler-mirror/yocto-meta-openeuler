SUMMARY = "phytium uboot"
DESCRIPTION = "phytium uboot"
LICENSE = "PPL-1.0"
LIC_FILES_CHKSUM = "file://COPYING;md5=9dd6301488f42abb6e3196ef96b8daa9"

inherit deploy

# Fetch only the prebuilt FIP binaries instead of cloning the whole
# phytium-rogue-umlibs repository, which is large and slow to fetch.
# The commit hash below pins the exact same revision as the old SRCREV.
PHYTIUM_UM_LIBS_REV = "291d906e69389fcb7acb04733b50ea9a12c9c886"
PHYTIUM_UM_LIBS_RAW = "https://gitee.com/phytium_embedded/phytium-rogue-umlibs/raw/${PHYTIUM_UM_LIBS_REV}"

SRC_URI = " \
    ${PHYTIUM_UM_LIBS_RAW}/COPYING;downloadfilename=COPYING;name=copying \
    ${PHYTIUM_UM_LIBS_RAW}/phyuboot/fip-all-optee-2GB.bin;downloadfilename=fip-all-optee-2GB.bin;name=fip2gb \
    ${PHYTIUM_UM_LIBS_RAW}/phyuboot/fip-all-optee-4GB.bin;downloadfilename=fip-all-optee-4GB.bin;name=fip4gb \
    "
SRC_URI[copying.sha256sum] = "63e2e2cc807dff2f29c61a5fd92c9723cd0e4c9b087a47495d76d6c574c3c264"
SRC_URI[fip2gb.sha256sum] = "5ea39ddf7bcfd8ff1b3448fa0c71847a9c1e653f2cdd2cfc2451f813d8c946e4"
SRC_URI[fip4gb.sha256sum] = "cc16f989a2d1fe94f103aa50ae70a03b1dad5b7a5523924ecfc2fa555f9adea9"

S = "${WORKDIR}"

do_configure[noexec] = "1"
do_compile[noexec] = "1"

# option size is "2GB" and "4GB"
RAMSIZE = "4GB"

do_install () {
    install -d ${D}
    install -m 0644 ${WORKDIR}/fip-all-optee-${RAMSIZE}.bin ${D}/fip-all.bin
}

do_deploy () {
    install -d ${DEPLOYDIR}/
    cp -r ${D}/* ${DEPLOYDIR}/
}
addtask deploy after do_install

PACKAGES += "${PN}-image"
FILES:${PN}-image += "/"
PACKAGE_ARCH = "${MACHINE_ARCH}"

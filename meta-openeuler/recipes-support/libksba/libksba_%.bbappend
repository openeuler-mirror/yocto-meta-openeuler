PV = "1.6.0"

OPENEULER_BRANCH = "master"
SRC_URI = "\
        ${GNUPG_MIRROR}/${BPN}/${BPN}-${PV}.tar.bz2 \
        file://backport-CVE-2022-3515-Detect-a-possible-overflow-directly-in-the-TLV-parse.patch \
"

# apply patches from poky
FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
SRC_URI += " \
           file://ksba-add-pkgconfig-support.patch \
"

SRC_URI[sha256sum] = "dad683e6f2d915d880aa4bed5cea9a115690b8935b78a1bbe01669189307a48b"

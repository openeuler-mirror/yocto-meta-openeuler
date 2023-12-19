PV = "1.6.4"

SRC_URI[sha256sum] = "bbb43f032b9164d86c781ffe42213a83bf4f2fee91455edfa4654521b8b03b6b"

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI_remove = " \
    ${GNUPG_MIRROR}/${BPN}/${BPN}-${PV}.tar.bz2 \
"

SRC_URI_prepend = " \
    file://${BP}.tar.bz2 \
"
PV = "1.3.2"

OPENEULER_SRC_URI_REMOVE = "https git http"

SRC_URI_remove = "${SOURCEFORGE_MIRROR}/${BPN}/${BP}.tar.bz2"
FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

SRC_URI += " \
    file://${BP}.tar.bz2 \
    file://0001-update-libtirpc-to-enable-tcp-port-listening.patch \
    file://CVE-2021-46828.patch \
"

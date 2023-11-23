PV = "1.3.2"

OPENEULER_SRC_URI_REMOVE = "https git http"

FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

SRC_URI += " \
    file://${BP}.tar.bz2 \
    file://0001-update-libtirpc-to-enable-tcp-port-listening.patch \
    file://CVE-2021-46828.patch \
"

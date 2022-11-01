PV = "1.3.2"

FILESEXTRAPATHS_prepend := "${THISDIR}/files/:"

SRC_URI[sha256sum] = "e24eb88b8ce7db3b7ca6eb80115dd1284abc5ec32a8deccfed2224fc2532b9fd"

SRC_URI += " \
    file://0001-update-libtirpc-to-enable-tcp-port-listening.patch \
    file://backport-CVE-2021-46828-yocto-ignore-install.patch \
"


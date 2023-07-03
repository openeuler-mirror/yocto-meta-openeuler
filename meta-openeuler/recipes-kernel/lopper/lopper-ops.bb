SUMMARY = "The operation files used by lopper."
DESCRITPION = "Lopper applies those operations to device tree, and outputs one or more modified/processed trees."
### License metadata
LICENSE = "MulanPSLv2"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/MulanPSL-2.0;md5=74b1b7a7ee537a16390ed514498bf23c"

# Use the operation files from current layer
FILESEXTRAPATHS:prepend := "${THISDIR}/:"
SRC_URI = "file://lops/"

DEPENDS += "lopper-native"

do_install() {
    install -d ${D}${libdir}
    cp -r ${WORKDIR}/lops ${D}${libdir}
}

FILES:${PN} += "${libdir}/lops"

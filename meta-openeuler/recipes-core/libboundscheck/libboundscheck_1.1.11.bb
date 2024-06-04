SUMMARY = "Enhanced safety functions"
DESCRIPTION = "libboundscheck provides a set of functions of the common memory/string operation classes."
LICENSE = "MulanPSL-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=ee892fc0a2b8916e6cd4a5ff81f92c08"

PV = "v1.1.11"

SRC_URI = "file://${BP}.tar.gz"

INSANE_SKIP:${PN} += "already-stripped"
FILES:${PN}-dev = "${includedir}"
FILES:${PN} = "${libdir}"

do_install () {
    install -d ${D}${libdir}/
    install -d ${D}/${includedir}/
    install -m 0755 ${S}/lib/libboundscheck.so ${D}${libdir}/
    install -m 554 ${S}/include/*.h ${D}${includedir}/
}

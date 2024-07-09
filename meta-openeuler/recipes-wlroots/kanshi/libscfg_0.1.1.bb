SUMMARY = "A C library for scfg(simple configuration file format)"
HOMEPAGE = "https://git.sr.ht/~emersion/libscfg"
SECTION = "LIBRARY"
LICENSE = "MIT"

LIC_FILES_CHKSUM = "file://LICENSE;md5=b32b698ab815d1913b4ed31d8c2ee8d7"

OPENEULER_LOCAL_NAME = "oee_archive"

PV = "0.1.1"

SRC_URI += " \
        file://${OPENEULER_LOCAL_NAME}/${BPN}/v${PV}.tar.gz \
"

inherit meson pkgconfig

S = "${WORKDIR}/libscfg-v${PV}"

FILES:${PN} = "${libdir}/*so"
FILES:${PN}-dev = "${includedir} ${libdir}/pkgconfig"

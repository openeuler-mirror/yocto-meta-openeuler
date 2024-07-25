# get src from here
# FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

OPENEULER_LOCAL_NAME = "oee_archive"

SRC_URI += "file://${OPENEULER_LOCAL_NAME}/${BPN}/${BPN}.tar.gz"

SRC_URI[sha256sum] = "9095a2093ea8ac3991da45b1bce872c4f90b262aa8076a227d5af35144cb5c0b"

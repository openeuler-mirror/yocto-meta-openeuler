# use local src file here
FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"

PV = "0.29.2"

OPENEULER_SRC_URI_REMOVE = "git"

SRC_URI:prepend = "file://pkg-config-${PV}.tar.gz \
           "

SRC_URI[sha256sum] = "8a7b4114765ef4c96cbf02b0be804c0097447461dd76a86c3700c2d241b723ad"

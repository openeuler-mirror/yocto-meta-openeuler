PV = "5.0"
S = "${WORKDIR}/${BP}"
OPENEULER_SRC_URI_REMOVE = "https http git"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:prepend = " \
        file://${BPN}-${PV}.tar.xz \
"


PV = "5.0"
S = "${WORKDIR}/${BP}"
OPENEULER_SRC_URI_REMOVE = "https http git"

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI_prepend = " \
        file://${BPN}-${PV}.tar.xz \
"

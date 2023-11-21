OPENEULER_LOCAL_NAME = "oee_archive"

OPENEULER_SRC_URI_REMOVE = "git"

PV = "1.0"

SRC_URI += "file://${OPENEULER_LOCAL_NAME}/${BPN}/${BPN}-cross-${PV}.tar.gz \
"

S = "${WORKDIR}/${BPN}-cross-${PV}"

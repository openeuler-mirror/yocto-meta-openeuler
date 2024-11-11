inherit oee-archive

PV = "1.0"

SRC_URI += "file://${BPN}-cross-${PV}.tar.gz \
"

S = "${WORKDIR}/${BPN}-cross-${PV}"


PV = "4.0.43"

# openeuler source
SRC_URI:prepend = "file://mtools-${PV}.tar.bz2 \
           "

S = "${WORKDIR}/mtools-${PV}"

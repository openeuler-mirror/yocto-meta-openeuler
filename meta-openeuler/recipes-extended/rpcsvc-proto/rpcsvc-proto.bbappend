
PV = "1.4.3"

# openeuler source
SRC_URI:prepend = "file://rpcsvc-proto-${PV}.tar.xz \
           "

S = "${WORKDIR}/rpcsvc-proto-${PV}"

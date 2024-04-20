
PV = "1.4.4"

SRCREV = "c65926005e50da02a4da3e26abc42eded36cd19d"

# openeuler source
SRC_URI:prepend = "file://${BP}.tar.xz \
           "

S = "${WORKDIR}/${BP}"

FILESEXTRAPATHS:prepend := "${THISDIR}/:"
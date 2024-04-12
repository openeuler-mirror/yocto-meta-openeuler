
PV = "1.4.4"

SRCREV = "c65926005e50da02a4da3e26abc42eded36cd19d"

# openeuler source
SRC_URI:prepend = "file://${BP}.tar.xz \
           "

SRC_URI:remove = "file://0001-Use-cross-compiled-rpcgen.patch \
"

S = "${WORKDIR}/${BP}"

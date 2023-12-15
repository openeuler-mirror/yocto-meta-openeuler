OPENEULER_SRC_URI_REMOVE = "https"

PV = "2.7.6"

# apply openeuler source package and patches
SRC_URI:prepend = "file://patch-${PV}.tar.xz \
"

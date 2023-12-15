OPENEULER_SRC_URI_REMOVE = "http"

PV = "0.16"

# apply openeuler source package and patches
SRC_URI:prepend = "file://chrpath-${PV}.tar.gz \
"

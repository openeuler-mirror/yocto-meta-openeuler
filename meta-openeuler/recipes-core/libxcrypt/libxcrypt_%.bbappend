OPENEULER_SRC_URI_REMOVE = "git"

PV = "4.4.36"

# openeuler patch
SRC_URI:prepend = "file://v${PV}.tar.gz \
           "

S = "${WORKDIR}/${BP}"

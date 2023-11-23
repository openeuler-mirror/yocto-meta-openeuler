OPENEULER_SRC_URI_REMOVE = "git"

PV = "0.1.19"

SRC_URI:prepend = "file://${PV}.tar.gz \
           "

S = "${WORKDIR}/${BP}"

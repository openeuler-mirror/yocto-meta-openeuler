OPENEULER_SRC_URI_REMOVE = "git"

PV = "0.16.0"

SRC_URI:prepend = "file://${BP}.tar.gz \
           "

S = "${WORKDIR}/${BP}"

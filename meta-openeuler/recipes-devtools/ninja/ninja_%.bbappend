OPENEULER_SRC_URI_REMOVE = "git"

SRC_URI:prepend = "file://${BP}.tar.gz \
"

S = "${WORKDIR}/${BP}"

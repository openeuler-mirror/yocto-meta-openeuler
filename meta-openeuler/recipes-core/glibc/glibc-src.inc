OPENEULER_REPO_NAME = "glibc"
OPENEULER_SRC_URI_REMOVE = "git https http"

PV = "2.38"

SRC_URI:prepend = "file://glibc-${PV}.tar.xz \
"

S = "${WORKDIR}/${BP}"

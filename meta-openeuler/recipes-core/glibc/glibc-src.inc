OPENEULER_REPO_NAME = "glibc"

PV = "2.38"

SRC_URI:prepend = "file://glibc-${PV}.tar.xz \
"

S = "${WORKDIR}/${BP}"

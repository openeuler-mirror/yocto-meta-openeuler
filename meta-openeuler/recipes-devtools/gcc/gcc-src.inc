OPENEULER_REPO_NAME = "gcc"
OPENEULER_SRC_URI_REMOVE = "http git"

# use openeuler source
SRC_URI += "file://gcc-${PV}.tar.xz"

PV = "12.3.0"
BINV = "12.3.0"

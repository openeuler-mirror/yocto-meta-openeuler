OPENEULER_REPO_NAME = "gcc"

# don't apply CVE patch in Poky
SRC_URI:remove = "file://CVE-2023-4039.patch"

# use openeuler source
SRC_URI += "file://gcc-${PV}.tar.xz"

PV = "12.3.0"
BINV = "12.3.0"

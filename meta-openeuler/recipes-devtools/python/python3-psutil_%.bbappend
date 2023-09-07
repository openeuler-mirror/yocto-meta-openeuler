OPENEULER_SRC_URI_REMOVE = "http https git"
OPENEULER_REPO_NAME = "python-psutil"
PV = "5.9.5"

LIC_FILES_CHKSUM = "file://LICENSE;md5=a9c72113a843d0d732a0ac1c200d81b1"

S = "${WORKDIR}/${PYPI_PACKAGE}-release-${PV}"

SRC_URI:remove = "file://0001-fix-failure-test-cases.patch"

SRC_URI:prepend = "file://psutil-${PV}.tar.gz "

BBCLASSEXTEND = "native"

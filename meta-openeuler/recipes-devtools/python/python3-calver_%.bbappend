PV = "2022.6.26"

OPENEULER_LOCAL_NAME = "python-calver"
SRC_URI = "file://calver-${PV}.tar.gz "
SRC_URI[sha256sum] = "e05493a3b17517ef1748fbe610da11f10485faa7c416b9d33fd4a52d74894f8b"

S = "${WORKDIR}/calver-${PV}"

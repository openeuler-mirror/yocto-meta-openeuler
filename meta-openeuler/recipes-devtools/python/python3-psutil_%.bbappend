PV = "5.9.0"
require pypi-src-openeuler.inc

S = "${WORKDIR}/${PYPI_PACKAGE}-release-${PV}"

SRC_URI[md5sum] = "080d75a78be3ef1ce72c39a9b001197d"
SRC_URI[sha256sum] = "ea4f431c10100079f46a494894582edb43e395324f200bd82ecf60b60b46a929"

# add RDEPENDS for 5.9
RDEPENDS:${PN} += " \
    ${PYTHON_PN}-ctypes \
    ${PYTHON_PN}-resource \
"

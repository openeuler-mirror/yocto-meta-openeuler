
PACKAGECONFIG[format] = " \
    ${PYTHON_PN}-jsonpointer \
     ${PYTHON_PN}-webcolors \
     ${PYTHON_PN}-rfc3987 \
     ${PYTHON_PN}-rfc3339-validator \
"

inherit oee-archive
OEE_ARCHIVE_SUB_DIR = "${PYPI_PACKAGE}"

SRC_URI:prepend = " \
    file://${PYPI_PACKAGE}-${PV}.tar.gz \
"

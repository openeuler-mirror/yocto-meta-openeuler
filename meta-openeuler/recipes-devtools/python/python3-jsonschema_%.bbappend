
PACKAGECONFIG[format] = " \
    ${PYTHON_PN}-jsonpointer \
     ${PYTHON_PN}-webcolors \
     ${PYTHON_PN}-rfc3987 \
     ${PYTHON_PN}-rfc3339-validator \
"

OPENEULER_LOCAL_NAME = "oee_archive"

SRC_URI:prepend = " \
    file://${OPENEULER_LOCAL_NAME}/${PYPI_PACKAGE}/${PYPI_PACKAGE}-${PV}.tar.gz \
"


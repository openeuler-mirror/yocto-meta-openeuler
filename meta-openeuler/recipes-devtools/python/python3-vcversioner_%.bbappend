OPENEULER_LOCAL_NAME = "oee_archive"

SRC_URI:prepend = " \
    file://${OPENEULER_LOCAL_NAME}/${PYPI_PACKAGE}/${PYPI_PACKAGE}-${PV}.tar.gz \
"


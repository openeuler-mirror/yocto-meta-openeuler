inherit oee-archive
OEE_ARCHIVE_SUB_DIR = "${PYPI_PACKAGE}"

SRC_URI:prepend = " \
    file://${PYPI_PACKAGE}-${PV}.tar.gz \
"

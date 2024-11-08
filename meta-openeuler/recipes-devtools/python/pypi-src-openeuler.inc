OPENEULER_LOCAL_NAME = "python-${PYPI_PACKAGE}"

# use openeuler's pkg src
SRC_URI:prepend = "file://${PYPI_PACKAGE}-${PV}.tar.gz "

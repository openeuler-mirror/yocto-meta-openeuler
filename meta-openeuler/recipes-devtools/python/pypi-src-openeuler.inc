OPENEULER_REPO_NAME = "python-${PYPI_PACKAGE}"

# use openeuler's pkg src
SRC_URI_remove += "${PYPI_SRC_URI} "
SRC_URI_prepend += "file://${PYPI_PACKAGE}-${PV}.tar.gz "

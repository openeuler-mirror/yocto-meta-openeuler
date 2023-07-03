OPENEULER_REPO_NAME = "python-${PYPI_PACKAGE}"

# use openeuler's pkg src
SRC_URI:remove = "${PYPI_SRC_URI} "
SRC_URI:prepend = "file://${PYPI_PACKAGE}-${PV}.tar.gz "

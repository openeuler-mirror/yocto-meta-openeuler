OPENEULER_REPO_NAME = "python-${PYPI_PACKAGE}"
OPENEULER_BRANCH = "openEuler-23.03"

# use openeuler's pkg src
SRC_URI_remove += "${PYPI_SRC_URI} "
SRC_URI_prepend += "file://${PYPI_PACKAGE}-${PV}.tar.gz "

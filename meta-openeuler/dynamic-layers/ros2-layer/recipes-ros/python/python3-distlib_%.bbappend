PV = "0.3.6"

OPENEULER_REPO_NAME = "python-${PYPI_PACKAGE}"
OPENEULER_BRANCH = "master"

# use openeuler's pkg src
SRC_URI_remove += "${PYPI_SRC_URI} "
SRC_URI_prepend += "file://${PYPI_PACKAGE}-${PV}.tar.gz "

SRC_URI += " \
        file://0001-add-setup.py.patch \
        "

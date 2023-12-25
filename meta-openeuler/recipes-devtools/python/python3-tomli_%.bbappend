# python3-pbr Dependencies
PV = "2.0.1"

OPENEULER_REPO_NAME = "python-tomli"

# use openeuler's pkg src
SRC_URI:remove = "${PYPI_SRC_URI} "
SRC_URI:prepend = "file://python-tomli-${PV}.tar.gz "

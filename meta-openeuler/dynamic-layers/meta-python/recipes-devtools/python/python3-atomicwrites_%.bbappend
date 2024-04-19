PV = "1.4.1"
OPENEULER_REPO_NAME = "python-${PYPI_PACKAGE}"

SRC_URI[sha256sum] = "81b2c9071a49367a7f770170e5eec8cb66567cfbbc8c73d20ce5ca4a8d71cf11"

RDEPENDS:${PN}-ptest += " \
       python3-unittest-automake-output \
"

SRC_URI:remove = " \
	file://run-ptest \
"

SRC_URI:prepend = "file://${PV}.tar.gz "

S = "${WORKDIR}/python-${PYPI_PACKAGE}-${PV}"

BBCLASSEXTEND = "native nativesdk"

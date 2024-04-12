PV = "3.1.3"

SRC_URI[sha256sum] = "ac8bd6544d4bb2c9792bf3a159e80bba8fda7f07e81bc3aed565432d5925ba90"

require pypi-src-openeuler.inc
OPENEULER_REPO_NAME = "python-jinja2"

RDEPENDS:${PN}-ptest += " \
    python3-unittest-automake-output \
"

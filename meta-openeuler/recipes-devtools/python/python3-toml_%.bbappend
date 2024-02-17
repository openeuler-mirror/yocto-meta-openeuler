PV = "0.10.2"
SRC_URI[md5sum] = "165f8d31000174760118dc9893ed9bb9"
SRC_URI[sha256sum] = "71d4039bbdec91e3e7591ec5d6c943c58f9a2d17e5f6783acdc378f743fcdd2a"

# use openeuler's pkg src
OPENEULER_REPO_NAME = "python-${PYPI_PACKAGE}"
SRC_URI:prepend = "file://${PV}.tar.gz "

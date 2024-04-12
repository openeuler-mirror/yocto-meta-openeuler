PV = "7.1.0"
require pypi-src-openeuler.inc

SRC_URI[sha256sum] = "6c508345a771aad7d56ebff0e70628bf2b0ec7573762be9960214730de278f27"

OPENEULER_REPO_NAME = "python-setuptools_scm"

UPSTREAM_CHECK_REGEX = "scm-(?P<pver>.*)\.tar"

DEPENDS += "python3-tomli-native python3-packaging-native python3-typing-extensions-native"

RDEPENDS:${PN} += " \
        ${PYTHON_PN}-pip \
        ${PYTHON_PN}-typing-extensions \
"

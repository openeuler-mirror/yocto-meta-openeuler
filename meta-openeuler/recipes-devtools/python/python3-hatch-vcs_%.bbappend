PV = "0.3.0"
require pypi-src-openeuler.inc

SRC_URI[sha256sum] = "cec5107cfce482c67f8bc96f18bbc320c9aa0d068180e14ad317bbee5a153fee"

SRC_URI:append = " file://Fix-setuptools_scm-7.1.0-test-incompatible.patch"

PV = "0.10.1"

# repo name containes "python3"
require pypi-src-openeuler.inc

# for 0.10.1
RDEPENDS:${PN} += " \
    python3-io \
"

SRC_URI[sha256sum] = "f4da4222ca8c3f43c8e18a8263e5426c750a3a837fdfeccf74c68d0408eaa3bf"
SRC_URI:append = " file://disable-test-oui-information.patch"

PV = "0.2.13"
require pypi-src-openeuler.inc

SRC_URI[sha256sum] = "72ea0c06399eb286d978fdedb6923a9eb47e1c486ce63e9b4e64fc18303972b5"

RDEPENDS:${PN}-ptest += " \
       python3-unittest-automake-output \
"

do_install_ptest:append() {
      install -d ${D}${PTEST_PATH}/bin
      cp -rf ${S}/bin/* ${D}${PTEST_PATH}/bin/
}

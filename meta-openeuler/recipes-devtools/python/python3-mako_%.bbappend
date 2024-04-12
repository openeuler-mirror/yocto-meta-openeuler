require pypi-src-openeuler.inc

OPENEULER_REPO_NAME = "python-mako"

PV = "1.2.4"

LIC_FILES_CHKSUM = "file://LICENSE;md5=ad08dd28df88e64b35bcac27c822ee34"

SRC_URI:remove = "file://CVE-2022-40023.patch"

SRC_URI[sha256sum] = "d60a3903dc3bb01a18ad6a89cdbe2e4eadc69c0bc8ef1e3773ba53d44c3f7a34"

RDEPENDS:${PN} += "${PYTHON_PN}-markupsafe \
                  ${PYTHON_PN}-pygments \
"

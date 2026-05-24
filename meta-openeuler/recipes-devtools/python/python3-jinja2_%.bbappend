PV = "3.1.3"
# Tarball extracts to Jinja2-3.1.3/ (capital J)
S = "${WORKDIR}/Jinja2-${PV}"
# The 3.1.3 tarball has LICENSE.rst (not LICENSE.txt as in poky's 3.1.6 recipe)
LIC_FILES_CHKSUM = "file://LICENSE.rst;md5=5dc88300786f1c214c1e9827a5229462"
# The 3.1.3 tarball uses setup.cfg/setup.py (not pyproject.toml), requiring setuptools for native build
DEPENDS:append:class-native = " python3-setuptools-native"
SRC_URI[sha256sum] = "ac8bd6544d4bb2c9792bf3a159e80bba8fda7f07e81bc3aed565432d5925ba90"

require pypi-src-openeuler.inc
OPENEULER_LOCAL_NAME = "python-jinja2"

RDEPENDS:${PN}-ptest += " \
    python3-unittest-automake-output \
"

SRC_URI:append = " \
    file://0001-disallow-invalid-characters-in-keys-to-xmlattr-filte.patch;patchdir=${S}/.. \
    file://backport-CVE-2024-56326.patch;patchdir=${S}/.. \
    file://backport-CVE-2024-56201.patch;patchdir=${S}/.. \
"

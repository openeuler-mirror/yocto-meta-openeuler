PV = "5.1.0"
require pypi-src-openeuler.inc

SRC_URI:remove = "file://CVE-2022-2309.patch"

# apply openeuler's patches
SRC_URI:append = " \
        file://Skip-failing-test_iterparse_utf16_bom.patch \
        "

SRC_URI[sha256sum] = "3eea6ed6e6c918e468e693c41ef07f3c3acc310b70ddd9cc72d9ef84bc9564ca"


SRC_URI = " \
    file://xsimd-13.2.0.tar.gz \
    file://0001-fix-copy-pasted-headers.patch \
"

RDEPENDS:${PN}-dev = ""
ALLOW_EMPTY:${PN} = "1"

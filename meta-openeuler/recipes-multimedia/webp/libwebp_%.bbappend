# main bb file: yocto-poky/meta/recipes-multimedia/webp/libwebp_1.2.0.bb
OPENEULER_SRC_URI_REMOVE = "http"

PV = "1.2.1"

SRC_URI_prepend = "file://${BP}.tar.gz \
"

SRC_URI += "file://libwebp-freeglut.patch \
        file://backport-CVE-2023-1999.patch \
        file://backport-0001-CVE-2023-4863.patch \
        file://backport-0002-CVE-2023-4863.patch \
"

SRC_URI[sha256sum] = "808b98d2f5b84e9b27fdef6c5372dac769c3bda4502febbfa5031bd3c4d7d018"

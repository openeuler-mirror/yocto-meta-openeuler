# main bb file: yocto-poky/meta/recipes-multimedia/webp/libwebp_1.2.0.bb

PV = "1.2.1"

SRC_URI += "file://backport-CVE-2023-1999.patch \
"

SRC_URI[sha256sum] = "808b98d2f5b84e9b27fdef6c5372dac769c3bda4502febbfa5031bd3c4d7d018"

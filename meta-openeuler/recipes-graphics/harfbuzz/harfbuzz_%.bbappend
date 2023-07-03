# main bb file: yocto-poky/meta/recipes-graphics/harfbuzz/harfbuzz_2.7.4.bb

PV = "6.0.0"

LIC_FILES_CHKSUM = "file://COPYING;md5=6ee0f16281694fb6aa689cca1e0fb3da \
"

SRC_URI = "file://${BP}.tar.xz \
    file://backport-CVE-2023-25193.patch \
"

SRC_URI[sha256sum] = "1d1010a1751d076d5291e433c138502a794d679a7498d1268ee21e2d4a140eb4"

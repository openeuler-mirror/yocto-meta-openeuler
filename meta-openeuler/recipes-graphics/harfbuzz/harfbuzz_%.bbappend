# main bb file: yocto-poky/meta/recipes-graphics/harfbuzz/harfbuzz_2.7.4.bb

PV = "2.8.2"

# update LICENSE checksum
LIC_FILES_CHKSUM_remove = "file://COPYING;md5=8f787620b7d3866d9552fd1924c07572 \
"
LIC_FILES_CHKSUM_prepend = "file://COPYING;md5=6ee0f16281694fb6aa689cca1e0fb3da \
"

SRC_URI_remove = "https://github.com/${BPN}/${BPN}/releases/download/${PV}/${BPN}-${PV}.tar.xz \
                  "

SRC_URI_prepend = "file://${BP}.tar.xz \
    file://backport-CVE-2022-33068.patch \
    file://backport-0001-CVE-2023-25193.patch \
    file://backport-0002-CVE-2023-25193.patch \
"

SRC_URI[sha256sum] = "1d1010a1751d076d5291e433c138502a794d679a7498d1268ee21e2d4a140eb4"

# no this configuration option in version 4.3.0
PACKAGECONFIG_remove = "fontconfig"
PACKAGECONFIG[fontconfig] = ""

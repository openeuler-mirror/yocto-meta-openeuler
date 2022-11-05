# main bb file: yocto-poky/meta/recipes-graphics/harfbuzz/harfbuzz_2.7.4.bb

PV = "4.3.0"

# update LICENSE checksum
LIC_FILES_CHKSUM_remove = "file://COPYING;md5=8f787620b7d3866d9552fd1924c07572 \
"
LIC_FILES_CHKSUM_prepend = "file://COPYING;md5=6ee0f16281694fb6aa689cca1e0fb3da \
"

SRC_URI_remove = "https://github.com/${BPN}/${BPN}/releases/download/${PV}/${BPN}-${PV}.tar.xz \
                  "

SRC_URI_prepend = "file://${BP}.tar.xz \
                   file://backport-CVE-2022-33068.patch \
                   "

SRC_URI[md5sum] = "29800d238d3e93f61bf804ba1a6364dc"
SRC_URI[sha256sum] = "a49628f4c4c8e6d8df95ef44935a93446cf2e46366915b0e3ca30df21fffb530"

# no this configuration option in version 4.3.0
PACKAGECONFIG_remove = "fontconfig"
PACKAGECONFIG[fontconfig] = ""

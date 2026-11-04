# the main bb file: yocto-poky/meta/recipes-graphics/xorg-lib/pixman_0.40.0.bb

PV = "0.42.2"

SRC_URI = "file://${BPN}-${BP}.tar.bz2 \
"

SRC_URI[md5sum] = "b07d3ba74f4824d94fa8f4e5248858d4"
SRC_URI[sha256sum] = "891a3a8b925562306dbbaaad88a80b83d68d6a41485ff2a8b1e09cd5350e4362"

S = "${WORKDIR}/${BPN}-${BP}"


# from 0.40.2.bb
LICENSE = "MIT & PD"
EXTRA_OEMESON:append:armv7a = "${@bb.utils.contains("TUNE_FEATURES","neon",""," -Dneon=disabled",d)}"
EXTRA_OEMESON:append:armv7ve = "${@bb.utils.contains("TUNE_FEATURES","neon",""," -Dneon=disabled",d)}"
EXTRA_OEMESON:append:class-native = " -Dopenmp=disabled"
# the main bb file: yocto-poky/meta/recipes-graphics/xorg-lib/pixman_0.40.0.bb

PV = "0.43.4"

SRC_URI = "file://${BPN}-${BP}.tar.bz2 \
"

SRC_URI[md5sum] = "9f89246b6e783a8c10fef451906791c1"
SRC_URI[sha256sum] = "b5d6e50d0738d6e4818d05054580fd6d4cf762e24e91d2a2884a4b91baa76d6a"

S = "${WORKDIR}/${BPN}-${BP}"


# from 0.40.2.bb
LICENSE = "MIT & PD"
EXTRA_OEMESON:append:armv7a = "${@bb.utils.contains("TUNE_FEATURES","neon",""," -Dneon=disabled",d)}"
EXTRA_OEMESON:append:armv7ve = "${@bb.utils.contains("TUNE_FEATURES","neon",""," -Dneon=disabled",d)}"
EXTRA_OEMESON:append:class-native = " -Dopenmp=disabled"
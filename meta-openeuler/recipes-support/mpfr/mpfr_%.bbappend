# main bb file: yocto-poky/meta/recipes-support/mpfr/mpfr_4.1.1.bb

PV = "4.2.1"

SRC_URI:append = " \
    file://${BP}.tar.xz \
"

SRC_URI[sha256sum] = "06a378df13501248c1b2db5aa977a2c8126ae849a9d9b7be2546fb4a9c26d993"

DEPENDS = "gmp autoconf-archive-native"
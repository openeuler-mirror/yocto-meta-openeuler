# main bb file: yocto-poky/meta/recipes-support/mpfr/mpfr_4.1.0.bb
PV = "4.1.0"
SRC_URI_remove = "https://www.mpfr.org/mpfr-${PV}/mpfr-${PV}.tar.xz "
SRC_URI_prepend = "file://${BPN}-${PV}.tar.xz "


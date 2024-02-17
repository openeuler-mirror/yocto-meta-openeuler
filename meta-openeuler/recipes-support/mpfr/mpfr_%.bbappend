# main bb file: yocto-poky/meta/recipes-support/mpfr/mpfr_4.1.1.bb

PV = "4.2.0"

SRC_URI:append = " \
    file://mpfr-${PV}.tar.xz \
    file://mpfr-tests-tsprintf.c-Modified-a-buggy-test-of-the-thousa.patch \
"

SRC_URI[sha256sum] = "06a378df13501248c1b2db5aa977a2c8126ae849a9d9b7be2546fb4a9c26d993"

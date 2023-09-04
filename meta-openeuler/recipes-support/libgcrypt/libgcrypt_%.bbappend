# the main bb file: yocto-poky/meta/recipes-support/libgcrypt/libgcrypt_1.9.4.bb

OPENEULER_SRC_URI_REMOVE = "http git"

PV = "1.10.2"

# patches in openEuler
SRC_URI:prepend = " \
    file://libgcrypt-${PV}.tar.bz2 \
    file://Use-the-compiler-switch-O0-for-compiling-jitterentro.patch \
    "

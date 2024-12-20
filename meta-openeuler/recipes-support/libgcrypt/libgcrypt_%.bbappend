# the main bb file: yocto-poky/meta/recipes-support/libgcrypt/libgcrypt_1.9.4.bb

PV = "1.10.2"

# patches in openEuler
SRC_URI:prepend = " \
    file://${BP}.tar.bz2 \
    file://Use-the-compiler-switch-O0-for-compiling-jitterentro.patch \
    file://add-GCRY_MD_SM3_PGP-set-to-109.patch \
    "

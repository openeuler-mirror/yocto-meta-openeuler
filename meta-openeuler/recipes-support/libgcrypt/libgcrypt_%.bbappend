# the main bb file: yocto-poky/meta/recipes-support/libgcrypt/libgcrypt_1.9.4.bb

# patches in openEuler
SRC_URI:prepend = " \
    file://libgcrypt-${PV}.tar.bz2 \
    file://backport-libgcrypt-1.8.5-use-fipscheck.patch \
    file://backport-libgcrypt-1.8.4-fips-keygen.patch \
    file://backport-libgcrypt-1.8.4-tests-fipsmode.patch \
    file://backport-libgcrypt-1.7.3-fips-cavs.patch \
    file://backport-libgcrypt-1.8.4-use-poll.patch \
    file://backport-libgcrypt-1.6.1-mpicoder-gccopt.patch \
    file://backport-libgcrypt-1.7.3-ecc-test-fix.patch \
    file://backport-libgcrypt-1.8.3-fips-ctor.patch \
    file://backport-libgcrypt-1.8.5-getrandom.patch \
    file://backport-libgcrypt-1.8.3-fips-enttest.patch \
    file://backport-libgcrypt-1.8.3-md-fips-enforce.patch \
    file://backport-libgcrypt-1.8.5-intel-cet.patch \
    file://backport-libgcrypt-1.8.5-fips-module.patch \
"

# version in openEuler
PV = "1.9.4"

# apply source package in openEuler
SRC_URI_remove = "${GNUPG_MIRROR}/libgcrypt/libgcrypt-${PV}.tar.bz2 \
"

SRC_URI_prepend = "file://libgcrypt/libgcrypt-${PV}.tar.bz2 \
"

# patches in openEuler
SRC_URI += "\
file://backport-libgcrypt-1.7.3-ecc-test-fix.patch \
file://backport-libgcrypt-1.8.4-fips-keygen.patch \
file://backport-libgcrypt-1.8.4-use-poll.patch \
file://backport-libgcrypt-1.6.1-mpicoder-gccopt.patch \
file://backport-libgcrypt-1.8.5-intel-cet.patch \
file://backport-libgcrypt-1.8.3-fips-ctor.patch \
file://backport-libgcrypt-1.8.5-use-fipscheck.patch \
file://backport-libgcrypt-1.8.3-fips-enttest.patch \
file://backport-libgcrypt-1.7.3-fips-cavs.patch \
file://backport-libgcrypt-1.8.3-md-fips-enforce.patch \
file://backport-libgcrypt-1.8.4-tests-fipsmode.patch \
file://backport-libgcrypt-1.8.5-fips-module.patch \
file://backport-libgcrypt-1.8.5-getrandom.patch \
"

# checksum changed
SRC_URI[sha256sum] = "ea849c83a72454e3ed4267697e8ca03390aee972ab421e7df69dfe42b65caaf7"

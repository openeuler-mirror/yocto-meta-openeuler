# main bb file: yocto-poky/meta/recipes-connectivity/openssl/openssl_1.1.1k.bb

# openEuler version
OPENEULER_SRC_URI_REMOVE = "https git http"
PV = "1.1.1wa"

# patches in openEuler
SRC_URI += "\
        file://openssl-${PV}.tar.gz \
        file://openssl-1.1.1-build.patch \
        file://openssl-1.1.1-fips.patch \
        file://Fix-FIPS-getenv-build-failure.patch \
        file://skip-some-test-cases.patch \
"

SRC_URI[sha256sum] = "f89199be8b23ca45fc7cb9f1d8d3ee67312318286ad030f5316aca6462db6c96"

# if PACKAGECONFIG variant has perl, add perl RDEPENDS
RDEPENDS_${PN}-misc = "${@bb.utils.contains('PACKAGECONFIG', 'perl', 'perl', '', d)}"

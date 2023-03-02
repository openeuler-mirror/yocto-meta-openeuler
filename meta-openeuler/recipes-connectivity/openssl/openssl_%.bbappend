# main bb file from:
# http://cgit.openembedded.org/openembedded-core/tree/meta/recipes-connectivity/openssl/openssl_3.0.8.bb

OPENEULER_SRC_URI_REMOVE = "https git http"
OPENEULER_BRANCH = "openEuler-23.03"

# openEuler version
PV = "3.0.8"

# patches in openEuler
SRC_URI += "\
    file://openssl-${PV}.tar.gz \
    file://openssl-3.0-build.patch \
"


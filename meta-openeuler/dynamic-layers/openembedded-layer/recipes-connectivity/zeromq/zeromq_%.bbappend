# main bbfile: yocto-meta-openembedded/meta-oe/recipes-connectivity/zeromq/zeromq_4.3.4.bb

OPENEULER_SRC_URI_REMOVE = "git https http"

PV = "4.3.4"

SRC_URI:append = " \
        file://libzmq-${PV}.tar.gz \
        file://fix-test_inproc_connect-occasionally-fails-on-slow-archs.patch \
"

SRC_URI[md5sum] = "cc20b769ac10afa352e5ed2769bb23b3"
SRC_URI[sha256sum] = "0ff5a531c9ffaf0dfdc7dc78d13d1383088f454896d252934c429b2554d10559"

S = "${WORKDIR}/libzmq-${PV}"

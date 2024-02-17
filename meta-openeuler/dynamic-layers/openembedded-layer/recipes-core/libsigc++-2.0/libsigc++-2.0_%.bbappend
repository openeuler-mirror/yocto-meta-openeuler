# main bb: yocto-meta-openembedded/meta-oe/recipes-core/libsigc++-2.0/libsigc++-2.0_2.10.7.bb

OPENEULER_LOCAL_NAME = "libsigcpp20"

PV = "2.12.0"

SRC_URI += " \
        file://${OPENEULER_LOCAL_NAME}/libsigc++-${PV}.tar.xz \
"

S = "${WORKDIR}/libsigc++-${PV}"

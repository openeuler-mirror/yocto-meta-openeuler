# main bb: yocto-poky/meta/recipes-multimedia/sbc/sbc_1.5.bb

OPENEULER_SRC_URI_REMOVE = "https http git gitsm"

PV = "2.0"

# no need for 2.0
SRC_URI:remove = " \
        file://0001-sbc_primitives-Fix-build-on-non-x86.patch \
"

SRC_URI += " \
        file://sbc-${PV}.tar.xz \
"

S = "${WORKDIR}/sbc-${PV}"


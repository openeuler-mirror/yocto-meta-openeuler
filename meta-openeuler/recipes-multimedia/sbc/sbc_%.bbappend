# main bb: yocto-poky/meta/recipes-multimedia/sbc/sbc_1.5.bb

PV = "2.0"

# no need for 2.0
SRC_URI:remove = " \
        file://0001-sbc_primitives-Fix-build-on-non-x86.patch \
"

SRC_URI:prepend = " \
        file://${BP}.tar.xz \
"

S = "${WORKDIR}/${BP}"

# main bb: yocto-meta-openembedded/meta-oe/recipes-graphics/cairo/cairomm_1.14.3.bb

PV = "1.14.4"

SRC_URI += " \
        file://${BP}.tar.xz \
"

S = "${WORKDIR}/${BP}"


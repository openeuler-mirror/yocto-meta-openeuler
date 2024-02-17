# main bb: yocto-meta-openembedded/meta-oe/recipes-graphics/pango/pangomm_2.46.2.bb

PV = "2.46.3"

SRC_URI += " \
        file://${BP}.tar.xz \
"

S = "${WORKDIR}/${BP}"


# main bb: yocto-meta-openembedded/meta-oe/recipes-gnome/atk/atkmm_2.28.2.bb


PV = "2.28.3"

SRC_URI += " \
        file://${BP}.tar.xz \
"

S = "${WORKDIR}/${BP}"


# main bb: yocto-poky/meta/recipes-support/vte/vte_0.66.2.bb
inherit oee-archive

PV = "0.66.2"

SRC_URI += " \
        file://${BP}.tar.xz \
"

S = "${WORKDIR}/${BP}"

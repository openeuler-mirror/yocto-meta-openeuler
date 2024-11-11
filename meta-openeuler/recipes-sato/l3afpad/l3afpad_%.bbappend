# main bb: yocto-poky/meta/recipes-sato/l3afpad/l3afpad_git.bb
# ref: git://git.toradex.com/meta-lxde.git

inherit oee-archive

PV = "0.8.18.1.11"

SRC_URI = " \
        file://${BP}.tar.gz \
"

S = "${WORKDIR}/${BP}"

# main bb: meta-lxde/recipes-lxde/lxtask/lxtask_0.1.10.bb
# ref: git://git.toradex.com/meta-lxde.git

PV = "0.1.10"

SRC_URI += " \
        file://${BP}.tar.xz \
"

S = "${WORKDIR}/${BP}"

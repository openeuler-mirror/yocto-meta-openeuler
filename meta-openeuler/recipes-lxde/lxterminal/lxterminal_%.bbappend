# main bb: meta-lxde/recipes-lxde/lxterminal/lxterminal_0.3.2.bb
# ref: git://git.toradex.com/meta-lxde.git

PV = "0.4.0"

SRC_URI += " \
        file://${BP}.tar.xz \
"

S = "${WORKDIR}/${BP}"

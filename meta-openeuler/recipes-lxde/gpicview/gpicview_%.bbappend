# main bb: meta-lxde/recipes-lxde/gpicview/gpicview_0.2.5.bb
# ref: git://git.toradex.com/meta-lxde.git

inherit oee-archive

PV = "0.2.5"

SRC_URI += " \
        file://gpicview-${PV}.tar.xz \
"

S = "${WORKDIR}/gpicview-${PV}"

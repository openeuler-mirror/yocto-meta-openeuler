# main bb: meta-lxde/recipes-lxde/lxterminal/lxterminal_0.3.2.bb
# ref: git://git.toradex.com/meta-lxde.git

OPENEULER_SRC_URI_REMOVE = "https http git gitsm"

PV = "0.4.0"

SRC_URI += " \
        file://lxterminal-${PV}.tar.xz \
"

S = "${WORKDIR}/lxterminal-${PV}"


# main bb: meta-lxde/recipes-lxde/lxtask/lxtask_0.1.10.bb
# ref: git://git.toradex.com/meta-lxde.git

OPENEULER_SRC_URI_REMOVE = "https http git gitsm"

PV = "0.1.10"

SRC_URI += " \
        file://lxtask-${PV}.tar.xz \
"

S = "${WORKDIR}/lxtask-${PV}"


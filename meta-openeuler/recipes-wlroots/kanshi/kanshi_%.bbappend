# main bb: meta-wayland/recipes-support/kanshi/kanshi_git.bb
# from https://github.com/MarkusVolk/meta-wayland.git

inherit oee-archive

PV = "1.7.0"

DEPENDS += "libscfg"

SRC_URI += " \
        file://v${PV}.tar.gz \
"

S = "${WORKDIR}/kanshi-v${PV}"

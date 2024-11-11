# main bb: meta-wayland/recipes-support/swaybg/swaybg_git.bb
# from https://github.com/MarkusVolk/meta-wayland.git

inherit oee-archive

PV = "1.2.1"

SRC_URI += " \
        file://v${PV}.tar.gz \
"

S = "${WORKDIR}/${BP}"

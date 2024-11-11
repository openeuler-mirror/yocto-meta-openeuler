# main bb: meta-wayland/recipes-extended/libdisplay-info/libdisplay-info_git.bb
# from https://github.com/MarkusVolk/meta-wayland.git
inherit oee-archive

PV = "0.1.1"

SRC_URI += " \
        file://${BP}.tar.gz \
"

S = "${WORKDIR}/${BP}"

# main bb: meta-wayland/recipes-extended/libliftoff/libliftoff_git.bb
# from https://github.com/MarkusVolk/meta-wayland.git
inherit oee-archive

PV = "v0.4.1"

SRC_URI += "file://${BP}.tar.gz \
"

S = "${WORKDIR}/${BP}"

# main bb: meta-wayland/recipes-wlroots/wayfire/wf-shell_git.bb
# from https://github.com/MarkusVolk/meta-wayland.git
inherit oee-archive

PV = "0.8.1"

SRC_URI += " \
        file://${BP}.tar.xz \
"

S = "${WORKDIR}/${BP}"

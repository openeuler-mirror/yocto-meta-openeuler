# main bb: meta-wayland/recipes-gtk/gtk-layer-shell/gtk-layer-shell_git.bb
# from https://github.com/MarkusVolk/meta-wayland.git
inherit oee-archive

PV = "0.8.1"

SRC_URI += " \
        file://${BP}.tar.gz \
"

S = "${WORKDIR}/${BP}"

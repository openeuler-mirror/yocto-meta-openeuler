# main bb: meta-wayland/recipes-gtk/gtk-layer-shell/gtk-layer-shell_git.bb
# from https://github.com/MarkusVolk/meta-wayland.git
OPENEULER_LOCAL_NAME = "oee_archive"

PV = "0.8.1"

SRC_URI += " \
        file://${OPENEULER_LOCAL_NAME}/${BPN}/${BP}.tar.gz \
"

S = "${WORKDIR}/${BP}"

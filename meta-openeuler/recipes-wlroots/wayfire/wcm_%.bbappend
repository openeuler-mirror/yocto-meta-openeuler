# main bb: meta-wayland/recipes-wlroots/wayfire/wcm_git.bb
# from https://github.com/MarkusVolk/meta-wayland.git
OPENEULER_LOCAL_NAME = "oee_archive"

PV = "0.8.0"

SRC_URI += " \
        file://${OPENEULER_LOCAL_NAME}/${BPN}/${BP}.tar.xz \
"

S = "${WORKDIR}/${BP}"

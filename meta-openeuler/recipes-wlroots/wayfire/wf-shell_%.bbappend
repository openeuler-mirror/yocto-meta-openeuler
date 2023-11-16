# main bb: meta-wayland/recipes-wlroots/wayfire/wf-shell_git.bb
# from https://github.com/MarkusVolk/meta-wayland.git

OPENEULER_LOCAL_NAME = "oee_archive"

PV = "0.7.0"

SRC_URI = " \
        file://${OPENEULER_LOCAL_NAME}/${BPN}/wf-shell-${PV}.tar.xz \
"

S = "${WORKDIR}/wf-shell-${PV}"



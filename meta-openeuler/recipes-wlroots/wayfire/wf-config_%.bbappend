# main bb: meta-wayland/recipes-wlroots/wayfire/wf-config_git.bb
# from https://github.com/MarkusVolk/meta-wayland.git

OPENEULER_LOCAL_NAME = "oee_archive"

PV = "0.7.1"

SRC_URI = " \
        file://${OPENEULER_LOCAL_NAME}/${BPN}/wf-config-${PV}.tar.xz \
"

S = "${WORKDIR}/wf-config-${PV}"



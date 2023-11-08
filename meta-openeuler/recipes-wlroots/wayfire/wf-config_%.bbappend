# main bb: meta-wayland/recipes-wlroots/wayfire/wf-config_git.bb
# from https://github.com/MarkusVolk/meta-wayland.git

OPENEULER_SRC_URI_REMOVE = "https http git"

FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

PV = "0.7.1"

SRC_URI += " \
        file://wf-config-${PV}.tar.xz \
"

S = "${WORKDIR}/wf-config-${PV}"



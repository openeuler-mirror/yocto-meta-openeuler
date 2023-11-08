# main bb: meta-wayland/recipes-wlroots/wayfire/wayfire_git.bb
# from https://github.com/MarkusVolk/meta-wayland.git

OPENEULER_SRC_URI_REMOVE = "https http git"

FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

PV = "0.7.5"

SRC_URI += " \
        file://wayfire-${PV}.tar.xz \
        file://ignore-drop-root.patch \
"

S = "${WORKDIR}/wayfire-${PV}"


# make a lite version
RRECOMMENDS:${PN}:remove = " wf-recorder "

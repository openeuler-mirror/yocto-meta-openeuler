# main bb: meta-wayland/recipes-wlroots/wayfire/wayfire_git.bb
# from https://github.com/MarkusVolk/meta-wayland.git

FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

OPENEULER_LOCAL_NAME = "oee_archive"

PV = "0.7.5"

SRC_URI = " \
        file://${OPENEULER_LOCAL_NAME}/${BPN}/wayfire-${PV}.tar.xz \
        file://ignore-drop-root.patch \
"

S = "${WORKDIR}/wayfire-${PV}"


# make a lite version
RRECOMMENDS:${PN}:remove = " wf-recorder "

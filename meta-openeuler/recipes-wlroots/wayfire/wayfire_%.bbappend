# main bb: meta-wayland/recipes-wlroots/wayfire/wayfire_git.bb
# from https://github.com/MarkusVolk/meta-wayland.git
FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

OPENEULER_LOCAL_NAME = "oee_archive"

PV = "0.8.1"

SRC_URI += " \
        file://${OPENEULER_LOCAL_NAME}/${BPN}/${BP}.tar.xz \
        file://ignore-drop-root.patch \
"

PACKAGECONFIG[use_system_wlroots] = "-Duse_system_wlroots=enabled,-Duse_system_wlroots=disabled,wlroots"

S = "${WORKDIR}/${BP}"


# make a lite version
RRECOMMENDS:${PN}:remove = " wf-recorder "

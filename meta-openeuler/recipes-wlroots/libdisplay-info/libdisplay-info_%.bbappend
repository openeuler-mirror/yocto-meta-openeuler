# main bb: meta-wayland/recipes-extended/libdisplay-info/libdisplay-info_git.bb
# from https://github.com/MarkusVolk/meta-wayland.git

OPENEULER_SRC_URI_REMOVE = "https http git"

# find patches under openeuler at firse
FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

PV = "0.1.1"

SRC_URI += " \
        file://libdisplay-info-${PV}.tar.gz \
"

S = "${WORKDIR}/libdisplay-info-${PV}"


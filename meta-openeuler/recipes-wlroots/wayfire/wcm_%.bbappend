# main bb: meta-wayland/recipes-wlroots/wayfire/wcm_git.bb
# from https://github.com/MarkusVolk/meta-wayland.git

OPENEULER_SRC_URI_REMOVE = "https http git"

FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

LIC_FILES_CHKSUM = "file://${S}/LICENSE;md5=ccb736ab917abd09ce6915fbf9a0f887"

PV = "0.7.5"

SRC_URI += " \
        file://wcm-${PV}.tar.xz \
"

S = "${WORKDIR}/wcm-${PV}"



# main bb: yocto-poky/meta/recipes-support/vte/vte_0.66.2.bb

OPENEULER_SRC_URI_REMOVE = "https http git gitsm"

FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

PV = "0.66.2"

SRC_URI += " \
        file://vte-${PV}.tar.xz \
"

S = "${WORKDIR}/vte-${PV}"


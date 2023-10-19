# main bb: yocto-poky/meta/recipes-sato/l3afpad/l3afpad_git.bb
# ref: git://git.toradex.com/meta-lxde.git

OPENEULER_SRC_URI_REMOVE = "https http git gitsm"

FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

PV = "0.8.18.1.11"

SRC_URI += " \
        file://l3afpad-${PV}.tar.gz \
"

S = "${WORKDIR}/l3afpad-${PV}"


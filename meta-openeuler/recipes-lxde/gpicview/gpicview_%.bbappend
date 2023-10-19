# main bb: meta-lxde/recipes-lxde/gpicview/gpicview_0.2.5.bb
# ref: git://git.toradex.com/meta-lxde.git

OPENEULER_SRC_URI_REMOVE = "https http git gitsm"

FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

PV = "0.2.5"

SRC_URI += " \
        file://gpicview-${PV}.tar.xz \
"

S = "${WORKDIR}/gpicview-${PV}"


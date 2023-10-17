# main bb: meta-wayland/recipes-extended/libliftoff/libliftoff_git.bb
# from https://github.com/MarkusVolk/meta-wayland.git

OPENEULER_SRC_URI_REMOVE = "https http git"

# find patches under openeuler at firse
FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

PV = "v0.4.1"

SRC_URI += " \
        file://libliftoff-${PV}.tar.gz \
"

S = "${WORKDIR}/libliftoff-${PV}"


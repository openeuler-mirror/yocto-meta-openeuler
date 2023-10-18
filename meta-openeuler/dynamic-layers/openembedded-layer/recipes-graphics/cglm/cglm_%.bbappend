# main bb: meta-openembedded/tree/meta-oe/recipes-graphics/cglm/cglm_0.9.1.bb
# from https://git.openembedded.org/

OPENEULER_SRC_URI_REMOVE = "https http git"

FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

PV = "0.9.1"

SRC_URI += " \
        file://cglm-${PV}.tar.gz \
"

S = "${WORKDIR}/cglm-${PV}"



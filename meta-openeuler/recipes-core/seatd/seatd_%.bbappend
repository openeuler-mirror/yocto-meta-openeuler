# main bb: yocto-poky/meta/recipes-core/seatd/seatd_0.6.4.bb

OPENEULER_SRC_URI_REMOVE = "https http git"

# find patches under openeuler at firse
FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

PV = "0.6.4"

SRC_URI += " \
        file://seatd-${PV}.tar.gz \
"

S = "${WORKDIR}/seatd-${PV}"


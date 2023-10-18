# main bb: yocto-meta-openembedded/meta-oe/recipes-gnome/atk/atkmm_2.28.2.bb

OPENEULER_SRC_URI_REMOVE = "https http git gitsm"

PV = "2.28.3"

SRC_URI += " \
        file://atkmm-${PV}.tar.xz \
"

S = "${WORKDIR}/atkmm-${PV}"


# main bb: yocto-meta-openembedded/meta-oe/recipes-gnome/gtk+/gtkmm3_3.24.5.bb

OPENEULER_SRC_URI_REMOVE = "https http git gitsm"
OPENEULER_LOCAL_NAME = "gtkmm30"

PV = "3.24.7"

SRC_URI += " \
        file://${OPENEULER_LOCAL_NAME}/gtkmm-${PV}.tar.xz \
"

S = "${WORKDIR}/gtkmm-${PV}"


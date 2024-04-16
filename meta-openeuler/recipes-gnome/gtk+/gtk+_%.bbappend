# main bb: yocto-meta-openembedded/meta-oe/recipes-gnome/gtk+/gtk+_2.24.33.bb
OPENEULER_LOCAL_NAME = "oee_archive"

PV = "2.24.33"

SRC_URI:prepend = " \
    file://${OPENEULER_LOCAL_NAME}/${BPN}/${BPN}-${PV}.tar.xz \
"


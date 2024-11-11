# main bb: yocto-meta-openembedded/meta-oe/recipes-gnome/gtk+/gtk+_2.24.33.bb
inherit oee-archive

PV = "2.24.33"

SRC_URI:prepend = " \
    file://{BPN}-${PV}.tar.xz \
"

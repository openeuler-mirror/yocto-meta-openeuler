# main bb: yocto-poky/meta/recipes-gnome/libnotify/libnotify_0.7.9.bb

PV = "0.8.2"

SRC_URI += " \
        file://libnotify-${PV}.tar.xz \
"

S = "${WORKDIR}/libnotify-${PV}"

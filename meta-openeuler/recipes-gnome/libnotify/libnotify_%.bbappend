# main bb: yocto-poky/meta/recipes-gnome/libnotify/libnotify_0.7.9.bb

PV = "0.8.3"

SRC_URI += " \
        file://${BP}.tar.xz \
"

S = "${WORKDIR}/${BP}"

# main bb: yocto-poky/meta/recipes-gnome/gsettings-desktop-schemas/gsettings-desktop-schemas_42.0.bb

PV = "45.0"

SRC_URI:prepend = " \
    file://${BP}.tar.xz \
"

S = "${WORKDIR}/${BP}"


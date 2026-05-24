# bbfile: yocto-poky/meta/recipes-devtools/vala/vala_0.56.3.bb

PV = "0.56.14"

DEPENDS += "gobject-introspection"

SRC_URI:prepend = " file://${BP}.tar.xz \
"

SRC_URI:remove = "file://0001-gtk4-Preserve-compatibility-with-4.14.patch"

# bbfile: yocto-poky/meta/recipes-devtools/vala/vala_0.56.3.bb

PV = "0.56.14"

DEPENDS += "gobject-introspection"

SRC_URI:prepend = " file://${BP}.tar.xz "

SRC_URI[sha256sum] = "9382c268ca9bdc02aaedc8152a9818bf3935273041f629c56de410e360a3f557"
# the main bb file: yocto-poky/meta/recipes-graphics/pango/pango_1.50.4.bb

PV = "1.50.12"

SRC_URI:prepend = "file://${BP}.tar.xz;name=archive \
"

SRC_URI[archive.sha256sum] = "caef96d27bbe792a6be92727c73468d832b13da57c8071ef79b9df69ee058fe3"

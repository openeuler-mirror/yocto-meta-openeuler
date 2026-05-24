# the main bb file: yocto-poky/meta/recipes-graphics/pango/pango_1.50.4.bb

PV = "1.51.0"

SRC_URI:prepend = "file://${BP}.tar.xz;name=archive \
"

# patch from oe-core
SRC_URI += " \
                   file://0001-Skip-running-test-layout-test.patch \
"

SRC_URI[archive.sha256sum] = "caef96d27bbe792a6be92727c73468d832b13da57c8071ef79b9df69ee058fe3"

PACKAGECONFIG[thai] = "-Dlibthai=enabled,-Dlibthai=disabled,libthai"

FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

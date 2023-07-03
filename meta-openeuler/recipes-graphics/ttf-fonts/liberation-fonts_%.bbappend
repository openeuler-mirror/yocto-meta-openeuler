# main bb file: yocto-poky/meta/recipes-graphics/ttf-fonts/liberation-fonts_2.1.5.bb

PV = "2.1.5"

# avoid download online, no source on openeuler
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:remove = "https://github.com/liberationfonts/liberation-fonts/files/7261482/liberation-fonts-ttf-${PV}.tar.gz \
"

SRC_URI:prepend = "file://liberation-fonts-ttf-${PV}.tar.gz \
"

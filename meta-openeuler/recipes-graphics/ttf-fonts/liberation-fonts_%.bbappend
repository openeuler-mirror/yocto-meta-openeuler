# main bb file: yocto-poky/meta/recipes-graphics/ttf-fonts/liberation-fonts_2.00.1.bb

# avoid download online
FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI_remove = "https://releases.pagure.org/liberation-fonts/liberation-fonts-ttf-${PV}.tar.gz \
"

SRC_URI_prepend = "file://liberation-fonts-ttf-${PV}.tar.gz \
"

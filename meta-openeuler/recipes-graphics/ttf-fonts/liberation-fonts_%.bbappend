# main bb file: yocto-poky/meta/recipes-graphics/ttf-fonts/liberation-fonts_2.1.5.bb

OPENEULER_LOCAL_NAME = "oee_archive"

OPENEULER_SRC_URI_REMOVE = "https"

PV = "2.1.5"

SRC_URI:prepend = "file://${OPENEULER_LOCAL_NAME}/${BPN}/liberation-fonts-ttf-${PV}.tar.gz \
"

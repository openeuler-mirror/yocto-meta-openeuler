# main bb file: yocto-poky/meta/recipes-graphics/ttf-fonts/ttf-dejavu_2.37.bb

OPENEULER_LOCAL_NAME = "oee_archive"

PV = "2.37"

SRC_URI:prepend = " \
    file://${OPENEULER_LOCAL_NAME}/${BPN}/dejavu-fonts-ttf-${PV}.tar.bz2 \
"


# main bbfile: yocto-poky/meta/recipes-support/libexif/libexif_0.6.24.bb
inherit oee-archive

SRC_URI:prepend = " \
    file://libexif-0.6.24.tar.bz2 \
    "

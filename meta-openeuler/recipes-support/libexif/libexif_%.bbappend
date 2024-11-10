# main bbfile: yocto-poky/meta/recipes-support/libexif/libexif_0.6.24.bb

SRC_URI:prepend = " \
    file://libexif-0_6_24-release.tar.gz;subdir=${BP};striplevel=1 \
    "

# the main bb file: yocto-poky/meta/recipes-multimedia/libvorbis/libvorbis_1.3.7.bb

PV = "1.3.7"

SRC_URI:prepend = " \
    file://${BP}.tar.xz \
"

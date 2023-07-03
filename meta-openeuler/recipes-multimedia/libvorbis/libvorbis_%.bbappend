# the main bb file: yocto-poky/meta/recipes-multimedia/libvorbis/libvorbis_1.3.7.bb

SRC_URI:remove = "http://downloads.xiph.org/releases/vorbis/${BP}.tar.xz \
"

SRC_URI:append = " \
    file://libvorbis-1.3.7.tar.xz \
"

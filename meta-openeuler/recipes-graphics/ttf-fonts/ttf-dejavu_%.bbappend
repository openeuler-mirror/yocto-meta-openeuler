# main bb file: yocto-poky/meta/recipes-graphics/ttf-fonts/ttf-dejavu_2.37.bb

inherit oee-archive

PV = "2.37"

SRC_URI:prepend = " \
    file://dejavu-fonts-ttf-${PV}.tar.bz2 \
"

PACKAGEFUNCS:remove = " add_fontcache_postinsts "

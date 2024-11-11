# main bb file: yocto-poky/meta/recipes-graphics/ttf-fonts/liberation-fonts_2.1.5.bb

inherit oee-archive

PV = "2.1.5"

SRC_URI:prepend = "file://liberation-fonts-ttf-${PV}.tar.gz \
"

PACKAGEFUNCS:remove = " add_fontcache_postinsts "
 

# main bb file: yocto-poky/meta/recipes-graphics/ttf-fonts/ttf-wqy-zenhei_0.9.45.bb

OPENEULER_LOCAL_NAME = "wqy-zenhei-fonts"

PV = "0.9.46-May"

SRC_URI:prepend = "file://wqy-zenhei-${PV}.tar.bz2 \
"

PACKAGEFUNCS:remove = " add_fontcache_postinsts "

# main bbfile: yocto-poky/meta/recipes-graphics/xorg-lib/xkeyboard-config_2.32.bb

OPENEULER_SRC_URI_REMOVE = "http git"

# version in src-openEuler
PV = "2.39"

SRC_URI:prepend = "file://${BP}.tar.xz \
"

BBCLASSEXTEND += "native"

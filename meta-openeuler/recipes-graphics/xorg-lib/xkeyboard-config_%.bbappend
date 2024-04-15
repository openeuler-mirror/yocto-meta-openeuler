# main bbfile: yocto-poky/meta/recipes-graphics/xorg-lib/xkeyboard-config_2.32.bb


# version in src-openEuler
PV = "2.39"

SRC_URI:prepend = " \
    file://${BP}.tar.xz \
"

BBCLASSEXTEND += "native"

# main bb file: yocto-poky/meta/recipes-graphics/xorg-proto/xorgproto_2021.5.bb


PV = "2023.1"

LIC_FILES_CHKSUM = "file://COPYING-x11proto;md5=0b9fe3db4015bcbe920e7c67a39ee3f1"

SRC_URI:prepend = "file://${BP}.tar.gz \
"

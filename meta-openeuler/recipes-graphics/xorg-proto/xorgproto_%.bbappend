# main bb file: yocto-poky/meta/recipes-graphics/xorg-proto/xorgproto_2021.5.bb
OPENEULER_REPO_NAME = "xorg-x11-proto-devel"

PV = "2021.5"

SRC_URI = "file://${BP}.tar.bz2 \
"

LIC_FILES_CHKSUM = "file://COPYING-x11proto;md5=dfc4bd2b0568b31725b85b0604e69b56"

SRC_URI[md5sum] = "bff0c9a6a060ecde954e255a2d1d9a22"
SRC_URI[sha256sum] = "aa2f663b8dbd632960b24f7477aa07d901210057f6ab1a1db5158732569ca015"

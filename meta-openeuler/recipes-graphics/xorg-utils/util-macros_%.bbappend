# main bbfile: yocto-poky/meta/recipes-graphics/xorg-util/util-macros_1.19.3.bb

OPENEULER_REPO_NAME = "xorg-x11-util-macros"

# use src-openEuler source
SRC_URI:remove = "${XORG_MIRROR}/individual/util/${XORG_PN}-${PV}.tar.gz"

SRC_URI:prepend = "file://${XORG_PN}-${PV}.tar.bz2 \
"

SRC_URI[md5sum] = "4be6df7e6af52e28e13dc533244eb9d7"
SRC_URI[sha256sum] = "0f812e6e9d2786ba8f54b960ee563c0663ddbe2434bf24ff193f5feab1f31971"

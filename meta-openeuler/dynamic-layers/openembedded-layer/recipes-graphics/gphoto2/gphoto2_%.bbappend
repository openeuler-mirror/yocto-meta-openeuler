# main bbfile: yocto-meta-openembedded/meta-oe/recipes-graphics/gphoto2/libgphoto2_2.5.27.bb

OPENEULER_REPO_NAME = "gphoto2"
OPENEULER_SRC_URI_REMOVE = "https http git"

PV = "2.5.17"

# file can't apply form oe
SRC_URI:remove = " \
        ${SOURCEFORGE_MIRROR}/gphoto/gphoto2-${PV}.tar.bz2;name=gphoto2 \
        "

# source change to openEuler
SRC_URI += " \
        file://gphoto2-${PV}.tar.bz2 \
        file://gphoto2-2.5.17-sw.patch \
        "


# main bbfile: yocto-meta-openembedded/meta-oe/recipes-graphics/gphoto2/libgphoto2_2.5.27.bb

OPENEULER_REPO_NAME = "gphoto2"

PV = "2.5.17"


# source change to openEuler
SRC_URI += " \
        file://gphoto2-${PV}.tar.bz2 \
        file://gphoto2-2.5.17-sw.patch \
        "

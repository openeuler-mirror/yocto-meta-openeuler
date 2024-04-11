# main bbfile: yocto-meta-openembedded/meta-oe/recipes-graphics/gphoto2/gphoto2_2.5.27.bb
PV = "2.5.28"

# source change to openEuler
SRC_URI += " \
        file://${BP}.tar.bz2 \
        file://gphoto2-2.5.17-sw.patch \
        "

# main bbfile: yocto-meta-openembedded/meta-oe/recipes-graphics/gphoto2/libgphoto2_2.5.27.bb

OPENEULER_REPO_NAME = "libgphoto2"
OPENEULER_SRC_URI_REMOVE = "https http git"

PV = "2.5.18"

# file can't apply form oe
SRC_URI:remove += " \
        "

# source change to openEuler
SRC_URI += " \
        file://libgphoto2-${PV}.tar.bz2 \
        file://gphoto2-pkgcfg.patch \
        file://gphoto2-device-return.patch \
        "

# for native sdk of gettext, its a workaround to avoid STAGING_DATADIR_NATIVE gettext files not exist
do_configure:prepend() {
    mkdir -p ${STAGING_DATADIR_NATIVE}/gettext/po
    if [ ! -e  ${STAGING_DATADIR_NATIVE}/gettext/po/Makefile.in.in ]; then
        cp -f ${OPENEULER_NATIVESDK_SYSROOT}/usr/share/gettext/po/Makefile.in.in ${STAGING_DATADIR_NATIVE}/gettext/po
    fi
}

# Delete old m4 macros, so autoreconf can repopulate it.
do_configure:prepend() {
    rm -rf ${S}/libgphoto2_port/auto-m4/*
    rm -rf ${S}/auto-m4/*
}

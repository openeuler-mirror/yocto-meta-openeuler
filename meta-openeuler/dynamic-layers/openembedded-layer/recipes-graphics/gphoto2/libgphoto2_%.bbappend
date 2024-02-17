# main bbfile: yocto-meta-openembedded/meta-oe/recipes-graphics/gphoto2/libgphoto2_2.5.27.bb

OPENEULER_REPO_NAME = "libgphoto2"

PV = "2.5.18"

# source change to openEuler
SRC_URI:append = " \
    file://${BP}.tar.bz2;name=libgphoto2 \
    file://gphoto2-pkgcfg.patch \
    file://gphoto2-device-return.patch \
"

SRC_URI[libgphoto2.md5sum] = "36c386f4c4e450d20bbc8b5a448e8b73"
SRC_URI[libgphoto2.sha256sum] = "5b17b89d7ca0ec35c72c94ac3701e87d49e52371f9509b8e5c08c913ae57a7ec"

# for native sdk of gettext, its a workaround to avoid STAGING_DATADIR_NATIVE gettext files not exist
do_configure:prepend() {
    if [ "${OPENEULER_PREBUILT_TOOLS_ENABLE}" = "yes" ] && [ ! -e  ${STAGING_DATADIR_NATIVE}/gettext/po/Makefile.in.in ];then
        mkdir -p ${STAGING_DATADIR_NATIVE}/gettext/po
        cp -f ${OPENEULER_NATIVESDK_SYSROOT}/usr/share/gettext/po/Makefile.in.in ${STAGING_DATADIR_NATIVE}/gettext/po
    fi
}

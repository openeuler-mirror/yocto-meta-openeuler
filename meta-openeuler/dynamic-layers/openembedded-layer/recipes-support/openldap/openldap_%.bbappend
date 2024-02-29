# openeuler specific adapt
# if we do use prebuilt tools, we need to copy files from nativesdk to sysroot
# so that the hardcode path in configure can be found
do_configure:prepend() {
    if [ "${OPENEULER_PREBUILT_TOOLS_ENABLE}" = "yes" ] && [ ! -d "${RECIPE_SYSROOT_NATIVE}/usr/share/libtool" ]; then
        install -d ${RECIPE_SYSROOT_NATIVE}/usr/share
	    cp -R ${OPENEULER_NATIVESDK_SYSROOT}/usr/share/libtool ${RECIPE_SYSROOT_NATIVE}/usr/share
    fi
}

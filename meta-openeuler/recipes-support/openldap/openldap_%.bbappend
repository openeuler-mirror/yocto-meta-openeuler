do_configure:prepend() {
    cp -R ${OPENEULER_NATIVESDK_SYSROOT}/usr/share/libtool ${RECIPE_SYSROOT_NATIVE}/usr/share
}
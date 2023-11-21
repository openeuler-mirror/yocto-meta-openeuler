# openeuler's native.bbclass adds extra EXTRA_NATIVE_PKGCONFIG_PATH
# In the future, if the problem of NATIVE and NATIVESDK is fixed,
# openeuler's native.bbclass can be removed

require ${COREBASE}/meta/classes/native.bbclass

# add nativesdk's pkgconfig search paths
OPENEULER_PREBUILD_PKGCONFIG_PATH = ":${OPENEULER_NATIVESDK_SYSROOT}/usr/lib/pkgconfig:${OPENEULER_NATIVESDK_SYSROOT}/usr/share/pkgconfig"
EXTRA_NATIVE_PKGCONFIG_PATH:append = "${@['', '${OPENEULER_PREBUILD_PKGCONFIG_PATH}']['${OPENEULER_PREBUILD_TOOLS_ENABLE}' == 'yes']}"

# openeuler's meson.bbclass requires meta/classes/meson.bbclass.
# use pkg-config command instead of pkg-config-native
# command when building native package
# In the future, if the problem of NATIVE and NATIVESDK is fixed, openeuler's meson.bbclass can be removed

require ${COREBASE}/meta/classes/meson.bbclass

# this is a workaround fix meson.native usage error: 
# use nativesdk's pkg-config command instead of pkg-config-native
# method: pkgconfig = 'pkg-config-native' -> pkgconfig = 'pkg-config'
do_write_config:append() {
    if [ "${OPENEULER_PREBUILD_TOOLS_ENABLE}" = "yes" ];then
        sed -i "s/pkgconfig = 'pkg-config-native'/pkgconfig = 'pkg-config'/g" ${WORKDIR}/meson.native
    fi
}

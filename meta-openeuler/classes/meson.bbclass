# openeuler's meson.bbclass requires meta/classes/meson.bbclass. There are two modification points: 
# one is not to build python3-native, the other is to use pkg-config command instead of pkg-config-native
# command when building native package
# In the future, if the problem of NATIVE and NATIVESDK is fixed, openeuler's meson.bbclass can be removed

require ${COREBASE}/meta/classes/meson.bbclass

# Since the python3 package already exists in the nativesdk tool,
# there is no need to build python3-native when building in meson
DEPENDS_remove = "python3-native"

# this is a workaround fix meson.native usage error: 
# use nativesdk's pkg-config command instead of pkg-config-native
# method: pkgconfig = 'pkg-config-native' -> pkgconfig = 'pkg-config'
do_write_config_append() {
    sed -i "s/pkgconfig = 'pkg-config-native'/pkgconfig = 'pkg-config'/g" ${WORKDIR}/meson.native
}

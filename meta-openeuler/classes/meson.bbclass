# openeuler's meson.bbclass requires meta/classes/meson.bbclass.
# use pkg-config command instead of pkg-config-native
# command when building native package
# In the future, if the problem of NATIVE and NATIVESDK is fixed, openeuler's meson.bbclass can be removed

require ${COREBASE}/meta/classes/meson.bbclass

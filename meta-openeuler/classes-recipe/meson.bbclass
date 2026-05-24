# openeuler's meson.bbclass requires meta/classes/meson.bbclass.
# use pkg-config command instead of pkg-config-native
# command when building native package
# In the future, if the problem of NATIVE and NATIVESDK is fixed, openeuler's meson.bbclass can be removed

require ${COREBASE}/meta/classes-recipe/meson.bbclass

# this is a workaround fix meson.native usage error: 
# use nativesdk's pkg-config command instead of pkg-config-native
# method: pkgconfig = 'pkg-config-native' -> pkgconfig = 'pkg-config'
do_write_config:append() {
    if [ "${OPENEULER_PREBUILT_TOOLS_ENABLE}" = "yes" ];then
        sed -i "s/pkgconfig = 'pkg-config-native'/pkgconfig = 'pkg-config'/g" ${WORKDIR}/meson.native
    fi
}

# On targets where libdir differs from Python's sysconfig platlib (e.g. aarch64
# openeuler uses libdir=/usr/lib64 but Python sysconfig reports /usr/lib/...), meson's
# Python module would install .so extensions and pure .py files to the wrong path.
# Inject the Yocto-derived platlibdir/purelibdir into the cross file [properties] so
# all meson-based Python packages install to the correct site-packages directory.
do_write_config:append:class-target() {
    if [ -n "${PYTHON_BASEVERSION}" ]; then
        sed -i "/^\[built-in options\]/a python.purelibdir = '${libdir}/python${PYTHON_BASEVERSION}/site-packages'" ${WORKDIR}/meson.cross
        sed -i "/^\[built-in options\]/a python.platlibdir = '${libdir}/python${PYTHON_BASEVERSION}/site-packages'" ${WORKDIR}/meson.cross
    fi
}

ROS_DISTRO = "humble"

inherit ${ROS_DISTRO_TYPE}_distro
inherit openeuler_source
inherit pkgconfig

# ----- libdir alignment: ros uses /usr/lib, openeuler uses /usr/lib64 -----
#
# Background:
#   openeuler sets baselib = "lib64" (BASE_LIB:tune-aarch64 = "lib64" in arch-arm64.inc),
#   so the standard libdir is /usr/lib64.  However, a large number of ROS upstream packages
#   hard-code CMAKE_INSTALL_LIBDIR as "lib" (not using GNUInstallDirs or similar), so they
#   always install to /usr/lib regardless of the host system's convention.
#   To keep ROS-internal dependency paths consistent, we normalise libdir to /usr/lib for
#   all non-native ROS target recipes.
#
#   Side-effects handled elsewhere:
#   - _sysconfigdata.py is installed by the openeuler python3 recipe under usr/lib64.
#     Because STAGING_LIBDIR now points to usr/lib, Python cannot find _sysconfigdata at
#     build time.  This is fixed in meta-openeuler/classes/python3targetconfig.bbclass by
#     appending ${STAGING_DIR_HOST}${exec_prefix}/lib64/python-sysconfigdata to PYTHONPATH.
#   - openeuler native packages (e.g. libpython3.11) still install their .pc files under
#     usr/lib64/pkgconfig.  PKG_CONFIG_PATH is extended below to include oldroslibdir.
#
# TODO: riscv64 uses a customized libdir of lp64d; revisit replace('64','') for that arch.
python ros_libdir_set() {
    d.setVar('oldroslibdir', d.getVar('libdir'))
    pn = e.data.getVar("PN")
    if pn.endswith("-native"):
        return
    d.setVar('libdir',  d.getVar('libdir').replace('64', ''))
    d.setVar('baselib', d.getVar('baselib').replace('64', ''))
}

addhandler ros_libdir_set
ros_libdir_set[eventmask] = "bb.event.RecipePreFinalise"

# openeuler non-ROS dependency packages install their .pc files under oldroslibdir
# (typically /usr/lib64/pkgconfig).  Append that path so pkg-config can locate them
# when building ROS recipes that depend on openeuler-native libraries.
PKG_CONFIG_PATH:append:class-target = ":${PKG_CONFIG_SYSROOT_DIR}/${oldroslibdir}/pkgconfig"

# ----- install-time lib64 → lib migration -----
#
# Even with libdir overridden to /usr/lib, some build systems (autotools, certain CMake
# configurations using GNUInstallDirs) may still install files to ${D}/usr/lib64.
# Migrate those files to ${D}/usr/lib so the final rootfs only contains /usr/lib for
# ROS content.  cp -a is used instead of mv to correctly handle nested subdirectories
# and avoid "cannot move: Directory not empty" errors when both lib and lib64 exist.
do_install:append() {
    if [ -d "${D}/usr/lib64" ]; then
        install -d "${D}/usr/lib"
        cp -a "${D}/usr/lib64/." "${D}/usr/lib/"
        rm -rf "${D}/usr/lib64"
    fi
}

# Fix set(CMAKE_CXX_STANDARD 14) invalid with cmake version 3.22
EXTRA_OECMAKE += " -DCMAKE_CXX_STANDARD_REQUIRED=ON "

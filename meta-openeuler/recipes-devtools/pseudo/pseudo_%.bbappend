# we can't move pseudo-native into native sdk currently because of deep couple of pseduo and yocto,
# but we can use native sdk to build pseudo-native to remove the dependency of sqlite-native and attr-native
DEPENDS:remove:class-native = "sqlite3-native attr-native"

OPENEULER_REPO_NAME = "yocto-pseudo"

SRC_URI:remove:class-native = " \
  git://git.yoctoproject.org/pseudo;branch=oe-core \
  http://downloads.yoctoproject.org/mirror/sources/pseudo-prebuilt-2.33.tar.xz;subdir=git/prebuilt;name=prebuilt \
  file://0001-configure-Prune-PIE-flags.patch \
"

SRC_URI:remove = " \
  file://older-glibc-symbols.patch \
"

SRC_URI:prepend:class-native = "file://${BP}.tar.gz \
          "
PV:class-native = "df1d1321fb093283485c387e3c933d2d264e509c"
S:class-native = "${WORKDIR}/${BP}"

# fix nativesdk lib use error: Failed to spawn fakeroot worker to run xxx/yocto-meta-openeuler/
# meta-openeuler/recipes-external/glibc/glibc-external.bb:do_install: [Errno 32] Broken pipe
BUILD_LDFLAGS:remove = " -L${OPENEULER_NATIVESDK_SYSROOT}/usr/lib \
                         -L${OPENEULER_NATIVESDK_SYSROOT}/lib \
                         -Wl,-rpath-link,${OPENEULER_NATIVESDK_SYSROOT}/usr/lib \
                         -Wl,-rpath-link,${OPENEULER_NATIVESDK_SYSROOT}/lib \
                         -Wl,-rpath,${OPENEULER_NATIVESDK_SYSROOT}/usr/lib \
                         -Wl,-rpath,${OPENEULER_NATIVESDK_SYSROOT}/lib"

# set --with-sqlite to native sdk path
do_compile:class-native () {
        if [ "${SITEINFO_BITS}" = "64" ]; then
          ${S}/configure ${PSEUDO_EXTRA_OPTS} --prefix=${prefix} --libdir=${prefix}/lib/pseudo/lib${SITEINFO_BITS} --with-sqlite-lib=${OPENEULER_NATIVESDK_SYSROOT}/usr/lib --with-sqlite=${OPENEULER_NATIVESDK_SYSROOT}/usr --cflags="${CFLAGS}" --bits=${SITEINFO_BITS} --without-rpath
        else
          ${S}/configure ${PSEUDO_EXTRA_OPTS} --prefix=${prefix} --libdir=${prefix}/lib/pseudo/lib --with-sqlite-lib=${OPENEULER_NATIVESDK_SYSROOT}/usr/lib --with-sqlite=${OPENEULER_NATIVESDK_SYSROOT}/usr --cflags="${CFLAGS}" --bits=${SITEINFO_BITS} --without-rpath
        fi
        oe_runmake ${MAKEOPTS}
}

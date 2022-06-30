# we can't move pseudo-native into native sdk currenlty because of deep couple of pseduo and yocto,
# but we can use native sdk to build pseudo-native to remove the dependency of sqlite-native and attr-native
DEPENDS_remove += "sqlite3 attr"

SRC_URI_class-native = "file://yocto-pseudo/pseudo-df1d1321fb093283485c387e3c933d2d264e509c.tar.gz \
                        file://fallback-passwd \
                        file://fallback-group \
                        "
PV = "1.9.0"
LIC_FILES_CHKSUM = "file://COPYING;md5=243b725d71bb5df4a1e5920b344b86ad"
LIC_FILES_CHKSUM = "file://COPYING;md5=a1d8023a6f953ac6ea4af765ff62d574"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/GPL-2.0-only;md5=801f80980d171dd6425610833a22dbe6"
S = "${WORKDIR}/${BPN}-df1d1321fb093283485c387e3c933d2d264e509c"

#set --with-sqlite to native sdk path
do_compile () {
        if [ "${SITEINFO_BITS}" = "64" ]; then
          ${S}/configure ${PSEUDO_EXTRA_OPTS} --prefix=${prefix} --libdir=${prefix}/lib/pseudo/lib${SITEINFO_BITS} --with-sqlite-lib=${OPENEULER_NATIVESDK_SYSROOT}/usr/lib --with-sqlite=${OPENEULER_NATIVESDK_SYSROOT}/usr --cflags="${CFLAGS}" --bits=${SITEINFO_BITS} --without-rpath
        else
          ${S}/configure ${PSEUDO_EXTRA_OPTS} --prefix=${prefix} --libdir=${prefix}/lib/pseudo/lib --with-sqlite-lib=${OPENEULER_NATIVESDK_SYSROOT}/usr/lib --with-sqlite=${OPENEULER_NATIVESDK_SYSROOT}/usr --cflags="${CFLAGS}" --bits=${SITEINFO_BITS} --without-rpath
        fi
        oe_runmake ${MAKEOPTS}
}

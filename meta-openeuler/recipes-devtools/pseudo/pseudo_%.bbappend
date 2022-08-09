# we can't move pseudo-native into native sdk currenlty because of deep couple of pseduo and yocto,
# but we can use native sdk to build pseudo-native to remove the dependency of sqlite-native and attr-native
DEPENDS_remove_class-native += "sqlite3-native attr-native"

SRC_URI_class-native = "file://yocto-pseudo/${BP}.tar.gz \
                        file://fallback-passwd \
                        file://fallback-group \
                        "
PV_class-native = "df1d1321fb093283485c387e3c933d2d264e509c"
S_class-native = "${WORKDIR}/${BP}"

# set root home directory to /root, not default /home/root
do_configure_prepend_class-native() {
        sed -i "1s/\/home//" ${WORKDIR}/fallback-passwd
}

#set --with-sqlite to native sdk path
do_compile_class-native () {
        if [ "${SITEINFO_BITS}" = "64" ]; then
          ${S}/configure ${PSEUDO_EXTRA_OPTS} --prefix=${prefix} --libdir=${prefix}/lib/pseudo/lib${SITEINFO_BITS} --with-sqlite-lib=${OPENEULER_NATIVESDK_SYSROOT}/usr/lib --with-sqlite=${OPENEULER_NATIVESDK_SYSROOT}/usr --cflags="${CFLAGS}" --bits=${SITEINFO_BITS} --without-rpath
        else
          ${S}/configure ${PSEUDO_EXTRA_OPTS} --prefix=${prefix} --libdir=${prefix}/lib/pseudo/lib --with-sqlite-lib=${OPENEULER_NATIVESDK_SYSROOT}/usr/lib --with-sqlite=${OPENEULER_NATIVESDK_SYSROOT}/usr --cflags="${CFLAGS}" --bits=${SITEINFO_BITS} --without-rpath
        fi
        oe_runmake ${MAKEOPTS}
}

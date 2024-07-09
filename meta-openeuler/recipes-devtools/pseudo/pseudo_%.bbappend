OPENEULER_REPO_NAME = "yocto-pseudo"

OPENEULER_REPO_NAMES = "yocto-pseudo oee_archive"

SRC_URI:prepend = "file://${BP}.tar.gz \
          file://oee_archive/pseudo/pseudo-prebuilt-2.33.tar.xz;subdir=${BP}/prebuilt;name=prebuilt \
           "

PV = "df1d1321fb093283485c387e3c933d2d264e509c"
S = "${WORKDIR}/${BP}"

# set --with-sqlite to native sdk path
do_compile:class-native:openeuler-prebuilt () {
        if [ "${SITEINFO_BITS}" = "64" ]; then
          ${S}/configure ${PSEUDO_EXTRA_OPTS} --prefix=${prefix} --libdir=${prefix}/lib/pseudo/lib${SITEINFO_BITS} --with-sqlite-lib=/lib --with-sqlite=${OPENEULER_NATIVESDK_SYSROOT}/usr --cflags="${CFLAGS}" --bits=${SITEINFO_BITS} --without-rpath
        else
          ${S}/configure ${PSEUDO_EXTRA_OPTS} --prefix=${prefix} --libdir=${prefix}/lib/pseudo/lib --with-sqlite-lib=/lib --with-sqlite=${OPENEULER_NATIVESDK_SYSROOT}/usr --cflags="${CFLAGS}" --bits=${SITEINFO_BITS} --without-rpath
        fi
        oe_runmake ${MAKEOPTS}
}

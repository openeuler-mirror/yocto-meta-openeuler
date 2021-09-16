DEPENDS_remove += "sqlite3 attr"
XSRC_URI = "git://git.yoctoproject.org/pseudo;branch=oe-core \
           file://0001-configure-Prune-PIE-flags.patch \
           file://fallback-passwd \
           file://fallback-group \
           "
FILESPATH_prepend += "${LOCAL_FILES}:"
SRC_URI_remove_class-native = " \
    http://downloads.yoctoproject.org/mirror/sources/pseudo-prebuilt-2.33.tar.xz;subdir=git/prebuilt;name=prebuilt \
    file://older-glibc-symbols.patch"
SRC_URI_class-native = "file://yocto-pseudo/pseudo-060058bb29f70b244e685b3c704eb0641b736f73.tar.gz \
           file://fallback-passwd \
           file://fallback-group \
           "
#BB_STRICT_CHECKSUM = "0"
PV = "1.9.0"
LIC_FILES_CHKSUM = "file://COPYING;md5=243b725d71bb5df4a1e5920b344b86ad"
LIC_FILES_CHKSUM = "file://COPYING;md5=a1d8023a6f953ac6ea4af765ff62d574"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/GPL-2.0-only;md5=801f80980d171dd6425610833a22dbe6"
S = "${WORKDIR}/${BPN}-060058bb29f70b244e685b3c704eb0641b736f73"
PSEUDO_EXTRA_OPTS_remove = "--enable-xattr"

#set --with-sqlite to system host,use system headers
do_compile () {
        if [ "${SITEINFO_BITS}" = "64" ]; then
          ${S}/configure ${PSEUDO_EXTRA_OPTS} --prefix=${prefix} --libdir=${prefix}/lib/pseudo/lib${SITEINFO_BITS} --with-sqlite-lib=/usr/lib --with-sqlite=/usr --cflags="${CFLAGS}" --bits=${SITEINFO_BITS} --without-rpath
        else
          ${S}/configure ${PSEUDO_EXTRA_OPTS} --prefix=${prefix} --libdir=${prefix}/lib/pseudo/lib --with-sqlite-lib=/usr/lib --with-sqlite=/usr --cflags="${CFLAGS}" --bits=${SITEINFO_BITS} --without-rpath
        fi
        oe_runmake ${MAKEOPTS}
}

#do install使用了chrpath，需新增
xxdo_install_append_class-native () {
        xchrpath ${D}${bindir}/pseudo -r `chrpath ${D}${bindir}/pseudo | cut -d = -f 2 | sed s/XORIGIN/\\$ORIGIN/`
        install -d ${D}${sysconfdir}
        # The fallback files should never be modified
        install -m 444 ${WORKDIR}/fallback-passwd ${D}${sysconfdir}/passwd
        install -m 444 ${WORKDIR}/fallback-group ${D}${sysconfdir}/group

        # Two native/nativesdk entries below are the same
        # If necessary install for the alternative machine arch.  This is only
        # necessary in a native build.
        maybe_make32
        if $make32; then
                mkdir -p ${D}${prefix}/lib/pseudo/lib
                cp lib/pseudo/lib/libpseudo.so ${D}${prefix}/lib/pseudo/lib/.
        fi
}

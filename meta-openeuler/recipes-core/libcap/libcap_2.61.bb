SUMMARY = "Library for getting/setting POSIX.1e capabilities"
HOMEPAGE = "http://sites.google.com/site/fullycapable/"

# no specific GPL version required
LICENSE = "BSD | GPLv2"

LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/GPL-2.0-only;md5=801f80980d171dd6425610833a22dbe6"

SRC_URI = "file://libcap/${BP}.tar.gz \
           file://libcap/libcap-buildflags.patch \
"

S = "${WORKDIR}/${BPN}-${PV}"

DEPENDS = "hostperl-runtime-native gperf-native"


inherit lib_package

PACKAGECONFIG ??= "${@bb.utils.filter('DISTRO_FEATURES', 'pam', d)}"
PACKAGECONFIG_class-native ??= ""

PACKAGECONFIG[pam] = "PAM_CAP=yes,PAM_CAP=no,libpam"


EXTRA_OEMAKE = " \
  INDENT=  \
  lib='${baselib}' \
  RAISE_SETFCAP=no \
  DYNAMIC=yes \
  BUILD_GPERF=yes \
"
INSANE_SKIP += "installed-vs-shipped"

#EXTRA_OEMAKE_append_class-target = " SYSTEM_HEADERS=${STAGING_INCDIR}"

# these are present in the libcap defaults, so include in our CFLAGS too
CFLAGS += "-D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64"

do_compile() {
        unset CFLAGS BUILD_CFLAGS
        oe_runmake ${PACKAGECONFIG_CONFARGS} \
                AR="${AR}" \
                CC="${CC}" \
                RANLIB="${RANLIB}" \
                OBJCOPY="${OBJCOPY}" \
                COPTS="${CFLAGS}" \
                BUILD_COPTS="${BUILD_CFLAGS}" 
}

do_install() {
	rm ${D}${libdir}/security/pam_cap.so -rf
        oe_runmake install \
                ${PACKAGECONFIG_CONFARGS} \
                DESTDIR="${D}" \
                prefix="${prefix}" \
                SBINDIR="${sbindir}"
}

do_install_append() {
        # Move the library to base_libdir
        install -d ${D}${base_libdir}
        if [ ! ${D}${libdir} -ef ${D}${base_libdir} ]; then
                mv ${D}${libdir}/libcap* ${D}${base_libdir}
                if [ -d ${D}${libdir}/security ]; then
                        mv ${D}${libdir}/security ${D}${base_libdir}
                fi
        fi
	rm ${D}${base_libdir}/security -rf
}

#FILES_${PN}-dev += "${base_libdir}/*.so"

# pam files
FILES_${PN} += "${base_libdir}/security/*.so"

BBCLASSEXTEND = "native nativesdk"


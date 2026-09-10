# meta-openeuler own recipe, shadowing poky's
# meta/recipes-extended/tcp-wrappers/tcp-wrappers_7.6.bb (same PN/PV;
# this layer has the higher BBFILE_PRIORITY).  The source is the
# src-openeuler tcp_wrappers tarball, the ipv6.4 variant with the
# usagi ipv6 changes already merged into the sources.
#
# Patch strategy follows the src-openeuler spec
# (https://atomgit.com/src-openeuler/tcp_wrappers): the spec patches
# listed first below are applied directly from the local src-openeuler
# clone via openeuler.bbclass FILESPATH, so the result matches the
# openEuler distribution build bit for bit.  Poky patches are kept
# only for fixes beyond the spec set, chiefly compile-time hygiene
# (gcc 14+ / clang 16+ turn implicit-function-declaration into an
# error, and clang-musl is an official toolchain of this repo); poky
# patches that conflict with the ipv6.4 baseline or duplicate spec
# patches are simply not carried.
SUMMARY = "Security tool that is a wrapper for TCP daemons"
HOMEPAGE = "http://www.softpanorama.org/Net/Network_security/TCP_wrappers/"
DESCRIPTION = "Tools for monitoring and filtering incoming requests for tcp \
               services."
SECTION = "console/network"

LICENSE = "BSD-1-Clause"
LIC_FILES_CHKSUM = "file://DISCLAIMER;md5=071bd69cb78b18888ea5e3da5c3127fa"
PR = "r10"

DEPENDS += "libnsl2"

PACKAGES = "${PN}-dbg libwrap libwrap-doc libwrap-dev libwrap-staticdev ${PN} ${PN}-doc"
# the runtime library ships from ${base_libdir} only, so that
# libwrap.so.1 has a single shlib provider; ${libdir} keeps just the
# dev symlink and the static archive
FILES:libwrap = "${base_libdir}/lib*${SOLIBS}"
FILES:libwrap-doc = "${mandir}/man3 ${mandir}/man5"
FILES:libwrap-dev = "${libdir}/lib*${SOLIBSDEV} ${includedir}"
FILES:libwrap-staticdev = "${libdir}/lib*.a"
FILES:${PN} = "${sbindir}"
FILES:${PN}-doc = "${mandir}/man8"

SRC_URI = " \
           file://tcp_wrappers_${PV}-ipv6.4.tar.gz \
           file://tcpw7.2-config.patch \
           file://man_fromhost.patch \
           file://safe_finger.patch \
           file://tcp_wrappers-7.6-sig.patch \
           file://tcp_wrappers-7.6-siglongjmp.patch \
           file://tcpdchk_libwrapped.patch \
           file://0001-Fix-build-with-clang.patch \
           file://fix_warnings.patch \
           file://0001-Remove-fgets-extern-declaration.patch \
           file://0001-Fix-implicit-function-declaration-warnings.patch \
           file://try-from.8 \
           file://safe_finger.8 \
           file://tcp_wrappers-7.6-fixgethostbyname.patch \
           file://tcp_wrappers-7.6-bug11881.patch \
           file://tcp_wrappers-7.6-bug17795.patch \
           file://tcp_wrappers-7.6-fix_sig-bug141110.patch \
           file://tcp_wrappers-7.6-162412.patch \
           file://tcp_wrappers-7.6-196326.patch \
           file://tcp_wrappers_7.6-249430.patch \
           file://tcp_wrappers-7.6-xgets.patch \
           file://tcp_wrappers-7.6-initgroups.patch \
           file://tcp_wrappers-7.6-uchart_fix.patch \
           file://tcp_wrappers-7.6-altformat.patch \
           "

SRC_URI[md5sum] = "ccbc2676977c31bbd43783abfbf2fdcf"
SRC_URI[sha256sum] = "038a580b6497bab516a3e0dca59dfa2fe8cf3c0151bef45d57572fb756c2a64c"

# the ipv6.4 tarball top dir differs from poky's S (tcp_wrappers_7.6)
S = "${WORKDIR}/tcp_wrappers_${PV}-ipv6.4"

# -fPIC -DPIC so the objects can also be linked into libwrap.so below;
# -DUSE_STRERROR because percent_m.c needs it to use strerror() instead
# of the long-removed glibc sys_nerr/sys_errlist (the Fedora linux
# target sets it, poky's EXTRA_OEMAKE does not)
EXTRA_OEMAKE = "'CC=${CC}' \
                'AR=${AR}' \
                'RANLIB=${RANLIB}' \
                'REAL_DAEMON_DIR=${sbindir}' \
                'STYLE=-DPROCESS_OPTIONS' \
                'FACILITY=LOG_DAEMON' \
                'SEVERITY=LOG_INFO' \
                'BUGS=' \
                'VSYSLOG=' \
                'RFC931_TIMEOUT=10' \
                'ACCESS=-DHOSTS_ACCESS' \
                'KILL_OPT=-DKILL_IP_OPTIONS' \
                'UMASK=-DDAEMON_UMASK=022' \
                'NETGROUP=${EXTRA_OEMAKE_NETGROUP}' \
                'ARFLAGS=rv' \
                'AUX_OBJ=weak_symbols.o' \
                'TLI=' \
                'COPTS=' \
                'STRINGS=' \
                'EXTRA_CFLAGS=${CFLAGS} -fPIC -DPIC -DSYS_ERRLIST_DEFINED -DHAVE_STRERROR -DHAVE_WEAKSYMS -D_REENTRANT -DUSE_STRERROR'"

EXTRA_OEMAKE_NETGROUP = "-DNETGROUP -DUSE_GETDOMAIN"
EXTRA_OEMAKE_NETGROUP:libc-musl = "-DUSE_GETDOMAIN"

EXTRA_OEMAKE:append:libc-musl = " 'LIBS='"

# neither the poky nor the src-openeuler ldflags patch applies on this
# Makefile; inject LDFLAGS into the link rules manually instead.
# weak_symbols.c comes from poky's 13_shlib_weaksym patch which does
# not apply on this Makefile; recreate it (the generic .c.o rule
# compiles it, AUX_OBJ=weak_symbols.o pulls it into libwrap.a)
do_configure:append() {
    sed -i 's/$(CC) $(CFLAGS) -o/$(CC) $(LDFLAGS) $(CFLAGS) -o/g' ${S}/Makefile
    # the ipv6.4 scaffold.c declares 'extern char *malloc()' although
    # it includes stdlib.h, conflicting with the standard declaration
    sed -i '/^extern char \*malloc();/d' ${S}/scaffold.c

    cat > ${S}/weak_symbols.c <<'EOF'
 /*
  * @(#) weak_symbols.h 1.5 99/12/29 23:50
  *
  * Author: Anthony Towns <ajt@debian.org>
  */

#ifdef HAVE_WEAKSYMS
#include <syslog.h>
int deny_severity = LOG_WARNING;
int allow_severity = SEVERITY;
#endif
EOF
}

# the libwrap.so link mirrors the src-openeuler shared patch which does
# not apply on this Makefile: build it from the same objects as
# libwrap.a (LIB_OBJ, including weak_symbols.o and fromhost.o)
do_compile () {
	oe_runmake 'TABLES=-DHOSTS_DENY=\"${sysconfdir}/hosts.deny\" -DHOSTS_ALLOW=\"${sysconfdir}/hosts.allow\"' \
		   all
	${CC} ${LDFLAGS} -shared -Wl,-soname,libwrap.so.1 \
	    -o libwrap.so.1.0.0 \
	    hosts_access.o options.o shell_cmd.o rfc931.o eval.o \
	    hosts_ctl.o refuse.o percent_x.o clean_exit.o \
	    weak_symbols.o fromhost.o fix_options.o socket.o tli.o \
	    workarounds.o update.o misc.o diag.o percent_m.o myvsyslog.o
	ln -sf libwrap.so.1.0.0 libwrap.so.1
	ln -sf libwrap.so.1.0.0 libwrap.so
}

BINS = "safe_finger tcpd tcpdchk try-from tcpdmatch"
MANS3 = "hosts_access"
MANS5 = "hosts_options"
MANS8 = "tcpd tcpdchk tcpdmatch"
do_install () {
	oe_libinstall -a libwrap ${D}${libdir}
	oe_libinstall -so libwrap ${D}${base_libdir}

	if [ "${libdir}" != "${base_libdir}" ] ; then
		# oe_libinstall copies the runtime objects into ${libdir} and
		# the static archive into ${base_libdir}; drop the duplicates
		# so that libwrap.so.1 is provided by ${base_libdir} alone
		# and the static archive stays in ${libdir}
		rm -f ${D}${libdir}/libwrap.so.1 ${D}${libdir}/libwrap.so.1.0.0
		rm -f ${D}${base_libdir}/libwrap.a
		rel_lib_prefix=`echo ${libdir} | sed 's,\(^/\|\)[^/][^/]*,..,g'`
		libname=`readlink ${D}${base_libdir}/libwrap.so | xargs basename`
		rm -f ${D}${libdir}/libwrap.so
		ln -s ${rel_lib_prefix}${base_libdir}/${libname} ${D}${libdir}/libwrap.so
		rm -f ${D}${base_libdir}/libwrap.so
	fi

	install -d ${D}${sbindir}
	for b in ${BINS}; do
		install -m 0755 $b ${D}${sbindir}/ || exit 1
	done

	install -d ${D}${mandir}/man3
	for m in ${MANS3}; do
		install -m 0644 $m.3 ${D}${mandir}/man3/ || exit 1
	done

	install -d ${D}${mandir}/man5
	for m in ${MANS5}; do
		install -m 0644 $m.5 ${D}${mandir}/man5/ || exit 1
	done

	install -d ${D}${mandir}/man8
	for m in ${MANS8}; do
		install -m 0644 $m.8 ${D}${mandir}/man8/ || exit 1
	done

	install -m 0644 ${WORKDIR}/try-from.8 ${D}${mandir}/man8/
	install -m 0644 ${WORKDIR}/safe_finger.8 ${D}${mandir}/man8/

	install -d ${D}${includedir}
	install -m 0644 tcpd.h ${D}${includedir}/

	install -d ${D}${sysconfdir}
	touch ${D}${sysconfdir}/hosts.allow
	touch ${D}${sysconfdir}/hosts.deny
}

FILES:${PN} += "${sysconfdir}/hosts.allow ${sysconfdir}/hosts.deny"

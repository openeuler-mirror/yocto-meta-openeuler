DESCRIPTION = "A a package of utilities for doing and managing mounts of the Linux CIFS filesystem."
HOMEPAGE = "http://wiki.samba.org/index.php/LinuxCIFS_utils"
SECTION = "otherosfs"
LICENSE = "GPLv3 & LGPLv3"
LIC_FILES_CHKSUM = "file://COPYING;md5=d32239bcb673463ab874e80d47fae504"

SRC_URI = "file://cifs-utils/${BP}.tar.bz2"
SRC_URI[sha256sum] = "6609e8074b5421295ff012a31f02ccd9a058415c619c81362ebb788dbf0756b8"

PACKAGECONFIG ??= ""
PACKAGECONFIG[cap] = "--with-libcap,--without-libcap,libcap"
# when enabled, it creates ${bindir}/cifscreds and --ignore-fail-on-non-empty in do_install_append is needed
PACKAGECONFIG[cifscreds] = "--enable-cifscreds,--disable-cifscreds,keyutils"
# when enabled, it creates ${sbindir}/cifs.upcall and --ignore-fail-on-non-empty in do_install_append is needed
PACKAGECONFIG[cifsupcall] = "--enable-cifsupcall,--disable-cifsupcall,krb5 libtalloc keyutils"
PACKAGECONFIG[cifsidmap] = "--enable-cifsidmap,--disable-cifsidmap,keyutils samba"
PACKAGECONFIG[cifsacl] = "--enable-cifsacl,--disable-cifsacl,samba"
PACKAGECONFIG[pam] = "--enable-pam --with-pamdir=${base_libdir}/security,--disable-pam,libpam keyutils"

inherit autotools pkgconfig

do_install_append() {
    # Remove empty /usr/bin and /usr/sbin directories since the mount helper
    # is installed to /sbin
    rmdir --ignore-fail-on-non-empty ${D}${bindir} ${D}${sbindir}
}

do_compile_prepend() {
	#fix open source compile error because of the dependency problem
	cat Makefile | grep "@\$(MAKE) \$(AM_MAKEFLAGS) install-exec-am install-data-am" || return  1
	sed -i 's/^[[:space:]]@$(MAKE) $(AM_MAKEFLAGS) install-exec-am install-data-am/\t\@\$(MAKE) \$(AM_MAKEFLAGS) install-data-am\n\t\@\$(MAKE) \$(AM_MAKEFLAGS) install-exec-am/g' Makefile
}

FILES_${PN} += "${base_libdir}/security"
FILES_${PN}-dbg += "${base_libdir}/security/.debug"
RRECOMMENDS_${PN} = "kernel-module-cifs"

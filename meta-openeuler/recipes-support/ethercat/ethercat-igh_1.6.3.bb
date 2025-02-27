DESCRIPTION = "IgH EtherCAT Master for Linux"
HOMEPAGE = "http://etherlab.org/download/ethercat"
LICENSE = "GPL-2.0-only & LGPL-2.1-only"
LIC_FILES_CHKSUM = "file://COPYING;md5=59530bdf33659b29e73d4adb9f9f6552"
SECTION = "net"

# Currently, version 1.5.2 is on src-openEuler/master branch.
# However, this version does not support kernel 6.6, so we use
# version 1.6.3 from oee_archive for now.
inherit oee-archive
OEE_ARCHIVE_SUB_DIR = "igh-ethercat"

SRC_URI = " \
    file://ethercat-${PV}.tar.bz2 \
"

S = "${WORKDIR}/ethercat-${PV}"

PACKAGECONFIG ??= "generic"

PACKAGECONFIG[generic] = "--enable-generic,--disable-generic,"
PACKAGECONFIG[8139too] = "--enable-8139too,--disable-8139too,"
PACKAGECONFIG[e100]    = "--enable-e100,--disable-e100,"
PACKAGECONFIG[e1000]   = "--enable-e1000,--disable-e1000,"
PACKAGECONFIG[e1000e]  = "--enable-e1000e,--disable-e1000e,"
PACKAGECONFIG[r8169]   = "--enable-r8169,--disable-r8169,"

do_configure[depends] += "virtual/kernel:do_shared_workdir"

inherit autotools-brokensep pkgconfig module-base

# disable the textrel check
INSANE_SKIP:${PN} = "textrel"

EXTRA_OECONF += "--with-linux-dir=${STAGING_KERNEL_BUILDDIR}"
EXTRA_OECONF += "--with-module-dir=kernel/ethercat"

do_configure:prepend() {
	# Fixes configure error
	# | Makefile.am: error: required file './ChangeLog' not found"
	touch ChangeLog
}

do_compile:append() {
	oe_runmake modules
}

do_install:append() {
	oe_runmake MODLIB=${D}${nonarch_base_libdir}/modules/${KERNEL_VERSION} modules_install
	# Do distclean after installation to fix the error in the second compilation:
	# | error: .libs/libethercat_la-common.o: No such file or directory
	oe_runmake distclean
}

FILES:${PN} += " \
${nonarch_base_libdir}/modules/${KERNEL_VERSION} \
/usr/share \
"

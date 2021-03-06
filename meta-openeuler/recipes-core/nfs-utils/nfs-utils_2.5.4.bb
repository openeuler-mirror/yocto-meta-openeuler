SUMMARY = "userspace utilities for kernel nfs"
DESCRIPTION = "The nfs-utils package provides a daemon for the kernel \
NFS server and related tools."
HOMEPAGE = "http://nfs.sourceforge.net/"
SECTION = "console/network"

LICENSE = "MIT & GPLv2+ & BSD"
LIC_FILES_CHKSUM = "file://COPYING;md5=95f3a93a5c3c7888de623b46ea085a84"

# util-linux for libblkid
DEPENDS = "libcap libevent util-linux libtirpc"
RDEPENDS_${PN} = "${PN}-client"
RRECOMMENDS_${PN} = "kernel-module-nfsd"

USERADD_PACKAGES = "${PN}-client"
USERADD_PARAM_${PN}-client = "--system  --home-dir /var/lib/nfs \
			      --shell /bin/false --user-group rpcuser"

SRC_URI = "file://nfs-utils/${BP}.tar.xz \
           file://nfs-utils/0000-systemd-idmapd-require-rpc-pipefs.patch \
           file://nfs-utils/0001-correct-the-statd-path-in-man.patch \
           file://nfs-utils/0002-nfs-utils-set-use-gss-proxy-1-to-enable-gss-proxy-by.patch \
           file://nfs-utils/0003-idmapd-Fix-error-status-when-nfs-idmapd-exits.patch \
           file://nfs-utils/0004-fix-coredump-in-bl_add_disk.patch \
           file://nfsserver \
           file://nfscommon \
           file://nfs-utils.conf \
           file://nfs-server.service \
           file://nfs-mountd.service \
           file://nfs-statd.service \
           file://proc-fs-nfsd.mount \
           "
SRC_URI[sha256sum] = "51997d94e4c8bcef5456dd36a9ccc38e231207c4e9b6a9a2c108841e6aebe3dd"

# Only kernel-module-nfsd is required here (but can be built-in)  - the nfsd module will
# pull in the remainder of the dependencies.

INITSCRIPT_PACKAGES = "${PN} ${PN}-client"
INITSCRIPT_NAME = "nfsserver"
INITSCRIPT_PARAMS = "defaults"
INITSCRIPT_NAME_${PN}-client = "nfscommon"
INITSCRIPT_PARAMS_${PN}-client = "defaults 19 21"

inherit autotools-brokensep pkgconfig systemd

SYSTEMD_PACKAGES = "${PN} ${PN}-client"
SYSTEMD_SERVICE_${PN} = "nfs-server.service nfs-mountd.service"
SYSTEMD_SERVICE_${PN}-client = "nfs-statd.service"

# --enable-uuid is need for cross-compiling
EXTRA_OECONF = "--with-statduser=rpcuser \
                --enable-mountconfig \
                --enable-libmount-mount \
                --enable-uuid \
                --disable-gss \
                --disable-nfsdcltrack \
                --with-statdpath=/var/lib/nfs/statd \
                --with-rpcgen=${HOSTTOOLS_DIR}/rpcgen \
               "

PACKAGECONFIG ??= "${@bb.utils.filter('DISTRO_FEATURES', 'ipv6', d)} \
"
PACKAGECONFIG_remove_libc-musl = "tcp-wrappers"
PACKAGECONFIG[ipv6] = "--enable-ipv6,--disable-ipv6,"
# libdevmapper is available in meta-oe
PACKAGECONFIG[nfsv41] = "--enable-nfsv41,--disable-nfsv41,libdevmapper,libdevmapper"
# keyutils is available in meta-oe
PACKAGECONFIG[nfsv4] = "--enable-nfsv4,--disable-nfsv4,keyutils,python3-core"

PACKAGES =+ "${PN}-client ${PN}-mount ${PN}-stats"

CONFFILES_${PN}-client += "${localstatedir}/lib/nfs/etab \
			   ${localstatedir}/lib/nfs/rmtab \
			   ${localstatedir}/lib/nfs/xtab \
			   ${localstatedir}/lib/nfs/statd/state \
			   ${sysconfdir}/nfsmount.conf"

FILES_${PN}-client = "${sbindir}/*statd \
		      ${sbindir}/rpc.idmapd ${sbindir}/sm-notify \
		      ${sbindir}/showmount ${sbindir}/nfsstat \
		      ${localstatedir}/lib/nfs \
		      ${sysconfdir}/nfs-utils.conf \
		      ${sysconfdir}/nfsmount.conf \
		      ${sysconfdir}/init.d/nfscommon \
		      ${systemd_unitdir}/system/nfs-statd.service"
RDEPENDS_${PN}-client = "${PN}-mount"

FILES_${PN}-mount = "${base_sbindir}/*mount.nfs*"

FILES_${PN}-stats = "${sbindir}/mountstats ${sbindir}/nfsiostat ${sbindir}/nfsdclnts"

FILES_${PN}-staticdev += "${libdir}/libnfsidmap/*.a"

FILES_${PN} += "${systemd_unitdir} ${libdir}/libnfsidmap/"

do_configure_prepend() {
	sed -i -e 's,sbindir = /sbin,sbindir = ${base_sbindir},g' \
		${S}/utils/mount/Makefile.am
}

# Make clean needed because the package comes with
# precompiled 64-bit objects that break the build
do_compile_prepend() {
	make clean
}

# Works on systemd only
HIGH_RLIMIT_NOFILE ??= "4096"

do_install_append () {
	install -d ${D}${sysconfdir}/init.d
	install -m 0750 ${WORKDIR}/nfsserver ${D}${sysconfdir}/init.d/nfsserver
	install -m 0750 ${WORKDIR}/nfscommon ${D}${sysconfdir}/init.d/nfscommon

	install -m 0755 ${WORKDIR}/nfs-utils.conf ${D}${sysconfdir}
	install -m 0755 ${S}/utils/mount/nfsmount.conf ${D}${sysconfdir}

	install -d ${D}${systemd_unitdir}/system
	install -m 0644 ${WORKDIR}/nfs-server.service ${D}${systemd_unitdir}/system/
	install -m 0644 ${WORKDIR}/nfs-mountd.service ${D}${systemd_unitdir}/system/
	install -m 0644 ${WORKDIR}/nfs-statd.service ${D}${systemd_unitdir}/system/
	sed -i -e 's,@SBINDIR@,${sbindir},g' \
		-e 's,@SYSCONFDIR@,${sysconfdir},g' \
		-e 's,@HIGH_RLIMIT_NOFILE@,${HIGH_RLIMIT_NOFILE},g' \
		${D}${systemd_unitdir}/system/*.service
	if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
		install -m 0644 ${WORKDIR}/proc-fs-nfsd.mount ${D}${systemd_unitdir}/system/
		install -d ${D}${systemd_unitdir}/system/sysinit.target.wants/
		ln -sf ../proc-fs-nfsd.mount ${D}${systemd_unitdir}/system/sysinit.target.wants/proc-fs-nfsd.mount
	fi

	# kernel code as of 3.8 hard-codes this path as a default
	install -d ${D}/var/lib/nfs/v4recovery

	chmod 0644 ${D}${localstatedir}/lib/nfs/statd/state

	# Make python tools use python 3
	sed -i -e '1s,#!.*python.*,#!${bindir}/python3,' ${D}${sbindir}/mountstats ${D}${sbindir}/nfsiostat
}

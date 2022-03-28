SUMMARY = "Universal Addresses to RPC Program Number Mapper"
DESCRIPTION = "The rpcbind utility is a server that converts RPC \
               program numbers into universal addresses."
SECTION = "console/network"
HOMEPAGE = "http://sourceforge.net/projects/rpcbind/"
BUGTRACKER = "http://sourceforge.net/tracker/?group_id=201237&atid=976751"
DEPENDS = "libtirpc quota"

LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://COPYING;md5=b46486e4c4a416602693a711bb5bfa39 \
                    file://src/rpcinfo.c;beginline=1;endline=27;md5=f8a8cd2cb25ac5aa16767364fb0e3c24"

SRC_URI = "file://rpcbind/${BP}.tar.bz2 \
           file://rpcbind/rpcbind-0.2.4-runstatdir.patch \
           file://rpcbind/bugfix-rpcbind-GETADDR-return-client-ip.patch \
           file://rpcbind/CVE-2017-8779.patch \
           file://rpcbind/backport-fix-double-free-in-init_transport.patch \
           file://rpcbind/bugfix-listen-tcp-port-111.patch \
           file://init.d \
           file://rpcbind.conf \
"
SRC_URI[md5sum] = "2d84ebbb7d6fb1fc3566d2d4b37f214b"
SRC_URI[sha256sum] = "5613746489cae5ae23a443bb85c05a11741a5f12c8f55d2bb5e83b9defeee8de"

inherit autotools systemd pkgconfig 

PACKAGECONFIG ??= "tcp-wrappers"
PACKAGECONFIG[tcp-wrappers] = "--enable-libwrap,--disable-libwrap,tcp-wrappers"

INITSCRIPT_NAME = "rpcbind"
INITSCRIPT_PARAMS = "start 12 2 3 4 5 . stop 60 0 1 6 ."

SYSTEMD_SERVICE_${PN} = "rpcbind.service rpcbind.socket"

USERADD_PACKAGES = "${PN}"
USERADD_PARAM_${PN} = "--system --no-create-home --home-dir / \
                       --shell /bin/false --user-group rpc"

PACKAGECONFIG ??= "${@bb.utils.filter('DISTRO_FEATURES', 'systemd', d)}"
PACKAGECONFIG[systemd] = "--with-systemdsystemunitdir=${systemd_unitdir}/system/, \
                          --without-systemdsystemunitdir, \
                          systemd \
"

EXTRA_OECONF += " --enable-warmstarts --with-rpcuser=rpc --without-systemdsystemunitdir"

do_install_append () {
	install -d ${D}${sysconfdir}/init.d
	sed -e 's,/etc/,${sysconfdir}/,g' \
		-e 's,/sbin/,${sbindir}/,g' \
		${WORKDIR}/init.d > ${D}${sysconfdir}/init.d/rpcbind
	chmod 0755 ${D}${sysconfdir}/init.d/rpcbind
}

ALTERNATIVE_${PN} = "rpcinfo"
ALTERNATIVE_LINK_NAME[rpcinfo] = "${bindir}/rpcinfo"

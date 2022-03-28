SUMMARY = "ISC Internet Domain Name Server"
HOMEPAGE = "https://www.isc.org/bind/"
DESCRIPTION = "BIND 9 provides a full-featured Domain Name Server system"
SECTION = "console/network"

LICENSE = "MPL-2.0"
LIC_FILES_CHKSUM = "file://COPYRIGHT;md5=8f17f64e47e83b60cd920a1e4b54419e"

DEPENDS = "openssl libcap zlib"

SRC_URI = "file://dhcp/dhcp-4.4.2.tar.gz \
           file://0001-revert-d10fbdec-for-lib-dns-gen.c-as-it-is-a-build-p.patch \
           file://conf.patch \
           file://named.service \
           file://bind9 \
           file://generate-rndc-key.sh \
           "

SRC_URI[sha256sum] = "1a7ccd64a16e5e68f7b5e0f527fd07240a2892ea53fe245620f4f5f607004521"

UPSTREAM_CHECK_URI = "https://ftp.isc.org/isc/bind9/"
# stay at 9.16 follow the ESV versions divisible by 4
UPSTREAM_CHECK_REGEX = "(?P<pver>9.(16|20|24|28)(\.\d+)+(-P\d+)*)/"

inherit autotools systemd pkgconfig multilib_header

# PACKAGECONFIGs readline and libedit should NOT be set at same time
PACKAGECONFIG ?= "readline"
PACKAGECONFIG[httpstats] = "--with-libxml2=${STAGING_DIR_HOST}${prefix},--without-libxml2,libxml2"
PACKAGECONFIG[readline] = "--with-readline=-lreadline,,readline"
PACKAGECONFIG[libedit] = "--with-readline=-ledit,,libedit"
PACKAGECONFIG[urandom] = "--with-randomdev=/dev/urandom,--with-randomdev=/dev/random,,"
PACKAGECONFIG[python3] = "--with-python=yes --with-python-install-dir=${PYTHON_SITEPACKAGES_DIR} , --without-python, python3-ply-native,"

EXTRA_OECONF = " --with-libtool --disable-devpoll --enable-epoll \
                 --with-gssapi=no --with-lmdb=no --with-zlib \
                 --with-ecdsa=yes --with-eddsa=no --with-gost=no \
                 --sysconfdir=${sysconfdir}/bind \
                 --with-openssl=${STAGING_DIR_HOST}${prefix} \
               "
LDFLAGS_append = " -lz"

inherit ${@bb.utils.contains('PACKAGECONFIG', 'python3', 'python3native distutils3-base', '', d)}

# dhcp needs .la so keep them
REMOVE_LIBTOOL_LA = "0"

USERADD_PACKAGES = "${PN}"
USERADD_PARAM_${PN} = "--system --home ${localstatedir}/cache/bind --no-create-home \
                       --user-group bind"

INITSCRIPT_NAME = "bind"
INITSCRIPT_PARAMS = "defaults"

SYSTEMD_SERVICE_${PN} = "named.service"

do_unpak () {
        cd ${WORKDIR}
        tar -xf dhcp-4.4.2/bind/bind.tar.gz
}

addtask unpak after do_unpack before do_patch

do_install_append() {

	rmdir "${D}${localstatedir}/run"
	rmdir --ignore-fail-on-non-empty "${D}${localstatedir}"
	install -d bind "${D}${localstatedir}/cache/bind"
	install -d "${D}${sysconfdir}/bind"
	install -d "${D}${sysconfdir}/init.d"
	install -m 644 ${S}/conf/* "${D}${sysconfdir}/bind/"
	install -m 750 "${S}/init.d" "${D}${sysconfdir}/init.d/bind"
        if ${@bb.utils.contains('PACKAGECONFIG', 'python3', 'true', 'false', d)}; then
		sed -i -e '1s,#!.*python3,#! /usr/bin/python3,' \
		${D}${sbindir}/dnssec-coverage \
		${D}${sbindir}/dnssec-checkds \
		${D}${sbindir}/dnssec-keymgr
	fi

	# Install systemd related files
	install -d ${D}${sbindir}
	install -m 755 ${WORKDIR}/generate-rndc-key.sh ${D}${sbindir}
	install -d ${D}${systemd_unitdir}/system
	install -m 0644 ${WORKDIR}/named.service ${D}${systemd_unitdir}/system
	sed -i -e 's,@BASE_BINDIR@,${base_bindir},g' \
	       -e 's,@SBINDIR@,${sbindir},g' \
	       ${D}${systemd_unitdir}/system/named.service

	install -d ${D}${sysconfdir}/default
	install -m 0644 ${WORKDIR}/bind9 ${D}${sysconfdir}/default

	if ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'true', 'false', d)}; then
		install -d ${D}${sysconfdir}/tmpfiles.d
		echo "d /run/named 0755 bind bind - -" > ${D}${sysconfdir}/tmpfiles.d/bind.conf
	fi

    oe_multilib_header isc/platform.h
}

CONFFILES_${PN} = " \
	${sysconfdir}/bind/named.conf \
	${sysconfdir}/bind/named.conf.local \
	${sysconfdir}/bind/named.conf.options \
	${sysconfdir}/bind/db.0 \
	${sysconfdir}/bind/db.127 \
	${sysconfdir}/bind/db.empty \
	${sysconfdir}/bind/db.local \
	${sysconfdir}/bind/db.root \
	"

ALTERNATIVE_${PN}-utils = "nslookup"
ALTERNATIVE_LINK_NAME[nslookup] = "${bindir}/nslookup"
ALTERNATIVE_PRIORITY = "100"

PACKAGE_BEFORE_PN += "${PN}-utils"
FILES_${PN}-utils = "${bindir}/host ${bindir}/dig ${bindir}/mdig ${bindir}/nslookup ${bindir}/nsupdate"
FILES_${PN}-dev += "${bindir}/isc-config.h"
FILES_${PN} += "${sbindir}/generate-rndc-key.sh"

PACKAGE_BEFORE_PN += "${PN}-libs"
# special arrangement below due to
# https://github.com/isc-projects/bind9/commit/0e25af628cd776f98c04fc4cc59048f5448f6c88
FILES_SOLIBSDEV = "${libdir}/*[!0-9].so ${libdir}/libbind9.so"
FILES_${PN}-libs = "${libdir}/named/*.so* ${libdir}/*-${PV}.so"
FILES_${PN}-staticdev += "${libdir}/*.la"

PACKAGE_BEFORE_PN += "${@bb.utils.contains('PACKAGECONFIG', 'python3', 'python3-bind', '', d)}"
FILES_python3-bind = "${sbindir}/dnssec-coverage ${sbindir}/dnssec-checkds \
                ${sbindir}/dnssec-keymgr ${PYTHON_SITEPACKAGES_DIR}"

RDEPENDS_${PN}-dev = ""
RDEPENDS_python3-bind = "python3-core python3-ply"

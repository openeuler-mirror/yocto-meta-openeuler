SECTION = "console/network"
SUMMARY = "Internet Software Consortium DHCP package"
DESCRIPTION = "DHCP (Dynamic Host Configuration Protocol) is a protocol \
which allows individual devices on an IP network to get their own \
network configuration information from a server.  DHCP helps make it \
easier to administer devices."

HOMEPAGE = "http://www.isc.org/"

LICENSE = "ISC"
LIC_FILES_CHKSUM = "file://LICENSE;md5=b9c6e660b3d9260de9a342d2fb77540a"

SRC_URI = "file://dhcp/${BP}.tar.gz \
           file://dhcp/backport-0001-change-bug-url.patch \
           file://dhcp/backport-0002-additional-dhclient-options.patch \
           file://dhcp/backport-0003-Handle-releasing-interfaces-requested-by-sbin-ifup.patch \
           file://dhcp/backport-0004-Support-unicast-BOOTP-for-IBM-pSeries-systems-and-ma.patch \
           file://dhcp/backport-0005-Change-default-requested-options.patch \
           file://dhcp/backport-0006-Various-man-page-only-fixes.patch \
           file://dhcp/backport-0007-Change-paths-to-conform-to-our-standards.patch \
           file://dhcp/backport-0008-Make-sure-all-open-file-descriptors-are-closed-on-ex.patch \
           file://dhcp/backport-0009-Fix-garbage-in-format-string-error.patch \
           file://dhcp/backport-0010-Handle-null-timeout.patch \
           file://dhcp/backport-0011-Drop-unnecessary-capabilities.patch \
           file://dhcp/backport-0012-RFC-3442-Classless-Static-Route-Option-for-DHCPv4-51.patch \
           file://dhcp/backport-0013-DHCPv6-over-PPP-support-626514.patch \
           file://dhcp/backport-0014-IPoIB-support-660681.patch \
           file://dhcp/backport-0015-Add-GUID-DUID-to-dhcpd-logs-1064416.patch \
           file://dhcp/backport-0016-Turn-on-creating-sending-of-DUID.patch \
           file://dhcp/backport-0017-Send-unicast-request-release-via-correct-interface.patch \
           file://dhcp/backport-0018-No-subnet-declaration-for-iface-should-be-info-not-e.patch \
           file://dhcp/backport-0019-dhclient-write-DUID_LLT-even-in-stateless-mode-11563.patch \
           file://dhcp/backport-0020-Discover-all-hwaddress-for-xid-uniqueness.patch \
           file://dhcp/backport-0021-Load-leases-DB-in-non-replay-mode-only.patch \
           file://dhcp/backport-0022-dhclient-make-sure-link-local-address-is-ready-in-st.patch \
           file://dhcp/backport-0023-option-97-pxe-client-id.patch \
           file://dhcp/backport-0025-bind-Detect-system-time-changes.patch \
           file://dhcp/backport-0026-Add-dhclient-5-B-option-description.patch \
           file://dhcp/backport-0027-Add-missed-sd-notify-patch-to-manage-dhcpd-with-syst.patch \
           file://dhcp/bugfix-dhcp-4.2.5-check-dhclient-pid.patch \ 
	   file://dhcp/bugfix-reduce-getifaddr-calls.patch \
	   file://dhcp/bugfix-dhcpd-2038-problem.patch \
	   file://dhcp/dhcpd-coredump-infiniband.patch \
	   file://dhcp/bugfix-dhclient-check-if-pid-was-held.patch \
	   file://dhcp/bugfix-dhcp-64-bit-lease-parse.patch \
	   file://dhcp/backport-CVE-2021-25217.patch \
	   file://dhcp/fix-multiple-definition-with-gcc-10-1.patch \
	   file://dhcp/fix-multiple-definition-with-gcc-10-2.patch \
	   file://0007-Add-configure-argument-to-make-the-libxml2-dependenc.patch \
	   file://0013-fixup_use_libbind.patch \
	   file://init-server file://default-server \
	   file://dhclient.conf file://dhcpd.conf \
	   "

SRC_URI[sha256sum] = "1a7ccd64a16e5e68f7b5e0f527fd07240a2892ea53fe245620f4f5f607004521"
DEPENDS = "openssl bind"

UPSTREAM_CHECK_URI = "http://ftp.isc.org/isc/dhcp/"
UPSTREAM_CHECK_REGEX = "(?P<pver>\d+\.\d+\.(\d+?))/"

inherit autotools-brokensep systemd

USERADD_PACKAGES = "${PN}-server"
USERADD_PARAM_${PN}-server = "--system --no-create-home --home-dir /var/run/${BPN} --shell /bin/false --user-group ${BPN}"

SYSTEMD_PACKAGES = "${PN}-server ${PN}-relay ${PN}-client"
#SYSTEMD_SERVICE_${PN}-server = "dhcpd.service dhcpd6.service"
#SYSTEMD_AUTO_ENABLE_${PN}-server = "disable"

#SYSTEMD_SERVICE_${PN}-relay = "dhcrelay.service"
#SYSTEMD_AUTO_ENABLE_${PN}-relay = "disable"

#SYSTEMD_SERVICE_${PN}-client = "dhclient.service"
#SYSTEMD_AUTO_ENABLE_${PN}-client = "disable"

INITSCRIPT_PACKAGES = "dhcp-server"
INITSCRIPT_NAME_dhcp-server = "dhcp-server"
INITSCRIPT_PARAMS_dhcp-server = "defaults"

TARGET_CFLAGS += "-D_GNU_SOURCE"
TARGET_CFLAGS +=  "-fcommon"
EXTRA_OECONF = "--with-srv-lease-file=${localstatedir}/lib/dhcp/dhcpd.leases \
                --with-srv6-lease-file=${localstatedir}/lib/dhcp/dhcpd6.leases \
                --with-cli-lease-file=${localstatedir}/lib/dhcp/dhclient.leases \
                --with-cli6-lease-file=${localstatedir}/lib/dhcp/dhclient6.leases \
                --enable-paranoia --enable-static=yes --enable-shared=yes \
                --with-randomdev=/dev/random \
                --with-libbind=${STAGING_DIR_HOST} \
                --enable-libtool \
               "

do_unpak() {
	cd ${WORKDIR}/${BP}/bind
	tar -xf bind.tar.gz
	mv bind-9.11.14/ bind
}

addtask unpak after do_unpack before do_patch

#Enable shared libs per dhcp README
do_configure_prepend () {
    cp configure.ac+lt configure.ac
}

do_install_append () {
    install -d ${D}${sysconfdir}/init.d
    install -d ${D}${sysconfdir}/default
    install -d ${D}${sysconfdir}/dhcp
    install -m 0755 ${WORKDIR}/init-server ${D}${sysconfdir}/init.d/dhcp-server
    install -m 0644 ${WORKDIR}/default-server ${D}${sysconfdir}/default/dhcp-server

    rm -f ${D}${sysconfdir}/dhclient.conf*
    rm -f ${D}${sysconfdir}/dhcpd.conf*
    install -m 0644 ${WORKDIR}/dhclient.conf ${D}${sysconfdir}/dhcp/dhclient.conf
    install -m 0644 ${WORKDIR}/dhcpd.conf ${D}${sysconfdir}/dhcp/dhcpd.conf

    install -d ${D}${base_sbindir}/
    if [ "${sbindir}" != "${base_sbindir}" ]; then
        mv ${D}${sbindir}/dhclient ${D}${base_sbindir}/
    fi
    install -m 0755 ${S}/client/scripts/linux ${D}${base_sbindir}/dhclient-script
    #delete extra rpath
    for dhcpFile in $(find ${D} -type f)
    do
         file ${dhcpFile} | grep ELF || continue
         readelf  -a ${dhcpFile} | grep rpath || continue
         ${RPATH_DELETE} ${dhcpFile}
    done
}

PACKAGES += "dhcp-libs dhcp-server dhcp-server-config dhcp-client dhcp-relay dhcp-omshell"

FILES_${PN} = "${base_sbindir}/dhclient \
               ${base_sbindir}/dhclient-script \
               ${sysconfdir}/dhcp/dhclient.conf \
               ${bindir}/omshell \
               ${sbindir}/dhcrelay \
              "
RDEPENDS_${PN}-dev = ""
RDEPENDS_${PN}-staticdev = ""
FILES_${PN}-libs = "${libdir}/libdhcpctl.so.0* ${libdir}/libomapi.so.0* ${libdir}/libdhcp.so.0*"

FILES_${PN}-server = "${sbindir}/dhcpd ${sysconfdir}/init.d/dhcp-server"
RRECOMMENDS_${PN}-server = "dhcp-server-config"

FILES_${PN}-server-config = "${sysconfdir}/default/dhcp-server ${sysconfdir}/dhcp/dhcpd.conf"

FILES_${PN}-relay = "${sbindir}/dhcrelay ${sysconfdir}/init.d/dhcp-relay ${sysconfdir}/default/dhcp-relay"

FILES_${PN}-client = "${base_sbindir}/dhclient \
                      ${base_sbindir}/dhclient-script \
                      ${sysconfdir}/dhcp/dhclient.conf \
                      ${base_sbindir}/dhclient-systemd-wrapper \
                     "

FILES_${PN}-omshell = "${bindir}/omshell"

pkg_postinst_dhcp-client() {
    mkdir -p $D/${localstatedir}/lib/dhcp
}

pkg_postrm_dhcp-server() {
    rm -f $D/${localstatedir}/lib/dhcp/dhcpd.leases
    rm -f $D/${localstatedir}/lib/dhcp/dhcpd6.leases

    if ! rmdir $D/${localstatedir}/lib/dhcp 2>/dev/null; then
        echo "Not removing ${localstatedir}/lib/dhcp as it is non-empty."
    fi
}

pkg_postrm_dhcp-client() {
    rm -f $D/${localstatedir}/lib/dhcp/dhclient.leases
    rm -f $D/${localstatedir}/lib/dhcp/dhclient6.leases

    if ! rmdir $D/${localstatedir}/lib/dhcp 2>/dev/null; then
        echo "Not removing ${localstatedir}/lib/dhcp as it is non-empty."
    fi
}

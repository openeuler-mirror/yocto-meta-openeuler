# source bb: meta-overc/recipes-connectivity/dhcp/dhcp_4.4.2-P1.bb
# update patches: 
# 0004-Fix-out-of-tree-builds.patch,
# 0007-Add-configure-argument-to-make-the-libxml2-dependenc.patch,
# 0013-fixup_use_libbind.patch

# version in openEuler
PV = "4.4.3"

LIC_FILES_CHKSUM = "file://LICENSE;beginline=4;md5=613211e713c4ffc489ec370e1caceabb"

# apply patches in openEuler
# backport-0025-bind-Detect-system-time-changes.patch, backport-Fix-CVE-2021-25220.patch for bind
SRC_URI:prepend = " \
           file://${BP}.tar.gz \
           file://backport-0001-change-bug-url.patch \
           file://backport-0002-additional-dhclient-options.patch \
           file://backport-0003-Handle-releasing-interfaces-requested-by-sbin-ifup.patch \
           file://backport-0004-Support-unicast-BOOTP-for-IBM-pSeries-systems-and-ma.patch \
           file://backport-0005-Change-default-requested-options.patch \
           file://backport-0006-Various-man-page-only-fixes.patch \
           file://backport-0007-Change-paths-to-conform-to-our-standards.patch \
           file://backport-0008-Make-sure-all-open-file-descriptors-are-closed-on-ex.patch \
           file://backport-0009-Fix-garbage-in-format-string-error.patch \
           file://backport-0010-Handle-null-timeout.patch \
           file://backport-0011-Drop-unnecessary-capabilities.patch \
           file://backport-0012-RFC-3442-Classless-Static-Route-Option-for-DHCPv4-51.patch \
           file://backport-0013-DHCPv6-over-PPP-support-626514.patch \
           file://backport-0014-IPoIB-support-660681.patch \
           file://backport-0015-Add-GUID-DUID-to-dhcpd-logs-1064416.patch \
           file://backport-0016-Turn-on-creating-sending-of-DUID.patch \
           file://backport-0017-Send-unicast-request-release-via-correct-interface.patch \
           file://backport-0018-No-subnet-declaration-for-iface-should-be-info-not-e.patch \
           file://backport-0019-dhclient-write-DUID_LLT-even-in-stateless-mode-11563.patch \
           file://backport-0020-Discover-all-hwaddress-for-xid-uniqueness.patch \
           file://backport-0021-Load-leases-DB-in-non-replay-mode-only.patch \
           file://backport-0022-dhclient-make-sure-link-local-address-is-ready-in-st.patch \
           file://backport-0023-option-97-pxe-client-id.patch \
           file://backport-0024-Detect-system-time-changes.patch \
           file://backport-0026-Add-dhclient-5-B-option-description.patch \
           file://backport-0027-Add-missed-sd-notify-patch-to-manage-dhcpd-with-syst.patch \
           file://bugfix-dhcp-4.2.5-check-dhclient-pid.patch \
           file://bugfix-reduce-getifaddr-calls.patch \
           file://bugfix-dhcpd-2038-problem.patch \
           file://dhcpd-coredump-infiniband.patch \
           file://bugfix-dhclient-check-if-pid-was-held.patch \
           file://bugfix-dhcp-64-bit-lease-parse.patch \
           file://fix-coredump-when-client-active-is-NULL.patch \
           file://feature-lease-time-config-ipv6.patch \
           file://add-a-test-case-to-parse-code93-in-option_unittest.patch \
           file://bugfix-error-message-display.patch \
           file://backport-Fix-CVE-2022-2928.patch \
           file://backport-Fix-CVE-2022-2929.patch \
           file://Revert-correcting-the-logic-in-dhclient.patch \
"

SRC_URI[md5sum] = "9076af4cc1293dde5a7c6cae7de6ab45"
SRC_URI[sha256sum] = "0e3ec6b4c2a05ec0148874bcd999a66d05518378d77421f607fb0bc9d0135818"

# it will make a error when using dhclient
# because backport-0007-Change-paths-to-conform-to-our-standards.patch
# changed the path /sbin/dhclient-script to /usr/sbin/dhclient-script for dhclient finding dhclient-script
# so re-install the dhclient-script to fix it.
do_install:append() {
        rm -f ${D}${base_sbindir}/dhclient-script
        install -m 0755 ${S}/client/scripts/linux ${D}${sbindir}/dhclient-script
}

FILES:${PN}-client += "${sbindir}/dhclient-script "

FILES:${PN}-client:remove = "${base_sbindir}/dhclient-script"

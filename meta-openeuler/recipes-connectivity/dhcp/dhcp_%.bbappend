# source bb: meta-overc/recipes-connectivity/dhcp/dhcp_4.4.2-P1.bb

# version in openEuler
PV = "4.4.2"

# apply patches in openEuler
SRC_URI_prepend = "file://backport-0001-change-bug-url.patch \
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
           file://backport-CVE-2021-25217.patch \
           file://fix-multiple-definition-with-gcc-10-1.patch \
           file://fix-multiple-definition-with-gcc-10-2.patch \
           file://fix-coredump-when-client-active-is-NULL.patch \
           file://bugfix-error-message-display.patch \
           file://feature-lease-time-config-ipv6.patch \
           file://add-a-test-case-to-parse-code93-in-option_unittest.patch \
"

SRC_URI[sha256sum] = "1a7ccd64a16e5e68f7b5e0f527fd07240a2892ea53fe245620f4f5f607004521"
SRC_URI[md5sum] = "2afdaf8498dc1edaf3012efdd589b3e1"

# it will make a error when using dhclient
# because backport-0007-Change-paths-to-conform-to-our-standards.patch
# changed the path /sbin/dhclient-script to /usr/sbin/dhclient-script for dhclient finding dhclient-script
# so re-install the dhclient-script to fix it.
do_install_append() {
        rm -f ${D}${base_sbindir}/dhclient-script
        install -m 0755 ${S}/client/scripts/linux ${D}${sbindir}/dhclient-script
}

FILES_${PN}-client += "${sbindir}/dhclient-script "

FILES_${PN}-client_remove = "${base_sbindir}/dhclient-script"

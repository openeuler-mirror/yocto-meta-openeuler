# version in openEuler
PV = "8.4.0"

# files, patches that come from openeuler
# do not apply backport-0101-curl-7.32.0-multilib.patch due to failure "libcurl.pc failed sanity test" when doing QA staging "pkg-config libcurl" in this patch
# note that 8.x version doesn't need any patches from poky.
SRC_URI = " \
	file://${BP}.tar.xz \
	file://backport-curl-7.84.0-test3026.patch \
	file://backport-curl-7.88.0-tests-warnings.patch \
	file://backport-CVE-2023-46218.patch \
	file://backport-0001-CVE-2023-46219.patch \
	file://backport-0002-CVE-2023-46219.patch \
	file://backport-openssl-avoid-BN_num_bits-NULL-pointer-derefs.patch \
	file://backport-pre-CVE-2024-2004.patch \
	file://backport-CVE-2024-2004.patch \
	file://backport-CVE-2024-2398.patch \
	file://backport-tool_cb_rea-limit-rate-unpause-for-T-uploads.patch \
	file://backport-paramhlp-fix-CRLF-stripping-files-with-d-file.patch \
	file://backport-libssh2-set-length-to-0-if-strdup-failed.patch \
	file://backport-openldap-create-ldap-URLs-correctly-for-IPv6-addresses.patch \
	file://backport-multi-avoid-memory-leak-risk.patch \
	file://backport-tool_cfgable-free-proxy_-cipher13_list-on-exit.patch \
	file://backport-CVE-2024-7264-x509asn1-clean-up-GTime2str.patch \
	file://backport-CVE-2024-7264-x509asn1-unittests-and-fixes-fo.patch \
"      

### openeuler configuration
EXTRA_OECONF:remove = " \
        --with-ca-bundle=${sysconfdir}/ssl/certs/ca-certificates.crt \
"

# in the ca-certificates package, there is no ca-certificates.crt file, so use ca-bundle.crt instead
EXTRA_OECONF:append = " \
        --with-ca-bundle=${sysconfdir}/ssl/certs/ca-bundle.crt \
"

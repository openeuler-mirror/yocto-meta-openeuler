# source bb: meta-oe/recipes-connectivity/krb5/krb5_1.17.2.bb

PV = "1.21.2"

LIC_FILES_CHKSUM = "file://${S}/../NOTICE;md5=32cb3a99207053d9f5c1ef177c4d6e34"

# apply openeuler source and patch
SRC_URI:prepend = "file://${BP}.tar.gz \
    file://ksu-pam-integration.patch;patchdir=${S}/.. \
    file://SELinux-integration.patch;patchdir=${S}/.. \
    file://Adjust-build-configuration.patch;patchdir=${S}/.. \
    file://netlib-and-dns.patch;patchdir=${S}/.. \
    file://fix-debuginfo-with-y.tab.c.patch;patchdir=${S}/.. \
    file://Remove-3des-support.patch;patchdir=${S}/.. \
    file://Fix-krb5_cccol_have_content-bad-pointer-free.patch;patchdir=${S}/.. \
    file://Do-not-reload-a-modified-profile-data-object.patch;patchdir=${S}/.. \
    file://backport-Fix-unimportant-memory-leaks.patch;patchdir=${S}/.. \
    file://backport-Remove-klist-s-defname-global-variable.patch;patchdir=${S}/.. \
    file://backport-Fix-two-unlikely-memory-leaks.patch;patchdir=${S}/.. \
    file://backport-Allow-modifications-of-empty-profiles.patch;patchdir=${S}/.. \
    file://fix-leak-in-KDC-NDR-encoding.patch;patchdir=${S}/.. \
    file://backport-Fix-more-non-prototype-functions.patch;patchdir=${S}/.. \
    file://backport-Fix-Python-regexp-literals.patch;patchdir=${S}/.. \
    file://backport-Handle-empty-initial-buffer-in-IAKERB-initiator.patch;patchdir=${S}/.. \
    file://backport-CVE-2024-37370-CVE-2024-37371-Fix-vulnerabilities-in-GSS-message-token-handling.patch;patchdir=${S}/.. \
    file://backport-Change-krb5_get_credentials-endtime-behavior.patch;patchdir=${S}/.. \
    file://backport-Fix-memory-leak-in-PAC-checksum-verification.patch;patchdir=${S}/.. \
    file://fix-libkadm5-parameter-leak.patch;patchdir=${S}/.. \
    file://backport-CVE-2024-3596.patch;patchdir=${S}/.. \
    file://backport-Avoid-mutex-locking-in-krb5int_trace.patch;patchdir=${S}/.. \
    file://backport-Fix-unlikely-password-change-leak.patch;patchdir=${S}/.. \
    file://backport-Allow-null-keyblocks-in-IOV-checksum-functions.patch;patchdir=${S}/.. \
    file://backport-Fix-krb5_ldap_list_policy-filtering-loop.patch;patchdir=${S}/.. \
    file://backport-Fix-various-issues-detected-by-static-analysis.patch;patchdir=${S}/.. \
    file://backport-Fix-krb5_crypto_us_timeofday-microseconds-check.patch;patchdir=${S}/.. \
    file://backport-Prevent-late-initialization-of-GSS-error-map.patch;patchdir=${S}/.. \
    file://backport-CVE-2025-24528.patch;patchdir=${S}/.. \
    file://backport-Fix-LDAP-module-leak-on-authentication-error.patch;patchdir=${S}/.. \
    file://backport-Fix-minor-logic-errors.patch;patchdir=${S}/.. \
    file://backport-Fix-type-violation-in-libkrad.patch;patchdir=${S}/.. \
    file://backport-Fix-various-small-logic-errors.patch;patchdir=${S}/.. \
    file://backport-Prevent-undefined-shift-in-decode_krb5_flags.patch;patchdir=${S}/.. \
    file://backport-Check-lengths-in-xdr_krb5_key_data.patch;patchdir=${S}/.. \
    file://backport-Fix-conditional-in-kadm5_chpass_principal_3.patch;patchdir=${S}/.. \
    file://backport-Fix-correctness-in-LDAP-delegation-ACL-checking.patch;patchdir=${S}/.. \
    file://backport-Fix-kdb5_util-ark-with-no-e-option.patch;patchdir=${S}/.. \
    file://backport-Fix-typo-in-AS-REQ-client-code.patch;patchdir=${S}/.. \
    file://backport-Fix-error-handling-in-pkinit_server_verify_padata.patch;patchdir=${S}/.. \
    file://backport-In-PKINIT-check-for-null-PKCS7-enveloped-fields.patch;patchdir=${S}/.. \
    file://backport-Fix-potential-PAC-processing-crash.patch;patchdir=${S}/.. \
    file://backport-Fix-crash-on-empty-TXT-records.patch;patchdir=${S}/.. \
    file://backport-Simplify-preauth-fallback-disabling.patch;patchdir=${S}/.. \
    file://backport-CVE-2026-40355-and-CVE-2026-40356.patch;patchdir=${S}/.. \
    file://backport-fix-reachable-assert-when-importing-krb5-names.patch;patchdir=${S}/.. \
    file://backport-CVE-2026-11850-prevent-read-overrun-in-libkdb_ldap.patch;patchdir=${S}/.. \
    file://backport-CVE-2026-107778-Avoid-null-dereference-in-krb5_rd_cred.patch;patchdir=${S}/.. \
    file://backport-CVE-2026-107708-Fix-error-handling-in-KDC-PAC-processing.patch;patchdir=${S}/.. \
"

SRC_URI:remove = " \
    file://0001-aclocal-Add-parameter-to-disable-keyutils-detection.patch \
    file://CVE-2021-36222.patch;striplevel=2 \
    file://CVE-2021-37750.patch;striplevel=2 \
    file://CVE-2022-42898.patch;striplevel=2 \
"

# the following configuration is for krb5-1.21.2
# ===============================================
inherit pkgconfig

SRC_URI[md5sum] = "7ac456e97c4959ebe5c836dc2f5aab2c"
SRC_URI[sha256sum] = "7d8d687d42aed350c2525cb69a4fc3aa791694da6761dccc1c42c2ee7796b5dd"

DEPENDS += "libselinux"

PACKAGECONFIG[keyutils] = "--with-keyutils,--without-keyutils,keyutils"

EXTRA_OECONF:remove = "--without-tcl"

inherit multilib_script
MULTILIB_SCRIPTS = "${PN}-dev:${bindir}/krb5-config"

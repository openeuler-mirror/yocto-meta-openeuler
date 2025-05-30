# source bb: meta-oe/recipes-connectivity/krb5/krb5_1.17.2.bb

PV = "1.21.2"

LIC_FILES_CHKSUM = "file://${S}/../NOTICE;md5=32cb3a99207053d9f5c1ef177c4d6e34"

# apply openeuler source and patch
PATCH_DIR = "${S}/.."
SRC_URI:prepend = " \
    file://${BP}.tar.gz \
    file://ksu-pam-integration.patch;patchdir=${PATCH_DIR} \
    file://SELinux-integration.patch;patchdir=${PATCH_DIR} \
    file://Adjust-build-configuration.patch;patchdir=${PATCH_DIR} \
    file://netlib-and-dns.patch;patchdir=${PATCH_DIR} \
    file://fix-debuginfo-with-y.tab.c.patch;patchdir=${PATCH_DIR} \
    file://Remove-3des-support.patch;patchdir=${PATCH_DIR} \
    file://Fix-krb5_cccol_have_content-bad-pointer-free.patch;patchdir=${PATCH_DIR} \
    file://Do-not-reload-a-modified-profile-data-object.patch;patchdir=${PATCH_DIR} \
    file://backport-Fix-two-unlikely-memory-leaks.patch;patchdir=${PATCH_DIR} \
    file://backport-Fix-unimportant-memory-leaks.patch;patchdir=${PATCH_DIR} \
    file://backport-Allow-modifications-of-empty-profiles.patch;patchdir=${PATCH_DIR} \
    file://fix-leak-in-KDC-NDR-encoding.patch;patchdir=${PATCH_DIR} \
    file://backport-Fix-more-non-prototype-functions.patch;patchdir=${PATCH_DIR} \
    file://backport-Fix-Python-regexp-literals.patch;patchdir=${PATCH_DIR} \
    file://backport-Handle-empty-initial-buffer-in-IAKERB-initiator.patch;patchdir=${PATCH_DIR} \
    file://backport-CVE-2024-37370-CVE-2024-37371-Fix-vulnerabilities-in-GSS-message-token-handling.patch;patchdir=${PATCH_DIR} \
    file://backport-Change-krb5_get_credentials-endtime-behavior.patch;patchdir=${PATCH_DIR} \
    file://backport-Fix-memory-leak-in-PAC-checksum-verification.patch;patchdir=${PATCH_DIR} \
    file://fix-libkadm5-parameter-leak.patch;patchdir=${PATCH_DIR} \
    file://backport-CVE-2024-3596.patch;patchdir=${PATCH_DIR} \
    file://backport-Avoid-mutex-locking-in-krb5int_trace.patch;patchdir=${PATCH_DIR} \
    file://backport-Fix-unlikely-password-change-leak.patch;patchdir=${PATCH_DIR} \
    file://backport-Allow-null-keyblocks-in-IOV-checksum-functions.patch;patchdir=${PATCH_DIR} \
    file://backport-Fix-krb5_ldap_list_policy-filtering-loop.patch;patchdir=${PATCH_DIR} \
    file://backport-Fix-various-issues-detected-by-static-analysis.patch;patchdir=${PATCH_DIR} \
    file://backport-Fix-krb5_crypto_us_timeofday-microseconds-check.patch;patchdir=${PATCH_DIR} \
    file://backport-Prevent-late-initialization-of-GSS-error-map.patch;patchdir=${PATCH_DIR} \
    file://backport-CVE-2025-24528.patch;patchdir=${PATCH_DIR} \
    file://backport-Fix-LDAP-module-leak-on-authentication-error.patch;patchdir=${PATCH_DIR} \
    file://backport-Fix-minor-logic-errors.patch;patchdir=${PATCH_DIR} \
    file://backport-Fix-type-violation-in-libkrad.patch;patchdir=${PATCH_DIR} \
    file://backport-Fix-various-small-logic-errors.patch;patchdir=${PATCH_DIR} \
    file://backport-Prevent-undefined-shift-in-decode_krb5_flags.patch;patchdir=${PATCH_DIR} \
"

# unapplicable patch from openEuler
#  file://backport-Remove-klist-s-defname-global-variable.patch;patchdir=${PATCH_DIR} 


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

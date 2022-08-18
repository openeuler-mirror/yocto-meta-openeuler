# main bb file: yocto-poky/meta/recipes-connectivity/openssl/openssl_1.1.1k.bb

# openEuler version
PV = "1.1.1m"

# patches in openEuler
SRC_URI += "\
        file://openssl-1.1.1-build.patch \
        file://openssl-1.1.1-fips.patch \
        file://CVE-2022-0778-Add-a-negative-testcase-for-BN_mod_sqrt.patch \
        file://CVE-2022-0778-Fix-possible-infinite-loop-in-BN_mod_sqrt.patch \
        file://CVE-2022-1292.patch \
        file://Backport-Support-raw-input-data-in-apps-pkeyutl.patch \
        file://Backport-Fix-no-ec-no-sm2-and-no-sm3.patch \
        file://Backport-Support-SM2-certificate-verification.patch \
        file://Backport-Guard-some-SM2-functions-with-OPENSSL_NO_SM2.patch \
        file://Backport-Add-test-cases-for-SM2-cert-verification.patch \
        file://Backport-Add-documents-for-SM2-cert-verification.patch \
        file://Backport-Fix-a-memleak-in-apps-verify.patch \
        file://Backport-Skip-the-correct-number-of-tests-if-SM2-is-disabled.patch \
        file://Backport-Make-X509_set_sm2_id-consistent-with-other-setters.patch \
        file://Backport-Support-SM2-certificate-signing.patch \
        file://Backport-Support-parsing-of-SM2-ID-in-hexdecimal.patch \
        file://Backport-Fix-a-double-free-issue-when-signing-SM2-cert.patch \
        file://Backport-Fix-a-document-description-in-apps-req.patch \
        file://Backport-Update-expired-SCT-certificates.patch \
        file://Backport-ct_test.c-Update-the-epoch-time.patch \
        file://Feature-Support-TLCP-protocol.patch \
        file://Feature-X509-command-supports-SM2-certificate-signing-with-default-sm2id.patch \
        file://CVE-2022-2068-Fix-file-operations-in-c_rehash.patch \
        file://CVE-2022-2097-Fix-AES-OCB-encrypt-decrypt-for-x86-AES-NI.patch \
"

SRC_URI[sha256sum] = "f89199be8b23ca45fc7cb9f1d8d3ee67312318286ad030f5316aca6462db6c96"

# if PACKAGECONFIG variant has perl, add perl RDEPENS
RDEPENDS_${PN}-misc = "${@bb.utils.contains('PACKAGECONFIG', 'perl', 'perl', '', d)}"

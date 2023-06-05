# main bb file: yocto-poky/meta/recipes-connectivity/openssl/openssl_1.1.1k.bb

# openEuler version
OPENEULER_SRC_URI_REMOVE = "https git http"
PV = "1.1.1m"

# patches in openEuler
SRC_URI += "\
        file://openssl-${PV}.tar.gz \
        file://openssl-1.1.1-build.patch \
        file://openssl-1.1.1-fips.patch \
        file://CVE-2022-0778-Add-a-negative-testcase-for-BN_mod_sqrt.patch \
        file://CVE-2022-0778-Fix-possible-infinite-loop-in-BN_mod_sqrt.patch \
        file://CVE-2022-1292.patch \
        file://CVE-2022-2068-Fix-file-operations-in-c_rehash.patch \
        file://CVE-2022-2097-Fix-AES-OCB-encrypt-decrypt-for-x86-AES-NI.patch \
        file://Update-expired-SCT-certificates.patch \
        file://ct_test.c-Update-the-epoch-time.patch \
        file://Fix-reported-performance-degradation-on-aarch64.patch \
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
        file://Feature-Support-TLCP-protocol.patch \
        file://Feature-X509-command-supports-SM2-certificate-signing-with-default-sm2id.patch \
        file://Feature-PKCS7-sign-and-verify-support-SM2-algorithm.patch \
        file://backport-Update-further-expiring-certificates-that-affect-tes.patch \
        file://backport-Backport-a-missing-bug-fix-from-master.patch \
        file://backport-Prevent-crash-with-engine-using-different-openssl-ru.patch \
        file://Feature-add-ARMv8-implementations-of-SM4-in-ECB-and-XTS.patch \
        file://Backport-SM3-acceleration-with-SM3-hardware-instruction-on-aa.patch \
        file://Backport-SM4-optimization-for-ARM-by-HW-instruction.patch \
        file://Feature-SM4-XTS-optimization-for-ARM-by-HW-instruction.patch \
        file://backport-Fix-a-DTLS-server-hangup-due-to-TLS13_AD_MISSING_EXT.patch \
        file://backport-Fix-an-assertion-in-the-DTLS-server-code.patch \
        file://backport-Fix-a-memory-leak-in-X509_issuer_and_serial_hash.patch \
        file://backport-Fix-strict-client-chain-check-with-TLS-1.3.patch \
        file://backport-CVE-2022-4304-Fix-Timing-Oracle-in-RSA-decryption.patch \
        file://backport-CVE-2022-4450-Avoid-dangling-ptrs-in-header-and-data-params-for-PE.patch \
        file://backport-CVE-2023-0215-Check-CMS-failure-during-BIO-setup-with-stream-is-ha.patch \
        file://backport-CVE-2023-0215-Fix-a-UAF-resulting-from-a-bug-in-BIO_new_NDEF.patch \
        file://backport-CVE-2023-0286-Fix-GENERAL_NAME_cmp-for-x400Address-1.patch \
        file://backport-test-add-test-cases-for-the-policy-resource-overuse.patch \
        file://backport-x509-excessive-resource-use-verifying-policy-constra.patch \
        file://backport-Ensure-that-EXFLAG_INVALID_POLICY-is-checked-even-in.patch \
        file://backport-Fix-documentation-of-X509_VERIFY_PARAM_add0_policy.patch \
        file://backport-Add-a-Certificate-Policies-Test.patch \
        file://backport-Generate-some-certificates-with-the-certificatePolic.patch \
"

SRC_URI[sha256sum] = "f89199be8b23ca45fc7cb9f1d8d3ee67312318286ad030f5316aca6462db6c96"

# if PACKAGECONFIG variant has perl, add perl RDEPENDS
RDEPENDS_${PN}-misc = "${@bb.utils.contains('PACKAGECONFIG', 'perl', 'perl', '', d)}"

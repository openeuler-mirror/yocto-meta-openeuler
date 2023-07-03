# main bb file from: meta/recipes-connectivity/openssl/openssl_3.0.8.bb

OPENEULER_SRC_URI_REMOVE = "https git http"

# openEuler version
PV = "3.0.8"

# conflict with openEuler patches
SRC_URI:remove = "file://CVE-2023-0464.patch \
           file://CVE-2023-0465.patch \
           file://CVE-2023-0466.patch \
           "

# patches in openEuler
SRC_URI:prepend = "file://${BP}.tar.gz \
           file://openssl-3.0-build.patch \
           file://Backport-aarch64-support-BTI-and-pointer-authentication-in-as.patch \
           file://Backport-SM3-acceleration-with-SM3-hardware-instruction-on-aa.patch \
           file://Backport-Fix-sm3ss1-translation-issue-in-sm3-armv8.pl.patch \
           file://Backport-providers-Add-SM4-GCM-implementation.patch \
           file://Backport-SM4-optimization-for-ARM-by-HW-instruction.patch \
           file://Backport-Further-acceleration-for-SM4-GCM-on-ARM.patch \
           file://Backport-SM4-optimization-for-ARM-by-ASIMD.patch \
           file://Backport-providers-Add-SM4-XTS-implementation.patch \
           file://Backport-Fix-SM4-CBC-regression-on-Armv8.patch \
           file://Backport-Fix-SM4-test-failures-on-big-endian-ARM-processors.patch \
           file://Backport-Apply-SM4-optimization-patch-to-Kunpeng-920.patch \
           file://Backport-SM4-AESE-optimization-for-ARMv8.patch \
           file://Backport-Fix-SM4-XTS-build-failure-on-Mac-mini-M1.patch \
           file://Backport-CVE-2023-0464-x509-excessive-resource-use-verifying-policy-constra.patch \
           file://Backport-test-add-test-cases-for-the-policy-resource-overuse.patch \
           file://backport-Add-a-Certificate-Policies-Test.patch \
           file://backport-Ensure-that-EXFLAG_INVALID_POLICY-is-checked-even-in.patch \
           file://backport-Generate-some-certificates-with-the-certificatePolic.patch \
           file://backport-Fix-documentation-of-X509_VERIFY_PARAM_add0_policy.patch \
           "

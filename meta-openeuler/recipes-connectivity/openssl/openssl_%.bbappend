# main bb file from: meta/recipes-connectivity/openssl/openssl_3.0.8.bb

# openEuler version
PV = "3.0.12"

# conflict with openEuler patches
SRC_URI:remove = "file://CVE-2023-0464.patch \
        file://CVE-2023-0465.patch \
        file://CVE-2023-0466.patch \
        file://0001-Configure-do-not-tweak-mips-cflags.patch \
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
        file://Backport-support-decode-SM2-parameters.patch \
        file://Feature-support-SM2-CMS-signature.patch \
        file://Feature-use-default-id-if-SM2-id-is-not-set.patch \
        file://Backport-Make-DH_check_pub_key-and-DH_generate_key-safer-yet.patch \
        file://Backport-poly1305-ppc.pl-Fix-vector-register-clobbering.patch \
        file://Backport-Limit-the-execution-time-of-RSA-public-key-check.patch \
        file://Backport-Add-NULL-checks-where-ContentInfo-data-can-be-NULL.patch \
        file://Backport-Fix-SM4-XTS-aarch64-assembly-implementation-bug.patch \
        file://fix-add-loongarch64-target.patch \
"
do_install:append () {
        #Remove the empty directory that conflict with ca-certificates.
        rm -rf ${D}${sysconfdir}/ssl/certs
}
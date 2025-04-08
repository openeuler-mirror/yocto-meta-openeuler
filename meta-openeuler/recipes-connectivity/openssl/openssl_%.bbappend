# main bb file from: meta/recipes-connectivity/openssl/openssl_3.0.8.bb

# openEuler version
PV = "3.0.12"

FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

# conflict with openEuler patches
SRC_URI:remove = "file://CVE-2023-0464.patch \
        file://CVE-2023-0465.patch \
        file://CVE-2023-0466.patch \
        file://0001-Configure-do-not-tweak-mips-cflags.patch \
"

EXTRA_OECONF:append = " enable-sm2 enable-sm4"

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
        file://backport-CVE-2024-2511-Fix-unconstrained-session-cache-growth-in-TLSv1.3.patch \
        file://backport-Add-a-test-for-session-cache-handling.patch \
        file://backport-Extend-the-multi_resume-test-for-simultaneous-resump.patch \
        file://backport-Hardening-around-not_resumable-sessions.patch \
        file://backport-Add-a-test-for-session-cache-overflow.patch \
        file://backport-CVE-2024-4603-Check-DSA-parameters-for-exce.patch \
        file://Backport-Add-a-test-for-late-loading-of-an-ENGINE-in-TLS.patch \
        file://Backport-Don-t-attempt-to-set-provider-params-on-an-ENGINE-ba.patch \
        file://Backport-CVE-2024-4741-Only-free-the-read-buffers-if-we-re-not-using-them.patch \
        file://Backport-CVE-2024-4741-Set-rlayer.packet-to-NULL-after-we-ve-finished-using.patch \
        file://Backport-CVE-2024-4741-Extend-the-SSL_free_buffers-testing.patch \
        file://Backport-CVE-2024-4741-Move-the-ability-to-load-the-dasync-engine-into-sslt.patch \
        file://Backport-CVE-2024-4741-Further-extend-the-SSL_free_buffers-testing.patch \
        file://Backport-bn-Properly-error-out-if-aliasing-return-value-with-.patch \
        file://Backport-CVE-2024-5535-Fix-SSL_select_next_proto.patch \
        file://Backport-CVE-2024-5535-Add-a-test-for-ALPN-and-NPN.patch \
"

# use openeuler style ssl env setup file
SRC_URI:append:class-nativesdk = " \
           file://environment.d-openeuler-openssl.sh \
           "

do_install:append () {
        #Remove the empty directory that conflict with ca-certificates.
        rm -rf ${D}${sysconfdir}/ssl/certs
}

do_install:append:class-nativesdk () {
        # override poky ssl env setup file
	rm -f ${D}${SDKPATHNATIVE}/environment-setup.d/openssl.sh
        install -m 644 ${WORKDIR}/environment.d-openeuler-openssl.sh ${D}${SDKPATHNATIVE}/environment-setup.d/openssl.sh
}

ASSUME_PROVIDE_PKGS ="openssl openssl-libs"

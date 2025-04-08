# main bb file from: meta/recipes-connectivity/openssl/openssl_3.0.8.bb

# openEuler version
PV = "3.0.12"

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
        file://backport-Add-FIPS_mode-compatibility-macro.patch \
        file://Backport-CVE-2024-6119-Avoid-type-errors-in-EAI-related-name-check-logic.patch \
        file://backport-Add-CTX-copy-function-for-EVP_MD-to-optimize-the-per.patch \
        file://backport-Decoder-resolution-performance-optimizations.patch \
        file://backport-Improve-performance-of-the-encoder-collection.patch \
        file://backport-evp_md_init_internal-Avoid-reallocating-algctx-if-di.patch \
        file://backport-Remove-the-_fetch_by_number-functions.patch \
        file://backport-Make-IV-buf-in-prov_cipher_ctx_st-aligned.patch \
        file://backport-ossl_namemap_name2_num-Avoid-unnecessary-OPENSSL_str.patch \
        file://backport-performance-improve-ossl_lh_strcasehash.patch \
        file://backport-01-Improve-FIPS-RSA-keygen-performance.patch \
        file://backport-02-Improve-FIPS-RSA-keygen-performance.patch \
        file://backport-When-we-re-just-reading-EX_CALLBACK-data-just-get-a-.patch \
        file://backport-Avoid-an-unneccessary-lock-if-we-didn-t-add-anything.patch \
        file://backport-use-__builtin_expect-to-improve-EVP_EncryptUpdate-pe.patch \
        file://backport-Drop-ossl_namemap_add_name_n-and-simplify-ossl_namem.patch \
        file://backport-Don-t-take-a-write-lock-to-retrieve-a-value-from-a-s.patch \
        file://backport-aes-avoid-accessing-key-length-field-directly.patch \
        file://backport-evp-enc-cache-cipher-key-length.patch \
        file://backport-Avoid-calling-into-provider-with-the-same-iv_len-or-.patch \
        file://backport-property-use-a-stack-to-efficiently-convert-index-to.patch \
        file://backport-Revert-Release-the-drbg-in-the-global-default-contex.patch \
        file://backport-Refactor-a-separate-func-for-provider-activation-fro.patch \
        file://backport-Refactor-OSSL_LIB_CTX-to-avoid-using-CRYPTO_EX_DATA.patch \
        file://backport-Release-the-drbg-in-the-global-default-context-befor.patch \
        file://backport-params-provide-a-faster-TRIE-based-param-lookup.patch \
        file://add-FIPS_mode_set-support.patch \
        file://backport-CVE-2024-9143-Harden-BN_GF2m_poly2arr-against-misuse.patch \
        file://Fix-build-error-for-ppc64le.patch \
"
do_install:append () {
        #Remove the empty directory that conflict with ca-certificates.
        rm -rf ${D}${sysconfdir}/ssl/certs
}

ASSUME_PROVIDE_PKGS ="openssl openssl-libs"

# main bbfile: yocto-poky/meta/recipes-support/gnutls/gnutls_3.7.4.bb

# version in openEuler
PV = "3.8.2"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

# files, patches from poky can't be applied to openeuler 3.8.13 (incorporates these CVEs)
SRC_URI:remove = "         file://CVE-2022-2509.patch         file://CVE-2023-0361.patch         file://CVE-2024-12243.patch         file://CVE-2025-32989.patch         file://0001-psk-fix-read-buffer-overrun-in-the-pre_shared_key-ex.patch         file://0001-x509-reject-zero-length-version-in-certificate-reque.patch         file://CVE-2025-32988.patch         file://CVE-2025-32990.patch         file://CVE-2025-6395.patch         file://CVE-2025-9820.patch         file://CVE-2025-14831-1.patch         file://CVE-2025-14831-2.patch         file://CVE-2025-14831-3.patch         file://CVE-2025-14831-4.patch         file://CVE-2025-14831-5.patch         file://CVE-2025-14831-6.patch         file://CVE-2025-14831-7.patch         file://CVE-2025-14831-8.patch         file://CVE-2025-14831-9.patch "

# 0001-Creating-.hmac-file-should-be-excuted-in-target-envi.patch and
# Add-ptest-support.patch are already in the upstream recipe SRC_URI; keeping
# them here too caused double-application on 3.8.13 source
SRC_URI:append = "         file://run-ptest "

# files, patches that come from openeuler 3.8.13
SRC_URI:append = "         file://${BP}.tar.xz         file://fix-ipv6-handshake-failed.patch "

EXTRA_OECONF:remove = "--disable-libdane                         --disable-guile "

do_compile_ptest() {
    oe_runmake -C tests buildtest-TESTS
}

do_install:append:class-target() {
        if ${@bb.utils.contains('PACKAGECONFIG', 'fips', 'true', 'false', d)}; then
          install -d ${D}${bindir}/bin
          install -m 0755 ${B}/lib/.libs/fipshmac ${D}/${bindir}/
        fi
}

DEPENDS:remove:libc-musl = "argp-standalone"
LDFLAGS:remove:libc-musl = " -largp"

PACKAGECONFIG[fips] = "--enable-fips140-mode --with-libdl-prefix=${STAGING_BASELIBDIR}"


FILES:${PN}-dane = "${libdir}/libgnutls-dane.so.*"
FILES:${PN}-fips = "${bindir}/fipshmac"

pkg_postinst_ontarget:${PN}-fips () {
    if test -x ${bindir}/fipshmac
    then
        mkdir ${sysconfdir}/gnutls
        touch ${sysconfdir}/gnutls/config
        ${bindir}/fipshmac ${libdir}/libgnutls.so.30.*.* > ${libdir}/.libgnutls.so.30.hmac
        ${bindir}/fipshmac ${libdir}/libnettle.so.8.* > ${libdir}/.libnettle.so.8.hmac
        ${bindir}/fipshmac ${libdir}/libgmp.so.10.*.* > ${libdir}/.libgmp.so.10.hmac
        ${bindir}/fipshmac ${libdir}/libhogweed.so.6.* > ${libdir}/.libhogweed.so.6.hmac
    fi
}

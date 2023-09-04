# main bbfile: yocto-poky/meta/recipes-support/gnutls/gnutls_3.7.4.bb

# version in openEuler
PV = "3.8.0"

LIC_FILES_CHKSUM = "file://LICENSE;md5=71391c8e0c1cfe68077e7fce3b586283 \
                    file://doc/COPYING;md5=1ebbd3e34237af26da5dc08a4e440464 \
                    file://doc/COPYING.LESSER;md5=4fbd65380cdd255951079008b364516c"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

# files, patches can't be applied in openeuler or conflict with openeuler
SRC_URI:remove = " \
        https://www.gnupg.org/ftp/gcrypt/gnutls/v${SHRT_VER}/gnutls-${PV}.tar.xz \
        file://CVE-2022-2509.patch \
        file://CVE-2023-0361.patch \
"

SRC_URI:append = " \
        file://0001-Creating-.hmac-file-should-be-excuted-in-target-envi.patch \
"

# files, patches that come from openeuler
SRC_URI:append = " \
        file://${BP}.tar.xz \
        file://fix-ipv6-handshake-failed.patch \
"

EXTRA_OECONF:remove = "--disable-libdane \
                        --disable-guile \
"

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

SRC_URI[sha256sum] = "0ea0d11a1660a1e63f960f157b197abe6d0c8cb3255be24e1fb3815930b9bdc5"

PACKAGECONFIG[fips] = "--enable-fips140-mode --with-libdl-prefix=${STAGING_BASELIBDIR}"
PACKAGES:append = " ${PN}-fips ${PN}-dane"

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

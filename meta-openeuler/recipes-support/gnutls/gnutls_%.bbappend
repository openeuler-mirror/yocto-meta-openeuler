# main bbfile: yocto-poky/meta/recipes-support/gnutls/gnutls_3.7.4.bb

# version in openEuler
PV = "3.7.8"

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
        file://backport-01-CVE-2023-0361.patch \
        file://backport-02-CVE-2023-0361.patch \
"

EXTRA_OECONF:remove = "--enable-local-libopts"

SRC_URI[sha256sum] = "646e6c5a9a185faa4cea796d378a1ba8e1148dbb197ca6605f95986a25af2752"

PACKAGECONFIG[fips] = "--enable-fips140-mode --with-libdl-prefix=${STAGING_BASELIBDIR}"
PACKAGES:append = " ${PN}-fips"

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

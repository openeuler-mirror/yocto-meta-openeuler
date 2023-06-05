# main bbfile: yocto-poky/meta/recipes-support/gnutls/gnutls_3.7.1.bb

# version in openEuler
PV = "3.7.2"

# files, patches can't be applied in openeuler or conflict with openeuler
SRC_URI_remove = " \
        https://www.gnupg.org/ftp/gcrypt/gnutls/v${SHRT_VER}/gnutls-${PV}.tar.xz \
"

# files, patches that come from openeuler
SRC_URI += " \
        file://${BP}.tar.xz \
        file://fix-ipv6-handshake-failed.patch \
        file://backport-CVE-2022-2509.patch \
        file://backport-CVE-2021-4209.patch \
        file://backport-01-CVE-2023-0361.patch \
        file://backport-02-CVE-2023-0361.patch \
"

EXTRA_OECONF_remove = "--enable-local-libopts"

SRC_URI[sha256sum] = "646e6c5a9a185faa4cea796d378a1ba8e1148dbb197ca6605f95986a25af2752"

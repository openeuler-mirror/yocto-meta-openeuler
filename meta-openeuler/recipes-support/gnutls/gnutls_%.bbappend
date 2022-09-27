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
"

SRC_URI[md5sum] = "95c32a1af583ecfcb280648874c0fbd9"
SRC_URI[sha256sum] = "646e6c5a9a185faa4cea796d378a1ba8e1148dbb197ca6605f95986a25af2752"

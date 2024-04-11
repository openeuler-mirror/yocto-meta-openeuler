# the main bb file: yocto-poky/meta/recipes-extended/libtirpc/libtirpc_1.3.2.bb

FILESEXTRAPATHS:append := "${THISDIR}/files/:"

PV = "1.3.4"

SRC_URI = " \
    file://${BP}.tar.bz2 \
    file://0001-update-libtirpc-to-enable-tcp-port-listening.patch \
"
SRC_URI[sha256sum] = "6474e98851d9f6f33871957ddee9714fdcd9d8a5ee9abb5a98d63ea2e60e12f3"

# sync from 1.3.4 openembedded-core/meta/recipes-extended/libtirpc/libtirpc_1.3.4.bb
SRC_URI:append = " \
        file://ipv6.patch \
"
PACKAGECONFIG ??= "\
    ${@bb.utils.filter('DISTRO_FEATURES', 'ipv6', d)} \
"
PACKAGECONFIG[ipv6] = "--enable-ipv6,--disable-ipv6"
PACKAGECONFIG[gssapi] = "--enable-gssapi,--disable-gssapi,krb5"


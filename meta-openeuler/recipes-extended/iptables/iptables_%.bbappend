# the main bb file: yocto-poky/meta/recipes-connectivity/iproute2/iproute2_5.17.0.bb

LICENSE = "GPL-2.0-or-later"

PV = "1.8.9"

OPENEULER_SRC_URI_REMOVE = "https git http"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:remove = " \
    http://netfilter.org/projects/iptables/files/iptables-${PV}.tar.bz2 \
    file://0001-configure-Add-option-to-enable-disable-libnfnetlink.patch \
    file://0002-configure.ac-only-check-conntrack-when-libnfnetlink-enabled.patch \
    file://0001-Makefile.am-do-not-install-etc-ethertypes.patch \
"

# sync 1.8.9 SRC_URI files
SRC_URI:append = " \
    file://0002-iptables-xshared.h-add-missing-sys.types.h-include.patch \
    file://0003-Makefile.am-do-not-install-etc-ethertypes.patch \
    file://0004-configure.ac-only-check-conntrack-when-libnfnetlink-.patch \
    file://format-security.patch \
"

SRC_URI:append = " \
    file://${BPN}-${PV}.tar.xz \
"
# the openeuler patch apply failed
# file://0001-extensions-NAT-Fix-for-Werror-format-security.patch

SRC_URI[sha256sum] = "ef6639a43be8325a4f8ea68123ffac236cb696e8c78501b64e8106afb008c87f"

do_configure:prepend() {
    # Remove some libtool m4 files
    # Keep ax_check_linker_flags.m4 which belongs to autoconf-archive.
    rm -f libtool.m4 lt~obsolete.m4 ltoptions.m4 ltsugar.m4 ltversion.m4

    # Copy a header to fix out of tree builds
    cp -f ${S}/libiptc/linux_list.h ${S}/include/libiptc/
}

do_install:append() {
    # if libnftnl is included, make the iptables symlink point to the nft-based binary by default
    if ${@bb.utils.contains('PACKAGECONFIG', 'libnftnl', 'true', 'false', d)} ; then
        ln -sf ${sbindir}/xtables-nft-multi ${D}${sbindir}/iptables 
    fi
}

FILES:${PN}-module-xt-ct += " ${libdir}/xtables/libxt_REDIRECT.so"
FILES:${PN}-module-xt-nat += "${libdir}/xtables/libxt_SNAT.so ${libdir}/xtables/libxt_DNAT.so ${libdir}/xtables/libxt_MASQUERADE.so"

INSANE_SKIP:${PN}-module-xt-nat = "dev-so"

# the poky bb file about PACKAGECONFIG[libnfnetlink] is "--enable-libnfnetlink,--disable-libnfnetlink,libnfnetlink libnetfilter-conntrack"
# but it will be failed in do_configure about "configure was passed unrecognised options: --disable-libnfnetlink [unknown-configure-option]"
# so delete "--disable-libnfnetlink"
PACKAGECONFIG[libnfnetlink] = "--enable-libnfnetlink,libnfnetlink libnetfilter-conntrack"

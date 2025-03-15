# the main bb file: yocto-poky/meta/recipes-connectivity/iptables/iptables_1.8.7.bb

LICENSE = "GPL-2.0-or-later"

PV = "1.8.9"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:remove = " \
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

# the openeuler patch 0001-extensions-NAT-Fix-for-Werror-format-security.patch apply failed

SRC_URI:append = " \
    file://${BP}.tar.xz \
    file://enabled-makecheck-in-extensions.patch \
    file://bugfix-add-check-fw-in-entry.patch \
    file://backport-ebtables-translate-Print-flush-command-after-parsing-is-finished.patch \
    file://backport-xtables-eb-fix-crash-when-opts-isn-t-reallocated.patch \
    file://backport-iptables-Fix-handling-of-non-existent-chains.patch \
    file://backport-Special-casing-for-among-match-in-compare_matches.patch \
    file://backport-libipt_icmp-Fix-confusion-between-255-and-any.patch \
    file://backport-fix-wrong-maptype-of-base-chain-counters-on-restore.patch \
    file://backport-Fix-checking-of-conntrack-ctproto.patch \
    file://backport-Fix-for-non-CIDR-compatible-hostmasks.patch \
    file://backport-Prevent-XTOPT_PUT-with-XTTYPE_HOSTMASK.patch \
    file://backport-libiptc-Fix-for-another-segfault-due-to-chain-index-NULL-pointer.patch \
    file://backport-libxtables-Fix-memleak-of-matches-udata.patch \
    file://backport-xshared-Fix-parsing-of-empty-string-arg-in-c-option.patch \
    file://tests-extensions-add-some-testcases.patch \
    file://backport-extensions-recent-Fix-format-string-for-unsigned-values.patch \
    file://backport-nft-cmd-Init-struct-nft_cmd-head-early.patch \
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

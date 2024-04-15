require util-linux-common.inc

# diff from upstream 2.37.4 to 2.39.1
PACKAGECONFIG[selinux] = "--with-selinux,--without-selinux,libselinux"
RRECOMMENDS:${PN}-ptest += " kernel-module-algif-hash "
ALTERNATIVE_LINK_NAME[ipcrm] = "${bindir}/ipcrm"
ALTERNATIVE_LINK_NAME[ipcs] = "${bindir}/ipcs"

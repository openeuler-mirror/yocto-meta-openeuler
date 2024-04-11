PV = "2.6.3"

FILESEXTRAPATHS:append := "${THISDIR}/${BPN}/:"

# apply patches in openeuler
SRC_URI:prepend = " \
        file://${BP}.tar.xz \
        file://0000-systemd-idmapd-require-rpc-pipefs.patch \
        file://0001-correct-the-statd-path-in-man.patch \
        file://0002-nfs-utils-set-use-gss-proxy-1-to-enable-gss-proxy-by.patch \
        file://0003-export-fix-handling-of-error-from-match_fsid.patch \
        file://0004-export-move-cache_open-before-workers-are-forked.patch \
        file://0005-gssd-fix-handling-DNS-lookup-failure.patch \
"

# patch in oe-core
SRC_URI += "file://0001-configure.ac-libevent-and-libsqlite3-checked-when-nf.patch"

# we current use rc5.d of rcS, in normal mode we don't want it autostart default for security
INITSCRIPT_PARAMS = "start 20 2 3 4 . stop 20 0 1 6 ."
INITSCRIPT_PARAMS-${PN}-client = "start 19 2 3 4 . stop 21 0 1 6 ."


# from upstream nfs-utils_2.6.2.bb, fix error:
# do_package_qa: QA Issue: /usr/sbin/rpcctl contained in package nfs-utils requires /usr/bin/python3, but no providers found in RDEPENDS:nfs-utils? [file-rdeps]
PACKAGES =+ "${PN}-rpcctl"
FILES:${PN}-rpcctl = "${sbindir}/rpcctl"
RDEPENDS:${PN}-rpcctl = "python3-core"


FILES:${PN}-client += "${libdir}/libnfsidmap.so.*"

FILES:${PN} += "${nonarch_libdir}/modprobe.d"

LDFLAGS:append = " -lsqlite3 -levent"

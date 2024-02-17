PV = "2.6.2"

# apply patches in openeuler
SRC_URI:prepend = " \
        file://${BP}.tar.xz \
        file://0000-systemd-idmapd-require-rpc-pipefs.patch \
        file://0001-correct-the-statd-path-in-man.patch \
        file://0002-nfs-utils-set-use-gss-proxy-1-to-enable-gss-proxy-by.patch \
        file://0003-fix-coredump-in-bl_add_disk.patch \
        file://0004-nfs-blkmaped-Fix-the-error-status-when-nfs_blkmapd-s.patch \
        file://0005-nfs-blkmapd-PID-file-read-by-systemd-failed.patch \
"

# not support tcp-wrappers currently
PACKAGECONFIG:remove = "tcp-wrappers"

SRC_URI[sha256sum] = "5200873e81c4d610e2462fc262fe18135f2dbe78b7979f95accd159ae64d5011"

# we current use rc5.d of rcS, in normal mode we don't want it autostart default for security
INITSCRIPT_PARAMS = "start 20 2 3 4 . stop 20 0 1 6 ."
INITSCRIPT_PARAMS-${PN}-client = "start 19 2 3 4 . stop 21 0 1 6 ."


# from upstream nfs-utils_2.6.2.bb, fix error:
# do_package_qa: QA Issue: /usr/sbin/rpcctl contained in package nfs-utils requires /usr/bin/python3, but no providers found in RDEPENDS:nfs-utils? [file-rdeps]
PACKAGES =+ "${PN}-rpcctl"
FILES:${PN}-rpcctl = "${sbindir}/rpcctl"
RDEPENDS:${PN}-rpcctl = "python3-core"

FILES:${PN} += "${nonarch_libdir}/modprobe.d"

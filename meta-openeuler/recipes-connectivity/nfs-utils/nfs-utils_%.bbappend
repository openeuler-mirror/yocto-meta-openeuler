PV = "2.5.4"

# apply patches in openeuler
SRC_URI_prepend = "file://0000-systemd-idmapd-require-rpc-pipefs.patch \
           file://0001-correct-the-statd-path-in-man.patch \
           file://0002-nfs-utils-set-use-gss-proxy-1-to-enable-gss-proxy-by.patch \
           file://0003-idmapd-Fix-error-status-when-nfs-idmapd-exits.patch \
           file://0004-fix-coredump-in-bl_add_disk.patch \
           file://0005-Fix-format-overflow-warning.patch \
           file://0006-nfs-blkmaped-Fix-the-error-status-when-nfs_blkmapd-s.patch \
           file://0007-nfs-blkmapd-PID-file-read-by-systemd-failed.patch \
           file://0008-svcgssd-Fix-use-after-free-bug-config-variables.patch \
           file://0009-rpc-pipefs-generator-allocate-enough-space-for-pipef.patch \
           file://0010-nfs-utils-Don-t-allow-junction-tests-to-trigger-auto.patch \
           file://0011-Covscan-Scan-Wrong-Check-of-Return-Value.patch \
           file://0012-rpcdebug-avoid-buffer-underflow-if-read-returns-0.patch \
           file://0013-export-Fix-rootdir-corner-case-in-next_mnt.patch \
           file://0014-Move-version.h-into-a-common-include-directory.patch \
           file://0015-mountd-only-do-NFSv4-logging-on-supported-kernels.patch \
           file://0016-libnfsidmap-try-to-get-the-domain-directly-from-host.patch \
           file://0017-Fixed-a-regression-in-the-junction-code.patch \
           file://0018-export-fix-handling-of-error-from-match_fsid.patch \
           file://0019-export-move-cache_open-before-workers-are-forked.patch \
           file://0020-gssd-fix-handling-DNS-lookup-failure.patch \
"

# fix nativesdk lib use error: /opt/buildtools/nativesdk/sysroots/x86_64-pokysdk-linux/usr/lib/libresolv.so: 
# file not recognized: file format not recognized
BUILD_LDFLAGS_remove = " -L${OPENEULER_NATIVESDK_SYSROOT}/usr/lib \
                         -L${OPENEULER_NATIVESDK_SYSROOT}/lib \
                         -Wl,-rpath-link,${OPENEULER_NATIVESDK_SYSROOT}/usr/lib \
                         -Wl,-rpath-link,${OPENEULER_NATIVESDK_SYSROOT}/lib \
                         -Wl,-rpath,${OPENEULER_NATIVESDK_SYSROOT}/usr/lib \
                         -Wl,-rpath,${OPENEULER_NATIVESDK_SYSROOT}/lib"

# not support tcp-wrappers currently
PACKAGECONFIG_remove = "tcp-wrappers"

SRC_URI[sha256sum] = "51997d94e4c8bcef5456dd36a9ccc38e231207c4e9b6a9a2c108841e6aebe3dd"

# nfs-utils-stats has a collection of python scripts
# remove the dependency of python3-core to simplify the build
# when python3 support becomes mature, remove the following code
RDEPENDS_${PN}-stats = ""

# we current use rc5.d of rcS, in normal mode we don't want it autostart default for security
INITSCRIPT_PARAMS = "start 20 2 3 4 . stop 20 0 1 6 ."
INITSCRIPT_PARAMS-${PN}-client = "start 19 2 3 4 . stop 21 0 1 6 ."

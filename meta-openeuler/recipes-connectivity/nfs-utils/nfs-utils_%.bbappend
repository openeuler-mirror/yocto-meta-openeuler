PV = "2.6.2"

# apply patches in openeuler
SRC_URI:prepend = "file://0000-systemd-idmapd-require-rpc-pipefs.patch \
        file://0001-correct-the-statd-path-in-man.patch \
        file://0002-nfs-utils-set-use-gss-proxy-1-to-enable-gss-proxy-by.patch \
        file://0003-fix-coredump-in-bl_add_disk.patch \
        file://0004-nfs-blkmaped-Fix-the-error-status-when-nfs_blkmapd-s.patch \
        file://0005-nfs-blkmapd-PID-file-read-by-systemd-failed.patch \
"

# fix nativesdk lib use error: /opt/buildtools/nativesdk/sysroots/x86_64-pokysdk-linux/usr/lib/libresolv.so: 
# file not recognized: file format not recognized
BUILD_LDFLAGS:remove = " -L${OPENEULER_NATIVESDK_SYSROOT}/usr/lib \
                         -L${OPENEULER_NATIVESDK_SYSROOT}/lib \
                         -Wl,-rpath-link,${OPENEULER_NATIVESDK_SYSROOT}/usr/lib \
                         -Wl,-rpath-link,${OPENEULER_NATIVESDK_SYSROOT}/lib \
                         -Wl,-rpath,${OPENEULER_NATIVESDK_SYSROOT}/usr/lib \
                         -Wl,-rpath,${OPENEULER_NATIVESDK_SYSROOT}/lib"

# not support tcp-wrappers currently
PACKAGECONFIG:remove = "tcp-wrappers"

SRC_URI[sha256sum] = "5200873e81c4d610e2462fc262fe18135f2dbe78b7979f95accd159ae64d5011"

# For nfs-utils-2.6.2, the following files need to be added to FILES:${PN}
FILES:${PN} += "${nonarch_libdir}/modprobe.d"

# nfs-utils-stats has a collection of python scripts
# remove the dependency of python3-core to simplify the build
# when python3 support becomes mature, remove the following code
RDEPENDS:${PN}-stats = ""

# we current use rc5.d of rcS, in normal mode we don't want it autostart default for security
INITSCRIPT_PARAMS = "start 20 2 3 4 . stop 20 0 1 6 ."
INITSCRIPT_PARAMS-${PN}-client = "start 19 2 3 4 . stop 21 0 1 6 ."

PV = "2.5.4"

# apply patches in openeuler
SRC_URI_prepend = "file://0000-systemd-idmapd-require-rpc-pipefs.patch \
           file://0001-correct-the-statd-path-in-man.patch \
           file://0002-nfs-utils-set-use-gss-proxy-1-to-enable-gss-proxy-by.patch \
           file://0003-idmapd-Fix-error-status-when-nfs-idmapd-exits.patch \
           file://0004-fix-coredump-in-bl_add_disk.patch \
"

# not support tcp-wrappers currently
PACKAGECONFIG_remove = "tcp-wrappers"

SRC_URI[sha256sum] = "51997d94e4c8bcef5456dd36a9ccc38e231207c4e9b6a9a2c108841e6aebe3dd"

# nfs-utils-stats has a collection of python scripts
# remove the dependency of python3-core to simplify the build
# when python3 support becomes mature, remove the following code
RDEPENDS_${PN}-stats = ""

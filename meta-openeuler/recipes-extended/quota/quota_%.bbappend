# main bbfile: yocto-poky/meta/recipes-extended/quota/quota_4.06.bb

# version in openEuler
PV = "4.06"

DEPENDS_remove += "dbus"
PACKAGECONFIG_remove += "tcp-wrappers"

# files, patches that come from openeuler
SRC_URI_prepend = "file://0000-Limit-number-of-comparison-characters-to-4.patch \
           file://0001-Limit-maximum-of-RPC-port.patch \
           file://0002-quotaio_xfs-Warn-when-large-kernel-timestamps-cannot.patch \
           file://0003-quota-Add-sw64-architecture.patch \
           "

SRC_URI[sha256sum] = "2f3e03039f378d4f0d97acdb49daf581dcaad64d2e1ddf129495fd579fbd268d"

#from yocto-poky/meta/recipes-extended/cronie/cronie_1.5.5.bb

OPENEULER_SRC_URI_REMOVE = "https git http"

PV = "1.6.1"

SRC_URI += " \
    file://cronie-${PV}.tar.gz \
    file://bugfix-cronie-systemd-alias.patch \
    file://backport-Support-reloading-with-SIGURG-in-addition-to-SIGHUP.patch \
"

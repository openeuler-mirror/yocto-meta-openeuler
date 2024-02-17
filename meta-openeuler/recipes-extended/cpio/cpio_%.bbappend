
PV = "2.14"

FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}/:"

# conflict patches
SRC_URI:remove = "file://0001-Unset-need_charset_alias-when-building-for-musl.patch \
           file://0002-src-global.c-Remove-superfluous-declaration-of-progr.patch \
           file://CVE-2021-38185.patch \
           "

# upstream src and patches
SRC_URI:prepend = " file://${BP}.tar.bz2 \
           "

# poky patches
SRC_URI += "file://0001-configure-Include-needed-header-for-major-minor-macr.patch"

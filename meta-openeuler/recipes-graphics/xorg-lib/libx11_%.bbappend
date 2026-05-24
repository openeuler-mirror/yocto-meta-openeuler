require openeuler-xorg-lib-common.inc

XORG_EXT = "tar.xz"

PV = "1.8.13"

SRC_URI:remove = "file://CVE-2022-3554.patch \
           file://CVE-2022-3555.patch \
           "

SRC_URI:prepend = "file://dont-forward-keycode-0.patch \
        file://libX11-1.7.2-sw_64.patch \
"

# fix error: not found keysymdef.h

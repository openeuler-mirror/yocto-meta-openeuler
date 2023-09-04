require openeuler-xorg-lib-common.inc

XORG_EXT = "tar.xz"

PV = "1.8.6"

# update LICENSE checksum
LIC_FILES_CHKSUM = "file://COPYING;md5=1d49cdd2b386c5db11ec636d680b7116"

SRC_URI:remove = "file://CVE-2022-3554.patch \
           file://CVE-2022-3555.patch \
           "

SRC_URI:prepend = "file://dont-forward-keycode-0.patch \
           "

# fix error: not found keysymdef.h
EXTRA_OECONF:class-native += "--with-keysymdefdir=${OPENEULER_NATIVESDK_SYSROOT}/usr/include/X11/"

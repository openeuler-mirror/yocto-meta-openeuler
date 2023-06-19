require openeuler-xorg-lib-common.inc

XORG_EXT = "tar.xz"

PV = "1.8.1"

SRC_URI:remove = "file://CVE-2022-3554.patch \
           file://CVE-2022-3555.patch \
           "

SRC_URI:prepend = "file://dont-forward-keycode-0.patch \
           file://backport-CVE-2022-3554.patch \
           "

SRC_URI[sha256sum] = "1bc41aa1bbe01401f330d76dfa19f386b79c51881c7bbfee9eb4e27f22f2d9f7"

# fix error: not found keysymdef.h
EXTRA_OECONF:class-native += "--with-keysymdefdir=${OPENEULER_NATIVESDK_SYSROOT}/usr/include/X11/"

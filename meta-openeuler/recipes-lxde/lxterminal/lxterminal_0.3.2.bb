SUMMARY = "Lightweight vte-based tabbed terminal emulator for LXDE"
HOMEPAGE = "http://lxde.sf.net"
SECTION = "x11"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://COPYING;md5=59530bdf33659b29e73d4adb9f9f6552"

DEPENDS = "glib-2.0 glib-2.0-native gtk+3 intltool-native vte xmlto-native"

SRC_URI = " \
    ${SOURCEFORGE_MIRROR}/lxde/lxterminal-${PV}.tar.xz \
    file://0002-man-Makefile.am-don-t-error-out-on-missing-man-depen.patch \
"
SRC_URI[md5sum] = "62e57c3aafb831505cc1638b2b737cc9"
SRC_URI[sha256sum] = "3166b18493a8e55811b02aa0de825cbbea65e2b628e69006c1a65b98e1bb4484"

EXTRA_OECONF += "--enable-gtk3 --enable-man"

FILES:${PN} += "${datadir}/icons/hicolor/128x128/apps/lxterminal.png"

inherit autotools pkgconfig gettext


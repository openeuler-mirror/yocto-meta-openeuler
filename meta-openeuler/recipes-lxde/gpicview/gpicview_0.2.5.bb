SUMMARY = "Simple Image Viewer for X"
HOMEPAGE = "http://lxde.sourceforge.net/gpicview"
SECTION = "x11"

LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = "file://COPYING;md5=59530bdf33659b29e73d4adb9f9f6552"

DEPENDS = "glib-2.0-native intltool-native jpeg"
RDEPENDS:${PN} = "adwaita-icon-theme"

SRC_URI = " \
    ${SOURCEFORGE_MIRROR}/lxde/${P}.tar.xz \
    file://remove-gdk-x11.patch \
"
SRC_URI[md5sum] = "26be9b0c5a234f1afe7d83d02a4a33f4"
SRC_URI[sha256sum] = "38466058e53702450e5899193c4b264339959b563dd5cd81f6f690de32d82942"

PACKAGECONFIG ?= "gtk3"
PACKAGECONFIG[gtk2] = ",,gtk+"
PACKAGECONFIG[gtk3] = "--enable-gtk3,,gtk+3"

inherit autotools gettext mime-xdg pkgconfig

FILES:${PN} += "${datadir}/icons/*"

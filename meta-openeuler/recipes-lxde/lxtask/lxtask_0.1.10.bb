SUMMARY = "LXDE task manager"
HOMEPAGE = "http://lxde.org/"
SECTION = "x11"

LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://COPYING;md5=b234ee4d69f5fce4486a80fdaf4a4263"

DEPENDS = "glib-2.0 glib-2.0-native intltool-native virtual/libintl"

SRC_URI = "${SOURCEFORGE_MIRROR}/lxde/lxtask-${PV}.tar.xz"
SRC_URI[md5sum] = "27b5258847afc237a5b89666e7a8b45b"
SRC_URI[sha256sum] = "2216df9bc4bb2d80733e788966512ac58c421e0a0a1ff85210f34a29d1eb4e2c"

PACKAGECONFIG ?= "gtk3"
PACKAGECONFIG[gtk3] = "--enable-gtk3,,gtk+3"
python __anonymous () {
    depends = d.getVar("DEPENDS", d, 1)
    if 'gtk3' not in d.getVar('PACKAGECONFIG', True):
        d.setVar("DEPENDS", "%s gtk+" % depends)
}

inherit autotools pkgconfig gettext

SUMMARY = "gphoto2 - a command-line frontend to libgphoto2"
HOMEPAGE = "http://www.gphoto.com/"
LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = "file://COPYING;md5=59530bdf33659b29e73d4adb9f9f6552"

DEPENDS = "libgphoto2 popt readline"
RDEPENDS:gphoto2 = "libgphoto2"

SRC_URI = "${SOURCEFORGE_MIRROR}/gphoto/gphoto2-${PV}.tar.bz2;name=gphoto2 \
           file://0001-configure.ac-remove-AM_PO_SUBDIRS.patch \
"
SRC_URI[gphoto2.sha256sum] = "be08a449bbed9613bc9db105997c4ba71410d41870496420359a99b37502c406"

inherit autotools pkgconfig gettext

EXTRA_OECONF += "--with-jpeg-prefix=${STAGING_INCDIR} \
                 --without-cdk \
"

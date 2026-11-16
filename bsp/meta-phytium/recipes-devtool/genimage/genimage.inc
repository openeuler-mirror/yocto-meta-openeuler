SUMMARY = "Image generation tool"
HOMEPAGE = "https://github.com/pengutronix/genimage"

SECTION = "base"
LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = "file://COPYING;md5=570a9b3749dd0463a1778803b12a6dce"

DEPENDS = "libconfuse"

inherit oee-archive

SRC_URI = "file://${BP}.tar.xz"

EXTRA_OECONF = "--enable-largefile --with-shell=/bin/bash"

inherit pkgconfig autotools gettext

RDEPENDS:${PN}:append:class-target = " bash"

BBCLASSEXTEND = "native nativesdk"

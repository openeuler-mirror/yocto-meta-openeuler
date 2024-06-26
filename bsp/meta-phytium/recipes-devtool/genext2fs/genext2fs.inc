SUMMARY = "Ext2 filesystem generation tool"
DESCRIPTION = "A tool to generate an ext2 filesystem \
as a normal (non-root) user."
HOMEPAGE = "http://genext2fs.sourceforge.net/"
SECTION = "console/utils"

LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = "file://COPYING;md5=94d55d512a9ba36caa9b7df079bae19f \
                    file://genext2fs.c;beginline=9;endline=17;md5=23ea077d1f7fbfd3a6fa573b415fa001"

SRC_URI = "file://v${PV}.tar.gz"
S = "${WORKDIR}/genext2fs-${PV}"

inherit autotools

BBCLASSEXTEND = "native nativesdk"

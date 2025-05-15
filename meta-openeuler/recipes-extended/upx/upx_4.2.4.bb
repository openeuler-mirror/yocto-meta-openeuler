# ref: https://github.com/UpdateHub/meta-updatehub
HOMEPAGE = "http://upx.sourceforge.net"
SUMMARY = "Ultimate executable compressor."
LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = "file://LICENSE;md5=353753597aa110e0ded3508408c6374a"
inherit pkgconfig cmake
SRC_URI = "\
    file://oee_archive/upx/upx-${PV}-src.tar.xz \
"
SRC_URI[sha256sum] = "5ed6561607d27fb4ef346fc19f08a93696fa8fa127081e7a7114068306b8e1c4"
DEPENDS = "zlib libucl xz"
S = "${WORKDIR}/upx-${PV}-src"
BBCLASSEXTEND = "native"

DESCRIPTION = "Yet Another JSON Library - A Portable JSON parsing and serialization library in ANSI C"
LICENSE = "MIT"

LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/GPL-2.0-only;md5=801f80980d171dd6425610833a22dbe6"

SRC_URI = "file://yajl/2.1.0.tar.gz \
	   file://yajl/yajl-2.1.0-pkgconfig-location.patch    \
	   file://yajl/yajl-2.1.0-pkgconfig-includedir.patch    \
	   file://yajl/yajl-2.1.0-test-location.patch    \
	   file://yajl/yajl-2.1.0-dynlink-binaries.patch    \
	   file://yajl/yajl-2.1.0-fix-memory-leak.patch    \
	  "

FILESPATH_prepend += "${LOCAL_FILES}/${BPN}:"
DL_DIR = "${LOCAL_FILES}"
S = "${WORKDIR}/${BPN}-${PV}"

inherit cmake

INHIBIT_PACKAGE_DEBUG_SPLIT = "1"
INSANE_SKIP_${PN} += "already-stripped"

FILES_${PN} += "${libdir}/libyajl.so* "

do_install_append() {
        ${STRIP} ${D}/${libdir}/*.so*
}


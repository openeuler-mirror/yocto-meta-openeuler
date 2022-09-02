DESCRIPTION = "Yet Another JSON Library - A Portable JSON parsing and serialization library in ANSI C"
LICENSE = "MIT"

LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/GPL-2.0-only;md5=801f80980d171dd6425610833a22dbe6"

SRC_URI = " \
        file://${PV}.tar.gz \
        file://0001-yajl-2.1.0-pkgconfig-location.patch \
        file://0002-yajl-2.1.0-pkgconfig-includedir.patch \
        file://0003-yajl-2.1.0-test-location.patch \
        file://0004-yajl-2.1.0-dynlink-binaries.patch \
        file://0005-yajl-2.1.0-fix-memory-leak.patch \
        file://0006-fix-memory-leak-of-ctx-root.patch \
        file://0007-add-cmake-option-for-test-and-binary.patch \
	  "

S = "${WORKDIR}/${BPN}-${PV}"

inherit cmake

INHIBIT_PACKAGE_DEBUG_SPLIT = "1"
INSANE_SKIP_${PN} += "already-stripped"
INSANE_SKIP_${PN} += "dev-so"

FILES_${PN} += "${libdir}/libyajl.so* "
FILES_SOLIBSDEV = ""

do_install_append() {
        ${STRIP} ${D}/${libdir}/*.so*
}

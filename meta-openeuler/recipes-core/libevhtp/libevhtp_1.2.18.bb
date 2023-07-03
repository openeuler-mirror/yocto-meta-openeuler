SUMMARY = "libevhtp -- Create extremely-fast and secure embedded HTTP servers with ease."
DESCRIPTION = "libevhtp -- Create extremely-fast and secure embedded HTTP servers with ease."
SECTION = "console/tools"
LICENSE = "BSD-3-Clause"

LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/GPL-2.0-only;md5=801f80980d171dd6425610833a22dbe6"

SRC_URI = "file://libevhtp/1.2.18.tar.gz \
	   file://libevhtp/0001-decrease-numbers-of-fd-for-shared-pipe-mode.patch \
	   file://libevhtp/0002-evhtp-enable-dynamic-thread-pool.patch \
	   file://libevhtp/0003-close-open-ssl.-we-do-NOT-use-it-in-lcrd.patch \
	   file://libevhtp/0004-Use-shared-library-instead-static-one.patch \
	   file://libevhtp/0005-libevhtp-add-securce-compile-options.patch \
	   file://libevhtp/0006-libevhtp-add-gcov-compile-options.patch \
	  "

S = "${WORKDIR}/${BPN}-${PV}"

DEPENDS = "libevent"

EXTRA_OECMAKE = "-DEVHTP_BUILD_SHARED=on -DEVHTP_DISABLE_SSL=on  "

inherit cmake

FILES:${PN}-dev = "${includedir}/* ${libdir}/pkgconfig/*"
#FILES:${PN}-compiler = "${bindir}"
FILES:${PN} = "${libdir}/*"

do_package_qa() {
	:
}

do_install:append () {
        [[ "${libdir}" != "/usr/lib" ]] || return 0
        if test -d ${D}/usr/lib ; then
                install -d ${D}/${libdir}
                mv ${D}/usr/lib/* ${D}/${libdir}
                rm -rf ${D}/usr/lib/
        fi
}

BBCLASSEXTEND = "native nativesdk"

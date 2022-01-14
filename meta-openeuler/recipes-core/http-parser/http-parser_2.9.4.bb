SUMMARY = "Protocol Buffers - structured data serialisation mechanism"
DESCRIPTION = "Yet Another JSON Library - A Portable JSON parsing and serialization library in ANSI C"
SECTION = "console/tools"
LICENSE = "BSD-2-Clause"

LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/GPL-2.0-only;md5=801f80980d171dd6425610833a22dbe6"

SRC_URI = "file://http-parser/http-parser-2.9.4.tar.gz"

S = "${WORKDIR}/${BPN}-${PV}"

INHIBIT_PACKAGE_DEBUG_SPLIT = "1"

DEPENDS = ""
#CFLAGS_remove = "-D_FORTIFY_SOURCE=2"
#CPPFLAGS_remove = "-D_FORTIFY_SOURCE=2"
#CXXPFLAGS_remove = "-D_FORTIFY_SOURCE=2"


inherit autotools pkgconfig

PACKAGES = "${PN}-dev ${PN}"
FILES_${PN}-dev = "${includedir}/*"
FILES_${PN} += "${libdir}/*"

do_package_qa() {
	:
}

do_compile() {
        make library
}

do_install_append () {
        [[ "${libdir}" != "/usr/local/lib" ]] || return 0
        if test -d ${D}/usr/local/lib ; then
		cd ${D}/usr/local/lib
		ln -sf libhttp_parser.so.${PV} libhttp_parser.so
		cd -
                mv ${D}/usr/local/lib ${D}/${libdir}
        fi
	if test -d ${D}/usr/local/include ; then
		mv ${D}/usr/local/include ${D}/${includedir}
	fi
	rm -rf ${D}/usr/local
}

BBCLASSEXTEND = "native nativesdk"
B = "${S}"



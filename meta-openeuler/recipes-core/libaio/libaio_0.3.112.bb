SUMMARY = "Asynchronous I/O library"
DESCRIPTION = "Asynchronous input/output library that uses the kernels native interface"
HOMEPAGE = "http://lse.sourceforge.net/io/aio.html"

LICENSE = "LGPLv2.1+"
LIC_FILES_CHKSUM = "file://COPYING;md5=d8045f3b8f929c1cb29a1e3fd737b499"

SRC_URI = "file://libaio/libaio-${PV}.tar.gz \
	   file://libaio/0001-libaio-arm64-ilp32.patch \
	   file://libaio/0002-libaio-makefile-cflags.patch \
	   file://libaio/0003-libaio-fix-for-x32.patch \
           file://00_arches.patch \
           "
EXTRA_OEMAKE =+ "prefix=${prefix} includedir=${includedir} libdir=${libdir}"

do_install () {
    oe_runmake install DESTDIR=${D}
}

BBCLASSEXTEND = "native nativesdk"

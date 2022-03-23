DESCRIPTION = "Yet Another JSON Library - A Portable JSON parsing and serialization library in ANSI C"
LICENSE = "MIT"

LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/GPL-2.0-only;md5=801f80980d171dd6425610833a22dbe6"

SRC_URI = "file://libwebsockets/${BP}.tar.gz \
           file://libwebsockets/0001-add-secure-compile-option-in-Makefile.patch \
           file://libwebsockets/0002-solve-the-BEP-problem.patch \
"

S = "${WORKDIR}/${BP}"

inherit cmake

DEPENDS = "zlib openssl"

EXTRA_OECMAKE = "-DLWS_WITH_HTTP2=ON -DLWS_IPV6=ON -DLWS_WITH_ZIP_FOPS=ON -DLWS_WITH_SOCKS5=ON -DLWS_WITH_RANGES=ON -DLWS_WITH_ACME=ON \
		-DLWS_WITH_LIBUV=OFF -DLWS_WITH_LIBEV=OFF -DLWS_WITH_LIBEVENT=OFF -DLWS_WITH_FTS=ON -DLWS_WITH_THREADPOOL=ON -DLWS_UNIX_SOCK=ON \
		-DLWS_WITH_HTTP_PROXY=ON -DLWS_WITH_DISKCACHE=ON -DLWS_WITH_LWSAC=ON -DLWS_LINK_TESTAPPS_DYNAMIC=ON -DLWS_WITHOUT_BUILTIN_GETIFADDRS=ON -DLWS_USE_BUNDLED_ZLIB=OFF \
		-DLWS_WITHOUT_BUILTIN_SHA1=ON \
    	-DLWS_WITH_STATIC=OFF \
    	-DLWS_WITHOUT_CLIENT=OFF \
    	-DLWS_WITHOUT_SERVER=OFF \
    	-DLWS_WITHOUT_TESTAPPS=OFF \
    	-DLWS_WITHOUT_TEST_SERVER=ON \
    	-DLWS_WITHOUT_TEST_SERVER_EXTPOLL=ON \
    	-DLWS_WITHOUT_TEST_PING=ON \
    	-DLWS_WITHOUT_TEST_CLIENT=ON \
		"

INHIBIT_PACKAGE_DEBUG_SPLIT = "1"

FILES_${PN} += "${libdir}/*"
INSANE_SKIP_${PN} += "already-stripped"
INSANE_SKIP_${PN} += "dev-so"
FILES_SOLIBSDEV = ""

do_install_append() {
	rm -rf ${D}/usr/share
        ${STRIP} ${D}/${libdir}/*.so*
}

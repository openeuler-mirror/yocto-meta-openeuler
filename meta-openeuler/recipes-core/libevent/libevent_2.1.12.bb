SUMMARY = "An asynchronous event notification library"
HOMEPAGE = "http://libevent.org/"
BUGTRACKER = "https://github.com/libevent/libevent/issues"
SECTION = "libs"

LICENSE = "BSD & MIT"

LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/GPL-2.0-only;md5=801f80980d171dd6425610833a22dbe6"

SRC_URI = "file://libevent/libevent-2.1.12-stable.tar.gz \
	   file://libevent/libevent-nonettests.patch \
	   file://libevent/http-add-callback-to-allow-server-to-decline-and-the.patch \
	 "

FILESPATH_prepend += "${LOCAL_FILES}/${BPN}:"
DL_DIR = "${LOCAL_FILES}"

UPSTREAM_CHECK_URI = "http://libevent.org/"

S = "${WORKDIR}/${BPN}-${PV}-stable"


DEPENDS = "zlib"

BBCLASSEXTEND = "native nativesdk"

do_configure() {
        pushd ${S}
	sh autogen.sh
	./configure --host=${HOST_SYS} --disable-openssl --prefix=/usr/
	popd
}

do_install() {
        oe_runmake DESTDIR=${D} install
}

do_package_qa() {
        :
}

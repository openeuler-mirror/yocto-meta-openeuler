DESCRIPTION = "Yet Another JSON Library - A Portable JSON parsing and serialization library in ANSI C"
LICENSE = "MIT"

LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/GPL-2.0-only;md5=801f80980d171dd6425610833a22dbe6"

SRC_URI = "file://iSulad/v2.0.9.tar.gz \
	   file://fix_bug_disable_selinux_not_selinux_label_file.patch \
	   file://delete_call_setlocale.patch \
	"

FILESPATH_prepend += "${LOCAL_FILES}/${BPN}:"
DL_DIR = "${LOCAL_FILES}"
S = "${WORKDIR}/${BPN}"

inherit cmake
OECMAKE_GENERATOR = "Unix Makefiles"

DEPENDS = "yajl zlib libarchive http-parser curl lcr libevent libevhtp openssl libwebsockets"

EXTRA_OECMAKE = "-DENABLE_GRPC=OFF -DENABLE_SYSTEMD_NOTIFY=OFF -DENABLE_SELINUX=OFF \
		-DENABLE_SHIM_V2=OFF -DENABLE_OPENSSL_VERIFY=OFF \
	 	-DGRPC_CONNECTOR=OFF -DDISABLE_OCI=ON \
		"

INHIBIT_PACKAGE_DEBUG_SPLIT = "1"

FILES_${PN} += "${libdir}/* "

do_configure_prepend() {
        grep -q CMAKE_SYSROOT ${WORKDIR}/toolchain.cmake || cat >> ${WORKDIR}/toolchain.cmake <<EOF
        set( CMAKE_SYSROOT ${STAGING_DIR_HOST} )
EOF
}

do_install_append() {
        [[ "${libdir}" != "/usr/local/lib" ]] || return 0
        if test -d ${D}/usr/local/lib; then
                mv ${D}/usr/local/lib ${D}/${libdir}
        fi
        if test -d ${D}/usr/local/include ; then
                mv ${D}/usr/local/include ${D}/${includedir}
        fi
        rm -rf ${D}/usr/local
}

do_package() {
:
}
do_package_write_rpm() {
:
}

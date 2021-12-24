DESCRIPTION = "Yet Another JSON Library - A Portable JSON parsing and serialization library in ANSI C"
LICENSE = "MIT"

LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/GPL-2.0-only;md5=801f80980d171dd6425610833a22dbe6"

SRC_URI = "file://iSulad/v2.0.10.tar.gz \
	   file://0001-fix-bug-disable-selinux-not-selinux-label-file.patch \
	   file://0002-delete-call-setlocale.patch \
	   file://0003-modify-printf-to-arm32.patch \
	   file://0004-deamon-do-not-support-attach-and-pause.patch \
	   file://0005-fix-exec-30s-exit.patch \
	   file://iSulad/0002-fix-memleak-when-use-multiple-volumes-from.patch \
	   file://iSulad/0005-delete-isulad-h-flag.patch \
	   file://iSulad/0006-Fix-memory-leak-in-ClearCniNetwork-when-calling-get_.patch \
	   file://iSulad/0007-fix-cri-libwebsockets-sync_close_sem-memory-leak.patch \
	   file://iSulad/0008-fix-cpu-variant-get-error.patch \
	   file://iSulad/0009-fix-unit-test-error-of-registry-in-armv8.patch \
	   file://iSulad/0010-Modified-cmakelist-of-storage_layer-and-added-a-new-.patch \
	   file://iSulad/0011-add-fuzz-build-in-CI.patch \ 
	   file://iSulad/0012-print-valgrind-log.patch \
	   file://iSulad/0013-fix-cri-version-memory-leak.patch \
	   file://iSulad/0014-fix-undefined-reference-in-libisulad_img.so.patch \
	   file://iSulad/0015-fix-undefined-reference-to-service_arguments_free-in.patch \
	   file://iSulad/0016-fix-mem-leak.patch \
	   file://iSulad/0017-isula-pull-does-not-support-format-name-digest.patch \
	   file://iSulad/0019-add-pull-request-gateway-checker-for-build-and-ut.patch \
	   file://iSulad/0020-Optimize-websocket-streaming-service-code.patch \
	"
FILESPATH_prepend += "${LOCAL_FILES}/${BPN}:"
DL_DIR = "${LOCAL_FILES}"
S = "${WORKDIR}/${BPN}"
WARN_QA_remove += "uppercase-pn"

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

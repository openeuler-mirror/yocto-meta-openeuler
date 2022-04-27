DESCRIPTION = "Yet Another JSON Library - A Portable JSON parsing and serialization library in ANSI C"
LICENSE = "MIT"

LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/GPL-2.0-only;md5=801f80980d171dd6425610833a22dbe6"

SRC_URI = "file://iSulad/v${PV}.tar.gz \
           file://iSulad/0001-cleancode-http-request.patch \
           file://iSulad/0002-refactor-mount-parse-in-spec-module.patch \
           file://iSulad/0003-support-isula-wait-even-if-it-s-not-oci-image.patch \
"

S = "${WORKDIR}/${BPN}-v${PV}"
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
#remove so from ${PN}-dev
FILES_SOLIBSDEV = ""

do_configure_prepend() {
        grep -q CMAKE_SYSROOT ${WORKDIR}/toolchain.cmake || cat >> ${WORKDIR}/toolchain.cmake <<EOF
        set( CMAKE_SYSROOT ${STAGING_DIR_HOST} )
EOF
}

do_install_append() {
        [[ "${libdir}" == "/usr/lib64" ]] || return 0
        if test -d ${D}/usr/lib; then
                mkdir -p ${D}/${libdir}
                mv ${D}/usr/lib/* ${D}/${libdir}
                rm -r ${D}/usr/lib/
        fi
}

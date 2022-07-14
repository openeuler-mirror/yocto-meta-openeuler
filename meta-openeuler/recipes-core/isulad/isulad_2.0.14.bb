SUMMARY = "A lightweight C++/C based container runtime daemon"
DESCRIPTION = "iSulad is a lightweight container runtime daemon which is designed for IOT and \
                Cloud infrastructure.iSulad has the characteristics of light, fast and not limited \
                by hardware specifications and architecture, and can be applied more widely"
HOMEPAGE = "https://gitee.com/openeuler/iSulad"
LICENSE = "MulanPSLv2"

LIC_FILES_CHKSUM = "file://LICENSES/LICENSE;md5=1acb172ffd3d252285dd1b8b8459941e"

SRC_URI = "file://iSulad/v${PV}.tar.gz \
           file://iSulad/0001-do-not-mkdir-of-isulad-if-no-controller-found.patch \
        "

S = "${WORKDIR}/${BPN}-v${PV}"

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

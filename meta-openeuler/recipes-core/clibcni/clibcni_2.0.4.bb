DESCRIPTION = "Yet Another JSON Library - A Portable JSON parsing and serialization library in ANSI C"
LICENSE = "MIT"

LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/GPL-2.0-only;md5=801f80980d171dd6425610833a22dbe6"

SRC_URI = "file://clibcni/v2.0.4.tar.gz \
	   file://clibcni/0001-fix-CNI_ARGS-value-when-there-is-no-args.patch \
	   file://clibcni/0002-add-error-info-for-failed-run-cni-plugin.patch \
	  "

FILESPATH_prepend += "${LOCAL_FILES}/${BPN}:"
DL_DIR = "${LOCAL_FILES}"
S = "${WORKDIR}/${BPN}"

inherit cmake
OECMAKE_GENERATOR = "Unix Makefiles"

DEPENDS = "lcr"
INHIBIT_PACKAGE_DEBUG_SPLIT = "1"


FILES_${PN} += "${libdir}/libclibcni.so* "

do_configure_prepend() {
	grep -q CMAKE_SYSROOT ${WORKDIR}/toolchain.cmake || cat >> ${WORKDIR}/toolchain.cmake <<EOF
	set( CMAKE_SYSROOT ${STAGING_DIR_HOST} )
EOF

}

do_install_append() {
	[[ "${libdir}" != "/usr/lib" ]] || return 0
	if test -d ${D}/usr/lib; then
		mv ${D}/usr/lib ${D}/${libdir}
	fi

        ${STRIP} ${D}/${libdir}/*.so*
}

INSANE_SKIP += "dev-elf"
INSANE_SKIP += "ldflags"


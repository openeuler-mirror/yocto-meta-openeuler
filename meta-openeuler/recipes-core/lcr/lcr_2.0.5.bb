DESCRIPTION = "Yet Another JSON Library - A Portable JSON parsing and serialization library in ANSI C"
LICENSE = "MIT"

LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/GPL-2.0-only;md5=801f80980d171dd6425610833a22dbe6"

SRC_URI = "file://lcr/v2.0.5.tar.gz \
	  file://lcr/0001-support-quiet-of-log-config.patch \
	  file://lcr/0002-lcr-add-inactive-file-total-metric.patch \
          file://lcr/0003-lcr-add-default-runtime-field-for-isula-info.patch \
          file://lcr/0004-support-isula-exec-workdir.patch \
          file://lcr/0005-add-secure-compile-options.patch \
          file://lcr/0006-remove-invalid-fuzz-option.patch \
          file://lcr/0007-support-cgroup-v2.patch \
          file://lcr/0008-fix-pause-container-error.patch \
          file://lcr/0009-Fix-spelling-errors.patch \
          file://lcr/0010-fix-memory-usage-of-stats-not-right-when-runtime-is-.patch \
          file://lcr/0011-support-auto-resize-of-isulad-shim.patch \
	  "

FILESPATH_prepend += "${LOCAL_FILES}/${BPN}:"
DL_DIR = "${LOCAL_FILES}"
S = "${WORKDIR}/${BPN}"

inherit cmake

OECMAKE_GENERATOR = "Unix Makefiles"

#OECMAKE_C_COMPILER += "${OECMAKE_C_FLAGS}"
#OECMAKE_CXX_COMPILER += "${OECMAKE_CXX_FLAGS}"

DEPENDS = "yajl lxc"

INHIBIT_PACKAGE_DEBUG_SPLIT = "1"

FILES_${PN} += "/usr/local/lib/* "
FILES_${PN}-dev = "/usr/local/*"
do_compile() {
	cd ${S}
	rm -rf build
	mkdir build
	cd build
	cmake --prefix=/usr/ ..
	make
}

do_install() {
	cd ${S}/build/
	oe_runmake install DESTDIR="${D}" \
                prefix="${prefix}" \
                SBINDIR="${sbindir}"
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


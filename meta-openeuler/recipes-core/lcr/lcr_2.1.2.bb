### Descriptive metadata
SUMMARY = "lcr(Lightweight Container Runtime)"
DESCRIPTION = "lcr`(Lightweight Container Runtime) is CLI tool for spawning and running containers according to \
               OCI specification. It is based on `liblxc` and written by `C`. It can use by container engine: \
               iSulad"
HOMEPAGE = "https://gitee.com/openeuler/lcr"
BUGTRACKER = "https://gitee.com/openeuler/yocto-meta-openeuler"

### License metadata
LICENSE = "LGPL-2.1-only"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/GPL-2.0-only;md5=801f80980d171dd6425610833a22dbe6"

### Inheritance and includes if needed
inherit cmake pkgconfig

### Build metadata
SRC_URI = " \
        file://v${PV}.tar.gz \
        file://0001-support-check-symbols-and-compile-code-in-cmake.patch \
        file://0002-remove-unnecessary-strerror.patch \
        file://0003-improve-code-of-function-in-log.patch \
        file://0004-support-visibility-of-compiler.patch \
        file://0005-refactor-util-buffer-and-add-ut.patch \
        file://0006-264-Support-both-C-11-and-C-17.patch \
        file://0007-262-Fix-empty-pointer-and-overflow.patch \
        file://0008-266-set-env-to-avoid-invoke-lxc-binary-directly.patch \
"

S = "${WORKDIR}/${BPN}-v${PV}"

OECMAKE_GENERATOR = "Unix Makefiles"

DEPENDS = "yajl lxc"

### Package metadata
INHIBIT_PACKAGE_DEBUG_SPLIT = "1"
#remove so from ${PN}-dev
FILES_SOLIBSDEV = ""
FILES:${PN} += "${libdir}/* "
FILES:${PN}-staticdev_riscv64 += "${libdir}/*.a"

### Tasks for package
do_configure:prepend() {
        grep -q CMAKE_SYSROOT ${WORKDIR}/toolchain.cmake || cat >> ${WORKDIR}/toolchain.cmake <<EOF
        set( CMAKE_SYSROOT ${STAGING_DIR_HOST} )
EOF
}

do_install:append() {
	[[ "${libdir}" != "/usr/lib" ]] || return 0
	if test -d ${D}/usr/lib; then
        install -d ${D}/${libdir}
		mv ${D}/usr/lib/* ${D}/${libdir}
        rm -rf ${D}/usr/lib/
	fi
        if test -d ${D}/usr/local/include ; then
                mv ${D}/usr/local/include ${D}/${includedir}
        fi
}

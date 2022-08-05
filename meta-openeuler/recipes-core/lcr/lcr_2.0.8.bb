### Descriptive metadata
SUMMARY = "lcr(Lightweight Container Runtime)"
DESCRIPTION = "lcr`(Lightweight Container Runtime) is CLI tool for spawning and running containers according to \
               OCI specification. It is based on `liblxc` and written by `C`. It can use by container engine: \
               iSulad"
HOMEPAGE = "https://gitee.com/openeuler/lcr"
BUGTRACKER = "https://gitee.com/openeuler/yocto-meta-openeuler"

### License metadata
LICENSE = "LGPLv2.1"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/GPL-2.0-only;md5=801f80980d171dd6425610833a22dbe6"

### Inheritance and includes if needed
inherit cmake

### Build metadata
SRC_URI = "file://v${PV}.tar.gz \
           file://0001-feat-Add-json-spec-for-rest-resize-api.patch \
           file://0002-add-HAVE_ISULAD-definition-for-lxc-header.patch \
           file://0003-fix-cpu-quota-out-of-range-when-update-to-1.patch \
"

S = "${WORKDIR}/${BPN}-v${PV}"

OECMAKE_GENERATOR = "Unix Makefiles"

DEPENDS = "yajl lxc"

### Package metadata
INHIBIT_PACKAGE_DEBUG_SPLIT = "1"
#remove so from ${PN}-dev
FILES_SOLIBSDEV = ""
FILES_${PN} += "${libdir}/* "

### Tasks for package
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
        if test -d ${D}/usr/local/include ; then
                mv ${D}/usr/local/include ${D}/${includedir}
        fi
}

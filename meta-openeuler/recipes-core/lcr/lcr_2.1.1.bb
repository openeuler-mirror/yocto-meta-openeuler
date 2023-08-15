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
inherit cmake

### Build metadata
SRC_URI = "file://v${PV}.tar.gz \
           file://0001-add-libisula.pc.patch \
           file://0002-add-unified-and-memory_swap_limit_in_bytes-into-host.patch \
           file://0003-fix-update-cpu-rt-period-failed.patch \
           file://0004-fix-writing-config-line-with-wrong-length.patch \
           file://0005-Add-memory-related-fields.patch \
           file://0006-mod-headers.patch \
           file://0007-add-cgroup-resources-json-schema-for-isula-update.patch \
           file://0008-add-field-for-isulad-daemon-configs.patch \
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

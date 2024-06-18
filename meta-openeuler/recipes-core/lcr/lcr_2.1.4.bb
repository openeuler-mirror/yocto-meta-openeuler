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
        file://0001-add-systemd-cgroup-field-in-isulad-and-shim-config.patch \
        file://0002-Add-http-parser-as-third-party-component.patch \
        file://0003-add-enable-pod-events-field.patch \
        file://0004-add-swap-usage-fields-in-shim-stats-and-container-in.patch \
        file://0005-Add-oomkilled-field-in-inspect.json.patch \
        file://0006-add-runtime-in-process-state.patch \
        file://0007-restore-bufsize-to-prevent-log-loss.patch \
        file://0008-support-clang-build.patch \
        file://0009-support-cdi-spec.patch \
        file://0010-remove-file-mode-check-in-ut.patch \
        file://0011-remove-lcr-created-spec-only-if-create-failed.patch \
        file://0012-Fix-info-inproper-data-type-for-timestamp.patch \
        file://0013-fix-bug-for-potential-config-seccomp-ocihook-write-e.patch \
        file://0014-add-codecheck-fix.patch \
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

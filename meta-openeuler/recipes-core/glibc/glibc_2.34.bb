SUMMARY = "GLIBC (GNU C Library)"
DESCRIPTION = "The GNU C Library is used as the system C library in most systems with the Linux kernel. \
                In openEuler, glibc is prebuilt and part of toolchain. This recipe just installs the glibc \
                binary"
HOMEPAGE = "http://www.gnu.org/software/libc/libc.html"
SECTION = "libs"
LICENSE = "GPLv2 & LGPLv2.1"

LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/GPL-2.0-only;md5=801f80980d171dd6425610833a22dbe6"

PACKAGES = "${PN} ${PN}-dev ${PN}-staticdev"

#need strip command from compiler when do_package
DEPENDS = "virtual/${TARGET_PREFIX}gcc"
PROVIDES += "virtual/libc virtual/libiconv virtual/libintl"
#RPROVIDES_${PN}-dev += "libc-dev"


INHIBIT_DEFAULT_DEPS = "1"

PR = "r1"

require ../../recipes-devtools/gcc/gcc-bin-toolchain.inc

SRC_URI_aarch64 = "file://openeuler_gcc_arm64le"
SRC_URI_arm = "file://openeuler_gcc_arm32le"

#Not strip toolchain
INHIBIT_SYSROOT_STRIP = "1"
INSANE_SKIP_${PN} += "already-stripped"

S_aarch64 = "${WORKDIR}/openeuler_gcc_arm64le"
S_arm = "${WORKDIR}/openeuler_gcc_arm32le"

PSEUDO_DISABLED = "1"

do_configure() {
	:
}

do_compile () {
	:
}

do_install() {
    install -m 0755 -d ${D}/
    install -m 0755 -d ${D}/${base_libdir}
    install -m 0755 -d ${D}/${libdir}
    cp -pPR ${S}/sysroot/* ${D}/
    chmod -R 755 ${D}/${base_libdir}
    chmod -R 755 ${D}/${libdir}
    rm -rf ${D}/etc/rpc
    rm -rf ${D}${datadir}/info
    rm -rf ${D}${base_libdir}/debug
    chown root:root ${D}/ -R
}

FILES_${PN} = " \
    ${base_libdir}/*.so \
    ${base_libdir}/*.so.* \
    ${libdir}/*.so \
    ${libdir}/*.so.* \
    ${base_sbindir}/ldconfig \
"
FILES_${PN}-staticdev = " \
    ${base_libdir}/*.a \
    ${libdir}/*.a \
"

INSANE_SKIP_${PN} += "installed-vs-shipped"
INSANE_SKIP += "dev-elf dev-so"

SYSROOT_DIRS += "/*"

BBCLASSEXTEND = "nativesdk"

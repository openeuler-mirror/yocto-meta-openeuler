SUMMARY = "GLIBC (GNU C Library)"
DESCRIPTION = "The GNU C Library is used as the system C library in most systems with the Linux kernel. \
                In openEuler, glibc is prebuilt and part of toolchain. This recipe just installs the glibc \
                binary"
HOMEPAGE = "http://www.gnu.org/software/libc/libc.html"
SECTION = "libs"
LICENSE = "GPLv2 & LGPLv2.1"

LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/GPL-2.0-only;md5=801f80980d171dd6425610833a22dbe6"

# currently, glibc just provides 3 packages:
# * glibc - runtime package,mainly includes dynamic libraries
# * glibc-dev - files used by SDK
# * glibc-static - runtime static libraries
PACKAGES = "${PN} ${PN}-dev ${PN}-staticdev"

DEPENDS = "virtual/${TARGET_PREFIX}gcc"
PROVIDES += "virtual/libc virtual/libiconv virtual/libintl"


PR = "r1"

require ../../recipes-devtools/gcc/gcc-bin-toolchain.inc

# toolchain path related configuration, to fix in the future
SRC_URI_aarch64 = "file://openeuler_gcc_arm64le"
SRC_URI_arm = "file://openeuler_gcc_arm32le"
S_aarch64 = "${WORKDIR}/openeuler_gcc_arm64le"
S_arm = "${WORKDIR}/openeuler_gcc_arm32le"

#No require on compiler and c library
INHIBIT_DEFAULT_DEPS = "1"

#No strip the symbols in .o and .a, as they are required to
#link
INHIBIT_PACKAGE_STRIP = "1"
INHIBIT_SYSROOT_STRIP = "1"

# sanity configuration
INSANE_SKIP_${PN} += "already-stripped"
INSANE_SKIP_${PN} += "installed-vs-shipped"
INSANE_SKIP += "dev-elf dev-so"

PSEUDO_DISABLED = "1"

# no configure for prebuilt toolchain
do_configure() {
	:
}

# no compile for prebuilt toolchain
do_compile () {
	:
}

# install prebuilt toolchain files to D dir
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

# glibc runtime only has dynamic libraries
FILES_${PN} = " \
    ${base_libdir}/*.so \
    ${base_libdir}/*.so.* \
    ${libdir}/*.so \
    ${libdir}/*.so.* \
    ${base_sbindir}/ldconfig \
"

# glibc-staticdev has static libraries
FILES_${PN}-staticdev = " \
    ${base_libdir}/*.a \
    ${libdir}/*.a \
"
# *noshare.a is part of glibc-dev
FILES_${PN}-staticdev_remove = " ${libdir}/libc_nonshared.a"

# .o files could be used to init, e.g., crt1.0, crti.o
# glibc-dev is required by SDK, is a complement of glibc
FILES_${PN}-dev += " \
    ${libdir}/libc_nonshared.a \
"

SYSROOT_DIRS += "/*"

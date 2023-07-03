SUMMARY = "An implementation of the standard library for Linux-based systems"
DESCRIPTION = "A new standard library to power a new generation of Linux-based devices. \
musl is lightweight, fast, simple, free, and strives to be correct in the sense of \
standards-conformance and safety."

HOMEPAGE = "http://www.musl-libc.org/"
LICENSE = "MIT"
SECTION = "libs"

LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

PACKAGES = "${PN} ${PN}-dev ${PN}-staticdev"

PROVIDES += "virtual/libc \
             virtual/libiconv \
             virtual/libintl \
             virtual/crypt \
             linux-libc-headers \
             linux-libc-headers-dev"

DEPENDS = "bsd-headers \
          libssp-nonshared \
          "
INHIBIT_DEFAULT_DEPS = "1"

PR = "r1"

INHIBIT_SYSROOT_STRIP = "1"
INSANE_SKIP:${PN} += "already-stripped"

PSEUDO_DISABLED = "1"

inherit external-toolchain

do_configure() {
        :
}

do_compile () {
        :
}

python do_install () {
    bb.build.exec_func('external_toolchain_do_install', d)
    bb.build.exec_func('musl_external_do_install_extra', d)
}

musl_external_do_install_extra(){
    # Modify musl dynamic library search path
    mkdir -p ${D}${sysconfdir}
    touch ${D}${sysconfdir}/ld-musl-aarch64.path 
    echo "${base_libdir}" > ${D}${sysconfdir}/ld-musl-aarch64.path
    echo "${libdir}" >> ${D}${sysconfdir}/ld-musl-aarch64.path
    
    # Support perf compile
    # Due to musl missing __always_inline definition
    sed -i '/#include <asm\/swab.h>/a\#include <sys/cdefs.h>' ${D}${includedir}/linux/swab.h
    sed -i '/#include <linux\/swab.h>/a\#include <sys/cdefs.h>' ${D}${includedir}/linux/byteorder/little_endian.h
    
    # Delete conflict file
    rm -f ${D}${base_libdir}/libgcc_s.so
    rm -f ${D}${base_libdir}/libgcc_s.so.1
}

do_package_qa[noexec] = "1"
EXCLUDE_FROM_SHLIBS = "1"

# In case of conflict 
FILES:${PN} = " \
    ${base_libdir}/*.so \
    ${base_libdir}/*.so.* \
    ${base_sbindir}/ldconfig \
    ${includedir}/* \
    ${libdir}/* \
    /usr/lib/* \
    ${sysconfdir}/ld-musl-aarch64.path \
"
FILES:${PN}-staticdev = " \
${base_libdir}/*.a 
"
# Add depend package
RDEPENDS:${PN} += " bsd-headers gcompat gcompat-dev"

INSANE_SKIP:${PN} += "installed-vs-shipped"
INSANE_SKIP += "dev-elf dev-so"


SYSROOT_DIRS = "/usr/*"

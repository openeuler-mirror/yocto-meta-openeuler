SUMMARY = "An implementation of the standard library for Linux-based systems"
DESCRIPTION = "A new standard library to power a new generation of Linux-based devices. \
musl is lightweight, fast, simple, free, and strives to be correct in the sense of \
standards-conformance and safety."

HOMEPAGE = "http://www.musl-libc.org/"
LICENSE = "MIT"
SECTION = "libs"

LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

PACKAGES = "${PN} ${PN}-dev ${PN}-staticdev"

PROVIDES += "virtual/libc virtual/libiconv virtual/libintl virtual/crypt"

DEPENDS = "bsd-headers \
          "
INHIBIT_DEFAULT_DEPS = "1"

PR = "r1"

INHIBIT_SYSROOT_STRIP = "1"
INSANE_SKIP_${PN} += "already-stripped"

PSEUDO_DISABLED = "1"

do_configure() {
        :
}

do_compile () {
        :
}


do_install() {
    install -m 0755 -d ${D}/
    cp -rdpRP ${EXTERNAL_TOOLCHAIN}/aarch64-openeuler-linux-musl/sysroot/* ${D}/
    rm -rf ${D}/lib64
    rm -rf ${D}/usr/lib64
    mkdir ${D}/lib64
    cp -pPR ${D}/lib/* ${D}/lib64
    mkdir ${D}/usr/lib64
    cp -pPR ${D}/usr/lib/* ${D}/usr/lib64
    rm -rf ${D}/lib64/ld-musl-aarch64.so.1
    cp ${D}/usr/lib64/libc.so ${D}/lib64/
    mv ${D}/lib64/libc.so ${D}/lib64/ld-musl-aarch64.so.1
    chmod -R 755 ${D}/${base_libdir}
    chmod -R 755 ${D}/${libdir}
    rm -rf ${D}/etc/rpc
    rm -rf ${D}${datadir}/info
    rm -rf ${D}${base_libdir}/debug
    chown root:root ${D}/ -R
}

do_package_qa[noexec] = "1"
EXCLUDE_FROM_SHLIBS = "1"

FILES_${PN} = " \
    /lib64/*.so \
    /lib64/*.so.* \
    ${base_sbindir}/ldconfig \
"
FILES_${PN}-staticdev = " \
    /lib64/*.a \
"


RDEPENDSPN_${}-dev += "bsd-headers-dev"


INSANE_SKIP_${PN} += "installed-vs-shipped"
INSANE_SKIP += "dev-elf dev-so"


SYSROOT_DIRS = "/usr/*"

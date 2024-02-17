## in openEuler Embedded, newlib is not an alternative of glibc, it's used by RTOS
## or baremetal in the case of multi-os mixed  deployment.
## Because of this, .bbappend is not used but independent bb file
SUMMARY = "Newlib is a C library intended for use on embedded systems"
HOMEPAGE = "https://sourceware.org/newlib/"
DESCRIPTION = "C library intended for use on embedded systems. It is a conglomeration of several library parts, all under free software licenses that make them easily usable on embedded products."
SECTION = "libs"

LICENSE = "GPL-2.0-only & LGPL-3.0-only & GPL-3.0-only & LGPL-2.0-only & BSD-2-Clause & TCL"

# current version
PV = "3.3.0"

# license checksum and tarball file checksum for newlib-3.3.0
# pls update when version changes
LIC_FILES_CHKSUM = " \
		file://COPYING;md5=59530bdf33659b29e73d4adb9f9f6552 \
		file://COPYING3.LIB;md5=6a6a8e020838b23406c81b19c1d46df6 \
		file://COPYING3;md5=d32239bcb673463ab874e80d47fae504 \
		file://COPYING.LIBGLOSS;md5=54b778d585443cd7fbfa1b47cbd63a89 \
		file://COPYING.LIB;md5=2d5025d4aa3495befef8f17206a5b0a1 \
		file://COPYING.NEWLIB;md5=ac17c68751aad7a5298ce3f249121070 \
		file://newlib/libc/posix/COPYRIGHT;md5=103468ff1982be840fdf4ee9f8b51bbf \
		file://newlib/libc/sys/linux/linuxthreads/LICENSE;md5=73640207fbc79b198c7ffd4ad4d97aa0 \
		"

SRC_URI = " \
		file://${BP}.tar.gz \
		file://Modify-neon-instruction.patch \
		"
SRC_URI[sha256sum] = "58dd9e3eaedf519360d92d84205c3deef0b3fc286685d1c562e245914ef72c66"

# disable pie security flags by default
SECURITY_CFLAGS = "${SECURITY_NOPIE_CFLAGS}"
SECURITY_LDFLAGS = ""

INHIBIT_DEFAULT_DEPS = "1"
DEPENDS = "virtual/${TARGET_PREFIX}gcc"

S = "${WORKDIR}/${BP}"
B = "${WORKDIR}/build"

## disable stdlib
TARGET_CC_ARCH:append = " -nostdlib"

# when to use elf, when to use eabi
# depends on toolchain and architecture
NEWLIB_OS ?= "elf"
NEWLIB_TARGET = "${TARGET_ARCH}${TARGET_VENDOR}-${NEWLIB_OS}"

EXTRA_OECONF = " \
        --build=${BUILD_SYS}  \
        --target=${NEWLIB_TARGET} \
		--host=${HOST_SYS} \
        --prefix=${prefix}  \
        --exec-prefix=${exec_prefix} \
        --bindir=${bindir} \
        --libdir=${libdir} \
        --includedir=${includedir} \
		--enable-languages=c \
		--with-newlib \
		--with-gnu-as \
		--with-gnu-ld \
		--disable-multilib \
		--disable-newlib-supplied-syscalls \
		"

do_configure[cleandirs] = "${B}"

# tell yocto do not skip newlibc
COMPATIBLE_HOST_libc-musl:class-target = ""
COMPATIBLE_HOST_libc-glibc:class-target = ""

do_configure() {
    export CC_FOR_TARGET="${CC}"
    ${S}/configure ${EXTRA_OECONF}
}

# oe_runmake will call "make -j 8 install xxx",  -j 8 will cause
# concurrency problem, so use make only.
do_install() {
	${MAKE} install DESTDIR='${D}'

	# Move include files and libs to default directories so they can be picked up later
	mv -v ${D}${prefix}/${NEWLIB_TARGET}/lib ${D}${libdir}
	mv -v ${D}${prefix}/${NEWLIB_TARGET}/include ${D}${includedir}

	# Remove original directory
	rmdir ${D}${prefix}/${NEWLIB_TARGET}
}

# put the *.specs file and cpu-init into dev package
FILES:${PN}-dev += " ${libdir}/*.specs ${libdir}/cpu-init "

# No rpm package is actually created but -dev depends on it, avoid dnf error
RDEPENDS:${PN}-dev = ""

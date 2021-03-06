SUMMARY = "System call tracing tool"
HOMEPAGE = "http://strace.io"
DESCRIPTION = "strace is a diagnostic, debugging and instructional userspace utility for Linux. It is used to monitor and tamper with interactions between processes and the Linux kernel, which include system calls, signal deliveries, and changes of process state."
SECTION = "console/utils"
LICENSE = "LGPL-2.1+ & GPL-2+"
LIC_FILES_CHKSUM = "file://COPYING;md5=318cfc887fc8723f4e9d4709b55e065b"

SRC_URI = "file://strace/strace-${PV}.tar.xz \
           file://run-ptest \
           "
SRC_URI[sha256sum] = "901bee6db5e17debad4530dd9ffb4dc9a96c4a656edbe1c3141b7cb307b11e73"

inherit autotools ptest

#PACKAGECONFIG_class-target ??= "\
#    ${@bb.utils.contains('DISTRO_FEATURES', 'bluetooth', 'bluez', '', d)} \
#"

#PACKAGECONFIG[bluez] = "ac_cv_header_bluetooth_bluetooth_h=yes,ac_cv_header_bluetooth_bluetooth_h=no,bluez5"
PACKAGECONFIG[libunwind] = "--with-libunwind,--without-libunwind,libunwind"

EXTRA_OECONF += "--enable-mpers=no --disable-gcc-Werror"

CFLAGS_append_libc-musl = " -Dsigcontext_struct=sigcontext"

TESTDIR = "tests"
PTEST_BUILD_HOST_PATTERN = "^(DEB_CHANGELOGTIME|RPM_CHANGELOGTIME|WARN_CFLAGS_FOR_BUILD|LDFLAGS_FOR_BUILD)"

do_compile_ptest() {
	oe_runmake ${PARALLEL_MAKE} -C ${TESTDIR} buildtest-TESTS
}

do_install_ptest() {
	oe_runmake -C ${TESTDIR} install-ptest BUILDDIR=${B} DESTDIR=${D}${PTEST_PATH} TESTDIR=${TESTDIR}
	mkdir -p ${D}${PTEST_PATH}/build-aux
	mkdir -p ${D}${PTEST_PATH}/src
	install -m 755 ${S}/build-aux/test-driver ${D}${PTEST_PATH}/build-aux/
	install -m 644 ${B}/src/config.h ${D}${PTEST_PATH}/src/
        sed -i -e '/^src/s/strace.*[0-9]/ptest/' ${D}/${PTEST_PATH}/${TESTDIR}/Makefile
}

RDEPENDS_${PN}-ptest += "make coreutils grep gawk sed"

RDEPENDS_${PN}-ptest_append_libc-glibc = "\
     locale-base-en-us.iso-8859-1 \
"

BBCLASSEXTEND = "native"
TOOLCHAIN = "gcc"

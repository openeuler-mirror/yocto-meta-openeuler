SUMMARY = "interface to seccomp filtering mechanism"
DESCRIPTION = "The libseccomp library provides and easy to use, platform independent,interface to the Linux Kernel's syscall filtering mechanism: seccomp."
SECTION = "security"
HOMEPAGE = "https://github.com/seccomp/libseccomp"
BUGTRACKER = "https://github.com/seccomp/libseccomp/issues"
LICENSE = "LGPL-2.1"

LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/GPL-2.0-only;md5=801f80980d171dd6425610833a22dbe6"

SRC_URI = "file://libseccomp/${BP}.tar.gz"


S = "${WORKDIR}/${BP}"

inherit autotools

FILES_${PN} = "${bindir} ${libdir}/${BPN}.so*"

do_compile_prepend() {
        cp ${B}/include/seccomp.h ${S}/include
}

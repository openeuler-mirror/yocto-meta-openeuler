### Descriptive metadata: SUMMARY,DESCRITPION, HOMEPAGE, AUTHOR, BUGTRACKER
SUMMARY = "The deploy tool of openEuler Embedded's MCS feature"
DESCRIPTION = "${SUMMARY}"
AUTHOR = ""
HOMEPAGE = "https://gitee.com/openeuler/mcs"
BUGTRACKER = "https://gitee.com/openeuler/yocto-meta-openeuler"

### License metadata
LICENSE = "MulanPSL-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=74b1b7a7ee537a16390ed514498bf23c"

### Build metadata: SRC_URI, SRCDATA, S, B, FILESEXTRAPATHS....
OPENEULER_REPO_NAME = "mcs"

SRC_URI:append:aarch64 = " \
    file://mcs \
    "
S = "${WORKDIR}/mcs"

# for x86
OPENEULER_LOCAL_NAME:x86-64 = "mcs-x86"
SRC_URI:append:x86-64 = " \
    file://mcs-x86 \
    "
S:x86-64 = "${WORKDIR}/mcs-x86"

do_fetch[depends] += "mcs-linux:do_fetch"

RDEPENDS:${PN} = "procps"

do_install:aarch64 () {
        # We may not use the Linux kernel's RemoteProc framework in the future,
        # but we are keeping this tool for now. And it is renamed to 'mica_rproc'
        # to distinguish it from the python tool.
	install -d ${D}/usr/bin
	install -m 0755 ${S}/tools/mica ${D}/usr/bin/mica_rproc
}

do_install:x86-64 () {
	install -d ${D}/usr/bin
	install -m 0755 ${S}/tools/mica ${D}/usr/bin/
}

FILES:${PN} += "${bindir}/*"
FILES:${PN} += "/lib/firmware"
INSANE_SKIP:${PN} += "already-stripped"

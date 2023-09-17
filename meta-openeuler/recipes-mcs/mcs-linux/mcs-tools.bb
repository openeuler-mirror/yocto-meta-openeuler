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

SRC_URI = " \
    file://mcs \
    "
S = "${WORKDIR}/mcs"

do_fetch[depends] += "mcs-linux:do_fetch"

do_install:aarch64 () {
	install -d ${D}/usr/bin
	install -m 0755 ${S}/tools/mica ${D}/usr/bin/

	# install rtos demo
	install -d ${D}/lib/firmware
	cp ${S}/rtos/arm64/* ${D}/lib/firmware/
}

FILES:${PN} += "/usr/bin/mica"
FILES:${PN} += "/lib/firmware"
INSANE_SKIP:${PN} += "already-stripped"

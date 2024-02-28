### Descriptive metadata: SUMMARY,DESCRITPION, HOMEPAGE, AUTHOR, BUGTRACKER
SUMMARY = "The linux side's codes of openeuler embedded's mixed criticality system related feature"
DESCRITPION = "The linux side's codes of openeuler embedded's mixed criticality system related feature"
AUTHOR = ""
HOMEPAGE = "https://gitee.com/openeuler/mcs"
BUGTRACKER = "https://gitee.com/openeuler/yocto-meta-openeuler"

SECTION = "libs"

### License metadata
LICENSE = "MulanPSL-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=74b1b7a7ee537a16390ed514498bf23c"


### Inheritance and includes if needed
inherit cmake

### Build metadata: SRC_URI, SRCDATA, S, B, FILESEXTRAPATHS....
OPENEULER_REPO_NAME = "mcs"
PV = "0.0.1"
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

EXTRA_OECMAKE:x86-64 = " \
    -DDEMO_TARGET=mica_demo \
    -DCONFIG_RING_BUFFER=y \
    -DMICA_DEBUG_LOG=y \
    "

# the software packages required in build
DEPENDS = "openamp libmetal update-rc.d-native"

# libgcc_s.so must be installed for pthread_cancel to work in rpmsg_main
RDEPENDS:${PN} = "libgcc-external"

do_install:append:aarch64 () {
    if ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'true', 'false', d)}; then
        install -d ${D}${systemd_system_unitdir}
        install -m 0644 ${S}/mica/micad/init/micad.service ${D}${systemd_system_unitdir}
    fi

    if ${@bb.utils.contains('DISTRO_FEATURES', 'sysvinit', 'true', 'false', d)}; then
        install -d ${D}${sysconfdir}/init.d
        install -d ${D}${sysconfdir}/rc5.d
        install -m 0755 ${S}/mica/micad/init/micad.init ${D}${sysconfdir}/init.d
	update-rc.d -r ${D} micad.init start 90 5 .
    fi
}

FILES:${PN} = " \
     ${bindir}/* \
     ${systemd_system_unitdir} \
     ${sysconfdir} \
"

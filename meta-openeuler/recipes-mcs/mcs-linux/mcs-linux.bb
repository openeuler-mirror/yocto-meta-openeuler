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
OPENEULER_LOCAL_NAME_x86-64 = "mcs-x86"
SRC_URI:append:x86-64 = " \
    file://mcs-x86 \
    "
S_x86-64 = "${WORKDIR}/mcs-x86"

# the software packages required in build
DEPENDS = "openamp libmetal"

# libgcc_s.so must be installed for pthread_cancel to work in rpmsg_main
RDEPENDS:${PN} = "libgcc-external"

# extra cmake options
EXTRA_OECMAKE = " \
	-DDEMO_TARGET=rpmsg_pty_demo \
	"

FILES:${PN} = " \
     ${bindir}/rpmsg_main \
"

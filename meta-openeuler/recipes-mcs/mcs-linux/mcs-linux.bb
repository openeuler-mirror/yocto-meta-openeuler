### Descriptive metadata: SUMMARY,DESCRITPION, HOMEPAGE, AUTHOR, BUGTRACKER
SUMMARY = "The linux side's codes of openeuler embedded's mixed criticality system related feature"
DESCRITPION = "The linux side's codes of openeuler embedded's mixed criticality system related feature"
AUTHOR = ""
HOMEPAGE = "https://gitee.com/openeuler/mcs"
BUGTRACKER = "https://gitee.com/openeuler/yocto-meta-openeuler"

SECTION = "libs"

### License metadata
LICENSE = "MulanPSLv2"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/MulanPSL-2.0;md5=74b1b7a7ee537a16390ed514498bf23c"


### Inheritance and includes if needed
inherit cmake


### Build metadata: SRC_URI, SRCDATA, S, B, FILESEXTRAPATHS....
PV = "0.0.1"
OPENEULER_REPO_NAME = "mcs"
OPENEULER_GIT_URL = "https://gitee.com/openeuler"
OPENEULER_BRANCH = "v0.0.1"
SRC_URI += "file://mcs"
S = "${WORKDIR}/mcs"

# the software packages required in build
DEPENDS = "openamp libmetal"

# libgcc_s.so must be installed for pthread_cancel to work in rpmsg_main
RDEPENDS:${PN} = "libgcc-external"

# extra cmake options
EXTRA_OECMAKE = " \
	-DDEMO_TARGET=rpmsg_pty_demo \
	"

FILES_${PN} = " \
     ${bindir}/rpmsg_main \
"

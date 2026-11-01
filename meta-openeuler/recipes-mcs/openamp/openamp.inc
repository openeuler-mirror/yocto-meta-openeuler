### Descriptive metadata: SUMMARY,DESCRITPION, HOMEPAGE, AUTHOR, BUGTRACKER
SUMMARY = "Open Asymmetric Multi Processing (OpenAMP) framework"
DESCRITPION = "The OpenAMP framework provides software components that enable \
               development of software applications for Asymmetric Multiprocessing \
               (AMP) systems"
AUTHOR = ""
HOMEPAGE = "https://github.com/OpenAMP/open-amp/"
BUGTRACKER = "https://gitee.com/openeuler/yocto-meta-openeuler"

### Package manager metadata: SECTION, PRIOIRTY(only for deb, opkg)
SECTION = "libs"

OPENEULER_LOCAL_NAME = "OpenAMP"

### License metadata
LICENSE = "BSD-2-Clause & BSD-3-Clause & GPL-2.0-only & Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE.md;md5=dfc0adf4d04cc738ba65b7d3f587dca5"

### Inheritance and includes if needed
inherit cmake

### Build metadata: SRC_URI, SRCDATA, S, B, FILESEXTRAPATHS....
SRC_URI = " \
	file://${BP}.tar.gz \
	file://0001-fix-CVE-2026-37540-ELF-loader-integer-overflow.patch \
	"

S = "${WORKDIR}/${BP}"

# the software packages required in build
DEPENDS = "libmetal"

# alias package name
PROVIDES = "openamp"

# extra cmake options
# rpmsg_rpc is required by mcs, only the shared library is packaged
EXTRA_OECMAKE = " \
	-DMACHINE=generic \
	-DWITH_PROXY=ON \
	-DWITH_STATIC_LIB=OFF \
	"

### Runtime metadata


### Package metadata
FILES:${PN} = " \
    ${libdir}/*.so* \
"

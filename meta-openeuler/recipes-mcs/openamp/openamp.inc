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

OPENEULER_REPO_NAME = "OpenAMP"

### License metadata
LICENSE = "BSD-2-Clause & BSD-3-Clause & GPL-2.0-only & Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE.md;md5=a8d8cf662ef6bf9936a1e1413585ecbf"

### Inheritance and includes if needed
inherit cmake

### Build metadata: SRC_URI, SRCDATA, S, B, FILESEXTRAPATHS....
SRC_URI = " \
	file://${BP}.tar.gz \
	file://0001-remoteproc-Fix-management-of-non-loadable-program-se.patch \
	"

S = "${WORKDIR}/${BP}"

# the software packages required in build
DEPENDS = "libmetal"

# alias package name
PROVIDES = "openamp"

# extra cmake options
EXTRA_OECMAKE = " \
	-DLIB_INSTALL_DIR=${libdir} \
	-DLIBEXEC_INSTALL_DIR=${libexecdir} \
	-DMACHINE=generic \
	-DWITH_PROXY=ON \
	-DWITH_APPS=ON \
	"

### Runtime metadata


### Package metadata
ALLOW_EMPTY:${PN}-demos = "1"
PACKAGES:append = " ${PN}-demos"

FILES:${PN} = " \
    ${libdir}/*.so* \
"

FILES:${PN}-demos = " \
    ${bindir}/*-shared \
"
### Tasks for package

do_install:append () {
	# Only install echo test client, matrix multiplication client,
	# and proxy app server for ZynqMP
	rm -rf ${D}/${bindir}/*-static
}

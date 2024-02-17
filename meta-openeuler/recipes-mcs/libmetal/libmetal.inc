### Descriptive metadata: SUMMARY,DESCRITPION, HOMEPAGE, AUTHOR, BUGTRACKER
SUMMARY = "Libmetal: Libmetal implements an abstraction layer across user-space Linux, baremetal, and RTOS environments"
DESCRITPION = "Libmetal provides common user APIs to access devices, handle device interrupts and request memory across \
               the following operating environments: \
                - Linux user space (based on UIO and VFIO support in the kernel) \
                - RTOS (with and without virtual memory) \
                - Bare-metal environments"
AUTHOR = ""
HOMEPAGE = "https://github.com/OpenAMP/libmetal/"
BUGTRACKER = "https://gitee.com/openeuler/yocto-meta-openeuler"
### Package manager metadata: SECTION, PRIOIRTY(only for deb, opkg)
SECTION = "libs"

### License metadata
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://LICENSE.md;md5=fe0b8a4beea8f0813b606d15a3df3d3c"

### Inheritance and includes if needed
inherit cmake

### Build metadata: SRC_URI, SRCDATA, S, B, FILESEXTRAPATHS....
SRC_URI = "file://libmetal/${BP}.tar.gz"

S = "${WORKDIR}/${BP}"

# the software packages required in build
# if user want to enable hugetlbfs support, please
# add "DEPENDS:append:pn-libmetal = " libhugetlbfs "" to your local.conf
# udev/mdev(provided by busybox) is required, may need to add it into DEPENDS
DEPENDS = "sysfsutils"

# alias package name
PROVIDES = "libmetal"

# extra cmake options
EXTRA_OECMAKE = " \
	-DWITH_EXAMPLES=ON \
    -DWITH_DOC=OFF \
	"

### Runtime metadata
#RDEPENDS:${PN} += "libudev"

### Package metadata
FILES:${PN} = " \
    ${libdir}/*.so* \
"

FILES:${PN}-dev += " \
    ${bindir}/test-* \
"

### Tasks for package

do_install:append () {
	# Only install the shared lib binaries
	rm -rf ${D}/${bindir}/*-static

	for f in `find ${D}/${bindir}/ -type f -regex ".*-shared*"`; do
		newf="`echo ${f} | sed 's/-shared*$//g'`"
		mv "${f}" "${newf}"
	done
}

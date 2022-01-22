### Descriptive metadata: SUMMARY,DESCRITPION, HOMEPAGE, AUTHOR, BUGTRACKER
SUMMARY = "Tools for working with sysfs"
DESCRIPTION = "Tools for working with the sysfs virtual filesystem.  The tool 'systool' \
                can query devices by bus, class and topology."
AUTHOR = ""
HOMEPAGE = "http://linux-diag.sourceforge.net/Sysfsutils.html"
BUGTRACKER = "https://gitee.com/openeuler/yocto-meta-openeuler"

### Package manager metadata: SECTION, PRIOIRTY(only for deb, opkg)
SECTION = "libs"

### License metadata
LICENSE = "GPLv2 & LGPLv2.1"
LICENSE_${PN} = "GPLv2"
LICENSE_libsysfs = "LGPLv2.1"
LIC_FILES_CHKSUM = "file://COPYING;md5=dcc19fa9307a50017fca61423a7d9754 \
                    file://cmd/GPL;md5=b234ee4d69f5fce4486a80fdaf4a4263 \
                    file://lib/LGPL;md5=4fbd65380cdd255951079008b364516c"

### Inheritance and includes if needed
inherit autotools

### Build metadata: SRC_URI, SRCDATA, S, B, FILESEXTRAPATHS....
SRC_URI = "file://sysfsutils/v${PV}.tar.gz "

S = "${WORKDIR}/${BPN}-${PV}"

### Runtime metadata

### Package metadata
PACKAGES =+ "libsysfs"
FILES_libsysfs = "${libdir}/lib*${SOLIBS}"

export libdir = "${base_libdir}"

### Tasks for package

SUMMARY = "Display or change ethernet card settings"
DESCRIPTION = "A small utility for examining and tuning the settings of your ethernet-based network interfaces."
HOMEPAGE = "http://www.kernel.org/pub/software/network/ethtool/"
SECTION = "console/network"
LICENSE = "GPLv2+"
LIC_FILES_CHKSUM = "file://COPYING;md5=b234ee4d69f5fce4486a80fdaf4a4263 \
                    file://ethtool.c;beginline=4;endline=17;md5=c19b30548c582577fc6b443626fc1216"

SRC_URI = "file://ethtool/ethtool-${PV}.tar.xz \
           file://run-ptest \
           file://avoid_parallel_tests.patch \
           "

SRC_URI[sha256sum] = "686fd6110389d49c2a120f00c3cd5dfe43debada8e021e4270d74bbe452a116d"

UPSTREAM_CHECK_URI = "https://gitee/src-openeuler/ethtool"

#inherit autotools ptest bash-completion pkgconfig
inherit autotools ptest

RDEPENDS_${PN}-ptest += "make"

#PACKAGECONFIG ?= "netlink"
PACKAGECONFIG[netlink] = "--disable-netlink,--disable-netlink,libmnl"
FILES_${PN}-bash-completion += "/usr/share/bash-completion/completions/*"
PACKAGES += "ethtool-bash-completion"

do_compile_ptest() {
   oe_runmake buildtest-TESTS
}

do_install_ptest () {
   cp ${B}/Makefile                 ${D}${PTEST_PATH}
   install ${B}/test-cmdline        ${D}${PTEST_PATH}
   install ${B}/ethtool             ${D}${PTEST_PATH}/ethtool
   sed -i 's/^Makefile/_Makefile/'  ${D}${PTEST_PATH}/Makefile
}

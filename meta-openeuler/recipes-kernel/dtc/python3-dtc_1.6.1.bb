SUMMARY = "Python Library for the Device Tree Compiler"
HOMEPAGE = "https://devicetree.org/"
DESCRIPTION = "A python library for the Device Tree Compiler, a tool used to manipulate Device Tree files which contain a data structure for describing hardware."
SECTION = "bootloader"
LICENSE = "GPL-2.0-only | BSD-2-Clause"

DEPENDS = "flex-native bison-native swig-native libyaml dtc"

OPENEULER_REPO_NAME = "dtc"
SRC_URI = "file://dtc-${PV}.tar.xz"

LIC_FILES_CHKSUM = "file://GPL;md5=b234ee4d69f5fce4486a80fdaf4a4263 \
                    file://pylibfdt/libfdt.i;beginline=1;endline=6;md5=afda088c974174a29108c8d80b5dce90 \
                    "

S = "${WORKDIR}/dtc-${PV}"

inherit distutils3

DISTUTILS_SETUP_PATH = "${S}/pylibfdt"

do_configure:prepend() {
    oe_runmake -C "${S}" version_gen.h
    mv "${S}/version_gen.h" "${DISTUTILS_SETUP_PATH}/"
}

BBCLASSEXTEND = "native nativesdk"

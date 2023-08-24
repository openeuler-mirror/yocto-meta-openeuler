# From meta-virtualization
SUMMARY = "Python Library for the Device Tree Compiler"
HOMEPAGE = "https://devicetree.org/"
DESCRIPTION = "A python library for the Device Tree Compiler, a tool used to manipulate Device Tree files which contain a data structure for describing hardware."
SECTION = "bootloader"
LICENSE = "GPL-2.0-only | BSD-2-Clause"

DEPENDS = "flex-native bison-native swig-native python3-setuptools-scm-native libyaml dtc"

OPENEULER_REPO_NAME = "dtc"
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI = "file://dtc-${PV}.tar.xz \
           file://0001-disable-setuptools_scm.patch \
          "

LIC_FILES_CHKSUM = "file://pylibfdt/libfdt.i;beginline=1;endline=6;md5=afda088c974174a29108c8d80b5dce90"

S = "${WORKDIR}/dtc-${PV}"

inherit setuptools3 pkgconfig

BBCLASSEXTEND = "native nativesdk"

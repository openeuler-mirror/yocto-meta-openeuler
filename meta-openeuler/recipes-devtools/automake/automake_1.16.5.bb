require automake.inc
LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = "file://COPYING;md5=751419260aa954499f7abaabaa882bbe"
DEPENDS:class-native = "autoconf-native"

NAMEVER = "${@oe.utils.trim_version("${PV}", 2)}"

RDEPENDS:${PN} += "\
    autoconf \
    perl \
    perl-module-bytes \
    perl-module-data-dumper \
    perl-module-strict \
    perl-module-text-parsewords \
    perl-module-thread-queue \
    perl-module-threads \
    perl-module-vars "

RDEPENDS:${PN}:class-native = "autoconf-native hostperl-runtime-native"

SRC_URI += "\
           file://0001-automake-Add-default-libtool_tag-to-cppasm.patch \
           file://0001-automake-Update-for-python.m4-to-respect-libdir.patch \
           file://0003-build-fix-race-in-parallel-builds.patch \
           file://0004-Add-a-new-distro-feature-ptest.patch \
           file://0005-Set-relative-to-top_builddir-path-in-Makefile-to-acc.patch \
           file://performance.patch \
           "

SRC_URI[sha256sum] = "f01d58cd6d9d77fbdca9eb4bbd5ead1988228fdb73d6f7a201f5f8d6b118b469"

do_install:append () {
    install -d ${D}${datadir}
    sed -i -e 's@^#!.*perl$@#!/usr/bin/env perl@' ${D}/${bindir}/*
}

BBCLASSEXTEND = "native nativesdk"

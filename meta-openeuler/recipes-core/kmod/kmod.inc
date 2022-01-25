# Copyright (C) 2012 Khem Raj <raj.khem@gmail.com>
# Released under the MIT license (see COPYING.MIT for the terms)

SUMMARY = "Tools for managing Linux kernel modules"
DESCRIPTION = "kmod is a set of tools to handle common tasks with Linux kernel modules like \
               insert, remove, list, check properties, resolve dependencies and aliases."
HOMEPAGE = "http://kernel.org/pub/linux/utils/kernel/kmod/"
LICENSE = "GPL-2.0+ & LGPL-2.1+"
LICENSE_libkmod = "LGPL-2.1+"
SECTION = "base"

LIC_FILES_CHKSUM = "file://COPYING;md5=a6f89e2100d9b6cdffcea4f398e37343 \
                    file://libkmod/COPYING;md5=a6f89e2100d9b6cdffcea4f398e37343 \
                    file://tools/COPYING;md5=751419260aa954499f7abaabaa882bbe \
                   "
inherit autotools pkgconfig manpages

SRC_URI = "file://kmod/${BP}.tar.xz \
           file://kmod/0001-libkmod-module-check-new_from_name-return-value-in-g.patch \
           file://kmod/0002-Module-replace-the-module-with-new-module.patch \
           file://kmod/0003-Module-suspend-the-module-by-rmmod-r-option.patch \
           file://kmod/0004-don-t-check-module-s-refcnt-when-rmmod-with-r.patch \
           file://depmod-search.conf \
           "
SRC_URI[sha256sum] = "0b80eea7aa184ac6fd20cafa2a1fdf290ffecc70869a797079e2cc5c6225a52a"

EXTRA_OECONF +=" --enable-tools --with-zlib"

PACKAGECONFIG[debug] = "--enable-debug,--disable-debug"
PACKAGECONFIG[logging] = " --enable-logging,--disable-logging"
PACKAGECONFIG[manpages] = "--enable-manpages, --disable-manpages, libxslt-native xmlto-native"
PACKAGECONFIG[xz] = "--with-xz,--without-xz,xz"
PACKAGECONFIG[openssl] = "--with-openssl,--without-openssl,openssl"

GTKDOC_DOCDIR = "${S}/libkmod/docs"

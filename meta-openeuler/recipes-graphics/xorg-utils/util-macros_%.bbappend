# main bbfile: yocto-poky/meta/recipes-graphics/xorg-util/util-macros_1.19.3.bb

OPENEULER_SRC_URI_REMOVE = "http git"

PV = "1.20.0"

LIC_FILES_CHKSUM = "file://COPYING;md5=42ba50748cb7ccf8739424e5e2072b02"

FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}/:"

SRC_URI:prepend = "file://${XORG_PN}-${PV}.tar.gz \
"

# upstream patch, update
SRC_URI += "file://0001-xorg-macros.m4.in-do-not-run-AC_CANONICAL_HOST-in-ma.patch"

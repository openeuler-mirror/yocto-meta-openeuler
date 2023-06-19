# main bb file: yocto-poky/meta/recipes-graphics/xorg-lib/libx11-compose-data_1.6.8.bb

require openeuler-xorg-lib-common.inc

XORG_EXT = "tar.xz"

# update 0001-Drop-x11-dependencies.patch to libX11-1.7.2
FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"

PV = "1.8.1"

# update LICENSE checksum
LIC_FILES_CHKSUM = "file://COPYING;md5=172255dee66bb0151435b2d5d709fcf7"

SRC_URI:prepend = "file://dont-forward-keycode-0.patch \
           file://backport-CVE-2022-3554.patch \
           "

SRC_URI[sha256sum] = "1bc41aa1bbe01401f330d76dfa19f386b79c51881c7bbfee9eb4e27f22f2d9f7"

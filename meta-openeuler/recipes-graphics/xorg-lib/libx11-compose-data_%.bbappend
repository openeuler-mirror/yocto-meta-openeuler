# main bb file: yocto-poky/meta/recipes-graphics/xorg-lib/libx11-compose-data_1.6.8.bb

require openeuler-xorg-lib-common.inc

XORG_EXT = "tar.xz"

# update 0001-Drop-x11-dependencies.patch to libX11-1.8.6
FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"

PV = "1.8.7"

# update LICENSE checksum
LIC_FILES_CHKSUM = "file://COPYING;md5=1d49cdd2b386c5db11ec636d680b7116"

SRC_URI:prepend = "file://dont-forward-keycode-0.patch \
           "

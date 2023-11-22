# main bb file: yocto-poky/meta/recipes-graphics/xorg-lib/libx11-compose-data_1.6.8.bb

OPENEULER_REPO_NAME = "libX11"
OPENEULER_SRC_URI_REMOVE = "https http git"

# update 0001-Drop-x11-dependencies.patch to libX11-1.7.2
FILESEXTRAPATHS_prepend := "${THISDIR}/${BPN}:"

PV = "1.7.2"

# update LICENSE checksum
LIC_FILES_CHKSUM = "file://COPYING;md5=172255dee66bb0151435b2d5d709fcf7"

SRC_URI_prepend = "file://libX11-1.7.2.tar.bz2 \
           file://dont-forward-keycode-0.patch \
           file://backport-makekeys-handle-the-new-EVDEVK-xorgproto-symbols.patch \
           file://libX11-1.7.2-sw_64.patch \
           file://backport-CVE-2022-3554.patch \
           file://backport-0001-CVE-2022-3555.patch \
           file://backport-0002-CVE-2022-3555.patch \
           file://backport-CVE-2023-3138.patch \
           file://backport-CVE-2023-43785.patch \
           file://backport-0001-CVE-2023-43786.patch \
           file://backport-0002-CVE-2023-43786.patch \
           file://backport-0003-CVE-2023-43786.patch \
           file://backport-CVE-2023-43787.patch \
           "

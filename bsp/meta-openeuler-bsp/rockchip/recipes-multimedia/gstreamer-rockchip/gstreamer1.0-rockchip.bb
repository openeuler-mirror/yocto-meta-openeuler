# Copyright (C) 2016 - 2017 Randy Li <ayaka@soulik.info>
# Copyright (C) 2019, Fuzhou Rockchip Electronics Co., Ltd
# Released under the GNU GENERAL PUBLIC LICENSE Version 2
# (see COPYING.GPLv2 for the terms)

include recipes-multimedia/gstreamer/gst-plugins-package.inc
include recipes-multimedia/gstreamer/gstreamer1.0-plugins-packaging.inc

DESCRIPTION = "GStreamer 1.0 plugins for Rockchip platforms"

LICENSE = "LGPL-2.1-or-later"
LIC_FILES_CHKSUM = "file://COPYING;md5=4fbd65380cdd255951079008b364516c"
DEPENDS_append = " gstreamer1.0-plugins-base"

OPENEULER_REPO_NAME = "gstreamer-rockchip"

SRC_URI = " \
    file://gstreamer-rockchip \
"

S = "${WORKDIR}/gstreamer-rockchip"

PATCHPATH = "${THISDIR}/files"
inherit auto-patch

inherit meson pkgconfig

PACKAGECONFIG ??= "mpp ${@bb.utils.filter('DISTRO_FEATURES', 'x11', d)} rga"

PACKAGECONFIG[mpp] = "-Drockchipmpp=enabled,-Drockchipmpp=disabled,rockchip-mpp"
PACKAGECONFIG[x11] = "-Drkximage=enabled,-Drkximage=disabled,libx11 libdrm"
PACKAGECONFIG[rga] = "-Drga=enabled,-Drga=disabled,rockchip-librga"

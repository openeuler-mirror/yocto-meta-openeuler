# Copyright (C) 2019, Fuzhou Rockchip Electronics Co., Ltd
# Released under the MIT license (see COPYING.MIT for the terms)
DESCRIPTION = "Rockchip RGA 2D graphics acceleration library"
SECTION = "libs"

LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://COPYING;md5=89aea4e17d99a7cacdbeed46a0096b10"

SRC_URI = " \
	file://rockchip-librga \
"

S = "${WORKDIR}/rockchip-librga"

DEPENDS = "libdrm"

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit meson pkgconfig

EXTRA_OEMESON = "-Dlibdrm=true"

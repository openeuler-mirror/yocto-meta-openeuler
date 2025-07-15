# Copyright (C) 2019, Fuzhou Rockchip Electronics Co., Ltd
# Released under the MIT license (see COPYING.MIT for the terms)

PATCHPATH = "${CURDIR}/u-boot-rockchip"
inherit auto-patch

inherit python3-dir

require recipes-bsp/u-boot/u-boot.inc
require recipes-bsp/u-boot/u-boot-common.inc

# PROVIDES = "virtual/bootloader"

DEPENDS += "bc-native dtc-native"

OPENEULER_REPO_NAMES = "rk-binary-native u-boot-rockchip"

PV = "2017.09"

LIC_FILES_CHKSUM = "file://Licenses/README;md5=a2c678cfd4a4d97135585cad908541c6"

FILEEXTRAPATHS:prepend := "${THISDIR}/files"

SRC_URI = " \
	file://u-boot-rockchip \
	file://rk-binary-native;destsuffix=u-boot-rockchip/ \
"

S = "${WORKDIR}/u-boot-rockchip"

SRCREV_FORMAT = "default_rk-binary-native"

DEPENDS:append = " ${PYTHON_PN}-native"

# Needed for packing BSP u-boot
DEPENDS:append = " coreutils-native ${PYTHON_PN}-pyelftools-native"

do_unpack:append() {
    bb.build.exec_func('do_copy_rkbin_source', d)
}

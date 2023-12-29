# Copyright (C) 2020, Rockchip Electronics Co., Ltd
# Released under the MIT license (see COPYING.MIT for the terms)

DESCRIPTION = "Rockchip ALSA config files"
SECTION = "multimedia"

LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://NOTICE;md5=9645f39e9db895a4aa6e02cb57294595"
OPENEULER_REPO_NAME = "rockchip-alsa-config"
SRC_URI = " \
    file://rockchip-alsa-config \
"
S = "${WORKDIR}/rockchip-alsa-config"

inherit meson

FILES_${PN} = "*"

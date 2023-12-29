# Copyright (C) 2016 - 2017 Randy Li <ayaka@soulik.info>
# Copyright (C) 2019, Fuzhou Rockchip Electronics Co., Ltd
# Released under the GNU GENERAL PUBLIC LICENSE Version 2
# (see COPYING.GPLv2 for the terms)

LICENSE = "Apache-2.0 & MIT"
LIC_FILES_CHKSUM = " \
	file://LICENSES/Apache-2.0;md5=7f43e699e0a26fae98c2938092f008d2 \
	file://LICENSES/MIT;md5=e8f57dd048e186199433be2c41bd3d6d"

OPENEULER_REPO_NAME = "rockchip-mpp"

SRC_URI = " \
    file://rockchip-mpp \
"

S = "${WORKDIR}/rockchip-mpp"

inherit pkgconfig cmake

EXTRA_OECMAKE = " \
    -DRKPLATFORM=ON \
    -DHAVE_DRM=ON \
"

CFLAGS_append = " -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64"

PACKAGES = "${PN}-demos ${PN}-dbg ${PN}-staticdev ${PN}-dev ${PN} ${PN}-vpu"
FILES_${PN}-vpu = "${libdir}/lib*vpu${SOLIBS}"
FILES_${PN} = "${libdir}/lib*mpp${SOLIBS}"
FILES_${PN}-dev = "${libdir}/lib*${SOLIBSDEV} ${includedir} ${libdir}/pkgconfig"
FILES_${PN}-demos = "${bindir}/*"
SECTION_${PN}-dev = "devel"
FILES_${PN}-staticdev = "${libdir}/*.a"
SECTION_${PN}-staticdev = "devel"

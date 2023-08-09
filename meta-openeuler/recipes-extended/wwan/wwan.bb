#
# SPDX-License-Identifier: MIT
# This file Copyright (C) 2018, 2020-2021 Anton Kikin <a.kikin@tano-systems.com>
#
PR = "tano5"

DESCRIPTION = "Generic OpenWrt 3G/4G proto handler"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://LICENSE;md5=801f80980d171dd6425610833a22dbe6"
SECTION = "net/misc"

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}/patches:${THISDIR}/${PN}/files:"

SRC_URI += "\
	file://wwan.sh \
	file://wwan.usb \
	file://wwan.usbmisc \
	file://LICENSE \
"

S = "${WORKDIR}"

SRC_URI[data.md5sum] = "477aabf75258536005d58aef9b0d59d8"

inherit allarch

do_configure[noexec] = "1"
do_compile[noexec] = "1"
do_fetch[cleandirs] += "${WORKDIR}/data"

do_install:append() {
	install -dm 0755 ${D}/lib/netifd/proto
	install -m 0755 ${WORKDIR}/wwan.sh ${D}/lib/netifd/proto/wwan.sh

	install -dm 0755 ${D}${sysconfdir}/hotplug.d/usb
	install -m 0755 ${WORKDIR}/wwan.usb ${D}${sysconfdir}/hotplug.d/usb/00_wwan.sh

	install -dm 0755 ${D}${sysconfdir}/hotplug.d/usbmisc
	install -m 0755 ${WORKDIR}/wwan.usbmisc ${D}${sysconfdir}/hotplug.d/usbmisc/00_wwan.sh

	install -dm 0755 ${D}/lib/network/wwan

	#
	# In order to keep the GIT repo free of filenames with colons,
	# we name the files xxxx-yyyy and rename here after copying to the build directory
	#
	for filevar in ${WORKDIR}/data/*-*
	do
		[ -f "$filevar" ] || continue
		FILENAME=$(basename $filevar)
		NEWFILENAME=${FILENAME//-/:}
		cp "${WORKDIR}/data/${FILENAME}" \
		   "${D}/lib/network/wwan/${NEWFILENAME}"
	done
}

FILES:${PN} += "${sysconfidir}/ /lib/"

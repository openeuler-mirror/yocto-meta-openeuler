SUMMARY = "ZedBoard PL bitstream, OLED banner and their boot services"
DESCRIPTION = "Installs the vendor PL bitstream into /lib/firmware, the boot \
service that programs the PL through the kernel FPGA manager, and the \
'openEuler Embedded' banner shown on the on-board OLED."
LICENSE = "CLOSED"

inherit systemd

COMPATIBLE_MACHINE = "zedboard"

SRC_URI = " \
    file://zedboard-pl.service \
    file://zedboard-oled-banner.service \
    file://oled-banner.bin \
"

S = "${WORKDIR}"

ZEDBOARD_BITSTREAM ?= "${THISDIR}/../../files/bitstream/system.bit.bin"

do_install() {
	install -d ${D}${systemd_system_unitdir}
	install -m 0644 ${WORKDIR}/zedboard-pl.service ${D}${systemd_system_unitdir}/
	install -m 0644 ${WORKDIR}/zedboard-oled-banner.service ${D}${systemd_system_unitdir}/

	install -d ${D}${datadir}/zedboard
	install -m 0644 ${WORKDIR}/oled-banner.bin ${D}${datadir}/zedboard/oled-banner.bin

	if [ -f "${ZEDBOARD_BITSTREAM}" ]; then
		install -d ${D}${nonarch_base_libdir}/firmware
		install -m 0644 "${ZEDBOARD_BITSTREAM}" ${D}${nonarch_base_libdir}/firmware/system.bit.bin
	else
		bbwarn "ZEDBOARD_BITSTREAM (${ZEDBOARD_BITSTREAM}) not found; PL fallback loader disabled"
	fi
}

FILES:${PN} += " \
    ${nonarch_base_libdir}/firmware/system.bit.bin \
    ${datadir}/zedboard/oled-banner.bin \
"

SYSTEMD_SERVICE:${PN} = "zedboard-pl.service zedboard-oled-banner.service"
SYSTEMD_AUTO_ENABLE:${PN} = "enable"

RDEPENDS:${PN} += "zedboard-pl pmodoled-gpio"
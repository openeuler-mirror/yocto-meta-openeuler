SUMMARY = "ZedBoard small user I/O helpers"
DESCRIPTION = "Userspace helpers for the ZedBoard user LEDs and slide switches. \
zed-marquee cycles the LEDs (started once at boot via a timer), \
zed-switch-led mirrors the switches onto the LEDs and is run manually."
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

inherit systemd

COMPATIBLE_MACHINE = "zedboard"

SRC_URI = " \
    file://zed-marquee \
    file://zed-switch-led \
    file://zedboard-marquee.service \
    file://zedboard-marquee.timer \
"

S = "${WORKDIR}"

do_install() {
	install -d ${D}${bindir}
	install -m 0755 ${WORKDIR}/zed-marquee ${D}${bindir}/
	install -m 0755 ${WORKDIR}/zed-switch-led ${D}${bindir}/

	install -d ${D}${systemd_system_unitdir}
	install -m 0644 ${WORKDIR}/zedboard-marquee.service ${D}${systemd_system_unitdir}/
	install -m 0644 ${WORKDIR}/zedboard-marquee.timer ${D}${systemd_system_unitdir}/
}

FILES:${PN} += "${systemd_system_unitdir}/zedboard-marquee.service"

SYSTEMD_SERVICE:${PN} = "zedboard-marquee.timer"
SYSTEMD_AUTO_ENABLE:${PN} = "enable"
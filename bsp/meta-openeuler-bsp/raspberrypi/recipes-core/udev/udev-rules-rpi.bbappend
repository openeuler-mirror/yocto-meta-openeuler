
SRC_URI:remove = "git://github.com/RPi-Distro/raspberrypi-sys-mods;protocol=https;branch=master \
"

FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

SRC_URI:append = " \
        file://99-com.rules \
"

do_install () {
    install -d ${D}${sysconfdir}/udev/rules.d
    install -m 0644 ${WORKDIR}/99-com.rules ${D}${sysconfdir}/udev/rules.d/
    install -m 0644 ${WORKDIR}/can.rules ${D}${sysconfdir}/udev/rules.d/
}
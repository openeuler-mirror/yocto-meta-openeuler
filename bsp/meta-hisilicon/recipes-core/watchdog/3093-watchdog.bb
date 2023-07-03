DESCRIPTION = "Close Hi3093 Watchdog"
SECTION = "base"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

DEPENDS = " update-rc.d-native"

SRC_URI = "file://close_wdog.sh \
           "

#INITSCRIPT_NAME = "close_wdog.sh"
#INITSCRIPT_PARAMS = "start 16 5 ."

FILES:${PN} = "${sysconfdir}"

do_install () {
	install -d ${D}${sysconfdir}/init.d
	install -d ${D}${sysconfdir}/rc5.d

	install -m 0755 ${WORKDIR}/close_wdog.sh ${D}${sysconfdir}/init.d/
	update-rc.d -r ${D} close_wdog.sh start 90 5 .
}

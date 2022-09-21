SUMMARY = "Automatic file system expansion"
DESCRIPTION = "Expand file system to use all the space on the card at first boot"
SECTION = "base"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

RDEPENDS_${PN} = "parted util-linux-findmnt e2fsprogs-resize2fs"

# As the recipe doesn't inherit systemd.bbclass, we need to set this variable
# manually to avoid unnecessary postinst/preinst generated.
python __anonymous() {
    if not bb.utils.contains('DISTRO_FEATURES', 'sysvinit', True, False, d):
        d.setVar("INHIBIT_UPDATERCD_BBCLASS", "1")
}

inherit update-rc.d

# init_resize.sh: perform the partition resize
# resize2fs_once: resize file system at first boot
# reference: https://github.com/RPi-Distro/raspi-config/blob/master/usr/lib/raspi-config/init_resize.sh
SRC_URI = "file://init_resize.sh \
           file://resize2fs_once \
           "

INITSCRIPT_NAME = "resize2fs_once"
INITSCRIPT_PARAMS = "defaults"

S = "${WORKDIR}"

FILES_${PN} = "/usr/lib/init_resize.sh ${sysconfdir}/init.d/resize2fs_once"

do_install () {
	install -d ${D}${sysconfdir}/init.d/
	install -d ${D}/usr/lib/
	install -m 0755 ${WORKDIR}/resize2fs_once ${D}${sysconfdir}/init.d/
	install -m 0755 ${WORKDIR}/init_resize.sh ${D}/usr/lib/
}

ALLOW_EMPTY_${PN} = "1"

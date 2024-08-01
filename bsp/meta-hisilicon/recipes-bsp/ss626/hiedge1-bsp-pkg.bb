DESCRIPTION = "Some pre-compiled ko and initscripts for hiedge1"
SECTION = "base"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

DEPENDS = "update-rc.d-native"

OPENEULER_LOCAL_NAME = "HiEdge-driver"

RT_SUFFIX = "${@bb.utils.contains('DISTRO_FEATURES', 'preempt-rt', '-rt', '', d)}"

SRC_URI = " \
        file://HiEdge-driver/drivers/ko.tar.gz \
"

S = "${WORKDIR}/HiEuler-driver/drivers"

INSANE_SKIP:${PN} += "already-stripped"
FILES:${PN} = "${sysconfdir} ${systemd_system_unitdir} /usr/bin /ko /vendor /usr/sbin /firmware ${libdir}"

do_install () {
    cp -r ${WORKDIR}/ko ${D}/
}

INHIBIT_PACKAGE_STRIP = "1"
INHIBIT_SYSROOT_STRIP = "1"

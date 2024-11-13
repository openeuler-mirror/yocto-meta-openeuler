DESCRIPTION = "Some pre-compiled ko and initscripts for hipico"
SECTION = "base"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

DEPENDS = "update-rc.d-native"

OPENEULER_LOCAL_NAME = "hipico_hardware_driver"

SRC_URI = " file://hipico_hardware_driver \
        ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', ' file://hipico-bsp.service ', '', d)} \
"

S = "${WORKDIR}/hipico_hardware_driver"

INSANE_SKIP:${PN} += "already-stripped"
FILES:${PN} = "${sysconfdir} ${systemd_system_unitdir} /usr/sbin /ko /etc /root"

do_compile () {
    pushd ${S}/reg-tools-1.0.0
    oe_runmake
    popd
}

do_install () {
    install -d ${D}${sysconfdir}/init.d

    install -m 0755 ${S}/drivers/S90AutoRun.sh ${D}${sysconfdir}/init.d/
    if ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'true', 'false', d)}; then
        install -d ${D}${systemd_system_unitdir}
        install -m 0644 ${WORKDIR}/hipico-bsp.service ${D}${systemd_system_unitdir}
    else
        update-rc.d -r ${D} S90AutoRun.sh start 90 5 .
    fi

    install -d ${D}/ko/wifi
	
    cp ${S}/ko/* ${D}/ko -r
    cp ${S}/drivers/ws73/etc/* ${D}${sysconfdir}/ -r
    cp ${S}/drivers/ws73/ko/* ${D}/ko/wifi/
    install -d ${D}/usr/sbin
    install -m 0755 ${S}/drivers/ws73/bin/sparklinkctrl ${D}/usr/sbin
    install -m 0755 ${S}/drivers/ws73/bin/sparklinkd ${D}/usr/sbin
	
    install -d ${D}/usr/sbin
    cp ${S}/reg-tools-1.0.0/bin/* ${D}/usr/sbin

    install -d ${D}/root
    cp ${S}/scripts/* ${D}/root/
	
    cp -rf ${S}/Wireless ${D}/etc/
}

INHIBIT_PACKAGE_STRIP = "1"
INHIBIT_SYSROOT_STRIP = "1"

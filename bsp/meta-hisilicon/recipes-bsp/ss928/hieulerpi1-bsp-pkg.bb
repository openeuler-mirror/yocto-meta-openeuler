DESCRIPTION = "Some pre-compiled ko and initscripts for hieulerpi1"
SECTION = "base"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

DEPENDS = "update-rc.d-native"
DEPENDS += " ${@bb.utils.contains('DISTRO_FEATURES', 'kernel6', 'hieulerpi1-sdk-pkg', '', d)} "
do_fetch[depends] += "${@bb.utils.contains('DISTRO_FEATURES', 'kernel6', 'hieulerpi1-sdk-pkg:do_deploy', '', d)}"

OPENEULER_LOCAL_NAME = "HiEuler-driver"

RT_SUFFIX = "${@bb.utils.contains('DISTRO_FEATURES', 'preempt-rt', '-rt', '', d)}"

SRC_URI = " \
    ${@bb.utils.contains('DISTRO_FEATURES', 'kernel6', ' \
        file://${DEPLOY_DIR}/third_party_sdk/ko.tar.gz \
    ', ' \
        file://HiEuler-driver/drivers/ko${RT_SUFFIX}.tar.gz \ 
        file://HiEuler-driver/drivers/ko-extra.tar.gz \
    ', d)} \
        file://HiEuler-driver/drivers/btools \
        file://HiEuler-driver/drivers/S90AutoRun \
        file://HiEuler-driver/drivers/pinmux.sh \
        file://HiEuler-driver/drivers/env.tar.gz \
        file://HiEuler-driver/drivers/can-tools.tar.gz \
        file://HiEuler-driver/drivers/ws73.tar.gz \
        file://HiEuler-driver/drivers/sparklink-tools.tar.gz \
        file://HiEuler-driver/mcu \
        ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', ' file://hieulerpi1-bsp.service file://hieulerpi1-fb.service ', '', d)} \
"

S = "${WORKDIR}/HiEuler-driver/drivers"

INSANE_SKIP:${PN} += "already-stripped"
FILES:${PN} = "${sysconfdir} ${systemd_system_unitdir} /usr/bin /ko /vendor /usr/sbin /firmware ${libdir}"

do_install () {
    install -d ${D}/usr/bin
    install -d ${D}${libdir}
    install -d ${D}/firmware
    install -d ${D}${sysconfdir}/init.d
    install -d ${D}${sysconfdir}/rc5.d

    install -m 0755 ${WORKDIR}/HiEuler-driver/drivers/btools ${D}/usr/bin/
    ln -s /usr/bin/btools ${D}/usr/bin/bspmm
    ln -s /usr/bin/btools ${D}/usr/bin/i2c_read
    ln -s /usr/bin/btools ${D}/usr/bin/i2c_write
    if [ -e ${WORKDIR}/ko-extra/pre_vo ];then
        install -m 0755 ${WORKDIR}/ko-extra/pre_vo ${D}/usr/bin/
    fi

    cp -r ${WORKDIR}/ko ${D}/
    if [ -e ${WORKDIR}/ko-extra/ch343.ko ];then
        cp -f ${WORKDIR}/ko-extra/ch343.ko ${D}/ko
    fi

    #for mipi, use load_ss928v100 from ko-extra
    if [ -e ${WORKDIR}/ko-extra/load_ss928v100 ];then
        cp -f ${WORKDIR}/ko-extra/load_ss928v100 ${D}/ko
        # optimize awk format which may not recognized
        sed -i 's/\$1\/1024\/1024/strtonum(\$1)\/1024\/1024/' ${D}/ko/load_ss928v100*
        chmod 755 ${D}/ko/load_ss928v100
    fi

    # install wifi-1102a firmware
    if [ -e ${WORKDIR}/wifi-1102a-tools ];then
        cp -f ${WORKDIR}/wifi-1102a-tools/plat.ko ${D}/ko
        cp -f ${WORKDIR}/wifi-1102a-tools/wifi.ko ${D}/ko
        install -m 0755 ${WORKDIR}/wifi-1102a-tools/start_wifi ${D}/usr/bin/
        install -d ${D}/vendor
        cp -rf ${WORKDIR}/wifi-1102a-tools/vendor/* ${D}/vendor
    fi

    install -m 0755 ${S}/S90AutoRun ${D}${sysconfdir}/init.d/
    install -m 0755 ${S}/pinmux.sh ${D}${sysconfdir}/init.d/

    # workaround for 6.6 new version, just load sdk ko, other ko need pack later
    if [ -e ${WORKDIR}/ko/load_sdk_driver ];then
	echo "#!/bin/sh" > ${D}${sysconfdir}/init.d/S90AutoRun
	echo "/ko/load_sdk_driver -i" >> ${D}${sysconfdir}/init.d/S90AutoRun
    fi

    if ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'true', 'false', d)}; then
        install -d ${D}${systemd_system_unitdir}
        install -m 0644 ${WORKDIR}/hieulerpi1-bsp.service ${D}${systemd_system_unitdir}
        install -m 0644 ${WORKDIR}/hieulerpi1-fb.service ${D}${systemd_system_unitdir}
        if ${@bb.utils.contains('DISTRO_FEATURES', 'kernel6', 'true', 'false', d)}; then
            # enable auto start
            install -d ${D}${sysconfdir}/systemd/system/multi-user.target.wants/
            ln -sf ${systemd_system_unitdir}/hieulerpi1-bsp.service ${D}${sysconfdir}/systemd/system/multi-user.target.wants/hieulerpi1-bsp.service
            ln -sf ${systemd_system_unitdir}/hieulerpi1-fb.service ${D}${sysconfdir}/systemd/system/multi-user.target.wants/hieulerpi1-fb.service
        fi
    else
        update-rc.d -r ${D} S90AutoRun start 90 5 .
        update-rc.d -r ${D} pinmux.sh start 90 5 .
    fi

    install -m 0755 ${WORKDIR}/env/fw_env.config ${D}/etc/
    install -m 0755 ${WORKDIR}/env/fw_printenv ${D}/usr/bin/
    install -m 0755 ${WORKDIR}/env/fw_setenv ${D}/usr/bin/

    cp -r ${WORKDIR}/can-tools/canutils/sbin ${D}/usr/
    cp -r ${WORKDIR}/can-tools/canutils/bin/* ${D}/usr/bin/
    cp -r ${WORKDIR}/can-tools/libsocketcan/lib/* ${D}${libdir}

    install -m 0755 ${WORKDIR}/HiEuler-driver/mcu/load_riscv ${D}/usr/sbin
    install -m 0755 ${WORKDIR}/HiEuler-driver/mcu/virt-tty ${D}/usr/sbin
    install -m 0755 ${WORKDIR}/HiEuler-driver/mcu/LiteOS.bin ${D}/firmware

    install -d ${D}${sysconfdir}/ws73
    cp ${WORKDIR}/ws73/firmware/* ${D}${sysconfdir}/ws73/
    cp ${WORKDIR}/ws73/ko/* ${D}/ko/
    cp ${WORKDIR}/ws73/config/* ${D}${sysconfdir}/

    install -m 0755 ${WORKDIR}/sparklink-tools/sparklinkd ${D}/usr/sbin
    install -m 0755 ${WORKDIR}/sparklink-tools/sparklinkctrl ${D}/usr/sbin
}

INHIBIT_PACKAGE_STRIP = "1"
INHIBIT_SYSROOT_STRIP = "1"

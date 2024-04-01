DESCRIPTION = "Some pre-compiled ko and initscripts for sd3403"
SECTION = "base"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

DEPENDS = "update-rc.d-native"

OPENEULER_LOCAL_NAME = "HiEuler-driver"

SRC_URI = " \
        file://HiEuler-driver/drivers/ko.tar.gz \
        file://HiEuler-driver/drivers/ko-extra.tar.gz \
        file://HiEuler-driver/drivers/btools \
        file://HiEuler-driver/drivers/S90AutoRun \
        file://HiEuler-driver/drivers/pinmux.sh \
        file://HiEuler-driver/drivers/env.tar.gz \
        file://HiEuler-driver/drivers/can-tools.tar.gz \
	file://HiEuler-driver/drivers/ws73.tar.gz \
        file://HiEuler-driver/mcu \
"

S = "${WORKDIR}/HiEuler-driver/drivers"

INSANE_SKIP:${PN} += "already-stripped"
FILES:${PN} = "${sysconfdir} /usr/bin /ko /vendor /usr/sbin /firmware ${libdir}"

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
        install -m 0755 ${WORKDIR}/ko-extra/pre_vo ${D}/usr/bin/

        cp -r ${WORKDIR}/ko ${D}/
        cp -f ${WORKDIR}/ko-extra/ch343.ko ${D}/ko

        #for mipi, use load_ss928v100 from ko-extra
        cp -f ${WORKDIR}/ko-extra/load_ss928v100 ${D}/ko

        # install wifi-1102a firmware
        # cp -f ${WORKDIR}/wifi-1102a-tools/plat.ko ${D}/ko
        # cp -f ${WORKDIR}/wifi-1102a-tools/wifi.ko ${D}/ko
        # install -m 0755 ${WORKDIR}/wifi-1102a-tools/start_wifi ${D}/usr/bin/
        # install -d ${D}/vendor
        # cp -rf ${WORKDIR}/wifi-1102a-tools/vendor/* ${D}/vendor

        install -m 0755 ${S}/S90AutoRun ${D}${sysconfdir}/init.d/
        install -m 0755 ${S}/pinmux.sh ${D}${sysconfdir}/init.d/
        update-rc.d -r ${D} S90AutoRun start 90 5 .
        update-rc.d -r ${D} pinmux.sh start 90 5 .

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
}

INHIBIT_PACKAGE_STRIP = "1"
INHIBIT_SYSROOT_STRIP = "1"

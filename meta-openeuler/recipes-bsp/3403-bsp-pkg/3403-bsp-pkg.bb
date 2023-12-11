DESCRIPTION = "Some pre-compiled ko and initscripts for sd3403"
SECTION = "base"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

# dep linux-sd3403 to make 3rdparty_openeuler download first
DEPENDS = "update-rc.d-native linux-sd3403"

OPENEULER_LOCAL_NAME = "3rdparty_ss928v100_v2.0.2.2"

# old: 3rdparty_ss928v100_v2.0.2.2/org/smp/a55_linux/mpp/out/ko
SRC_URI = " \
        file://3rdparty_openeuler/drivers/ko.tar.gz \
        file://3rdparty_openeuler/drivers/ko-extra.tar.gz \
        file://3rdparty_ss928v100_v2.0.2.2/patch/sdt/btools \
        file://S90autorun \
        file://rohm_400M.sh \
"

S = "${WORKDIR}/3rdparty_ss928v100_v2.0.2.2/org/smp/a55_linux/mpp/out"

#INITSCRIPT_NAME = "close_wdog.sh"
#INITSCRIPT_PARAMS = "start 16 5 ."

INSANE_SKIP:${PN} += "already-stripped"
FILES:${PN} = "${sysconfdir} /usr/bin /ko"

do_install () {
        install -d ${D}/usr/bin
        install -d ${D}${sysconfdir}/init.d
        install -d ${D}${sysconfdir}/rc5.d

        install -m 0755 ${WORKDIR}/3rdparty_ss928v100_v2.0.2.2/patch/sdt/btools ${D}/usr/bin/
        ln -s /usr/bin/btools ${D}/usr/bin/bspmm
        ln -s /usr/bin/btools ${D}/usr/bin/i2c_read
        ln -s /usr/bin/btools ${D}/usr/bin/i2c_write
        install -m 0755 ${WORKDIR}/ko-extra/pre_vo ${D}/usr/bin/

        cp -r ${WORKDIR}/ko ${D}/
        cp -f ${WORKDIR}/ko-extra/ch343.ko ${D}/ko
        #for mipi, use load_ss928v100 from ko-extra
        cp -f ${WORKDIR}/ko-extra/load_ss928v100 ${D}/ko

        install -m 0755 ${WORKDIR}/S90autorun ${D}${sysconfdir}/init.d/
        install -m 0755 ${WORKDIR}/rohm_400M.sh ${D}${sysconfdir}/init.d/
        update-rc.d -r ${D} S90autorun start 90 5 .
}

INHIBIT_PACKAGE_STRIP = "1"
INHIBIT_SYSROOT_STRIP = "1"


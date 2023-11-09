DESCRIPTION = "Some pre-compiled ko and initscripts for sd3403"
SECTION = "base"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

DEPENDS = "update-rc.d-native"

OPENEULER_LOCAL_NAME = "3rdparty_ss928v100_v2.0.2.2"

SRC_URI = " \
        file://3rdparty_ss928v100_v2.0.2.2/org/smp/a55_linux/mpp/out/ko \
        file://3rdparty_ss928v100_v2.0.2.2/patch/sdt/btools \
        file://S90autorun \
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

        cp -r ${S}/ko ${D}/

        install -m 0755 ${WORKDIR}/S90autorun ${D}${sysconfdir}/init.d/
        update-rc.d -r ${D} S90autorun start 90 5 .
}

INHIBIT_PACKAGE_STRIP = "1"
INHIBIT_SYSROOT_STRIP = "1"


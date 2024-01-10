SUMMARY = "dsp_bin"
DESCRIPTION = "dsp_bin from hipirobot hieuler_dsp_sample"
HOMEPAGE = "hipirobot/hieuler_dsp_sample.git"
LICENSE = "CLOSED"

OPENEULER_LOCAL_NAME = "hieuler_dsp_sample"

SRC_URI = " \
        file://hieuler_dsp_sample/depth_to_laser_without_ground \
"

S = "${WORKDIR}/hieuler_dsp_sample/depth_to_laser_without_ground"

do_install:append() {
    install -d ${D}/root/
    cp -rf -P ${S}/dsp_bin ${D}/root/
}

FILES:${PN} = " \
    /root/dsp_bin \
"
 
INSANE_SKIP:${PN} += "already-stripped dev-deps"


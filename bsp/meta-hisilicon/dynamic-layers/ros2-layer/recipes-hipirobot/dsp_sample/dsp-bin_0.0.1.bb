SUMMARY = "dsp_bin"
DESCRIPTION = "dsp_bin from hipirobot hieuler_dsp_sample"
HOMEPAGE = "hipirobot/hieuler_dsp_sample.git"
LICENSE = "None"

LIC_FILES_CHKSUM = "file://readme.md;md5=c123bba26da35145e5f695f4b38ed2dc"

OPENEULER_LOCAL_NAME = "hieuler_dsp_sample"

SRC_URI = " \
        file://hieuler_dsp_sample/dsp \
"

S = "${WORKDIR}/hieuler_dsp_sample/dsp"

do_install:append() {
    install -d ${D}/root/
    cp -rf -P ${S}/dsp_bin ${D}/root/
}

FILES:${PN} = " \
    /root/dsp_bin \
"
 
INSANE_SKIP:${PN} += "already-stripped dev-deps"


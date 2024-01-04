SUMMARY = "dsp_bin"
DESCRIPTION = "dsp_bin from hipirobot hirobot_component_hw_accelerate"
HOMEPAGE = "hipirobot/hirobot_component_hw_accelerate.git"
LICENSE = "None"

LIC_FILES_CHKSUM = "file://readme.md;md5=c123bba26da35145e5f695f4b38ed2dc"

OPENEULER_LOCAL_NAME = "hirobot_component_hw_accelerate"

SRC_URI = " \
        file://hirobot_component_hw_accelerate/dsp \
"

S = "${WORKDIR}/hirobot_component_hw_accelerate/dsp"

do_install:append() {
    install -d ${D}/root/
    cp -rf -P ${S}/dsp_bin ${D}/root/
}

FILES:${PN} = " \
    /root/dsp_bin \
"
 
INSANE_SKIP:${PN} += "already-stripped dev-deps"


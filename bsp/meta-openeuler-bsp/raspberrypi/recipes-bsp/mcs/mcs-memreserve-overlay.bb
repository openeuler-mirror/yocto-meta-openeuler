SUMMARY = "mcs reservemem dtoverlay generator for Raspberry Pi 4 "
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://${THISDIR}/files/COPYING;md5=12f884d2ae1ff87c09e5b7ccc2c4ca7e"

SRC_URI = " \
        file://mcs-memreserve-overlay.dts \
        "

DEPENDS += "dtc-native"

inherit deploy nopackages

do_compile() {
    dtc -I dts -O dtb ${WORKDIR}/mcs-memreserve-overlay.dts -o ${WORKDIR}/mcs-memreserve.dtbo
}

do_deploy() {
    install -m 0644 ${WORKDIR}/mcs-memreserve.dtbo ${DEPLOYDIR}/
}

addtask deploy before do_build after do_install
do_deploy[dirs] += "${DEPLOYDIR}"

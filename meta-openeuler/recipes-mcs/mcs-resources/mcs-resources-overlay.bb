SUMMARY = "mcs resources dts overlay generator"
DESCRIPTION = " use dts overlay mechanism to reserve resources for client OS"
LICENSE = "MulanPSLv2"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/MulanPSL-2.0;md5=74b1b7a7ee537a16390ed514498bf23c"

SRC_URI = " \
        file://mcs-resources-overlay.dts \
        "

DEPENDS += "dtc-native"

inherit deploy nopackages

MCS_PSCI_METHOD = "hvc"
MCS_MEM_AT ?= "70000000"
MCS_MEM_START ?= "0x70000000"
MCS_MEM_SIZE ?= "0x10000000"

do_compile() {

    # fill dts with user defined parameters
    sed -i 's|MCS_MEM_AT|${MCS_MEM_AT}|' ${WORKDIR}/mcs-resources-overlay.dts
    sed -i 's|MCS_MEM_START|${MCS_MEM_START}|' ${WORKDIR}/mcs-resources-overlay.dts
    sed -i 's|MCS_MEM_SIZE|${MCS_MEM_SIZE}|' ${WORKDIR}/mcs-resources-overlay.dts
    sed -i 's|MCS_PSCI_METHOD|${MCS_PSCI_METHOD}|' ${WORKDIR}/mcs-resources-overlay.dts

    # generate dtbo
    dtc -I dts -O dtb ${WORKDIR}/mcs-resources-overlay.dts -o ${WORKDIR}/mcs-resources.dtbo
}

do_deploy() {
    install -m 0644 ${WORKDIR}/mcs-resources.dtbo ${DEPLOYDIR}/
}

addtask deploy before do_build after do_install
do_deploy[dirs] += "${DEPLOYDIR}"

inherit deploy

DEPENDS += "dtc-native"

SRC_URI += " \
        file://mcs-resources-overlay.dts \
        "

MCS_MEM_AT ?= "70000000"
MCS_MEM_START ?= "0x70000000"
MCS_MEM_SIZE ?= "0x10000000"

do_compile_mcs_dts_overlay() {

    # fill dts with user defined parameters
    sed -i 's|MCS_MEM_AT|${MCS_MEM_AT}|' ${WORKDIR}/mcs-resources-overlay.dts
    sed -i 's|MCS_MEM_START|${MCS_MEM_START}|' ${WORKDIR}/mcs-resources-overlay.dts
    sed -i 's|MCS_MEM_SIZE|${MCS_MEM_SIZE}|' ${WORKDIR}/mcs-resources-overlay.dts

    # generate dtbo
    dtc -I dts -O dtb ${WORKDIR}/mcs-resources-overlay.dts -o ${WORKDIR}/mcs-resources.dtbo
}

do_deploy() {

    if [ -e ${DEPLOYDIR}/mcs-resources.dtbo ];then
        rm ${DEPLOYDIR}/mcs-resources.dtbo
    fi

    install -m 0644 ${WORKDIR}/mcs-resources.dtbo ${DEPLOYDIR}/
}

addtask do_compile_mcs_dts_overlay after do_compile before do_deploy
addtask do_deploy after do_compile_mcs_dts_overlay before do_install

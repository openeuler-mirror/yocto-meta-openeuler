inherit deploy

DEPENDS += "dtc-native"

SRC_URI += " \
        file://mcs-resources-overlay.dts \
        "

do_compile_mcs_dts_overlay() {
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

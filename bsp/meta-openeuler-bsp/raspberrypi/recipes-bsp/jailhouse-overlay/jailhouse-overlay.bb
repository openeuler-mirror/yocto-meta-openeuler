inherit deploy

DEPENDS += "dtc-native"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI += " \
        file://${BPN}.dts \
        "

do_compile() {
    # generate dtbo
    dtc -I dts -O dtb ${WORKDIR}/${BPN}.dts -o ${WORKDIR}/${BPN}.dtbo
}

do_deploy() {
    if [ -e ${DEPLOYDIR}/${BPN}.dtbo ];then
        rm ${DEPLOYDIR}/${BPN}.dtbo
    fi

    install -m 0644 ${WORKDIR}/${BPN}.dtbo ${DEPLOYDIR}/
}

addtask do_deploy after do_compile before do_install
do_deploy[dirs] += "${DEPLOYDIR}"

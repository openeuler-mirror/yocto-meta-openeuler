inherit deploy

DEPENDS += "dtc-native"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

RPI_DTS = "bcm2711-rpi-4-b-jailhouse"

SRC_URI += " \
        file://${BPN}.dts \
        file://${RPI_DTS}.dts \
        "

do_compile() {
    # generate dtbo
    dtc -I dts -O dtb ${WORKDIR}/${BPN}.dts -o ${WORKDIR}/${BPN}.dtbo

    # In order to assign more devices to non-root linux, we need to enable
    # the tiny dtb(uart1 and ethernet) for root linux.
    dtc -I dts -O dtb ${WORKDIR}/${RPI_DTS}.dts -o ${WORKDIR}/${RPI_DTS}.dtb
}

do_deploy() {
    rm -f ${DEPLOYDIR}/${BPN}.dtbo ${DEPLOYDIR}/${RPI_DTS}.dtb

    install -m 0644 ${WORKDIR}/${BPN}.dtbo ${WORKDIR}/${RPI_DTS}.dtb ${DEPLOYDIR}/
}

addtask do_deploy after do_compile before do_install
do_deploy[dirs] += "${DEPLOYDIR}"

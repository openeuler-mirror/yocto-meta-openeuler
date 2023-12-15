DESCRIPTION = "openEuler Embedded environment configuration scripts"
SECTION = "base"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://environment.d-openeuler.sh"

S = "${WORKDIR}"

do_install() {
    mkdir -p ${D}${SDKPATHNATIVE}/environment-setup.d
    install -m 644 ${WORKDIR}/environment.d-openeuler.sh ${D}${SDKPATHNATIVE}/environment-setup.d/openeuler.sh
}

FILES:${PN}:append:class-nativesdk = " ${SDKPATHNATIVE}"

inherit nativesdk


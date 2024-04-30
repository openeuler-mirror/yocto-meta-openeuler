DESCRIPTION = "openEuler Embedded environment configuration scripts of prebuilt tool"
SECTION = "base"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

INHIBIT_DEFAULT_DEPS = "1"

SRC_URI = "file://environment.d-openeuler.sh"

S = "${WORKDIR}"

do_install() {
    mkdir -p ${D}${SDKPATHNATIVE}/environment-setup.d
    install -m 644 ${WORKDIR}/environment.d-openeuler.sh ${D}${SDKPATHNATIVE}/environment-setup.d/openeuler.sh
}

PACKAGES = "${PN}"

FILES:${PN} = "${SDKPATHNATIVE}"

inherit nativesdk


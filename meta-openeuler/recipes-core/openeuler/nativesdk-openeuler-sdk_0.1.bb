DESCRIPTION = "openEuler Embedded environment configuration scripts of SDK"
SECTION = "base"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

INHIBIT_DEFAULT_DEPS = "1"

SRC_URI = " \
        file://openeuler_target_env.sh \
        file://toolchain.cmake \
        file://requirements.txt \
        "

S = "${WORKDIR}"

do_install() {
    # add openeuler env to SDK
    local openeuler_env_path="${D}/${SDKPATHNATIVE}/environment-setup.d"
    install -d ${openeuler_env_path}/
    install ${WORKDIR}/openeuler_target_env.sh ${openeuler_env_path}/
    install ${WORKDIR}/toolchain.cmake ${openeuler_env_path}/
    install ${WORKDIR}/requirements.txt ${openeuler_env_path}/
}

PACKAGES = "${PN}"
FILES:${PN} = " ${SDKPATHNATIVE}"

inherit nativesdk

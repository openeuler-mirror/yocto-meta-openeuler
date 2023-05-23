FILESEXTRAPATHS_append := "${THISDIR}/files/:"
SRC_URI = " \
        file://openeuler_target_env.sh \
        file://toolchain.cmake \
        file://requirements.txt \
        "
LICENSE = "CLOSED"

addtask do_fetch before do_install
addtask do_unpack before do_install

do_install_append() {
    #add openeuler env to sdk
    local openeuler_env_path="${D}/${SDKPATHNATIVE}/environment-setup.d"
    install -d ${openeuler_env_path}/
    install ${WORKDIR}/openeuler_target_env.sh ${openeuler_env_path}/
    install ${WORKDIR}/toolchain.cmake ${openeuler_env_path}/
    install ${WORKDIR}/requirements.txt ${openeuler_env_path}/
}

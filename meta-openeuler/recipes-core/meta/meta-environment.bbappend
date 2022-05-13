
BBAPPENDDIR := "${@os.path.dirname(d.getVar('FILE', False))}"
S = "${BBAPPENDDIR}/files"

do_install_append() {
    #add openeuler env to sdk
    local openeuler_env_path="${D}/${SDKPATHNATIVE}/environment-setup.d"
    install -d ${openeuler_env_path}/
    install ${S}/openeuler_target_env.sh ${openeuler_env_path}/
}

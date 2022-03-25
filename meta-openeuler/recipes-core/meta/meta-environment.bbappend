SDKPATHNATIVE = "${SDKPATH}/sysroots/${REAL_MULTIMACH_TARGET_SYS}/"

BBAPPENDDIR := "${@os.path.dirname(d.getVar('FILE', False))}"
S = "${BBAPPENDDIR}/files"

do_install_append() {
    #add openeuler env to sdk
    local openeuler_env_path="${D}/${SDKPATH}/sysroots/${REAL_MULTIMACH_TARGET_SYS}/environment-setup.d"
    install -d ${openeuler_env_path}/
    install ${S}/openeuler_target_env.sh ${openeuler_env_path}/
}

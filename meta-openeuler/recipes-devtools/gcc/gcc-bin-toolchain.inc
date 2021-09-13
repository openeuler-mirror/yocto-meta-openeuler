TOOLCHAIN_GCC_VERSION = "7.3.1"
LICENSE = "CLOSED"
SECTION = "toolchain"

EULER_TOOLCHAIN_GCC_PATH_INNER = "${EULER_TOOLCHAIN_SYSNAME}/${TOOLCHAIN_GCC_VERSION}"
EULER_TOOLCHAIN_GCC_PATH = "/gcc/${EULER_TOOLCHAIN_GCC_PATH_INNER}"

#BUILD_TOOLS = "/usr1/openeuler/gcc/gcc-linaro-7.3.1-2018.05-x86_64_aarch64-linux-gnu"
python () {
    import os
    import platform
    import subprocess
    host = platform.machine()
    tune = d.getVar('TARGET_ARCH', True)
    config_xml = d.getVar('EULER_CONFIG_FILE', True)
    cmd = 'grep "name=\\\"sdk\\\"" %s | grep "tune=\\\"%s\\\"" | grep "hostmachine=\\\"%s\\\""  | awk -F"[<>]" \'{print $3}\'' % (config_xml, tune, host)
    compiler_path  = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE)
    stdout, stderr = compiler_path.communicate()

    local_toolchain = str(stdout, "utf-8").strip()
    if not os.path.exists(local_toolchain):
        return 1
    if os.path.exists(local_toolchain):
        d.setVar("S", local_toolchain)
        d.setVarFlag("do_fetch",  "noexec", "1")
        d.setVarFlag("do_unpack", "noexec", "1")
        d.setVarFlag("do_patch",  "noexec", "1")
}

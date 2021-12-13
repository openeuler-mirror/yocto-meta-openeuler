TOOLCHAIN_GCC_VERSION = "10.3.0"
LICENSE = "CLOSED"
SECTION = "toolchain"

TOOLCHAIN_PREFIX_arm = "arm-openeuler-linux-gnueabi"
TOOLCHAIN_PREFIX_aarch64 = "aarch64-openeuler-linux-gnu"
EULER_TOOLCHAIN_GCC_PATH_INNER = "${TOOLCHAIN_PREFIX}/${TOOLCHAIN_GCC_VERSION}"
EULER_TOOLCHAIN_GCC_PATH = "/gcc/${EULER_TOOLCHAIN_GCC_PATH_INNER}"

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
        if "glibc" == d.getVar('BPN', True):
            gcctopdir = os.path.abspath(os.path.dirname(local_toolchain))
            d.setVar("DL_DIR", gcctopdir)
            return 0
        d.setVar("S", local_toolchain)
        d.setVarFlag("do_fetch",  "noexec", "1")
        d.setVarFlag("do_unpack", "noexec", "1")
        d.setVarFlag("do_patch",  "noexec", "1")
        d.setVarFlag("do_configure",  "noexec", "1")
}

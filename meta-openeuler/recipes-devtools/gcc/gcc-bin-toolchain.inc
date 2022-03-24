TOOLCHAIN_GCC_VERSION = "10.3.1"
LICENSE = "CLOSED"
SECTION = "toolchain"

TOOLCHAIN_PREFIX_arm = "arm-openeuler-linux-gnueabi"
TOOLCHAIN_PREFIX_aarch64 = "aarch64-openeuler-linux-gnu"
EULER_TOOLCHAIN_GCC_PATH_INNER = "${TOOLCHAIN_PREFIX}/${TOOLCHAIN_GCC_VERSION}"
EULER_TOOLCHAIN_GCC_PATH = "/gcc/${EULER_TOOLCHAIN_GCC_PATH_INNER}"

python () {
    import os

    local_toolchain = str(d.getVar('OPENEULER_TOOLCHAIN_DIR', True))
    #nativesdk no arch, nativesdk-glibc cannot get specific toolchain
    if bb.data.inherits_class('nativesdk', d):
        return True
    if not os.path.exists(local_toolchain):
        bb.fatal("%s is not a directory [%s]!" % (local_toolchain, d.getVar('PN', True)))
    if os.path.exists(local_toolchain):
        if "glibc" == d.getVar('BPN', True):
            gcctopdir = os.path.abspath(os.path.dirname(local_toolchain))
            d.setVar("DL_DIR", gcctopdir)
            return True
        d.setVar("S", local_toolchain)
        d.setVarFlag("do_fetch",  "noexec", "1")
        d.setVarFlag("do_unpack", "noexec", "1")
        d.setVarFlag("do_patch",  "noexec", "1")
        d.setVarFlag("do_configure",  "noexec", "1")
}

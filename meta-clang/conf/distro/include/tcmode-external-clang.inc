EXTERNAL_CLANG ?= "clang"
CLANG_VERSION = "${@get_clang_version(d)}"
CLANG_VERSION_allarch = ""
CLANG_VERSION[vardepvalue] = "${CLANG_VERSION}"
BUILDCFG_VARS += "CLANG_VERSION"

PREFERRED_PROVIDER_clang-cross-${TARGET_ARCH} = "clang-external-cross-${TARGET_ARCH}"

# use gcc sysroot now, but set `--target=xxx` in wrapper script
HOST_CC_ARCH:remove:toolchain-clang = "-target ${HOST_SYS}"

# no need for clang
HOST_CC_ARCH:remove:toolchain-clang = "--no-sysroot-suffix"

TUNE_CCARGS:remove:toolchain-clang = "-Qunused-arguments"

# not use compiler-rt now, will be enable in the future.
COMPILER_RT:remove:runtime-gnu = "-rtlib=compiler-rt"

LDFLAGS:append:toolchain-clang:class-target:aarch64 = " -Wl,-dynamic-linker,${base_libdir}/ld-linux-aarch64.so.1"

TOOLCHAIN = "clang"
TOOLCHAIN:class-native = "clang"
TOOLCHAIN:class-cross = "clang"

BASEDEPENDS:toolchain-clang:class-native = " clang-native"
BASEDEPENDS:remove:pn-clang-native = "clang-native"

def get_clang_version(d):
    import os.path
    import re
    import subprocess
    import oe.path
    import bb
    version_output = ""
    toolchain_bin = d.getVar('EXTERNAL_TOOLCHAIN_CLANG_BIN')
    if toolchain_bin:
        path = os.path.join(toolchain_bin, d.getVar('EXTERNAL_CLANG'))
        cmd = path + " --version | head -n1"
        bb.debug(1, 'oe.external.run({})'.format(cmd))
        version_output = subprocess.getoutput(cmd)
        # clang version xx.yy.zz, here we get xx.yy.zz
        match = re.search("[0-9]+\.[0-9]+\.[0-9]", version_output)
        if match:
            return match.group()
    return 'UNKNOWN'

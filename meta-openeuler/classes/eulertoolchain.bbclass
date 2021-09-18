def eulertoolchain_raw_prefix(arch):
    raw_prefix_dict = {
        "arm"       : "arm-linux-gnueabi",
        "aarch64"   : "aarch64-linux-gnu",
    }
    return raw_prefix_dict[arch]

def eulertoolchain_euler_prefix(arch):
    euler_prefix_dict = {
        "arm"       : "arm-openeuler-linux-gnueabi",
        "aarch64"   : "aarch64-openeuler-linux",
    }
    return euler_prefix_dict[arch]

def eulertoolchain_prefix_to_arch(prefix):
    return prefix.split('-')[0]

def eulertoolchain_euler_prefix_to_raw(euler_prefix):
    arch = eulertoolchain_prefix_to_arch(euler_prefix)
    return eulertoolchain_raw_prefix(arch)

python eulertoolchain_virtclass_handler () {
    cls = e.data.getVar("BBEXTENDCURR")
    variant = e.data.getVar("BBEXTENDVARIANT")
    if cls != "eulertoolchain" or not variant:
        return

    e.data.setVar("PN", e.data.getVar("PN", False) + '-' + variant)
    e.data.setVar("TARGET_ARCH", variant)

    e.data.setVar("EULER_TOOLCHAIN_SYSNAME",            eulertoolchain_raw_prefix(variant))
    e.data.setVar("EULER_TOOLCHAIN_TARGET_PREFIX",      eulertoolchain_euler_prefix(variant) + '-')
    e.data.setVar("EULER_TOOLCHAIN_TARGET_PREFIX_RAW",  eulertoolchain_euler_prefix(variant))

    e.data.setVar("OVERRIDES", e.data.getVar("OVERRIDES", False) +
                    ":{}".format(variant.replace('_', '-')))
}

addhandler eulertoolchain_virtclass_handler
eulertoolchain_virtclass_handler[eventmask] = "bb.event.RecipePreFinalise"

#_HMTOOLCHAIN_SUPPORT_ARCHS := "aarch64 aarch64_be arm armeb"
_HMTOOLCHAIN_SUPPORT_ARCHS := "aarch64 arm"

def toolchain_bbclassextend(d, cls, variant):
    support_archs = d.getVar("_HMTOOLCHAIN_SUPPORT_ARCHS", True)
    exts = []
    for arch in support_archs.split():
        exts.append('{}:{}{}'.format(cls, variant, arch))
    return ' '.join(exts)

BBCLASSEXTEND = "${@toolchain_bbclassextend(d, 'eulertoolchain', '')}"

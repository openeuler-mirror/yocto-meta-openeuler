def eulertoolchain_raw_prefix(arch):
    raw_prefix_dict = {
        "arm"       : "arm-linux-gnueabi",
        "aarch64"   : "aarch64-openeuler-linux-gnu",
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
    cls = d.getVar("BBEXTENDCURR")
    variant = d.getVar("BBEXTENDVARIANT")
    if cls != "eulertoolchain" or not variant:
        return

    multilib = d.getVar("MULTILIB", True)
    prefix = ""
    if "64" not in variant and multilib:
        prefix = "lib32-"
    d.setVar("TARGET_ARCH", variant)
    d.setVar("EULER_TOOLCHAIN_SYSNAME",            prefix + eulertoolchain_raw_prefix(variant))
    d.setVar("EULER_TOOLCHAIN_TARGET_PREFIX",      prefix + eulertoolchain_euler_prefix(variant) + '-')
    d.setVar("EULER_TOOLCHAIN_TARGET_PREFIX_RAW",  prefix + eulertoolchain_euler_prefix(variant))

    d.setVar("OVERRIDES", d.getVar("OVERRIDES", False) +
                    ":{}".format(variant.replace('_', '-')))
}

addhandler eulertoolchain_virtclass_handler
eulertoolchain_virtclass_handler[eventmask] = "bb.event.RecipePreFinalise"

_EULERTOOLCHAIN_SUPPORT_ARCHS := "aarch64 arm"

def toolchain_bbclassextend(d, cls, variant):
    support_archs = d.getVar("_EULERTOOLCHAIN_SUPPORT_ARCHS", True)
    exts = []
    for arch in support_archs.split():
        exts.append('{}:{}{}'.format(cls, variant, arch))
    return ' '.join(exts)

BBCLASSEXTEND = "${@toolchain_bbclassextend(d, 'eulertoolchain', '')}"

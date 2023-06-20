SUMMARY = "Linux kernel"
SECTION = "kernel"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM ?= "file://COPYING;md5=6bc538ed5bd9a7fc9398086aedcd7e46"

inherit kernel

SRC_URI = "file://kernel-5.10 \
    file://config/${ARCH}/defconfig-kernel \
"

S = "${WORKDIR}/kernel-5.10"

LINUX_VERSION ?= "5.10"
PV = "${LINUX_VERSION}"

# add patches only for aarch64
SRC_URI_append_aarch64 = " \
    file://patches/${ARCH}/0001-arm64-add-zImage-support-for-arm64.patch \
"

# export symbol for jailhouse
SRC_URI_append = " ${@bb.utils.contains('MCS_FEATURES', 'jailhouse', 'file://Jailhouse/jailhouse_export_symbol.patch', '', d)}"

LINUX_VERSION_EXTENSION_append = "-openeuler"
# delete v8 in kernel module name, such as kernel-module-xxx-5.10.0-v8
KERNEL_MODULE_PACKAGE_SUFFIX = ""

# Skip processing of this recipe if it is not explicitly specified as the
# PREFERRED_PROVIDER for virtual/kernel. This avoids network access required
# by the use of AUTOREV SRCREVs, which are the default for this recipe.
python () {
    if d.getVar("KERNEL_PACKAGE_NAME") == "kernel" and d.getVar("PREFERRED_PROVIDER_virtual/kernel") != d.getVar("PN"):
        d.delVar("BB_DONT_CACHE")
        raise bb.parse.SkipRecipe("Set PREFERRED_PROVIDER_virtual/kernel to %s to enable it" % (d.getVar("PN")))
}

python do_fetch() {
    import os

    import git

    # the do_fetch will not execute if OPENEULER_FETCH is seted to disable
    if d.getVar('OPENEULER_FETCH') == "disable":
        return

    # download src-openeuler/kernel repo for patches
    d.setVar("OPENEULER_REPO_NAME", "kernel")
    d.setVar("OPENEULER_LOCAL_NAME", 'src-kernel-5.10')
    d.setVar("OPENEULER_BRANCH", 'openEuler-22.03-LTS-SP2')
    d.setVar("OPENEULER_GIT_URL", "https://gitee.com/src-openeuler")
    bb.build.exec_func("do_openeuler_fetch", d)

    # download openeuler/kernel repo for linux kernel src files
    src_dir = d.getVar("OPENEULER_SP_DIR")
    kernel_name = "kernel-5.10"
    kernel_dir = os.path.join(src_dir, kernel_name)
    if not os.path.exists(kernel_dir):
        os.mkdir(kernel_dir)
    lock_file = os.path.join(kernel_dir, "file.lock")
    # if change kernel version, just change `kernel_branch` param
    kernel_branch = "5.10.0-153.9.0"

    lf = bb.utils.lockfile(lock_file, block=True)
    
    # determine whether the variable MANIFEST_DIR is None
    if d.getVar("MANIFEST_DIR") is not None and os.path.exists(d.getVar("MANIFEST_DIR")):
        repo_item = get_manifest(d.getVar("MANIFEST_DIR"))[kernel_name]
        init_manifest_repo(repo_dir = kernel_dir, remote_url = repo_item['remote_url'], version = repo_item['version'])
    else:
        repo = init_repo_dir(kernel_dir)
        repo_url = 'https://gitee.com/openeuler/kernel.git'
        try:
            if not repo.remote("upstream").exists():
                git.Remote.add(repo = repo, name = "upstream", url = repo_url)
        except:
            repo.create_remote('upstream', repo_url)
        repo.remote("upstream").fetch(refspec=f"+refs/tags/{kernel_branch}:refs/tags/{kernel_branch}", depth=1)
        repo.git.checkout(kernel_branch)

    bb.utils.unlockfile(lf)
}

KERNEL_CC_append_aarch64 = " ${TOOLCHAIN_OPTIONS}"
KERNEL_LD_append_aarch64 = " ${TOOLCHAIN_OPTIONS}"

KERNEL_CC_append_riscv64 = " ${TOOLCHAIN_OPTIONS}"
KERNEL_LD_append_riscv64 = " ${TOOLCHAIN_OPTIONS}"

OPENEULER_KERNEL_CONFIG = "../config/${ARCH}/defconfig-kernel"
do_configure_prepend() {
    cp -f "${OPENEULER_KERNEL_CONFIG}" .config
}

# Even if the KERNEL_IMAGETYPE is zImage, we will install Image, so add it into PACKAGES
PACKAGES += "${KERNEL_PACKAGE_NAME}-img"
FILES_${KERNEL_PACKAGE_NAME}-img = "/boot/Image-${KERNEL_VERSION}"
do_install_append(){
    if [ -e ${KERNEL_OUTPUT_DIR}/Image ]; then
        install -m 0644 ${KERNEL_OUTPUT_DIR}/Image ${D}/${KERNEL_IMAGEDEST}/Image-${KERNEL_VERSION}
    fi
}

do_deploy_append() {
    if [ -e ${KERNEL_OUTPUT_DIR}/Image ]; then
        install -m 0644 ${KERNEL_OUTPUT_DIR}/Image $deployDir/Image-${KERNEL_VERSION}
    fi
}

#not found depmodwrapper, not run postinst now
pkg_postinst_${KERNEL_PACKAGE_NAME}-base () {
    :
}

# KERNEL_MODULE_AUTOLOAD need ko_basename to work,
# we make automatic conversion from pkgname to ko_basename
# then we can use pkgname in KERNEL_MODULE_AUTOLOAD
# reference 1: split_kernel_module_packages: yocto-poky/meta/classes/kernel-module-split.bbclass
# reference 2: do_split_packages: yocto-poky/meta/classes/package.bbclass
split_kernel_module_packages_prepend () {
    def update_module_loadlist ():
        module_regex = r'^(.*)\.k?o(?:\.[xg]z)?$'
        kernel_package_name = d.getVar("KERNEL_PACKAGE_NAME") or "kernel"
        module_pattern_prefix = d.getVar('KERNEL_MODULE_PACKAGE_PREFIX')
        module_pattern_suffix = d.getVar('KERNEL_MODULE_PACKAGE_SUFFIX')
        module_pattern = module_pattern_prefix + kernel_package_name + '-module-%s' + module_pattern_suffix
        root = '${nonarch_base_libdir}/modules'
        dvar = d.getVar('PKGD')
        root = d.expand(root)
        objs = []
        for walkroot, dirs, files in os.walk(dvar + root):
            for file in files:
                relpath = os.path.join(walkroot, file).replace(dvar + root + '/', '', 1)
                if relpath:
                    objs.append(relpath)
        for o in sorted(objs):
            import re, stat
            m = re.match(module_regex, os.path.basename(o))
            if not m:
                continue
            basename = m.group(1)
            on = legitimize_package_name(basename)
            pkg = module_pattern % on
            if pkg in (d.getVar("KERNEL_MODULE_AUTOLOAD") or "").split():
                old_list = d.getVar("KERNEL_MODULE_AUTOLOAD")
                d.setVar("KERNEL_MODULE_AUTOLOAD", "%s %s" % (old_list, basename))

    update_module_loadlist()
}

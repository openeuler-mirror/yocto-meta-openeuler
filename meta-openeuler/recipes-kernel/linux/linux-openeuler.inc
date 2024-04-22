SUMMARY = "openEuler Linux kernel"
SECTION = "kernel"
LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM ?= "file://COPYING;md5=6bc538ed5bd9a7fc9398086aedcd7e46"

# inherit basic kernel.bbclass for kernel build
inherit kernel
# inherit kernel-yocto.bbclass for using kernel meta data mechanism
# i.e, .scc files can be applied
inherit kernel-yocto
# the following tasks in kernel-yocto.bbclass does not work for openeuler
deltask do_validate_branches
deltask do_kernel_checkout

## handling for kernel meta data
# the original get_dirs_with_fragments will include OPENEULER_SP_DIR
# so that all the files under OPENEULER_SP_DIR will be in the file-checksums
# of do_kernel_metadata, which is not necessary
def get_dirs_with_metadata(d):
    extrapaths = []
    extrafiles = []
    extrapathsvalue = (d.getVar("FILESEXTRAPATHS") or "")

    # Remove global openeuler src dir
    openeuler_src_dir = d.getVar("OPENEULER_SP_DIR")
    extrapathsvalue = extrapathsvalue.replace(openeuler_src_dir, "")

    # Remove default flag which was used for checking
    extrapathsvalue = extrapathsvalue.replace("__default:", "")
    extrapaths = extrapathsvalue.split(":")

    # add scc files
    extrapaths += find_sccs(d)
   
    # add patches
    extrapaths += find_patches(d, '')
    for path in extrapaths:
        if path and path + ":True" not in extrafiles:
            extrafiles.append(path + ":" + str(os.path.exists(path)))

    return " ".join(extrafiles)

# override the original get_dirs_with_fragments in kernel-yocto.bbclass
do_kernel_metadata[file-checksums] = "${@get_dirs_with_metadata(d)}"

# enable kconf audit to output some message
KCONF_BSP_AUDIT_LEVEL = "2"
# as openeuler has defconfig, so here use all alldefconfig, all configs
# are set to default value
KCONFIG_MODE ?= "alldefconfig"

# default kernel config is in config/${ARCH}/defconfig
# users can override it in .bbappend or .conf
CONFIGVERSION="${@bb.utils.contains('DISTRO_FEATURES', 'kernel6', 'kernel6-', '', d)}"
OPENEULER_KERNEL_CONFIG ?= "file://${CONFIGVERSION}config/${ARCH}/defconfig"

## basic information
OPENEULER_REPO_NAME = "kernel-${PV}"
# download src-openeuler/kernel repo for patches
# download openeuler/kernel-5.10 repo for linux kernel src files
OPENEULER_MULTI_REPOS = "src-kernel-${PV} kernel-${PV}"

SRC_URI = "file://kernel-${PV} \
    ${OPENEULER_KERNEL_CONFIG} \
    file://meta-data;type=kmeta;destsuffix=meta-data \
"

# add common patches only for aarch64
SRC_URI:append:aarch64 = " \
    ${@bb.utils.contains('DISTRO_FEATURES', 'kernel6', ' \
    file://patches/${ARCH}/0001-kernel6.6-arm64-add-zImage-support-for-arm64.patch \
    ', ' \
    file://patches/${ARCH}/0001-arm64-add-zImage-support-for-arm64.patch \
    ', d)} \
"

S = "${WORKDIR}/kernel-${PV}"

LINUX_VERSION ?= "${@bb.utils.contains('DISTRO_FEATURES', 'kernel6', '6.6', '5.10', d)}"
PV = "${LINUX_VERSION}"

## Kernel feature sections:
# config kernel according to xxx FEATURES
## DEBUG FEATURES
KERNEL_FEATURES:append = " \
    ${@bb.utils.contains('IMAGE_FEATURES', 'debug-tweaks', 'features/debug/devmem.scc', '', d)} \
"

## mcs related patches and configs
## mcs_rpmsg.scc: Add basic functionality, including rpmsg, remoteproc
## mcs_jailhouse: Add jailhouse support
KERNEL_FEATURES:append = " \
        ${@bb.utils.contains('DISTRO_FEATURES', 'mcs', 'features/mcs/mcs_rpmsg.scc', '', d)} \
        ${@bb.utils.contains('MCS_FEATURES', 'jailhouse', 'features/mcs/mcs_jailhouse.scc', '', d)} \
        "
# add openamp support for x86 mcs
KERNEL_FEATURES:append:x86-64 = " \
    ${@bb.utils.contains('MCS_FEATURES', 'openamp', 'features/mcs/0001-x86-irq-add-a-vector-define-for-mcs.patch', '', d)} \
"
# export symbol for jailhouse, its patch is in jailhouse src folder
SRC_URI:append = " ${@bb.utils.contains('MCS_FEATURES', 'jailhouse', 'file://Jailhouse/jailhouse_export_symbol.patch', '', d)}"

# 6.6 can't support now, should support later and remove it.
KERNEL_FEATURES:remove = " \
    ${@bb.utils.contains('DISTRO_FEATURES', 'kernel6', ' \
    mcs \
    jailhouse \ 
    ', '', d)} \
"

MCS_FEATURES:remove = " \
    ${@bb.utils.contains('DISTRO_FEATURES', 'kernel6', ' \
    openamp \
    jailhouse \
    ', '', d)} \
"

# used by do_kernel_configme in yocoto-kernel.bbclass
LINUX_VERSION_EXTENSION:append = "-openeuler"
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
    bb.build.exec_func("do_openeuler_fetch_multi", d)
}

## kernel compile options
KERNEL_CC:append:aarch64 = " ${TOOLCHAIN_OPTIONS}"
KERNEL_LD:append:aarch64 = " ${TOOLCHAIN_OPTIONS}"

KERNEL_CC:append:riscv64 = " ${TOOLCHAIN_OPTIONS}"
KERNEL_LD:append:riscv64 = " ${TOOLCHAIN_OPTIONS}"

# Even if the KERNEL_IMAGETYPE is zImage, we will install Image, so add it into PACKAGES
PACKAGES += "${KERNEL_PACKAGE_NAME}-img"
FILES:${KERNEL_PACKAGE_NAME}-img = "/boot/Image-${KERNEL_VERSION}"

do_install:append(){
    if [ -e ${KERNEL_OUTPUT_DIR}/Image ]; then
        install -m 0644 ${KERNEL_OUTPUT_DIR}/Image ${D}/${KERNEL_IMAGEDEST}/Image-${KERNEL_VERSION}
    fi
}

do_deploy:append() {
    test -d "${OUTPUT_DIR}" || mkdir -p "${OUTPUT_DIR}"
    for kernel_img in {zImage,uImage,Image,vmlinux,zboot.img,boot.img}
    do
        if [ -f "${KERNEL_OUTPUT_DIR}/$kernel_img" ];then 
            echo ${OUTPUT_DIR} ${deployDir} | xargs -n 1 cp -fp ${KERNEL_OUTPUT_DIR}/$kernel_img
        fi
    done
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
split_kernel_module_packages:prepend () {
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

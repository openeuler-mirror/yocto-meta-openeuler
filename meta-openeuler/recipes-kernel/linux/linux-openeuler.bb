SUMMARY = "Linux kernel"
SECTION = "kernel"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM ?= "file://COPYING;md5=6bc538ed5bd9a7fc9398086aedcd7e46"

inherit kernel

SRC_URI = "file://kernel-5.10 \
     file://yocto-embedded-tools/config/${ARCH}/defconfig-kernel \
"
# add patches only for aarch64
SRC_URI_append_aarch64 += " \
    file://yocto-embedded-tools/patches/${ARCH}/0001-arm64-add-zImage-support-for-arm64.patch \
"

# add patches for OPENEULER_PLATFROM such as aarch64-pro
SRC_URI_append_aarch64-pro += " \
    file://src-kernel-5.10/0000-raspberrypi-kernel.patch \
    file://src-kernel-5.10/0001-add-preemptRT-patch.patch \
    file://src-kernel-5.10/0002-modifty-bcm2711_defconfig-for-rt-rpi-kernel.patch \
"

S = "${WORKDIR}/kernel-5.10"

LINUX_VERSION ?= "5.10"
LINUX_VERSION_EXTENSION_append = "-openeuler"
#delete v8 in kernel module name, such as kernel-module-xxx-5.10.0-v8
KERNEL_MODULE_PACKAGE_SUFFIX = ""

PV = "${LINUX_VERSION}"

COMPATIBLE_MACHINE = "qemuarm|qemuarmv5|qemuarm64|qemux86|qemuppc|qemuppc64|qemumips|qemumips64|qemux86-64|qemuriscv64|qemuriscv32|qemu-aarch64|qemu-arm|raspberrypi4-64"

# Skip processing of this recipe if it is not explicitly specified as the
# PREFERRED_PROVIDER for virtual/kernel. This avoids network access required
# by the use of AUTOREV SRCREVs, which are the default for this recipe.
python () {
    if d.getVar("KERNEL_PACKAGE_NAME") == "kernel" and d.getVar("PREFERRED_PROVIDER_virtual/kernel") != d.getVar("PN"):
        d.delVar("BB_DONT_CACHE")
        raise bb.parse.SkipRecipe("Set PREFERRED_PROVIDER_virtual/kernel to %s to enable it" % (d.getVar("PN")))
}

KERNEL_CC_append_aarch64 = " ${TOOLCHAIN_OPTIONS}"
KERNEL_LD_append_aarch64 = " ${TOOLCHAIN_OPTIONS}"

OPENEULER_KERNEL_CONFIG = "../yocto-embedded-tools/config/${ARCH}/defconfig-kernel"
OPENEULER_KERNEL_CONFIG_aarch64-pro = "${S}/arch/${ARCH}/configs/bcm2711_defconfig"
do_configure_prepend() {
    if [[ ${OPENEULER_PLATFORM} == "aarch64-pro" ]]; then
        sed -i '$a CONFIG_ACPI=y' ${OPENEULER_KERNEL_CONFIG}
    fi
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


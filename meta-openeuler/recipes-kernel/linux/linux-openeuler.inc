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

# For x86, we use the openeuler_defconfig provided by the kernel repository.
OPENEULER_KERNEL_CONFIG:x86-64 = ""
KBUILD_DEFCONFIG:x86-64 = "openeuler_defconfig"
SRC_URI:append:x86-64 = " \
    file://config/cfg-fragments/embedded-build.cfg \
    file://config/cfg-fragments/common-pc-drivers.cfg \
"
# strip modules for x86 image
EXTRA_OEMAKE:x86-64 += "INSTALL_MOD_STRIP=1"
INSANE_SKIP:${PN} += "already-stripped"

## basic information
OPENEULER_LOCAL_NAME = "kernel-${PV}"
# download src-openeuler/kernel repo for patches
# download openeuler/kernel-5.10 repo for linux kernel src files
OPENEULER_REPO_NAMES = "src-kernel-${PV} kernel-${PV}"

# workaround: avoid issue of '+' vermagic of module out-tree of yocto: 0001-fix-yocto-localversion-outtree-ko-error-for-6.6.patch
SRC_URI = "file://kernel-${PV} \
    ${OPENEULER_KERNEL_CONFIG} \
    file://meta-data;type=kmeta;destsuffix=meta-data \
    ${@bb.utils.contains('DISTRO_FEATURES', 'kernel6', 'file://patches/0001-fix-yocto-localversion-outtree-ko-error-for-6.6.patch', '', d)} \
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
## mcs_jailhouse: Add jailhouse support
KERNEL_FEATURES:append = " \
        ${@bb.utils.contains('MCS_FEATURES', 'jailhouse', 'features/mcs/mcs_jailhouse.scc', '', d)} \
        "
# add openamp support for x86 mcs
KERNEL_FEATURES:append:x86-64 = " \
    ${@bb.utils.contains('MCS_FEATURES', 'openamp', 'features/mcs/0001-x86-irq-add-a-vector-define-for-mcs.patch', '', d)} \
"

python () {
    pv = d.getVar("PV", True)
    if pv == "5.10":
        d.setVar("MCS_EXPORT_SYMBOL_PATCH", ' ')
    else:
        d.setVar("MCS_EXPORT_SYMBOL_PATCH", 'features/mcs/0005-arm64-cpu-export-cpu_logical_map-symbol-for-mcs.patch')
}
KERNEL_FEATURES:append:aarch64 = " \
    ${@bb.utils.contains('MCS_FEATURES', 'openamp', "${MCS_EXPORT_SYMBOL_PATCH}", '', d)} \
 "

# xen kernel support
KERNEL_FEATURES:append = "${@bb.utils.contains('DISTRO_FEATURES', 'xen', ' features/xen/xen.scc', '', d)}"

# zvm kernel support
KERNEL_FEATURES:append = "${@bb.utils.contains('MCS_FEATURES', 'zvm', ' features/zvm/zvm.scc', '', d)}"

# container kernel support (for moby echo container engines features)
KERNEL_FEATURES:append = "${@bb.utils.contains_any('DISTRO_FEATURES', 'containers containerd docker', ' features/containers/containers.scc', '', d)}"

# kubeedge kernel support
KERNEL_FEATURES:append = " \
    ${@bb.utils.contains('DISTRO_FEATURES', 'kubeedge', 'features/kubeedge/kubeedge.scc', '', d)} \
"

# K8s/K3s kernel support
KERNEL_FEATURES:append = " \
    ${@bb.utils.contains_any('DISTRO_FEATURES', 'k3s-agent k3s-server', 'features/k3s/k3s.scc', '', d)} \
"

# 3rd_driver librealsense kernel support
python () {
    pv = d.getVar("PV", True)
    if pv.startswith("5.10"):
        d.setVar("LIBREALSENSE_FIX_PATCH", ' \
            features/3rd_drivers/librealsense/0001-Add-missing-HID-timestamp-patch-for-Gyro-sensor_5.10.patch \
            features/3rd_drivers/librealsense/0002-Add-support-for-RealSense-camera-formats-metadata_5.10.patch \
            features/3rd_drivers/librealsense/0003-Bug-fix-for-incomplete-PowerLineFrequency-enumeration_5.10.patch')
    else:
        d.setVar("LIBREALSENSE_FIX_PATCH", ' features/3rd_drivers/librealsense/6.6-realsense-camera-formats.patch ')
}
KERNEL_FEATURES:append = " \
    ${@bb.utils.contains('DISTRO_FEATURES', 'librealsense', 'features/3rd_drivers/librealsense/librealsense.scc', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'librealsense', "${LIBREALSENSE_FIX_PATCH}", '', d)} \
"

# fetch jailhouse first to get jailhouse_export_symbol.patch
do_fetch[depends] += " ${@bb.utils.contains('MCS_FEATURES', 'jailhouse', 'jailhouse:do_fetch', '', d)}"
# export symbol for jailhouse, its patch is in jailhouse src folder
SRC_URI:append = " ${@bb.utils.contains('MCS_FEATURES', 'jailhouse', 'file://Jailhouse/jailhouse_export_symbol.patch', '', d)}"

# 6.6 can't support now, should support later and remove it.
KERNEL_FEATURES:remove = " \
    ${@bb.utils.contains('DISTRO_FEATURES', 'kernel6', ' \
    jailhouse \
    ', '', d)} \
"

MCS_FEATURES:remove = " \
    ${@bb.utils.contains('DISTRO_FEATURES', 'kernel6', ' \
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
    for kernel_img in {zImage,bzImage,uImage,Image,vmlinux,zboot.img,boot.img}
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


# qemu is the first class BSP in openeuler, so add qemu specific kernel customeriazation here
# for other BSP, plese do it in its own layer and use dynamic layer mechanism under bsp/met-openeuler-bsp, for example, see
# raspberrypi bsp
SRC_URI:append:qemu-aarch64= "${@bb.utils.contains('DISTRO_FEATURES', 'oe-xfce', 'file://config/cfg-fragments/qemu-aarch64-xfce.cfg', '', d)}"

do_container_configs[doc] = "Checks the kernel configs required by container, parses the output, and issues warnings/notes for missing configs."
do_container_configs() {
    wget --timeout=10 -P ${WORKDIR}  https://github.com/moby/moby/raw/master/contrib/check-config.sh || true
    if [ -f ${WORKDIR}/check-config.sh ]; then
        sed -i 's,zcat "$2" | grep "$1", cat "$2" | grep "$1",g' ${WORKDIR}/check-config.sh
        chmod +x ${WORKDIR}/check-config.sh
        kconfigfile="${B}/.config"
        section=""
        NO_COLOR=1 script_output=$(${WORKDIR}/check-config.sh ${kconfigfile} 2>&1 || true)
        echo "${script_output}" | while IFS= read -r line; do
            if echo "$line" | grep -q "Generally Necessary:"; then
                section="necessary"
                continue
            fi
            if echo "$line" | grep -q "Optional Features:"; then
                section="optional"
                continue
            fi

            if echo "$line" | grep -q "missing" && echo "$line" | grep -q "CONFIG_"; then
                local trimed=$(echo "$line" | sed -E 's/.*(CONFIG_[A-Z0-9_]+):\s*([a-z]+).*/\1 is \2/')
                if [ "$section" = "necessary" ]; then
                    bbwarn "necessary ability for container: $trimed"
                elif [ "$section" = "optional" ]; then
                    bbwarn "optional ability for container: $trimed"
                else
                    bbwarn "ability for container: $line"
                fi
            fi
        done
    else
        bbwarn "Could not download moby check-config.sh, skipping kernel config check."
    fi
}

python () {
    if bb.utils.contains_any('DISTRO_FEATURES', 'containerd k3s-agent k3s-server docker podman containers', True, False, d):
        bb.build.addtask('container_configs', 'do_compile', 'do_configure',d)
}

# apply RPI kernel patch
FILESEXTRAPATHS:append := "${THISDIR}/files/:"

# export symbol for jailhouse
SRC_URI:append = "${@bb.utils.contains('MCS_FEATURES', 'jailhouse', \
		' file://Jailhouse/jailhouse_fix_rpi4_compile_error.patch \
		  file://enable_cpu_hotplug.patch', '', d)} \
		  file://rpi4b.cfg "


# no external defconfig
OPENEULER_KERNEL_CONFIG = ""
# use in-tree defconfig, the defconfig is in src tree
# after patches are unpatched
KBUILD_DEFCONFIG = "bcm2711_defconfig"

COMPATIBLE_MACHINE = "raspberrypi4-64"

# use rpi kernel tag
SRC_URI:raspberrypi4 = " \
    ${OPENEULER_KERNEL_CONFIG} \
    file://meta-data;type=kmeta;destsuffix=meta-data \
    ${@bb.utils.contains('DISTRO_FEATURES', 'kernel6', ' \
            file://kernel-${PV} \
    ', ' \
            file://kernel-${PV}-tag-rpi \
    ', d)} \
"
OPENEULER_REPO_NAME:raspberrypi4 = "${@bb.utils.contains('DISTRO_FEATURES', 'kernel6', 'kernel-${PV}', 'kernel-${PV}-tag-rpi', d)}"
OPENEULER_LOACL_NAME:raspberrypi4 = "${@bb.utils.contains('DISTRO_FEATURES', 'kernel6', 'kernel-${PV}', 'kernel-${PV}-tag-rpi', d)}"
S:raspberrypi4 = "${@bb.utils.contains('DISTRO_FEATURES', 'kernel6', '${WORKDIR}/kernel-${PV}', '${WORKDIR}/kernel-${PV}-tag-rpi', d)}"
OPENEULER_REPO_NAMES:raspberrypi4 = " \
${@bb.utils.contains('DISTRO_FEATURES', 'kernel6', ' src-kernel-${PV} kernel-${PV} ', ' src-kernel-${PV}-tag-rpi kernel-${PV}-tag-rpi ', d)} \
"


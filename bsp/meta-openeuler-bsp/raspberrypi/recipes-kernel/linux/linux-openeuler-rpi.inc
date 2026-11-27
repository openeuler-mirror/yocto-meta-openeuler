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
    file://kernel-${PV}-tag-rpi \
"

OPENEULER_LOACL_NAME:raspberrypi4 = "kernel-${PV}-tag-rpi"
S:raspberrypi4 = "${WORKDIR}/kernel-${PV}-tag-rpi"
# use rpi kernel tag for both the source tree and the packaging assets:
# the rpi kernel6 patches follow their own tag lineage and do not track
# the main src-kernel-6.6 baseline
OPENEULER_REPO_NAMES:raspberrypi4 = " \
    kernel-${PV}-tag-rpi \
    src-kernel-${PV}-tag-rpi \
"

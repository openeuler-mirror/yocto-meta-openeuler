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

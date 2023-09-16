# apply RPI kernel patch
FILESEXTRAPATHS:append := "${THISDIR}/files/:"

# export symbol for jailhouse
SRC_URI:append = "${@bb.utils.contains('MCS_FEATURES', 'jailhouse', \
		   ' file://Jailhouse/jailhouse_fix_rpi4_compile_error.patch \
		     file://enable_cpu_hotplug.patch', '', d)}"


# no external defconfig
OPENEULER_KERNEL_CONFIG = ""
# use in-tree defconfig, the defconfig is in src tree
# after patches are unpatched
KBUILD_DEFCONFIG = "bcm2711_defconfig"


do_configure:prepend() {
    sed -i '$a CONFIG_ACPI=y' .config
	sed -i '$a CONFIG_NET_CLS_TCINDEX=y' .config
}

COMPATIBLE_MACHINE = "raspberrypi4-64"

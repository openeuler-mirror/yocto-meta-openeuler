# apply RPI kernel patch
FILESEXTRAPATHS_append := "${THISDIR}/files/:"

# export symbol for jailhouse
SRC_URI_append = "${@bb.utils.contains('MCS_FEATURES', 'jailhouse', \
		   ' file://Jailhouse/jailhouse_fix_rpi4_compile_error.patch \
		     file://enable_cpu_hotplug.patch', '', d)}"

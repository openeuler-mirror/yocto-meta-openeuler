KO_DIR_NAME = "norflash_1711"
KO_NAME = "physmap_1711.ko"
PREV_DEPEND += " log-hi3093 "
RPROVIDES:${PN} += "kernel-module-physmap-1711"
RPROVIDES:${PN} += "kernel-module-chipreg-${KERNEL_VERSION} "
RPROVIDES:${PN} += "kernel-module-map-funcs-${KERNEL_VERSION} "

require modules-hi3093.inc

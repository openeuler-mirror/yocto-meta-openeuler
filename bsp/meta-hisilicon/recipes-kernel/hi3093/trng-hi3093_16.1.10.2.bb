KO_DIR_NAME = "trng"
KO_NAME = "trng_drv.ko"
PREV_DEPEND += " log-hi3093 comm-hi3093 ksecurec "
RPROVIDES:${PN} += "kernel-module-trng-drv"

require modules-hi3093.inc

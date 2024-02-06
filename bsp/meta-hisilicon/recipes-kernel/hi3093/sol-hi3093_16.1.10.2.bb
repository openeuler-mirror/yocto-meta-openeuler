KO_DIR_NAME = "sol"
KO_NAME = "sol_drv.ko"
PREV_DEPEND += " log-hi3093 comm-hi3093 ksecurec "
RPROVIDES:${PN} += "kernel-module-sol-drv"

require modules-hi3093.inc

KO_DIR_NAME = "edma"
KO_NAME = "edma_drv.ko"
PREV_DEPEND += " log-hi3093 comm-hi3093 ksecurec sys-info-hi3093 "
RPROVIDES:${PN} += "kernel-module-edma-drv"

require modules-hi3093.inc

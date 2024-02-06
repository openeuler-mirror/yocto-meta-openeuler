KO_DIR_NAME = "vce"
KO_NAME = "vce_drv.ko"
PREV_DEPEND += " log-hi3093 comm-hi3093 "
RPROVIDES:${PN} += "kernel-module-vce-drv"

require modules-hi3093.inc

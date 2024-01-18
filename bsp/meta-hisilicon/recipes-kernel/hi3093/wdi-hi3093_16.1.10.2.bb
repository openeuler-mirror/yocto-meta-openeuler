KO_DIR_NAME = "wdi"
KO_NAME = "wdi_drv.ko"
PREV_DEPEND += " log-hi3093 comm-hi3093 "
RPROVIDES:${PN} += "kernel-module-wdi-drv"

require modules-hi3093.inc

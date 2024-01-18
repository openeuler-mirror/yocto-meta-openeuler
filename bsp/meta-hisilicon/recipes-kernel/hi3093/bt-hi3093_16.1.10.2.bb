KO_DIR_NAME = "bt"
KO_NAME = "bt_drv.ko"
PREV_DEPEND += " log-hi3093 comm-hi3093 ksecurec "
RPROVIDES:${PN} += "kernel-module-bt-drv"

require modules-hi3093.inc

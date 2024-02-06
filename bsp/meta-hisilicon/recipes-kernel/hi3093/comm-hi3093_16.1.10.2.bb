KO_DIR_NAME = "comm"
KO_NAME = "comm_drv.ko"
PREV_DEPEND += " ksecurec log-hi3093 "
RPROVIDES:${PN} += "kernel-module-comm-drv"

require modules-hi3093.inc

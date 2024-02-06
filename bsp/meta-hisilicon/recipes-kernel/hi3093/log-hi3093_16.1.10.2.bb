KO_DIR_NAME = "log"
KO_NAME = "log_drv.ko"
PREV_DEPEND += "ksecurec"
RPROVIDES:${PN} += "kernel-module-log-drv"

require modules-hi3093.inc

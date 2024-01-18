KO_DIR_NAME = "p80"
KO_NAME = "p80_drv.ko"
PREV_DEPEND += " log-hi3093 comm-hi3093 "
RPROVIDES:${PN} += "kernel-module-p80-drv"

require modules-hi3093.inc
